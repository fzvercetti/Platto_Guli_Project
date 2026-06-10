# platto_app

#  Platto - Sistema de Gestión de Restaurantes

Un sistema integral diseñado para optimizar el flujo de pedidos, la administración de mesas y la atención al cliente, ofreciendo una experiencia fluida tanto para el personal como para la administración.

##  Características Principales

* **Toma de órdenes intuitiva:** Interfaz gráfica optimizada para agilizar el trabajo del personal de servicio.
* **Gestión de mesas:** Visualización del estado de cada mesa y control de capacidad.
* **Arquitectura Multiplataforma:** Código base preparado para compilarse en dispositivos móviles (Android/iOS), web y escritorio (Windows/macOS/Linux).
* **Separación de Lógica (Cliente-Servidor):** Operaciones de base de datos protegidas a través de un backend independiente.

##  Stack Tecnológico

* **Frontend:** Flutter / Dart
* **Backend:** Python  / Flask
* **Base de Datos:** MySQL

##  Estructura del Proyecto

El repositorio sigue una arquitectura en capas claramente definida:

* `/lib` - Contiene el código fuente de la interfaz de usuario en Flutter.
* `/backend` - Aloja la lógica del servidor, la API y la conexión a la base de datos en Python.
* Directorios nativos (`/android`, `/ios`, `/web`, etc.) - Archivos de configuración para cada plataforma de despliegue.

##  Requisitos Previos

Antes de ejecutar el proyecto, asegúrate de tener instalado lo siguiente:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Python 3.x](https://www.python.org/downloads/)
* [MySQL Server](https://dev.mysql.com/downloads/) y MySQL Workbench (o tu gestor preferido).

##  Instalación y Ejecución Local

### 1. Clonar el repositorio
```bash
git clone [https://github.com/fzvercetti/Platto_Guli_Project.git](https://github.com/fzvercetti/Platto_Guli_Project.git)
cd Platto_Guli_Project