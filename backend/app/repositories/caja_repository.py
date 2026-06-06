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
    #lógica de guardado
    @staticmethod
    def obtener_totales_ventas_hoy():
        conexion = get_db_connection()
        cursor = conexion.cursor(dictionary=True)
        query = """
            SELECT metodo_pago, SUM(total_venta) as total 
            FROM ventas 
            WHERE DATE(fecha_hora) = CURDATE() 
            GROUP BY metodo_pago
        """
        cursor.execute(query)
        resultados = cursor.fetchall()
        cursor.close()
        conexion.close()
        
        totales = {"Efectivo": 0.0, "Tarjeta": 0.0}
        for item in resultados:
            if item['metodo_pago'] in totales:
                totales[item['metodo_pago']] = float(item['total'])
        return totales

    @staticmethod
    def insertar_cierre(data):
        conexion = get_db_connection()
        cursor = conexion.cursor()
        query = """
            INSERT INTO cierres_caja 
            (total_sistema_efectivo, total_fisico_efectivo, total_sistema_tarjeta, 
             total_fisico_tarjeta, diferencia) 
            VALUES (%s, %s, %s, %s, %s)
        """
        valores = (
            data['sistema_efectivo'], data['fisico_efectivo'],
            data['sistema_tarjeta'], data['fisico_tarjeta'],
            data['diferencia']
        )
        cursor.execute(query, valores)
        conexion.commit()
        cursor.close()
        conexion.close()            