-- Consultas de Verificación - Sistema de Ventas Simplificado 
USE SistemaVentas;
GO

-- ============================================
-- CONTAR REGISTROS EN CADA TABLA
-- ============================================
PRINT '============================================';
PRINT 'RESUMEN DE REGISTROS CARGADOS';
PRINT '============================================';

SELECT 'productos' as tabla, COUNT(*) as registros FROM productos
UNION ALL
SELECT 'clientes' as tabla, COUNT(*) as registros FROM clientes
UNION ALL
SELECT 'fuentes' as tabla, COUNT(*) as registros FROM fuentes
UNION ALL
SELECT 'ventas' as tabla, COUNT(*) as registros FROM ventas
UNION ALL
SELECT 'encuestas' as tabla, COUNT(*) as registros FROM encuestas
UNION ALL
SELECT 'comentarios' as tabla, COUNT(*) as registros FROM comentarios
UNION ALL
SELECT 'resenas' as tabla, COUNT(*) as registros FROM resenas;
GO

-- ============================================
-- VER PRIMEROS REGISTROS DE CADA TABLA
-- ============================================

PRINT CHAR(10); -- Agrega una línea en blanco para separar
PRINT '========== PRODUCTOS ==========';
SELECT * FROM productos;
GO

PRINT CHAR(10);
PRINT '========== CLIENTES ===========';
SELECT * FROM clientes;
GO

PRINT CHAR(10);
PRINT '========== FUENTES ===========';
SELECT * FROM fuentes;
GO

PRINT CHAR(10);
PRINT '========== VENTAS =============';
SELECT * FROM ventas;
GO

PRINT CHAR(10);
PRINT '========== ENCUESTAS =========';
SELECT * FROM encuestas;
GO

PRINT CHAR(10);
PRINT '========== COMENTARIOS =======';
SELECT * FROM comentarios;
GO

PRINT CHAR(10);
PRINT '========== RESEÑAS ===========';
SELECT * FROM resenas;
GO

-- ============================================
-- ANÁLISIS SIMPLES
-- ============================================

PRINT CHAR(10);
PRINT '===== PRODUCTOS POR CATEGORÍA =====';
SELECT categoria, COUNT(*) as total, AVG(precio) as precio_promedio
FROM productos 
GROUP BY categoria;
GO

PRINT CHAR(10);
PRINT '======= VENTAS POR CLIENTE =======';
SELECT c.nombre, COUNT(v.id) as total_compras, SUM(v.total) as gasto_total
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre
ORDER BY gasto_total DESC;
GO

PRINT CHAR(10);
PRINT '==== CALIFICACIÓN POR PRODUCTO ====';
SELECT 
    p.nombre, 
    AVG(CAST(e.calificacion AS DECIMAL(3,1))) as calificacion_promedio -- CORREGIDO: Casting para obtener decimales
FROM productos p
LEFT JOIN encuestas e ON p.id = e.producto_id
GROUP BY p.id, p.nombre
HAVING AVG(e.calificacion) IS NOT NULL
ORDER BY calificacion_promedio DESC;
GO

PRINT CHAR(10);
PRINT '==== COMENTARIOS POR FUENTE (Plataforma) ====';
-- CORREGIDO: La columna "plataforma" ya no existe, ahora se une con la tabla "fuentes"
SELECT 
    f.nombre as fuente, 
    COUNT(c.id) as total_comentarios, 
    SUM(c.likes) as total_likes
FROM comentarios c
JOIN fuentes f ON c.fuente_id = f.id
WHERE f.tipo = 'Red Social' -- Opcional: para filtrar solo las fuentes que son redes sociales
GROUP BY f.nombre
ORDER BY total_comentarios DESC;
GO