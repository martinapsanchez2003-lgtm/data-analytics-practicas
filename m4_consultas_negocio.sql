USE Ventas_Tech_DB
GO

--Consulta 1 — Resumen ejecutivo mensual 
SELECT YEAR(fecha_venta) AS ano,
	   MONTH(fecha_venta) AS mes,
	   SUM(cantidad*precio_unitario) AS total_facturado,
	   COUNT(id_venta) AS cantidad_pedidos,
	   CAST(AVG(cantidad*precio_unitario) AS DECIMAL(10,2))
	     AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY ano, mes;
GO
--Consulta 2 — Ranking de productos Top 5
SELECT TOP 5 id_producto, 
	SUM(cantidad) AS unidades_vendidas,
	SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

--Consulta 3 — Clientes recurrentes 
SELECT id_cliente,
		COUNT(*) AS cantidad_pedidos,
		SUM(cantidad*precio_unitario) AS total_gastado
FROM ventas
WHERE id_cliente IS NOT NULL
GROUP BY id_cliente
HAVING COUNT(*)>1
ORDER BY total_gastado DESC;
GO

--Consulta 4 — Productos por encima/por debajo del promedio
WITH total_producto AS (-- paso 1: total por producto
    SELECT id_producto,
           SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    WHERE id_producto IS NOT NULL
    GROUP BY id_producto)
SELECT
    id_producto,
    total_facturado,
    CASE -- paso 2: comparar con el promedio
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM total_producto)
            THEN 'Por encima' -- paso 3: etiquetar
        ELSE 'Por debajo'
    END AS posicion_vs_promedio
FROM total_producto
ORDER BY total_facturado DESC;
GO

--HALLAZGOS
-- 1) Alta concentración en pocos productos. El producto ID 1 genera
--    el 55,9% de la facturación ($3.600 de $6.444) y, junto con el
--    producto ID 3, 2 de 6 productos suman el 76,8% del total. Son
--    los únicos que quedan "Por encima" del promedio por producto
--    ($1.074).
--
-- 2) Más unidades no significa más facturación, ya que el producto ID 2 es
--    el que más se vendió dentro del ranking (13), pero apenas
--    aporta el 5,65% de la facturación ($364), mientras que el
--    producto ID 1 vendió 3 unidades y factura $3.600.
--
-- 3) Ingresos concentrados en pocos clientes, porque los clientes ID 1 e
--    ID 5 (2 de 5 clientes) concentran el 73,6% de la facturación
--    ($4.740 de $6.444).