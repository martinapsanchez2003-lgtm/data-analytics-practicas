USE Ventas_Tech_DB
GO
-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Propósito: una fila por venta con cliente, región, producto y categoría.
SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS cliente,
    r.nombre_region AS region,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario  AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
INNER JOIN regiones r ON c.id_region = r.id_region

ORDER BY v.fecha_venta DESC;

-- Hallazgo: la vista devuelve las 10 ventas con todos sus datos descriptivos y suma 6.444 en total.
-- La región Centro concentra cerca del 60% de lo facturado y Computación más del 75%.


--Consulta 2 — Clientes sin ventas (LEFT JOIN) 
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro DESC;

-- Hallazgo: 2 de los 7 clientes registrados nunca compraron y ambos se registraron en la segunda mitad de marzo


--Consulta 3 — Productos sin ventas (LEFT JOIN) 
-- Propósito: identificar artículos del catálogo sin ventas
SELECT
    p.nombre_producto,
    p.id_categoria,
    cat.nombre_categoria,
    p.precio
FROM productos p
LEFT JOIN ventas v ON p.id_producto = v.id_producto
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL
ORDER BY cat.nombre_categoria, p.nombre_producto;

-- Hallazgo: 2 de los 8 productos del catálogo no tienen ventas (Webcam HD y Pendrive 64GB), ambos de bajo precio.

--Consulta 4 — Consolidado por canal (UNION ALL)
--Propósito: comparar lo vendido por canal.
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Presencial' AS canal
    FROM ventas v
    INNER JOIN clientes c ON v.id_cliente = c.id_cliente
    WHERE c.id_region = 1
    UNION ALL
    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Online' AS canal
    FROM ventas v
    INNER JOIN clientes c ON v.id_cliente = c.id_cliente
    WHERE c.id_region <> 1
) AS consolidado
GROUP BY canal;

-- Hallazgo: el canal Presencial factura 3.834 (cerca del 60% del total) y el Online 2.610; con el
-- supuesto usado, el canal Online ya aporta cerca del 40% y es el que llega a Cuyo y Noroeste.