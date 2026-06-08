from app.database import get_db_connection

class ConciliationService:
    @staticmethod
    def get_summary_today():
        conexion = get_db_connection()
        if not conexion:
            return {"error": "Error de conexión"}, 500
            
        try:
            cursor = conexion.cursor(dictionary=True)
            
            # 1. Ingresos por Ventas (Total de ventas hoy)
            cursor.execute("SELECT COALESCE(SUM(total_venta), 0) as total FROM ventas WHERE DATE(fecha_hora) = CURDATE()")
            ventas_hoy = cursor.fetchone()['total']
            
            # 2. Ingresos manuales (Caja)
            cursor.execute("SELECT COALESCE(SUM(monto), 0) as total FROM caja_movimientos WHERE tipo = 'Ingreso' AND DATE(fecha_hora) = CURDATE()")
            ingresos_caja = cursor.fetchone()['total']
            
            # 3. Egresos manuales (Caja)
            cursor.execute("SELECT COALESCE(SUM(monto), 0) as total FROM caja_movimientos WHERE tipo = 'Egreso' AND DATE(fecha_hora) = CURDATE()")
            egresos_caja = cursor.fetchone()['total']
            
            # El "Balance inicial" lo puedes definir como 0 para este MVP
            # o traerlo de un registro de apertura.
            initial_balance = 0.0 
            
            total_income = float(ventas_hoy) + float(ingresos_caja)
            total_expenses = float(egresos_caja)
            
            return {
                "initial_balance": initial_balance,
                "income": total_income,
                "expenses": total_expenses
            }, 200
            
        except Exception as e:
            return {"error": str(e)}, 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            conexion.close()

    @staticmethod
    def guardar_cierre(data):
        print("--- debug: funcion guardar_cierre llamada ---")
        print("datos recibidos desde flutter:", data)
        conexion = get_db_connection()
        if not conexion:
            return {"error": "Error de conexión"}, 500
            
        try:
            cursor = conexion.cursor()
            
            # Ajustamos la consulta para que incluya tus columnas exactas.
            # 'NOW()' insertará automáticamente la fecha y hora actual.
            query = """
                INSERT INTO cierres_caja 
                (total_sistema_efectivo, total_fisico_efectivo, 
                 total_sistema_tarjeta, total_fisico_tarjeta, diferencia)
                VALUES (%s, %s, %s, %s, %s)
            """
            
            # Asumiendo que el 'expected_balance' del sistema es todo efectivo
            # Puedes ajustar si el sistema distingue efectivo/tarjeta
            valores = (
                data.get('expected_balance', 0),  # total_sistema_efectivo
                data.get('physical_cash', 0),     # total_fisico_efectivo
                0.0,                              # total_sistema_tarjeta (Asumido 0 si no llega)
                data.get('physical_cards', 0),    # total_fisico_tarjeta
                data.get('difference', 0)         # diferencia
            )
            
            print(f"DEBUG: Ejecutando Query con valores: {valores}")
            cursor.execute(query, valores)
            conexion.commit()
            print("DEBUG: Commit realizado con éxito")

            return {"mensaje": "Cierre guardado exitosamente"}, 200
            
        except Exception as e:
            print(f"DEBUG CRÍTICO: Error en SQL: {str(e)}")
            # Imprime el error en consola para que sepas qué pasó exactamente
            print(f"Error al guardar cierre: {e}")
            return {"error": str(e)}, 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            conexion.close()
            print("--- DEBUG: Cierre de conexión ---")