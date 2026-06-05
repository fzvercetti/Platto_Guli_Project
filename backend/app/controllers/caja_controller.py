# app/controllers/caja_controller.py
from flask import Blueprint, jsonify, request
from app.services.caja_service import CajaService

caja_bp = Blueprint('caja', __name__, url_prefix='/api')

@caja_bp.route('/transacciones', methods=['GET', 'POST'])
def manejar_transacciones():
    if request.method == 'GET':
        try:
            historial = CajaService.obtain_historial_caja()
            return jsonify(historial if historial else []), 200
        except Exception as e:
            return jsonify({"error": "Error al obtener movimientos de caja", "detalle": str(e)}), 500
            
    elif request.method == 'POST':
        datos = request.json or {}
        tipo = datos.get('tipo')
        monto = datos.get('monto')
        concepto = datos.get('concepto')
        
        if not all([tipo, monto, concepto]):
            return jsonify({"error": "Faltan campos obligatorios (tipo, monto, concepto)"}), 400
            
        try:
            resultado = CajaService.registrar_movimiento_caja(tipo, monto, concepto)
            if "error" in resultado:
                return jsonify({"error": resultado["error"]}), resultado["code"]
            return jsonify(resultado), resultado["code"]
        except Exception as e:
            return jsonify({"error": "Error al registrar movimiento de caja", "detalle": str(e)}), 500