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
@app.route('/productos', methods=['GET'])
def obtener_productos():
    try:
        conexion = conectar_db()
        cursor = conexion.cursor(dictionary=True)
        cursor.execute("SELECT * FROM productos")
        productos = cursor.fetchall()
        cursor.close()
        conexion.close()
        return jsonify(productos) if productos else jsonify([])
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

if __name__ == '__main__':
    # El puerto 5000 es donde escucha a tu app de Flutter
    app.run(host='0.0.0.0', port=5000, debug=True)