from flask import Flask, jsonify, request
import mysql.connector
from flask_cors import CORS

app = Flask(__name__)
# Permiso universal para que Flutter/Chrome pueda conectarse sin error de "Failed to fetch"
CORS(app, resources={r"/*": {"origins": "*"}})

# --- CONEXIÓN A  BASE DE DATOS LOCAL ---
def conectar_db():
    return mysql.connector.connect(
        host="localhost",
        port=3307,
        user="root",
        password="root",
        database="platto_db"
    )

# --- 1. OBTENER PRODUCTOS ---
@app.route('/api/productos', methods=['GET'])
def obtener_productos():
    try:
        conexion = conectar_db()
        cursor = conexion.cursor(dictionary=True)
        # 🔁 Usa alias para que coincidan con lo que espera Flutter
        cursor.execute("""
            SELECT 
                id_producto AS id, 
                nombre,               -- Asegúrate que en tu BD la columna se llama "nombre"
                precio_unitario AS precio
            FROM productos
        """)
        productos = cursor.fetchall()
        cursor.close()
        conexion.close()
        return jsonify(productos)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
# --- 2. OBTENER VENTAS ---
@app.route('/ventas', methods=['GET'])
def obtener_ventas():
    try:
        conexion = conectar_db()
        cursor = conexion.cursor(dictionary=True)
        cursor.execute("SELECT * FROM ventas ORDER BY fecha_hora DESC")
        ventas = cursor.fetchall()
        cursor.close()
        conexion.close()
        return jsonify(ventas) if ventas else jsonify([])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --- 3. TRANSACCIONES (ESTA ES LA CONEXIÓN PARA LA CAJA/PAGO) ---
@app.route('/api/transacciones', methods=['GET', 'POST'])
def manejar_transacciones():
    if request.method == 'GET':
        try:
            conexion = conectar_db()
            cursor = conexion.cursor(dictionary=True)
            cursor.execute("SELECT tipo, monto, concepto, fecha_hora FROM caja_movimientos ORDER BY fecha_hora DESC")
            historial = cursor.fetchall()
            cursor.close()
            conexion.close()
            return jsonify(historial) if historial else jsonify([])
        except Exception as e:
            return jsonify({"error": str(e)}), 500
            
    elif request.method == 'POST':
        try:
            datos = request.json
            tipo = datos.get('tipo')
            monto = datos.get('monto')
            concepto = datos.get('concepto')
            
            # Validación de seguridad
            if not tipo or not monto or not concepto:
                return jsonify({"error": "Faltan campos obligatorios"}), 400
                
            conexion = conectar_db()
            cursor = conexion.cursor()
            # Se inserta en la base de datos (NOW() pone la fecha y hora automáticamente)
            cursor.execute("INSERT INTO caja_movimientos (tipo, monto, concepto, fecha_hora) VALUES (%s, %s, %s, NOW())", (tipo, monto, concepto))
            conexion.commit()
            cursor.close()
            conexion.close()
            return jsonify({"status": "success"}), 201
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500

# --- 4. INVENTARIO (CONEXIÓN PARA LA PANTALLA DE STOCK) ---
@app.route('/api/inventario', methods=['GET', 'POST'])
def manejar_inventario():
    if request.method == 'GET':
        try:
            conexion = conectar_db()
            cursor = conexion.cursor(dictionary=True)
            cursor.execute("SELECT id_producto AS id, nombre, stock_actual AS stock, categoria, precio_unitario FROM productos ORDER BY nombre ASC")
            insumos = cursor.fetchall()
            cursor.close()
            conexion.close()
            return jsonify(insumos) if insumos else jsonify([])
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    elif request.method == 'POST':
        try:
            datos = request.json
            id_p = datos.get('id')
            nuevo_stock = datos.get('stock')
            conexion = conectar_db()
            cursor = conexion.cursor()
            cursor.execute("UPDATE productos SET stock_actual = %s WHERE id_producto = %s", (nuevo_stock, id_p))
            conexion.commit()
            cursor.close()
            conexion.close()
            return jsonify({"status": "success"}), 200
        except Exception as e:
            return jsonify({"error": str(e)}), 500
# --- 5. GUARDAR NUEVO PEDIDO (Conectado a ventas y detalle_ventas) ---
@app.route('/api/pedido', methods=['POST'])
def guardar_pedido():
    try:
        datos = request.json
        producto_id = datos.get('producto_id')
        cantidad = datos.get('cantidad')
        metodo_pago = datos.get('metodo_pago')
        
        conexion = conectar_db()
        cursor = conexion.cursor(dictionary=True)
        
        # 1. Buscamos el precio del producto
        cursor.execute("SELECT precio_unitario FROM productos WHERE id_producto = %s", (producto_id,))
        producto = cursor.fetchone()
        
        if not producto:
            return jsonify({"error": "Producto no encontrado"}), 404
            
        precio = producto['precio_unitario']
        subtotal = float(precio) * int(cantidad)
        
        # 2. Creamos el ticket general en la tabla 'ventas'
        cursor.execute(
            "INSERT INTO ventas (fecha_hora, total_venta, metodo_pago) VALUES (NOW(), %s, %s)", 
            (subtotal, metodo_pago)
        )
        # Obtenemos el ID del ticket que MySQL acaba de crear
        id_venta_generado = cursor.lastrowid 
        
        # 3. Metemos el platillo específico a la tabla 'detalle_ventas'
        cursor.execute(
            "INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, subtotal) VALUES (%s, %s, %s, %s)",
            (id_venta_generado, producto_id, cantidad, subtotal)
        )
        
        # 4. Descontamos el stock del inventario
        cursor.execute(
            "UPDATE productos SET stock_actual = stock_actual - %s WHERE id_producto = %s",
            (cantidad, producto_id)
        )
        
        conexion.commit()
        cursor.close()
        conexion.close()
        
        return jsonify({"status": "success", "mensaje": "Pedido guardado con éxito"}), 201
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# --- 6. VER VENTAS DEL DÍA (Consultando las 3 tablas juntas) ---
@app.route('/api/ventas/hoy', methods=['GET'])
def ventas_hoy():
    try:
        conexion = conectar_db()
        cursor = conexion.cursor(dictionary=True)
        
        # Juntamos ventas, detalle_ventas y productos para darle a Flutter todo masticadito
        consulta = """
            SELECT 
                v.id_venta AS id, 
                p.nombre AS producto, 
                v.total_venta AS total, 
                v.metodo_pago AS metodo 
            FROM ventas v
            JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
            JOIN productos p ON dv.id_producto = p.id_producto
            WHERE DATE(v.fecha_hora) = CURDATE()
            ORDER BY v.fecha_hora DESC
        """
        cursor.execute(consulta)
        ventas = cursor.fetchall()
        
        cursor.close()
        conexion.close()
        return jsonify(ventas) if ventas else jsonify([])
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # El puerto 5000 es donde escucha a tu app de Flutter
    app.run(host='0.0.0.0', port=5000, debug=True)