# app/services/producto_service.py
from app.repositories.producto_repository import ProductoRepository

class ProductoService:
    @staticmethod
    def listar_productos_menu():
        # Aquí se podrían filtrar solo los productos que estén "activos" si tuvieras esa columna
        return ProductoRepository.obtener_todos()

    @staticmethod
    def obtener_inventario_completo():
        return ProductoRepository.obtener_inventario()

    @staticmethod
    def modificar_stock(id_producto, nuevo_stock):
        # Validación de negocio: El stock no puede ser un número negativo
        try:
            stock_int = int(nuevo_stock)
            if stock_int < 0:
                return {"error": "El stock no puede ser menor a 0", "code": 400}
        except (ValueError, TypeError):
            return {"error": "El stock debe ser un número válido", "code": 400}

        # Si pasa la validación, va al repositorio
        ProductoRepository.actualizar_stock_directo(id_producto, stock_int)
        return {"status": "success", "mensaje": "Stock actualizado correctamente", "code": 200}