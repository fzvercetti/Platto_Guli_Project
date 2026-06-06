from flask import Blueprint, request, jsonify
from app.services.orders_service import OrdersService

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/pedidos', methods=['POST'])
def crear_pedido():
    data = request.get_json()
    OrdersService.guardar_pedido(data)
    return jsonify({"mensaje": "Pedido guardado"}), 200