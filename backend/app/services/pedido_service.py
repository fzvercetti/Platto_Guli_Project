# app/services/pedido_service.py
from app.database import connection_pool
from app.repositories.producto_repository import ProductoRepository
from app.repositories.pedido_repository import PedidoRepository

class PedidoService:
    @staticmethod
    def crear_pedido(producto_id, cantidad, metodo_pago):
        with connection_pool.get_connection() as conn:
            with conn.cursor(dictionary=True) as cursor:
                
                # 1. Validaciones lógicas de Negocio
                producto = ProductoRepository.obtener_por_id_tx(cursor, producto_id)
                if not producto:
                    return {"error": "Producto no encontrado", "code": 404}
                
                if producto['stock_actual'] < int(cantidad):
                    return {"error": f"Stock insuficiente. Disponible: {producto['stock_actual']}", "code": 400}
                
                subtotal = float(producto['precio_unitario']) * int(cantidad)
                
                # 2. Bloque Transaccional Atómico
                conn.start_transaction()
                try:
                    id_venta = PedidoRepository.insertar_venta_tx(cursor, subtotal, metodo_pago)
                    PedidoRepository.insertar_detalle_tx(cursor, id_venta, producto_id, cantidad, subtotal)
                    ProductoRepository.descontar_stock_tx(cursor, producto_id, cantidad)
                    
                    conn.commit()
                    return {"status": "success", "mensaje": "Pedido guardado con éxito", "code": 201}
                except Exception as e:
                    conn.rollback()
                    raise e

    @staticmethod
    def obtener_ventas_del_dia():
        return PedidoRepository.obtener_ventas_hoy()