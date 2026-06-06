from app.database import get_db_connection

class OrdersService:
    @staticmethod
    def guardar_pedido(data):
        conexion = get_db_connection()
        cursor = conexion.cursor()
        
        # Guardamos en la tabla ventas (asegúrate de que los campos coincidan)
        query = """
            INSERT INTO ventas (total_venta, metodo_pago, fecha_hora) 
            VALUES (%s, %s, NOW())
        """
        # Nota: Aquí guardamos el total. 
        # Si quieres guardar el nombre del producto, necesitas una tabla 'detalle_ventas'
        valores = (data['total'], data['metodo'])
        
        cursor.execute(query, valores)
        conexion.commit()
        cursor.close()
        conexion.close()
        return True