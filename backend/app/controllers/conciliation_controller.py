from flask import Blueprint, jsonify, request
from app.services.conciliation_service import ConciliationService

conciliacion_bp = Blueprint('conciliacion', __name__)

@conciliacion_bp.route('/summary_today', methods=['GET'])
def get_summary():
    data, status = ConciliationService.get_summary_today()
    return jsonify(data), status

@conciliacion_bp.route('/guardar_cierre', methods=['POST'])
def guardar_cierre():
    data = request.get_json()
    
    # Llamamos al servicio
    resultado, status = ConciliationService.guardar_cierre(data)
    return jsonify(resultado), status    