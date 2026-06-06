from flask import Blueprint, jsonify
from app.services.daily_sales_service import DailySalesService

daily_sales_bp = Blueprint('daily_sales', __name__)

@daily_sales_bp.route('/ventas', methods=['GET'])
def obtener_ventas_dia():
    ventas = DailySalesService.get_ventas_del_dia()
    return jsonify(ventas), 200