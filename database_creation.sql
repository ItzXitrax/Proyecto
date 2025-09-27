-- Sistema de Análisis de Ventas 
-- Creación de Base de Datos y Tablas

-- Crear y usar la base de datos
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SistemaVentas')
BEGIN
    CREATE DATABASE SistemaVentas;
END
GO

USE SistemaVentas;
GO

-- Tabla de Productos
CREATE TABLE productos (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(8,2) NOT NULL
);

-- Tabla de Clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50)
);

-- Tabla de Fuentes de Datos 
CREATE TABLE fuentes (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL, -- Ej: 'Facebook', 'Amazon', 'Tienda Física', 'Encuesta de Satisfacción'
    tipo VARCHAR(30) NOT NULL -- Ej: 'Red Social', 'Reseña Web', 'Punto de Venta', 'Encuesta'
);

-- Tabla de Ventas 
CREATE TABLE ventas (
    id INT PRIMARY KEY IDENTITY(1,1),
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    fuente_id INT NOT NULL, 
    cantidad INT NOT NULL,
    total DECIMAL(8,2) NOT NULL,
    fecha DATE NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (fuente_id) REFERENCES fuentes(id) 
);

-- Tabla de Encuestas 
CREATE TABLE encuestas (
    id INT PRIMARY KEY IDENTITY(1,1),
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    fuente_id INT NOT NULL, 
    calificacion INT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario NVARCHAR(MAX),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (fuente_id) REFERENCES fuentes(id) 
);

-- Tabla de Comentarios Sociales 
CREATE TABLE comentarios (
    id INT PRIMARY KEY IDENTITY(1,1),
    producto_id INT NOT NULL,
    fuente_id INT NOT NULL, 
    mensaje NVARCHAR(MAX) NOT NULL,
    likes INT DEFAULT 0,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (fuente_id) REFERENCES fuentes(id)
);

-- Tabla de Reseñas Web 
CREATE TABLE resenas (
    id INT PRIMARY KEY IDENTITY(1,1),
    producto_id INT NOT NULL,
    fuente_id INT NOT NULL, -- Reemplaza a 'sitio'
    titulo VARCHAR(100),
    contenido NVARCHAR(MAX) NOT NULL,
    puntuacion DECIMAL(2,1) CHECK (puntuacion BETWEEN 1.0 AND 5.0),
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (fuente_id) REFERENCES fuentes(id) 
);

-- Ver las tablas creadas
SELECT name FROM sys.tables;
GO


-- 1. Primero, poblamos la tabla de fuentes
INSERT INTO fuentes (nombre, tipo) VALUES
('Tienda Física A', 'Punto de Venta'),
('Sitio Web Oficial', 'E-commerce'),
('Facebook', 'Red Social'),
('Twitter', 'Red Social'),
('Encuesta Post-Venta Email', 'Encuesta'),
('Amazon', 'Reseña Web');

