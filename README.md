# Sistema de Análisis de Ventas

Un sistema simplificado de análisis de ventas que implementa un pipeline
ETL para consolidar datos de múltiples fuentes en una base de datos
normalizada de SQL Server.

## Tabla de Contenidos

-   [Resumen del Proyecto](#resumen-del-proyecto)
-   [Componentes del Proyecto](#componentes-del-proyecto)
-   [Requisitos](#requisitos)
-   [Instalación y Configuración](#instalación-y-configuración)
-   [Arquitectura de la Base de
    Datos](#arquitectura-de-la-base-de-datos)
-   [Descripción de Scripts](#descripción-de-scripts)
-   [Estructura de Datos CSV](#estructura-de-datos-csv)
-   [Uso del Sistema](#uso-del-sistema)
-   [Diagrama de Entidad-Relación](#diagrama-de-entidad-relación)

## Resumen del Proyecto

Este proyecto implementa un sistema integral de análisis de ventas que
centraliza datos de diversas fuentes incluyendo ventas directas,
encuestas, redes sociales y reseñas web. El objetivo principal es
consolidar datos de múltiples orígenes en una base de datos relacional
normalizada para facilitar consultas y generación de informes.

**Características Principales:** - Pipeline ETL escrito en Python - Base
de datos SQL Server con esquema normalizado - Validación y limpieza de
datos - Integración de datos multi-fuente - Consultas de verificación
comprensivas

## Componentes del Proyecto

El proyecto está compuesto por los siguientes archivos:

  -----------------------------------------------------------------------
  Archivo                       Descripción
  ----------------------------- -----------------------------------------
  `database_creation.sql`       Script SQL para crear la base de datos y
                                todas las tablas en SQL Server

  `etl_pipeline.py`             Script de Python que extrae datos de
                                archivos CSV, los limpia y los carga en
                                la base de datos

  `verification_queries.sql`    Script SQL con consultas para verificar
                                la carga de datos y realizar análisis
                                básicos

  `requirements.txt`            Archivo de dependencias de Python
                                (recomendado)
  -----------------------------------------------------------------------

## Requisitos

### Software Requerido

-   **SQL Server Developer 2024** (o versión compatible)
-   **Python 3.8** o superior
-   **Microsoft ODBC Driver for SQL Server**

### Librerías de Python

Instala las librerías requeridas usando pip:

``` bash
pip install pandas pyodbc
```

O crea un archivo `requirements.txt` con el siguiente contenido:

    pandas
    pyodbc

Luego instala con:

``` bash
pip install -r requirements.txt
```

## Instalación y Configuración

### Paso 1: Configurar la Base de Datos

1.  Abre SQL Server Management Studio (SSMS) o tu cliente de SQL Server
    preferido
2.  Abre el archivo `database_creation.sql`
3.  Ejecuta el script completo para crear la base de datos
    `SistemaVentas` y todas las tablas

### Paso 2: Preparar los Archivos de Datos (CSV)

Asegúrate de tener los siguientes archivos CSV en la misma carpeta que
`etl_pipeline.py`:

-   `productos.csv`
-   `clientes.csv`
-   `fuentes_datos.csv`
-   `ventas.csv`
-   `encuestas.csv`
-   `comentarios_sociales.csv`
-   `resenas_web.csv`

### Paso 3: Configurar el Script ETL

1.  Abre `etl_pipeline.py` en tu editor de código
2.  Modifica los parámetros de conexión en la clase ETL:

``` python
self.server = 'TU_SERVIDOR'  # Ej: 'localhost\SQLEXPRESS'
self.database = 'SistemaVentas'
self.username = 'tu_usuario'
self.password = 'tu_password'
self.driver = '{ODBC Driver 17 for SQL Server}'
```

### Paso 4: Ejecutar el Pipeline ETL

Abre una terminal, navega hasta la carpeta del proyecto y ejecuta:

``` bash
python etl_pipeline.py
```

El script mostrará el progreso de conexión, lectura, limpieza y carga de
datos.

### Paso 5: Verificar la Carga de Datos

1.  Vuelve a SSMS
2.  Abre `verification_queries.sql`
3.  Ejecuta las consultas para verificar que el proceso ETL fue exitoso

## Arquitectura de la Base de Datos

La base de datos está diseñada de forma relacional para garantizar la
integridad y evitar la redundancia de datos.

  -----------------------------------------------------------------------
  Tabla                       Propósito
  --------------------------- -------------------------------------------
  `productos`                 Almacena la información de los productos

  `clientes`                  Contiene los datos de los clientes que
                              realizan compras

  `fuentes`                   **Tabla central** que cataloga el origen de
                              los datos (ej. Facebook, Amazon)

  `ventas`                    Registra las transacciones de ventas,
                              vinculando clientes, productos y fuentes

  `encuestas`                 Guarda los resultados de encuestas de
                              satisfacción de clientes

  `comentarios`               Almacena comentarios de redes sociales
                              sobre productos

  `resenas`                   Guarda reseñas de productos obtenidas de
                              sitios web
  -----------------------------------------------------------------------

> **Nota:** La tabla `fuentes` es clave, ya que permite que las tablas
> `ventas`, `encuestas`, `comentarios` y `resenas` identifiquen su
> origen a través de una clave foránea (`fuente_id`).

## 📝 Descripción de Scripts

### `database_creation.sql`

**Propósito:** Prepara el entorno de la base de datos - Crea la base de
datos `SistemaVentas` - Define el esquema de las 7 tablas - Utiliza
`IDENTITY(1,1)` para claves primarias autoincrementables - Establece
relaciones de clave foránea entre tablas

### `etl_pipeline.py`

**Propósito:** Automatiza la extracción, transformación y carga de
datos - **Extraer:** Lee datos de múltiples archivos CSV usando
`pandas` - **Transformar:** Realiza limpieza básica, valida formatos y
tipos de datos - **Cargar:** Se conecta a SQL Server usando `pyodbc` e
inserta datos limpios

### `verification_queries.sql`

**Propósito:** Validar el resultado del proceso ETL - Resumen de carga:
cuenta registros en cada tabla - Vista previa: muestra primeros
registros - Análisis simples: ejecuta consultas con `JOIN` y funciones
de agregación

## Estructura de Datos CSV

Los archivos CSV deben tener las siguientes columnas:

  -----------------------------------------------------------------------
  Archivo                           Columnas
  --------------------------------- -------------------------------------
  `productos.csv`                   `id`, `nombre`, `categoria`, `precio`

  `clientes.csv`                    `id`, `nombre`, `email`, `ciudad`

  `fuentes_datos.csv`               `id`, `nombre`, `tipo`

  `ventas.csv`                      `id`, `cliente_id`, `producto_id`,
                                    `fuente_id`, `cantidad`, `total`,
                                    `fecha`

  `encuestas.csv`                   `id`, `cliente_id`, `producto_id`,
                                    `fuente_id`, `calificacion`,
                                    `comentario`

  `comentarios_sociales.csv`        `id`, `producto_id`, `fuente_id`,
                                    `mensaje`, `likes`

  `resenas_web.csv`                 `id`, `producto_id`, `fuente_id`,
                                    `titulo`, `contenido`, `puntuacion`
  -----------------------------------------------------------------------

## Uso del Sistema

1.  **Preparación:** Asegúrate de tener todos los archivos CSV con la
    estructura correcta
2.  **Ejecución:** Ejecuta el pipeline ETL con `python etl_pipeline.py`
3.  **Verificación:** Usa las consultas de verificación para confirmar
    la carga exitosa
4.  **Análisis:** Ejecuta consultas personalizadas para obtener insights
    de los datos

## Diagrama de Entidad-Relación

El diagrama ER muestra las relaciones entre las tablas del sistema. La
tabla `fuentes` actúa como tabla central que normaliza el origen de los
datos para las demás tablas transaccionales.
