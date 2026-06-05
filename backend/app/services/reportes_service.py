from app.database import get_db_connection

class ReportesService:
    @staticmethod
    def obtener_resumen():
        conexion = get_db_connection()
        if not conexion:
            return {"error": "Error de conexión a la base de datos"}, 500

        try:
            cursor = conexion.cursor(dictionary=True)

            # 1. Totales de HOY (Ventas y Pedidos)
            cursor.execute("""
                SELECT 
                    COUNT(id_venta) AS pedidos_hoy, 
                    COALESCE(SUM(total_venta), 0) AS ventas_hoy 
                FROM ventas 
                WHERE DATE(fecha_hora) = CURDATE()
            """)
            totales_hoy = cursor.fetchone()
            ventas_hoy = float(totales_hoy['ventas_hoy'])
            pedidos_hoy = int(totales_hoy['pedidos_hoy'])

            # 2. Ventas de AYER (Para el porcentaje)
            cursor.execute("""
                SELECT COALESCE(SUM(total_venta), 0) AS ventas_ayer 
                FROM ventas 
                WHERE DATE(fecha_hora) = CURDATE() - INTERVAL 1 DAY
            """)
            ventas_ayer = float(cursor.fetchone()['ventas_ayer'])

            # Calcular porcentaje de variación
            if ventas_ayer > 0:
                variacion = ((ventas_hoy - ventas_ayer) / ventas_ayer) * 100
                signo = "+" if variacion >= 0 else ""
                str_variacion = f"{signo}{variacion:.0f}%"
            else:
                str_variacion = "+100%" if ventas_hoy > 0 else "0%"

            # 3. Datos para la Gráfica (Agrupado por hora)
            cursor.execute("""
                SELECT SUM(total_venta) AS total 
                FROM ventas 
                WHERE DATE(fecha_hora) = CURDATE() 
                GROUP BY HOUR(fecha_hora)
                ORDER BY HOUR(fecha_hora) ASC
            """)
            # Extraemos solo los valores numéricos para Flutter
            grafica_data = [float(row['total']) for row in cursor.fetchall()]
            if not grafica_data:
                grafica_data = [0, 0, 0, 0, 0, 0, 0, 0] # Datos por defecto si no hay ventas

            # 4. Tabla de detalles (Últimas ventas del día)
            cursor.execute("""
                SELECT 
                    TIME_FORMAT(v.fecha_hora, '%H:%i') AS col1,
                    p.nombre AS col2,
                    CONCAT('$', dv.subtotal) AS col3
                FROM ventas v
                JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
                JOIN productos p ON dv.id_producto = p.id_producto
                WHERE DATE(v.fecha_hora) = CURDATE()
                ORDER BY v.fecha_hora DESC
                LIMIT 10
            """)
            tabla_detalles = cursor.fetchall()

            # 5. Empaquetar todo EXACTAMENTE como lo espera tu Flutter
            data = {
                "ventas_hoy": round(ventas_hoy, 2),
                "pedidos_hoy": pedidos_hoy,
                "clientes_hoy": pedidos_hoy, # Usamos pedidos como equivalente a clientes
                "porcentaje_vs_ayer": str_variacion,
                "grafica": grafica_data,
                "tabla_detalles": tabla_detalles
            }

            return data, 200

        except Exception as e:
            return {"error": str(e)}, 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            conexion.close()