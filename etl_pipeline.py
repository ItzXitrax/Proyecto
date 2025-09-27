"""
Sistema de Análisis de Ventas
Este script carga datos desde archivos CSV a una base de datos SQL Server
"""

import pandas as pd
import pyodbc 
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

class SimpleETL:
    def __init__(self):
        # Configuración de base de datos para SQL Server
        self.server = 'DESKTOP-CFJFHG9\WILLY'  # Ej: 'localhost', 'localhost\SQLEXPRESS', 'nombre_servidor'
        self.database = 'SistemaVentas'
        self.username = 'WILLY' # Ej: 'sa' o un usuario de Windows
        self.password = ' '
        # Generalmente, este es el controlador más moderno. Verifica cuál tienes instalado.
        self.driver = '{ODBC Driver 17 for SQL Server}'
        self.connection = None
    
    def conectar_db(self):
        """Conecta a la base de datos SQL Server"""
        try:
            # CAMBIO: Se construye una cadena de conexión ODBC
            conn_str = (
                f'DRIVER={self.driver};'
                f'SERVER={self.server};'
                f'DATABASE={self.database};'
                f'UID={self.username};'
                f'PWD={self.password};'
            )
            self.connection = pyodbc.connect(conn_str)
            logging.info("Conectado a la base de datos SQL Server")
            return True
        except pyodbc.Error as e:
            logging.error(f"Error conectando: {e}")
            return False
    
    def leer_csvs(self):
        """LEE los archivos CSV"""
        logging.info("Leyendo archivos CSV...")
        
        archivos = {
            'productos': 'productos.csv',
            'clientes': 'clientes.csv', 
            'fuentes': 'fuentes_datos.csv',
            'ventas': 'ventas.csv',
            'encuestas': 'encuestas.csv',
            'comentarios': 'comentarios_sociales.csv',
            'resenas': 'resenas_web.csv'
        }
        
        datos = {}
        for tabla, archivo in archivos.items():
            try:
                df = pd.read_csv(archivo)
                datos[tabla] = df
                logging.info(f"{archivo}: {len(df)} registros")
            except FileNotFoundError:
                logging.warning(f"⚠️  Archivo no encontrado: {archivo}")
                datos[tabla] = pd.DataFrame()
        
        return datos
    
    def limpiar_datos(self, datos):
        """LIMPIA y valida los datos (sin cambios en esta función)"""
        logging.info("Limpiando datos...")
        
        # Limpiar productos
        if not datos['productos'].empty:
            df = datos['productos'].copy()
            df = df.dropna(subset=['nombre', 'categoria', 'precio'])
            df['precio'] = pd.to_numeric(df['precio'], errors='coerce')
            df = df[df['precio'] > 0]
            datos['productos'] = df
            logging.info(f"Productos limpios: {len(df)} registros")
        
        # Limpiar clientes
        if not datos['clientes'].empty:
            df = datos['clientes'].copy()
            df = df.dropna(subset=['nombre', 'email'])
            df = df[df['email'].str.contains('@')]
            datos['clientes'] = df
            logging.info(f"Clientes limpios: {len(df)} registros")
        
        # Limpiar encuestas
        if not datos['encuestas'].empty:
            df = datos['encuestas'].copy()
            df = df.dropna(subset=['cliente_id', 'producto_id', 'calificacion'])
            df['calificacion'] = pd.to_numeric(df['calificacion'], errors='coerce')
            df = df[(df['calificacion'] >= 1) & (df['calificacion'] <= 5)]
            datos['encuestas'] = df
            logging.info(f"Encuestas limpias: {len(df)} registros")
        
        return datos
    
    def cargar_datos(self, datos):
        """CARGA datos a la base de datos SQL Server"""
        logging.info("Cargando datos a la base de datos...")
        
        if not self.connection:
            logging.error("No hay conexión a la base de datos")
            return False
        
        cursor = self.connection.cursor()
        
        # NUEVO: Diccionario para mapear tablas a sus scripts de inserción
        # Usamos '?' como placeholder
        inserciones = {
            'fuentes': "INSERT INTO fuentes (id, nombre, tipo) VALUES (?, ?, ?)",
            'productos': "INSERT INTO productos (id, nombre, categoria, precio) VALUES (?, ?, ?, ?)",
            'clientes': "INSERT INTO clientes (id, nombre, email, ciudad) VALUES (?, ?, ?, ?)",
            'ventas': "INSERT INTO ventas (id, cliente_id, producto_id, fuente_id, cantidad, total, fecha) VALUES (?, ?, ?, ?, ?, ?, ?)", 
            'encuestas': "INSERT INTO encuestas (id, cliente_id, producto_id, fuente_id, calificacion, comentario) VALUES (?, ?, ?, ?, ?, ?)", 
            'comentarios': "INSERT INTO comentarios (id, producto_id, fuente_id, mensaje, likes) VALUES (?, ?, ?, ?, ?)", 
            'resenas': "INSERT INTO resenas (id, producto_id, fuente_id, titulo, contenido, puntuacion) VALUES (?, ?, ?, ?, ?, ?)" 
        }

        # NUEVO: Orden de carga para respetar las claves foráneas
        orden_carga = ['fuentes', 'productos', 'clientes', 'ventas', 'encuestas', 'comentarios', 'resenas']

        try:
            for tabla in orden_carga:
                df = datos.get(tabla)
                if df is not None and not df.empty:
                    # Borra los datos existentes
                    cursor.execute(f"DELETE FROM {tabla}")
                    
                    # NUEVO: Habilitar la inserción de identidad para esta tabla
                    cursor.execute(f"SET IDENTITY_INSERT {tabla} ON")
                    
                    # Prepara los datos como una lista de tuplas
                    data_tuples = [tuple(row) for row in df.to_numpy()]
                    
                    # Ejecutar la inserción de muchos registros a la vez (más eficiente)
                    cursor.executemany(inserciones[tabla], data_tuples)
                    
                    # NUEVO: Deshabilitar la inserción de identidad
                    cursor.execute(f"SET IDENTITY_INSERT {tabla} OFF")
                    
                    logging.info(f"{tabla.capitalize()} cargados: {len(df)} registros")

            # Confirmar cambios
            self.connection.commit()
            logging.info("Todos los datos cargados exitosamente")
            
            # Mostrar resumen
            self.mostrar_resumen(cursor)
            
        except Exception as e:
            self.connection.rollback()
            logging.error(f"Error cargando datos: {e}")
            return False
        finally:
            cursor.close()
        
        return True
    
    def mostrar_resumen(self, cursor):
        """Muestra resumen de datos cargados (sin cambios)"""
        logging.info("\n" + "="*50)
        logging.info("RESUMEN DE DATOS CARGADOS")
        logging.info("="*50)
        
        tablas = ['productos', 'clientes', 'fuentes', 'ventas', 'encuestas', 'comentarios', 'resenas']
        
        for tabla in tablas:
            cursor.execute(f"SELECT COUNT(*) FROM {tabla}")
            count = cursor.fetchone()[0]
            logging.info(f"{tabla.upper()}: {count} registros")
        
        logging.info("="*50)
    
    def ejecutar_pipeline(self):
        """Ejecuta todo el pipeline ETL (sin cambios)"""
        logging.info("Iniciando Pipeline ETL")
        
        if not self.conectar_db():
            return
        
        try:
            datos = self.leer_csvs()
            datos = self.limpiar_datos(datos)
            self.cargar_datos(datos)
            logging.info("Pipeline ETL completado exitosamente")
            
        except Exception as e:
            logging.error(f" Error en pipeline: {e}")
        finally:
            if self.connection:
                self.connection.close()
                logging.info("🔌 Conexión cerrada")

def main():
    etl = SimpleETL()
    etl.ejecutar_pipeline()

if __name__ == "__main__":
    main()