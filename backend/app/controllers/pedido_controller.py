# app/controllers/pedido_controller.py
from flask import Blueprint, request, jsonify
from app.services.pedido_service import PedidoService

pedido_bp = Blueprint('pedido', __name__, url_prefix='/api')

@pedido_bp.route('/pedido', methods=['POST']) # Al registrarse en el BP se convierte en /api/pedido
def registrar_pedido():
    datos = request.json or {}
    producto_id = datos.get('producto_id')
    cantidad = datos.get('cantidad')
    metodo_pago = datos.get('metodo_pago')
    
    if not all([producto_id, cantidad, metodo_pago]):
        return jsonify({"error": "Campos obligatorios faltantes"}), 400
        
    try:
        resultado = PedidoService.crear_pedido(producto_id, cantidad, metodo_pago)
        if "error" in resultado:
            return jsonify({"error": resultado["error"]}), resultado["code"]
        return jsonify(resultado), resultado["code"]
    except Exception as e:
        return jsonify({"error": "Error interno", "detalle": str(e)}), 500

@pedido_bp.route('/ventas/hoy', methods=['GET'])
def obtener_ventas_hoy():
    try:
        ventas = PedidoService.obtener_ventas_del_dia()
        return jsonify(ventas if ventas else []), 200
    except Exception as e:
        return jsonify({"error": "Error al consultar ventas", "detalle": str(e)}), 500