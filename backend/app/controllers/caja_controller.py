from flask import Blueprint, jsonify, request
from app.services.caja_service import CajaService

caja_bp = Blueprint('caja', __name__, url_prefix='/api')

@caja_bp.route('/transacciones', methods=['GET', 'POST'])
def manejar_transacciones():
    if request.method == 'GET':
        try:
            # Corregido a 'obtener_historial_caja' para coincidir con tu service
            historial = CajaService.obtener_historial_caja()
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

# --- NUEVAS RUTAS PARA EL CIERRE DE CAJA ---

@caja_bp.route('/caja/totales', methods=['GET'])
def get_totales():
    """Obtiene los totales del sistema para comparar contra el físico"""
    try:
        totales = CajaService.obtener_totales_dia()
        return jsonify(totales), 200
    except Exception as e:
        return jsonify({"error": "Error al obtener totales del sistema", "detalle": str(e)}), 500

@caja_bp.route('/caja/cerrar', methods=['POST'])
def realizar_cierre():
    """Recibe el conteo físico, calcula la diferencia y guarda el cierre"""
    datos = request.json or {}
    
    # Validamos que vengan los campos necesarios
    campos_requeridos = ['sistema_efectivo', 'fisico_efectivo', 'sistema_tarjeta', 'fisico_tarjeta']
    if not all(k in datos for k in campos_requeridos):
        return jsonify({"error": "Faltan datos en el conteo de caja (sistema/fisico, efectivo/tarjeta)"}), 400
        
    try:
        resultado = CajaService.guardar_cierre(datos)
        if "error" in resultado:
            return jsonify(resultado), 500
        return jsonify(resultado), 201
    except Exception as e:
        return jsonify({"error": "Error al procesar el cierre de caja", "detalle": str(e)}), 500