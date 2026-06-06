# app/controllers/pedido_controller.py
from flask import Blueprint, request, jsonify
from app.services.pedido_service import PedidoService

pedido_bp = Blueprint('pedido', __name__, url_prefix='/api')

# app/controllers/pedido_controller.py

@pedido_bp.route('/pedido', methods=['POST'])
def registrar_pedido():
    try:
        data = request.json
        print(f"--- DATOS RECIBIDOS: {data} ---")
        
        # 1. Extraemos los valores del diccionario
        producto_id = data.get('producto_id')
        cantidad = data.get('cantidad')
        metodo_pago = data.get('metodo_pago')
        
        # 2. Los pasamos uno a uno (como espera tu servicio)
        PedidoService.crear_pedido(producto_id, cantidad, metodo_pago)
        
        return jsonify({"mensaje": "Pedido guardado"}), 200
        
    except Exception as e:
        print("--- ERROR CRÍTICO ---")
        print(str(e))
        return jsonify({"error": str(e)}), 500