from app.repositories.caja_repository import CajaRepository

class CajaService:
    @staticmethod
    def obtener_historial_caja():
        return CajaRepository.obtener_movimientos()

    @staticmethod
    def registrar_movimiento_caja(tipo, monto, concepto):
        tipo_normalizado = str(tipo).lower().strip()
        if tipo_normalizado not in ['ingreso', 'egreso']:
            return {"error": "El tipo de movimiento debe ser 'ingreso' o 'egreso'", "code": 400}

        try:
            monto_float = float(monto)
            if monto_float <= 0:
                return {"error": "El monto debe ser mayor a 0", "code": 400}
        except (ValueError, TypeError):
            return {"error": "El monto debe ser un número decimal válido", "code": 400}

        CajaRepository.insertar_movimiento(tipo_normalizado, monto_float, concepto)
        return {"status": "success", "mensaje": "Movimiento de caja registrado", "code": 201}

    @staticmethod
    def obtener_totales_dia():
        """Obtiene las sumas de ventas por método de pago del día actual"""
        return CajaRepository.obtener_totales_ventas_hoy()

    @staticmethod
    def guardar_cierre(data):
        """Calcula la diferencia y guarda el cierre en la base de datos"""
        try:
            # Extraemos los valores
            sis_efectivo = float(data.get('sistema_efectivo', 0))
            fis_efectivo = float(data.get('fisico_efectivo', 0))
            sis_tarjeta = float(data.get('sistema_tarjeta', 0))
            fis_tarjeta = float(data.get('fisico_tarjeta', 0))

            # Calculamos la diferencia total
            diferencia = (fis_efectivo + fis_tarjeta) - (sis_efectivo + sis_tarjeta)

            # Preparamos los datos
            cierre_data = {
                "sistema_efectivo": sis_efectivo,
                "fisico_efectivo": fis_efectivo,
                "sistema_tarjeta": sis_tarjeta,
                "fisico_tarjeta": fis_tarjeta,
                "diferencia": diferencia
            }

            CajaRepository.insertar_cierre(cierre_data)
            return {"status": "success", "mensaje": "Cierre registrado correctamente", "diferencia": diferencia}
        except Exception as e:
            return {"error": str(e), "code": 500}