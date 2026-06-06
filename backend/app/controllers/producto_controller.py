# app/controllers/producto_controller.py
from flask import Blueprint, jsonify, request
from app.services.producto_service import ProductoService

producto_bp = Blueprint('producto', __name__, url_prefix='/api')

@producto_bp.route('/productos', methods=['GET'])
def obtener_productos():
    try:
        productos = ProductoService.listar_productos_menu()
        return jsonify(productos if productos else []), 200
    except Exception as e:
        return jsonify({"error": "Error al obtener productos", "detalle": str(e)}), 500


@producto_bp.route('/inventario', methods=['GET', 'POST'])
def manejar_inventario():
    if request.method == 'GET':
        try:
            inventario = ProductoService.obtener_inventario_completo()
            return jsonify(inventario if inventario else []), 200
        except Exception as e:
            return jsonify({"error": "Error al obtener el inventario", "detalle": str(e)}), 500

    elif request.method == 'POST':
        datos = request.json or {}
        id_p = datos.get('id')
        nuevo_stock = datos.get('stock')
        
        if id_p is None or nuevo_stock is None:
            return jsonify({"error": "Faltan campos obligatorios (id, stock)"}), 400
            
        try:
            resultado = ProductoService.modificar_stock(id_p, nuevo_stock)
            if "error" in resultado:
                return jsonify({"error": resultado["error"]}), resultado["code"]
            return jsonify(resultado), resultado["code"]
        except Exception as e:
            return jsonify({"error": "Error al actualizar el inventario", "detalle": str(e)}), 500