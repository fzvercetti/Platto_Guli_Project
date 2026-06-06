from __future__ import annotations

from contextlib import contextmanager
from datetime import datetime, date, timedelta
from decimal import Decimal, InvalidOperation
import os
from typing import Any, Dict, Iterable, List, Optional, Tuple

import mysql.connector
from flask import Flask, jsonify, request
from flask_cors import CORS


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

DB_CONFIG = {
    "host": os.getenv("PLATTO_DB_HOST", "localhost"),
    "port": int(os.getenv("PLATTO_DB_PORT", "3307")),
    "user": os.getenv("PLATTO_DB_USER", "root"),
    "password": os.getenv("PLATTO_DB_PASSWORD", "root"),
    "database": os.getenv("PLATTO_DB_NAME", "platto_db"),
    "autocommit": False,
}

VALID_PAYMENT_METHODS = {"Efectivo", "Tarjeta", "Transferencia"}
VALID_MOVEMENT_TYPES = {
    "ingreso": "Ingreso",
    "income": "Ingreso",
    "entrada": "Ingreso",
    "egreso": "Egreso",
    "expense": "Egreso",
    "salida": "Egreso",
}


def conectar_db():
    return mysql.connector.connect(**DB_CONFIG)


@contextmanager
def db_cursor(dictionary: bool = False):
    conn = conectar_db()
    cursor = conn.cursor(dictionary=dictionary)
    try:
        yield conn, cursor
    finally:
        try:
            cursor.close()
        except Exception:
            pass
        try:
            conn.close()
        except Exception:
            pass


def error_response(message: str, status: int = 400):
    return jsonify({"error": message}), status


def money(value: Any) -> float:
    try:
        return float(Decimal(str(value or 0)).quantize(Decimal("0.01")))
    except (InvalidOperation, ValueError, TypeError):
        return 0.0


def int_or_none(value: Any) -> Optional[int]:
    if value is None or value == "":
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def parse_positive_int(value: Any, field_name: str) -> int:
    parsed = int_or_none(value)
    if parsed is None or parsed <= 0:
        raise ValueError(f"{field_name} debe ser un entero mayor a 0")
    return parsed


def parse_non_negative_int(value: Any, field_name: str) -> int:
    parsed = int_or_none(value)
    if parsed is None or parsed < 0:
        raise ValueError(f"{field_name} debe ser un entero mayor o igual a 0")
    return parsed


def parse_decimal(value: Any, field_name: str) -> Decimal:
    try:
        d = Decimal(str(value))
    except (InvalidOperation, TypeError, ValueError):
        raise ValueError(f"{field_name} debe ser numérico")
    return d


def normalize_payment_method(value: Any) -> str:
    if value is None:
        return "Efectivo"
    value = str(value).strip()
    return value if value in VALID_PAYMENT_METHODS else value


def normalize_movement_type(value: Any) -> Optional[str]:
    if value is None:
        return None
    key = str(value).strip().lower()
    return VALID_MOVEMENT_TYPES.get(key)


def format_sale_row(row: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": row.get("id_venta"),
        "fecha_hora": row.get("fecha_hora").isoformat(sep=" ", timespec="seconds") if row.get("fecha_hora") else None,
        "total": money(row.get("total_venta")),
        "metodo": row.get("metodo_pago"),
    }


def format_movement_row(row: Dict[str, Any]) -> Dict[str, Any]:
    tipo = str(row.get("tipo") or "").strip().lower()
    mapped_type = "income" if tipo in {"ingreso", "income", "entrada"} else "expense"
    fecha = row.get("fecha_hora")
    return {
        "id": row.get("id_movimiento"),
        "description": row.get("concepto"),
        "type": mapped_type,
        "amount": money(row.get("monto")),
        "time": fecha.strftime("%I:%M %p") if fecha else None,
        "payment_method": row.get("payment_method") or "N/A",
    }


def fetch_sales_between(start_dt: datetime, end_dt: datetime) -> Dict[str, Any]:
    with db_cursor(dictionary=True) as (conn, cursor):
        cursor.execute(
            """
            SELECT
                id_venta,
                fecha_hora,
                total_venta,
                metodo_pago
            FROM ventas
            WHERE fecha_hora >= %s AND fecha_hora < %s
            ORDER BY fecha_hora DESC
            """,
            (start_dt, end_dt),
        )
        sales = cursor.fetchall() or []

        cursor.execute(
            """
            SELECT
                dv.id_venta,
                dv.id_producto,
                p.nombre,
                dv.cantidad,
                dv.subtotal,
                v.fecha_hora
            FROM detalle_ventas dv
            INNER JOIN ventas v ON v.id_venta = dv.id_venta
            INNER JOIN productos p ON p.id_producto = dv.id_producto
            WHERE v.fecha_hora >= %s AND v.fecha_hora < %s
            ORDER BY v.fecha_hora DESC, dv.id_detalle DESC
            """,
            (start_dt, end_dt),
        )
        details = cursor.fetchall() or []

    total_sales = sum(Decimal(str(row["total_venta"] or 0)) for row in sales)
    return {
        "sales": sales,
        "details": details,
        "total_sales": total_sales,
        "count": len(sales),
    }


@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "platto-api"})


@app.route("/api/productos", methods=["GET"])
def obtener_productos():
    try:
        with db_cursor(dictionary=True) as (conn, cursor):
            cursor.execute(
                """
                SELECT
                    id_producto AS id,
                    nombre,
                    categoria,
                    precio_unitario AS precio,
                    precio_unitario AS precio_unitario,
                    stock_actual AS stock,
                    stock_minimo
                FROM productos
                ORDER BY nombre ASC
                """
            )
            productos = cursor.fetchall() or []
        return jsonify([
            {
                "id": row["id"],
                "nombre": row["nombre"],
                "categoria": row["categoria"],
                "precio": money(row["precio"]),
                "precio_unitario": money(row["precio_unitario"]),
                "stock": int(row["stock"] or 0),
                "stock_minimo": int(row.get("stock_minimo") or 0),
            }
            for row in productos
        ])
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/api/inventario", methods=["GET", "POST"])
def manejar_inventario():
    try:
        if request.method == "GET":
            with db_cursor(dictionary=True) as (conn, cursor):
                cursor.execute(
                    """
                    SELECT
                        id_producto AS id,
                        nombre,
                        categoria,
                        stock_actual AS stock,
                        precio_unitario AS precio_unitario,
                        precio_unitario AS precio,
                        stock_minimo
                    FROM productos
                    ORDER BY nombre ASC
                    """
                )
                rows = cursor.fetchall() or []
            return jsonify(rows)

        data = request.get_json(silent=True) or {}
        product_id = parse_positive_int(data.get("id"), "id")
        stock = parse_non_negative_int(data.get("stock"), "stock")

        with db_cursor(dictionary=False) as (conn, cursor):
            cursor.execute(
                "UPDATE productos SET stock_actual = %s WHERE id_producto = %s",
                (stock, product_id),
            )
            if cursor.rowcount == 0:
                conn.rollback()
                return error_response("Producto no encontrado", 404)
            conn.commit()

        return jsonify({"status": "success", "id": product_id, "stock": stock}), 200
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/ventas", methods=["GET"])
@app.route("/api/ventas", methods=["GET"])
def obtener_ventas():
    try:
        with db_cursor(dictionary=True) as (conn, cursor):
            cursor.execute(
                """
                SELECT id_venta, fecha_hora, total_venta, metodo_pago
                FROM ventas
                ORDER BY fecha_hora DESC, id_venta DESC
                """
            )
            rows = cursor.fetchall() or []
        return jsonify([format_sale_row(row) for row in rows])
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/api/ventas_dia", methods=["GET"])
@app.route("/api/ventas/hoy", methods=["GET"])
def ventas_hoy():
    try:
        today = date.today()
        start_dt = datetime.combine(today, datetime.min.time())
        end_dt = start_dt + timedelta(days=1)

        with db_cursor(dictionary=True) as (conn, cursor):
            cursor.execute(
                """
                SELECT
                    v.id_venta,
                    v.fecha_hora,
                    v.total_venta,
                    v.metodo_pago,
                    p.nombre AS producto
                FROM ventas v
                INNER JOIN detalle_ventas dv ON dv.id_venta = v.id_venta
                INNER JOIN productos p ON p.id_producto = dv.id_producto
                WHERE v.fecha_hora >= %s AND v.fecha_hora < %s
                ORDER BY v.fecha_hora DESC, v.id_venta DESC
                """,
                (start_dt, end_dt),
            )
            rows = cursor.fetchall() or []

        payload = []
        for row in rows:
            payload.append(
                {
                    "id": row["id_venta"],
                    "producto": row.get("producto"),
                    "total": money(row["total_venta"]),
                    "metodo": row["metodo_pago"],
                    "fecha_hora": row["fecha_hora"].isoformat(sep=" ", timespec="seconds") if row.get("fecha_hora") else None,
                }
            )
        return jsonify(payload)
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/api/transacciones", methods=["GET", "POST"])
@app.route("/api/movimiento", methods=["GET", "POST"])
def manejar_movimientos():
    try:
        if request.method == "GET":
            with db_cursor(dictionary=True) as (conn, cursor):
                cursor.execute(
                    """
                    SELECT
                        id_movimiento,
                        tipo,
                        monto,
                        concepto,
                        fecha_hora
                    FROM caja_movimientos
                    ORDER BY fecha_hora DESC, id_movimiento DESC
                    """
                )
                rows = cursor.fetchall() or []
            return jsonify([format_movement_row(row) for row in rows])

        data = request.get_json(silent=True) or {}
        tipo = normalize_movement_type(data.get("tipo"))
        monto = parse_decimal(data.get("monto"), "monto")
        concepto = str(data.get("concepto") or "").strip()
        payment_method = str(data.get("payment_method") or "N/A").strip() or "N/A"

        if not tipo:
            return error_response("tipo debe ser Ingreso o Egreso", 400)
        if monto <= 0:
            return error_response("monto debe ser mayor a 0", 400)
        if not concepto:
            return error_response("concepto es obligatorio", 400)

        with db_cursor(dictionary=False) as (conn, cursor):
            cursor.execute(
                """
                INSERT INTO caja_movimientos (tipo, monto, concepto, fecha_hora)
                VALUES (%s, %s, %s, NOW())
                """,
                (tipo, float(monto), concepto),
            )
            conn.commit()

        return jsonify({
            "status": "success",
            "tipo": tipo,
            "monto": money(monto),
            "concepto": concepto,
            "payment_method": payment_method,
        }), 201
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/api/pedido", methods=["POST"])
def guardar_pedido():
    try:
        data = request.get_json(silent=True) or {}
        producto_id = data.get("producto_id") or data.get("id_producto")
        cantidad = parse_positive_int(data.get("cantidad"), "cantidad")
        metodo_pago = normalize_payment_method(data.get("metodo_pago"))

        if metodo_pago not in VALID_PAYMENT_METHODS:
            return error_response("metodo_pago inválido", 400)

        with db_cursor(dictionary=True) as (conn, cursor):
            conn.start_transaction()

            cursor.execute(
                """
                SELECT id_producto, nombre, precio_unitario, stock_actual
                FROM productos
                WHERE id_producto = %s
                FOR UPDATE
                """,
                (producto_id,),
            )
            producto = cursor.fetchone()

            if not producto:
                conn.rollback()
                return error_response("Producto no encontrado", 404)

            stock_actual = int(producto["stock_actual"] or 0)
            if stock_actual < cantidad:
                conn.rollback()
                return error_response("Stock insuficiente", 400)

            precio = Decimal(str(producto["precio_unitario"]))
            subtotal = (precio * Decimal(cantidad)).quantize(Decimal("0.01"))

            cursor.execute(
                """
                INSERT INTO ventas (fecha_hora, total_venta, metodo_pago)
                VALUES (NOW(), %s, %s)
                """,
                (float(subtotal), metodo_pago),
            )
            id_venta = cursor.lastrowid

            cursor.execute(
                """
                INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, subtotal)
                VALUES (%s, %s, %s, %s)
                """,
                (id_venta, producto_id, cantidad, float(subtotal)),
            )

            cursor.execute(
                """
                UPDATE productos
                SET stock_actual = stock_actual - %s
                WHERE id_producto = %s
                """,
                (cantidad, producto_id),
            )

            conn.commit()

        return jsonify({
            "status": "success",
            "mensaje": "Pedido guardado con éxito",
            "id_venta": id_venta,
            "producto_id": int(producto_id),
            "cantidad": cantidad,
            "subtotal": money(subtotal),
            "stock_restante": stock_actual - cantidad,
        }), 201
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/api/cashflow", methods=["GET"])
def cashflow():
    try:
        with db_cursor(dictionary=True) as (conn, cursor):
            cursor.execute(
                """
                SELECT
                    id_movimiento,
                    tipo,
                    monto,
                    concepto,
                    fecha_hora
                FROM caja_movimientos
                ORDER BY fecha_hora DESC, id_movimiento DESC
                """
            )
            rows = cursor.fetchall() or []

        ingresos = sum(
            Decimal(str(row["monto"] or 0))
            for row in rows
            if str(row["tipo"] or "").strip().lower() in {"ingreso", "income", "entrada"}
        )
        egresos = sum(
            Decimal(str(row["monto"] or 0))
            for row in rows
            if str(row["tipo"] or "").strip().lower() in {"egreso", "expense", "salida"}
        )
        movimientos = [format_movement_row(row) for row in rows]
        neto = ingresos - egresos

        return jsonify({
            "neto": money(neto),
            "ingresos": money(ingresos),
            "egresos": money(egresos),
            "movimientos": movimientos,
        })
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/api/cash/summary_today", methods=["GET"])
def summary_today():
    try:
        today = date.today()
        start_today = datetime.combine(today, datetime.min.time())
        end_today = start_today + timedelta(days=1)

        with db_cursor(dictionary=True) as (conn, cursor):
            cursor.execute(
                """
                SELECT tipo, monto
                FROM caja_movimientos
                WHERE fecha_hora < %s
                """,
                (start_today,),
            )
            before_rows = cursor.fetchall() or []

            cursor.execute(
                """
                SELECT tipo, monto
                FROM caja_movimientos
                WHERE fecha_hora >= %s AND fecha_hora < %s
                """,
                (start_today, end_today),
            )
            today_rows = cursor.fetchall() or []

        initial_balance = sum(
            Decimal(str(row["monto"] or 0)) if str(row["tipo"] or "").strip().lower() in {"ingreso", "income", "entrada"}
            else -Decimal(str(row["monto"] or 0))
            for row in before_rows
        )
        income = sum(
            Decimal(str(row["monto"] or 0))
            for row in today_rows
            if str(row["tipo"] or "").strip().lower() in {"ingreso", "income", "entrada"}
        )
        expenses = sum(
            Decimal(str(row["monto"] or 0))
            for row in today_rows
            if str(row["tipo"] or "").strip().lower() in {"egreso", "expense", "salida"}
        )

        return jsonify({
            "initial_balance": money(initial_balance),
            "income": money(income),
            "expenses": money(expenses),
        })
    except Exception as e:
        return error_response(str(e), 500)


@app.route("/api/reportes/resumen", methods=["GET"])
def reporte_resumen():
    try:
        today = date.today()
        start_today = datetime.combine(today, datetime.min.time())
        end_today = start_today + timedelta(days=1)
        start_yesterday = start_today - timedelta(days=1)

        with db_cursor(dictionary=True) as (conn, cursor):
            # Ventas de hoy
            cursor.execute(
                """
                SELECT id_venta, fecha_hora, total_venta, metodo_pago
                FROM ventas
                WHERE fecha_hora >= %s AND fecha_hora < %s
                ORDER BY fecha_hora DESC, id_venta DESC
                """,
                (start_today, end_today),
            )
            ventas_hoy_rows = cursor.fetchall() or []

            # Ventas de ayer
            cursor.execute(
                """
                SELECT total_venta
                FROM ventas
                WHERE fecha_hora >= %s AND fecha_hora < %s
                """,
                (start_yesterday, start_today),
            )
            ventas_ayer_rows = cursor.fetchall() or []

            # Serie de los últimos 8 días
            cursor.execute(
                """
                SELECT DATE(fecha_hora) AS dia, COALESCE(SUM(total_venta), 0) AS total
                FROM ventas
                WHERE fecha_hora >= %s
                GROUP BY DATE(fecha_hora)
                ORDER BY dia ASC
                """,
                (start_today - timedelta(days=7),),
            )
            graph_rows = cursor.fetchall() or []

            # Detalle reciente de ventas
            cursor.execute(
                """
                SELECT
                    v.id_venta,
                    v.fecha_hora,
                    p.nombre,
                    dv.cantidad,
                    dv.subtotal
                FROM detalle_ventas dv
                INNER JOIN ventas v ON v.id_venta = dv.id_venta
                INNER JOIN productos p ON p.id_producto = dv.id_producto
                WHERE v.fecha_hora >= %s AND v.fecha_hora < %s
                ORDER BY v.fecha_hora DESC, dv.id_detalle DESC
                LIMIT 20
                """,
                (start_today, end_today),
            )
            detalle_rows = cursor.fetchall() or []

        ventas_hoy_total = sum(Decimal(str(row["total_venta"] or 0)) for row in ventas_hoy_rows)
        ventas_ayer_total = sum(Decimal(str(row["total_venta"] or 0)) for row in ventas_ayer_rows)

        if ventas_ayer_total == 0 and ventas_hoy_total == 0:
            porcentaje = "0%"
        elif ventas_ayer_total == 0:
            porcentaje = "+100%"
        else:
            delta = ((ventas_hoy_total - ventas_ayer_total) / ventas_ayer_total) * Decimal("100")
            sign = "+" if delta >= 0 else ""
            porcentaje = f"{sign}{delta.quantize(Decimal('0.1'))}%"

        grafica = [money(row["total"]) for row in graph_rows]
        if len(grafica) < 8:
            grafica = [0.0] * (8 - len(grafica)) + grafica
        else:
            grafica = grafica[-8:]

        tabla_detalles = [
            {
                "col1": f"Reg {row['id_venta']}",
                "col2": row["nombre"],
                "col3": f"${money(row['subtotal']):.2f}",
            }
            for row in detalle_rows
        ]

        # No existe una tabla de clientes en el esquema original.
        # Para que la interfaz siga funcionando, este valor se aproxima con la cantidad de ventas del día.
        clientes_hoy = len(ventas_hoy_rows)

        return jsonify({
            "ventas_hoy": money(ventas_hoy_total),
            "pedidos_hoy": len(ventas_hoy_rows),
            "clientes_hoy": clientes_hoy,
            "porcentaje_vs_ayer": porcentaje,
            "grafica": grafica,
            "tabla_detalles": tabla_detalles,
        })
    except Exception as e:
        return error_response(str(e), 500)


@app.errorhandler(404)
def not_found(_):
    return error_response("Ruta no encontrada", 404)


@app.errorhandler(405)
def method_not_allowed(_):
    return error_response("Método no permitido", 405)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PLATTO_API_PORT", "5000")), debug=True)
