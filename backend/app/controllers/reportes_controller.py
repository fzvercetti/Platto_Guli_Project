from flask import Blueprint, jsonify
from app.services.reportes_service import ReportesService

# Creamos el Blueprint para los reportes
reportes_bp = Blueprint('reportes', __name__)

@reportes_bp.route('/resumen', methods=['GET'])
def resumen_diario():
    # Llamamos al servicio
    data, status_code = ReportesService.obtener_resumen()
    
    # Retornamos el JSON a Flutter
    return jsonify(data), status_code