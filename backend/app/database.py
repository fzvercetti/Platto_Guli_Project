# app/database.py
import mysql.connector
from mysql.connector import pooling

db_config = {
    "host": "localhost",
    "port": 3307,
    "user": "root",
    "password": "zamora",
    "database": "platto_db"
}

try:
    connection_pool = pooling.MySQLConnectionPool(
        pool_name="platto_pool",
        pool_size=5,
        **db_config
    )
except mysql.connector.Error as err:
    print(f"Error crítico en el Pool de Datos: {err}")
    exit(1)

def get_db_connection():

    try:
        return connection_pool.get_connection()
    except mysql.connector.Error as err:
        print("Error obtenido conexión: {err}")
        return None    