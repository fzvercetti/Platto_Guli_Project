# app/services/caja_service.py
from app.repositories.caja_repository import CajaRepository

class CajaService:
    @staticmethod
    def obtener_historial_caja():
        return CajaRepository.obtener_movimientos()

    @staticmethod
    def registrar_movimiento_caja(tipo, monto, concepto):
        # Validación de negocio: Asegurar que el tipo sea estrictamente 'ingreso' o 'egreso'
        tipo_normalizado = str(tipo).lower().strip()
        if tipo_normalizado not in ['ingreso', 'egreso']:
            return {"error": "El tipo de movimiento debe ser 'ingreso' o 'egreso'", "code": 400}

        # Validación de negocio: El monto debe ser mayor que cero
        try:
            monto_float = float(monto)
            if monto_float <= 0:
                return {"error": "El monto debe ser mayor a 0", "code": 400}
        except (ValueError, TypeError):
            return {"error": "El monto debe ser un número decimal o entero válido", "code": 400}

        # Si todo es correcto, guardamos en la base de datos
        CajaRepository.insertar_movimiento(tipo_normalizado, monto_float, concepto)
        return {"status": "success", "mensaje": "Movimiento de caja registrado", "code": 201}

        