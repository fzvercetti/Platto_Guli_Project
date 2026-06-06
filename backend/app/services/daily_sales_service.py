from app.database import get_db_connection

class DailySalesService:
    @staticmethod
    def get_ventas_del_dia():
        conexion = get_db_connection()
        if not conexion:
            return []
            
        try:
            cursor = conexion.cursor(dictionary=True)
            # Asegúrate de que los nombres de columnas coincidan con tu tabla 'ventas'
            query = """
                SELECT id_venta, total_venta, metodo_pago 
                FROM ventas 
                WHERE DATE(fecha_hora) = CURDATE()
            """
            cursor.execute(query)
            resultados = cursor.fetchall()
            
            # Mapeo a lo que Flutter espera
            return [
                {
                    "id": v['id_venta'],
                    "total": float(v['total_venta']),
                    "metodo": v['metodo_pago']
                } for v in resultados
            ]
            
        except Exception as e:
            print(f"Error en DailySalesService: {e}")
            return []
        finally:
            if 'cursor' in locals():
                cursor.close()
            conexion.close()