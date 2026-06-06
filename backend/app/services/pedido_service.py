# app/services/pedido_service.py
from app.database import connection_pool
from app.repositories.producto_repository import ProductoRepository
from app.repositories.pedido_repository import PedidoRepository

class PedidoService:
    @staticmethod
    def crear_pedido(producto_id, cantidad, metodo_pago):
        # 1. Obtenemos la conexión del pool
        conn = connection_pool.get_connection()
        try:
            # 2. Configuramos la conexión para control manual de transacciones
            conn.autocommit = False 
            
            with conn.cursor(dictionary=True) as cursor:
                # 3. Validaciones lógicas
                producto = ProductoRepository.obtener_por_id_tx(cursor, producto_id)
                if not producto:
                    return {"error": "Producto no encontrado", "code": 404}
                
                if producto['stock_actual'] < int(cantidad):
                    return {"error": f"Stock insuficiente. Disponible: {producto['stock_actual']}", "code": 400}
                
                subtotal = float(producto['precio_unitario']) * int(cantidad)
                
                # 4. Operaciones transaccionales
                # No necesitamos conn.start_transaction() si autocommit es False
                id_venta = PedidoRepository.insertar_venta_tx(cursor, subtotal, metodo_pago)
                PedidoRepository.insertar_detalle_tx(cursor, id_venta, producto_id, cantidad, subtotal)
                ProductoRepository.descontar_stock_tx(cursor, producto_id, cantidad)
                
                # 5. Confirmar cambios
                conn.commit()
                return {"status": "success", "mensaje": "Pedido guardado con éxito", "code": 201}
                
        except Exception as e:
            # 6. Si algo falla, revertimos todo a estado original
            conn.rollback()
            print(f"--- ERROR EN TRANSACCIÓN DB: {str(e)} ---")
            raise e
        finally:
            # 7. IMPORTANTE: Devolvemos la conexión al pool
            conn.close()

    @staticmethod
    def obtener_ventas_del_dia():
        return PedidoRepository.obtener_ventas_hoy()