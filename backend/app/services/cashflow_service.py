from app.database import get_db_connection
from datetime import datetime

class CashFlowService:
    @staticmethod
    def get_cash_flow_data():
        conexion = get_db_connection()
        if not conexion:
            return {"error": "Error de conexión"}, 500
            
        try:
            cursor = conexion.cursor(dictionary=True)
            
            # 1. Total Ventas (Ingresos)
            cursor.execute("SELECT COALESCE(SUM(total_venta), 0) as total FROM ventas")
            ventas_totales = cursor.fetchone()['total']
            
            # 2. Total Ingresos Manuales
            cursor.execute("SELECT COALESCE(SUM(monto), 0) as total FROM caja_movimientos WHERE tipo = 'Ingreso'")
            ingresos_manuales = cursor.fetchone()['total']
            
            # 3. Total Egresos
            cursor.execute("SELECT COALESCE(SUM(monto), 0) as total FROM caja_movimientos WHERE tipo = 'Egreso'")
            egresos_totales = cursor.fetchone()['total']
            
            total_ingresos = float(ventas_totales) + float(ingresos_manuales)
            neto = total_ingresos - float(egresos_totales)

            # 4. Obtener todos los movimientos (Unión de tablas)
            # Usamos UNION ALL para listar ambos tipos de transacciones
            query_movimientos = """
                SELECT 'Venta' as description, 'income' as type, total_venta as amount, fecha_hora, 'N/A' as payment_method 
                FROM ventas
                UNION ALL
                SELECT concepto as description, lower(tipo) as type, monto as amount, fecha_hora, 'Efectivo' as payment_method 
                FROM caja_movimientos
                ORDER BY fecha_hora DESC
            """
            cursor.execute(query_movimientos)
            movimientos_raw = cursor.fetchall()
            
            # Formatear la hora para que coincida con lo que espera Flutter (10:30 AM)
            movimientos = []
            for m in movimientos_raw:
                movimientos.append({
                    "description": m['description'],
                    "type": m['type'],
                    "amount": float(m['amount']),
                    "time": m['fecha_hora'].strftime('%I:%M %p'),
                    "payment_method": m['payment_method']
                })
            
            return {
                "neto": neto,
                "ingresos": total_ingresos,
                "egresos": egresos_totales,
                "movimientos": movimientos
            }, 200
            
        except Exception as e:
            return {"error": str(e)}, 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            conexion.close()