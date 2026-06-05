# app/repositories/pedido_repository.py
from app.database import connection_pool

class PedidoRepository:
    @staticmethod
    def insertar_venta_tx(cursor, total, metodo_pago):
        cursor.execute(
            "INSERT INTO ventas (fecha_hora, total_venta, metodo_pago) VALUES (NOW(), %s, %s)",
            (total, metodo_pago)
        )
        return cursor.lastrowid

    @staticmethod
    def insertar_detalle_tx(cursor, id_venta, producto_id, cantidad, subtotal):
        cursor.execute(
            "INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, subtotal) VALUES (%s, %s, %s, %s)",
            (id_venta, producto_id, cantidad, subtotal)
        )

    @staticmethod
    def obtener_ventas_hoy():
        consulta = """
            SELECT v.id_venta AS id, p.nombre AS producto, v.total_venta AS total, v.metodo_pago AS metodo 
            FROM ventas v
            JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
            JOIN productos p ON dv.id_producto = p.id_producto
            WHERE DATE(v.fecha_hora) = CURDATE() ORDER BY v.fecha_hora DESC
        """
        with connection_pool.get_connection() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(consulta)
                return cursor.fetchall()