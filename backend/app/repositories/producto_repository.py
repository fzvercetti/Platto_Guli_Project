# app/repositories/producto_repository.py
from app.database import connection_pool

class ProductoRepository:
    @staticmethod
    def obtener_todos():
        with connection_pool.get_connection() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT id_producto AS id, nombre, precio_unitario AS precio FROM productos")
                return cursor.fetchall()

    @staticmethod
    def obtener_inventario():
        with connection_pool.get_connection() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT id_producto AS id, nombre, stock_actual AS stock, categoria, precio_unitario FROM productos ORDER BY nombre ASC")
                return cursor.fetchall()

    @staticmethod
    def actualizar_stock_directo(id_p, nuevo_stock):
        with connection_pool.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("UPDATE productos SET stock_actual = %s WHERE id_producto = %s", (nuevo_stock, id_p))
                conn.commit()

    # Métodos transaccionales internos (Utilizan un cursor externo activo)
    @staticmethod
    def obtener_por_id_tx(cursor, producto_id):
        cursor.execute("SELECT precio_unitario, stock_actual FROM productos WHERE id_producto = %s", (producto_id,))
        return cursor.fetchone()

    @staticmethod
    def descontar_stock_tx(cursor, producto_id, cantidad):
        cursor.execute("UPDATE productos SET stock_actual = stock_actual - %s WHERE id_producto = %s", (cantidad, producto_id))