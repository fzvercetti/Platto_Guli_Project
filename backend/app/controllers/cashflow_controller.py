from flask import Blueprint, jsonify
from app.services.cashflow_service import CashFlowService

cashflow_bp = Blueprint('cashflow', __name__)

@cashflow_bp.route('/cashflow', methods=['GET'])
def get_cashflow():
    data, status = CashFlowService.get_cash_flow_data()
    return jsonify(data), status