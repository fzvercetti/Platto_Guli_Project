# app/__init__.py
from flask import Flask
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    CORS(app, resources={r"/*": {"origins": "*"}})
    
    # Importamos los Blueprints de los controladores
    from app.controllers.pedido_controller import pedido_bp
    from app.controllers.producto_controller import producto_bp
    from app.controllers.caja_controller import caja_bp
    from app.controllers.reportes_controller import reportes_bp
    from app.controllers.conciliation_controller import conciliacion_bp
    from app.controllers.cashflow_controller import cashflow_bp
    from app.controllers.daily_sales_controller import daily_sales_bp
    
    # Los registramos en la app central
    app.register_blueprint(pedido_bp, url_prefix='/api/pedido')
    app.register_blueprint(producto_bp,url_prefix='/api/productos')
    app.register_blueprint(caja_bp,url_prefix='/api/caja')
    app.register_blueprint(reportes_bp, url_prefix='/api/resumen')
    app.register_blueprint(conciliacion_bp, url_prefix='/api/cash')
    app.register_blueprint(cashflow_bp, url_prefix='/api/')
    app.register_blueprint(daily_sales_bp, url_prefix='/api/')

    return app