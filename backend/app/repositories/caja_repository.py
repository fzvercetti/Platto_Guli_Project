# app/repositories/caja_repository.py
from app.database import connection_pool

class CajaRepository:
    @staticmethod
    def obtener_movimientos():
        with connection_pool.get_connection() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT tipo, monto, concepto, fecha_hora FROM caja_movimientos ORDER BY fecha_hora DESC")
                return cursor.fetchall()

    @staticmethod
    def insertar_movimiento(tipo, monto, concepto):
        with connection_pool.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("INSERT INTO caja_movimientos (tipo, monto, concepto, fecha_hora) VALUES (%s, %s, %s, NOW())", (tipo, monto, concepto))
                conn.commit()