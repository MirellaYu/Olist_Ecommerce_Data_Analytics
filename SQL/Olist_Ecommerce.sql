/* ============================================================
   PROYECTO: Olist E-Commerce Analytics
   TIPO: Análisis de Datos con SQL Server

   OBJETIVO:
   Analizar ventas, crecimiento, productos, clientes,
   vendedores, geografía, logística y satisfacción del cliente
   mediante consultas SQL.

   PROCESO:
   1. Definición de claves primarias y foráneas
   2. Validación de relaciones entre tablas
   3. Consultas de análisis de negocio
   4. Obtención de métricas, rankings y variaciones
   5. Preparación de resultados para su posterior
      visualización en Power BI
=============================================================== */

/* ============================================================
        1. CONFIGURACIÓN DEL MODELO RELACIONAL
=============================================================== */
--CLIENTES
ALTER TABLE dbo.[olist_customers_dataset_clean$]
ALTER COLUMN customer_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_customers_dataset_clean$]
ADD CONSTRAINT PK_customers
PRIMARY KEY (customer_id);

--ORDENES
ALTER TABLE dbo.[olist_orders_dataset_clean$]
ALTER COLUMN order_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_orders_dataset_clean$]
ADD CONSTRAINT PK_orders
PRIMARY KEY (order_id);

-- LLAVE FORÁNEA ORDERS → CUSTOMERS
ALTER TABLE dbo.[olist_orders_dataset_clean$]
ADD CONSTRAINT FK_orders_customers
FOREIGN KEY (customer_id)
REFERENCES dbo.[olist_customers_dataset_clean$](customer_id);

--PRODUCTOS
ALTER TABLE dbo.[olist_products_dataset_clean$]
ALTER COLUMN product_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_products_dataset_clean$]
ADD CONSTRAINT PK_products
PRIMARY KEY (product_id);

--VENDEDORES
ALTER TABLE dbo.[olist_sellers_dataset_clean$]
ALTER COLUMN seller_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_sellers_dataset_clean$]
ADD CONSTRAINT PK_sellers
PRIMARY KEY (seller_id);

--DETALLES DE ORDENES
ALTER TABLE dbo.[olist_order_items_dataset_clean$]
ALTER COLUMN order_id NVARCHAR(255) NOT NULL;


ALTER TABLE dbo.[olist_order_items_dataset_clean$]
ALTER COLUMN order_item_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_order_items_dataset_clean$]
ADD CONSTRAINT PK_order_items
PRIMARY KEY (order_id, order_item_id);

-- ORDER_ITEMS → ORDERS
ALTER TABLE dbo.[olist_order_items_dataset_clean$]
ADD CONSTRAINT FK_order_items_orders
FOREIGN KEY (order_id)
REFERENCES dbo.[olist_orders_dataset_clean$](order_id);


-- ORDER_ITEMS → PRODUCTS
ALTER TABLE dbo.[olist_order_items_dataset_clean$]
ADD CONSTRAINT FK_order_items_products
FOREIGN KEY (product_id)
REFERENCES dbo.[olist_products_dataset_clean$](product_id);


-- ORDER_ITEMS → SELLERS
ALTER TABLE dbo.[olist_order_items_dataset_clean$]
ADD CONSTRAINT FK_order_items_sellers
FOREIGN KEY (seller_id)
REFERENCES dbo.[olist_sellers_dataset_clean$](seller_id);

--PAYMENTS
ALTER TABLE dbo.[olist_order_payments_datase_cle$]
ALTER COLUMN order_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_order_payments_datase_cle$]
ALTER COLUMN payment_sequential FLOAT NOT NULL;

ALTER TABLE dbo.[olist_order_payments_datase_cle$]
ADD CONSTRAINT PK_order_payments
PRIMARY KEY (order_id, payment_sequential);

-- PAYMENTS → ORDERS
ALTER TABLE dbo.[olist_order_payments_datase_cle$]
ADD CONSTRAINT FK_order_payments_orders
FOREIGN KEY (order_id)
REFERENCES dbo.[olist_orders_dataset_clean$](order_id);

-- REVIEWS
ALTER TABLE dbo.[olist_order_review_clean$]
ALTER COLUMN review_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_order_review_clean$]
ALTER COLUMN order_id NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.[olist_order_review_clean$]
ADD CONSTRAINT PK_reviews
PRIMARY KEY (review_id, order_id);


-- LLAVE FORÁNEA
ALTER TABLE dbo.[olist_order_review_clean$]
ADD CONSTRAINT FK_reviews_orders
FOREIGN KEY (order_id)
REFERENCES dbo.[olist_orders_dataset_clean$](order_id);


/* ============================================================
                 2. CONSULTAS DE ANÁLISIS
=============================================================== */

--VENTAS Y CRECIMIENTO-----------------------------------
-- Q1.¿Cuántos pedidos se realizaron en total?
SELECT COUNT(DISTINCT order_id) AS "N° Pedidos"
FROM dbo.olist_orders_dataset_clean$;

-- Q2.¿Cuántos pedidos se realizaron por mes y año?
SELECT  YEAR(order_purchase_timestamp) AS Año,
        MONTH(order_purchase_timestamp) AS MES,
        COUNT(order_id) AS "N° Pedidos"
FROM dbo.olist_orders_dataset_clean$
GROUP BY YEAR(order_purchase_timestamp), 
         MONTH(order_purchase_timestamp)
ORDER BY Año,Mes;

-- Q3. ¿Cuál es el ingreso total generado por la venta de productos?
SELECT SUM(price) AS "Ingreso Total"
FROM dbo.olist_order_items_dataset_clean$;

-- Q4. ¿Cómo evolucionan los ingresos por mes y año?
SELECT YEAR(p.order_purchase_timestamp) AS Año,
       MONTH(p.order_purchase_timestamp) AS Mes,
       SUM(d.price) AS Ingreso
FROM dbo.olist_orders_dataset_clean$ AS p
INNER JOIN dbo.olist_order_items_dataset_clean$ AS d
ON p.order_id = d.order_id
GROUP BY YEAR(p.order_purchase_timestamp),  
         MONTH(p.order_purchase_timestamp)
ORDER BY Año,Mes;

-- Q5. ¿Cuál es el ticket promedio por pedido?
SELECT SUM(price) / COUNT(DISTINCT order_id) AS "Ticket Promedio"
FROM dbo.olist_order_items_dataset_clean$;

-- Q6. ¿Cómo evoluciona el ticket promedio por mes y año?
SELECT YEAR(p.order_purchase_timestamp) AS Año,
       MONTH(p.order_purchase_timestamp) AS Mes,
       SUM(d.price) / COUNT(DISTINCT d.order_id) AS "Ticket Promedio"
FROM dbo.olist_orders_dataset_clean$ AS p
INNER JOIN dbo.olist_order_items_dataset_clean$ AS d
ON p.order_id = d.order_id
GROUP BY YEAR(p.order_purchase_timestamp), 
         MONTH(p.order_purchase_timestamp)
ORDER BY Año,Mes;

-- Q7. ¿Cuál fue la variación mensual de los ingresos respecto al mes anterior?
WITH cte_VariacionMensual AS(
     SELECT 
         YEAR(p.order_purchase_timestamp) AS Año,
         MONTH(p.order_purchase_timestamp) AS Mes,
         SUM(d.price) AS Ingreso
     FROM dbo.olist_orders_dataset_clean$ AS p
     INNER JOIN dbo.olist_order_items_dataset_clean$ AS d
     ON p.order_id = d.order_id
     GROUP BY 
         YEAR(p.order_purchase_timestamp),
         MONTH(p.order_purchase_timestamp)
),
cte_Variacion AS (
    SELECT *,
           LAG(Ingreso) OVER(ORDER BY Año, Mes) AS Ingreso_Anterior
    FROM cte_VariacionMensual
)
SELECT 
    Año,
    Mes,
    Ingreso,
    Ingreso_Anterior,
    Ingreso - Ingreso_Anterior AS Variacion_Absoluta,
    ((Ingreso - Ingreso_Anterior) / NULLIF(Ingreso_Anterior, 0)) * 100 
        AS Variacion_Porcentual
FROM cte_Variacion
ORDER BY Año, Mes;

-- Q8. ¿Qué 5 estados concentran la mayor cantidad de pedidos?
SELECT TOP 5
       cli.customer_state,
       COUNT(ord.order_id) AS "N° de pedidos"
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
ON ord.customer_id = cli.customer_id
GROUP BY cli.customer_state
ORDER BY COUNT(ord.order_id) DESC;

-- Q9. ¿Qué 5 estados generan mayores ingresos?
SELECT TOP 5
       cli.customer_state,
       SUM(det.price) AS "Suma de Ingresos"
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
ON ord.customer_id = cli.customer_id
INNER JOIN dbo.olist_order_items_dataset_clean$ AS det
ON ord.order_id = det.order_id
GROUP BY cli.customer_state
ORDER BY SUM(det.price) DESC;

-- Q10. ¿Qué formas de pago concentran mayor cantidad de transacciones?
SELECT payment_type,
       COUNT(payment_type) AS cantidad
FROM dbo.olist_order_payments_datase_cle$
GROUP BY payment_type
ORDER BY COUNT(payment_type) DESC;

--PRODUCTOS Y CATEGORÍAS-------------------------------------
-- Q11.¿Cuáles son las 5 categorías con mayor volumen de productos vendidos?
SELECT TOP 5
       pro.product_category_name AS Categoria,
       COUNT(ord.product_id) AS Cantidad
FROM dbo.olist_order_items_dataset_clean$ AS ord
INNER JOIN dbo.olist_products_dataset_clean$ AS pro
ON ord.product_id = pro.product_id
GROUP BY pro.product_category_name
ORDER BY COUNT(ord.product_id) DESC;

-- Q12. ¿Cuáles son las 5 categorías que generan mayores ingresos?
SELECT TOP 5
       pro.product_category_name AS Categoria,
       SUM(ord.price) AS Suma
FROM dbo.olist_order_items_dataset_clean$ AS ord
INNER JOIN dbo.olist_products_dataset_clean$ AS pro
ON ord.product_id = pro.product_id
GROUP BY pro.product_category_name
ORDER BY SUM(ord.price) DESC;

-- Q13. ¿Qué 5 categorías tienen mayor participación en los ingresos?
SELECT TOP 5
       Categorias.product_category_name AS Categoria,
       Categorias.Ingresos,
       (Categorias.Ingresos/ 
              (SELECT SUM(price)
               FROM dbo.olist_order_items_dataset_clean$)
       ) * 100 AS Participacion
FROM( SELECT pro.product_category_name,
             SUM(ord.price) AS Ingresos
      FROM dbo.olist_order_items_dataset_clean$ AS ord
      INNER JOIN dbo.olist_products_dataset_clean$ AS pro
      ON ord.product_id = pro.product_id
      GROUP BY pro.product_category_name
      
) AS Categorias
ORDER BY Categorias.Ingresos DESC;

-- Q14. ¿Cuáles son las 3 principales categorías por ingresos de cada mes?
WITH cte_PIngresos AS(
     SELECT YEAR(ord.order_purchase_timestamp) AS Año,
       MONTH(ord.order_purchase_timestamp) AS Mes,
       pro.product_category_name AS Categoria,
       SUM(det.price) AS Ingreso
     FROM dbo.olist_orders_dataset_clean$ AS ord
     INNER JOIN dbo.olist_order_items_dataset_clean$ AS det
     ON ord.order_id = det.order_id
     INNER JOIN dbo.olist_products_dataset_clean$ AS pro
     ON det.product_id = pro.product_id
     GROUP BY YEAR(ord.order_purchase_timestamp),
              MONTH(ord.order_purchase_timestamp),
              pro.product_category_name
),
cte_Ranking AS(
     SELECT *,
            RANK() OVER(PARTITION BY Año, Mes ORDER BY INGRESO DESC) AS Ranking
     FROM cte_PIngresos
)
SELECT *
FROM cte_Ranking
WHERE Ranking <= 3
ORDER BY Año,Mes;

--CLIENTES-------------------------------------
-- Q15. ¿Cuántos clientes únicos realizaron compras?
SELECT COUNT(DISTINCT c.customer_unique_id) AS Cantidad
FROM dbo.olist_orders_dataset_clean$ AS o
INNER JOIN dbo.olist_customers_dataset_clean$ AS c
    ON o.customer_id = c.customer_id;

-- Q16. ¿Cuántos clientes nuevos hubo por mes?
WITH cte_PrimeraCompra AS(
     SELECT 
           c.customer_unique_id,
           MIN(o.order_purchase_timestamp) AS PrimeraCompra
     FROM dbo.olist_orders_dataset_clean$ AS o
     INNER JOIN dbo.olist_customers_dataset_clean$ c
     ON o.customer_id = c.customer_id
     GROUP BY customer_unique_id
)
SELECT YEAR(PrimeraCompra) AS Año,
       MONTH(PrimeraCompra) AS Mes,
       COUNT(customer_unique_id) AS "Clientes Nuevos"
FROM cte_PrimeraCompra
GROUP BY
    YEAR(PrimeraCompra),
    MONTH(PrimeraCompra)
ORDER BY Año, Mes;

-- Q17. ¿Cuántos clientes realizaron una sola compra?
SELECT COUNT(*) AS "Clientes con una sola compra"
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS CantidadPedidos
    FROM dbo.olist_orders_dataset_clean$ o
    INNER JOIN dbo.olist_customers_dataset_clean$ c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) = 1
) AS ClientesUnaCompra;

-- Q18. ¿Cuántos clientes son recurrentes?
SELECT COUNT(*) AS "Clientes recurrentes"
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS CantidadPedidos
    FROM dbo.olist_orders_dataset_clean$ o
    INNER JOIN dbo.olist_customers_dataset_clean$ c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
) AS ClientesRecurrentes;

-- Q19. ¿Cómo se distribuyen los clientes según su gasto?
WITH cte_GastoClientes AS (
    SELECT 
        c.customer_unique_id,
        SUM(det.price) AS GastoTotal
    FROM dbo.olist_orders_dataset_clean$ AS ord
    INNER JOIN dbo.olist_customers_dataset_clean$ AS c
        ON ord.customer_id = c.customer_id
    INNER JOIN dbo.olist_order_items_dataset_clean$ AS det
        ON ord.order_id = det.order_id
    GROUP BY c.customer_unique_id
),
cte_Percentiles AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY GastoTotal)
            OVER () AS P25,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY GastoTotal)
            OVER () AS P75
    FROM cte_GastoClientes
),
cte_Segmentacion AS (
    SELECT
        g.customer_unique_id,
        g.GastoTotal,
        p.P25,
        p.P75,
        CASE
            WHEN g.GastoTotal <= p.P25 THEN 'Bajo'
            WHEN g.GastoTotal <= p.P75 THEN 'Medio'
            ELSE 'Alto'
        END AS Segmento
    FROM cte_GastoClientes AS g
    CROSS JOIN cte_Percentiles AS p
)
SELECT
    Segmento,
    COUNT(*) AS Cantidad,
    MIN(GastoTotal) AS Gasto_Minimo,
    MAX(GastoTotal) AS Gasto_Maximo
FROM cte_Segmentacion
GROUP BY Segmento
ORDER BY
    CASE Segmento
        WHEN 'Bajo' THEN 1
        WHEN 'Medio' THEN 2
        WHEN 'Alto' THEN 3
    END;
--VENDEDORES-------------------------------------
-- Q20. ¿Cuántos vendedores realizaron ventas?
SELECT COUNT(DISTINCT seller_id) AS "N° Vendedores"
FROM dbo.olist_order_items_dataset_clean$;

-- Q21. ¿Cuáles son los 10 vendedores que generan mayores ingresos?
SELECT TOP 10
       ven.seller_id,
       ven.seller_city AS Ciudad,
       ven.seller_state AS Estado,
       SUM(ord.price) AS Ingreso
FROM dbo.olist_order_items_dataset_clean$ AS ord
INNER JOIN dbo.olist_sellers_dataset_clean$ AS ven
ON ord.seller_id = ven.seller_id
GROUP BY ven.seller_id, 
         ven.seller_city, 
         ven.seller_state
ORDER BY SUM(ord.price) DESC;

-- Q22. ¿Qué 5 vendedores tienen mayor cantidad de pedidos?
SELECT TOP 5
       ven.seller_id,
       ven.seller_city AS Ciudad,
       ven.seller_state AS Estado,
       COUNT(DISTINCT ord.order_id) AS Cantidad
FROM dbo.olist_order_items_dataset_clean$ AS ord
INNER JOIN dbo.olist_sellers_dataset_clean$ AS ven
ON ord.seller_id = ven.seller_id
GROUP BY ven.seller_id, 
         ven.seller_city, 
         ven.seller_state
ORDER BY COUNT(DISTINCT ord.order_id) DESC;

-- Q23. ¿Qué porcentaje de los ingresos totales generan los 5 principales vendedores?
WITH cte_IngresosPorVendedor AS(
     SELECT ven.seller_id,
            ven.seller_city AS Ciudad,
            ven.seller_state AS Estado,
            SUM(ord.price) AS Ingreso
     FROM dbo.olist_order_items_dataset_clean$ AS ord
     INNER JOIN dbo.olist_sellers_dataset_clean$ AS ven
     ON ord.seller_id = ven.seller_id
     GROUP BY ven.seller_id, 
              ven.seller_city, 
              ven.seller_state
)
SELECT TOP 5
       *,
       Ingreso /
       (SELECT SUM(price) AS TOTAL
        FROM dbo.olist_order_items_dataset_clean$ )*100 AS Porcentaje
FROM cte_IngresosPorVendedor
ORDER BY Porcentaje DESC;

------------GEOGRAFÍA--------------------------------------------
-- Q24. ¿Los 5 estados que concentran mayor cantidad de clientes?
SELECT  TOP 5
        customer_state AS Estados,
        COUNT(DISTINCT customer_unique_id) AS Cantidad
FROM dbo.olist_customers_dataset_clean$
GROUP BY customer_state
ORDER BY Cantidad DESC;

-- Q25. ¿Los 5 estados que concentran mayor cantidad de pedidos e ingresos?
SELECT TOP 5
       cli.customer_state AS Estados,
       COUNT(DISTINCT ord.order_id) AS Cantidad,
       SUM(det.price) AS Ingresos
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
ON ord.customer_id = cli.customer_id
INNER JOIN dbo.olist_order_items_dataset_clean$ AS det
ON ord.order_id = det.order_id
GROUP BY cli.customer_state
ORDER BY Cantidad DESC, Ingresos DESC;

-- Q26. ¿Qué estados concentran mayor cantidad de vendedores?
SELECT  TOP 5
        seller_state AS Estados,
        COUNT(seller_id) AS Cantidad
FROM dbo.olist_sellers_dataset_clean$
GROUP BY seller_state
ORDER BY COUNT(seller_id) DESC;

-- Q27. ¿Qué estados presentan alta demanda frente a una baja oferta de vendedores?
WITH cte_PedidosEstado AS(
       SELECT cli.customer_state AS Estado,
              COUNT(DISTINCT ord.order_id) AS "N° Pedidos"
              
       FROM dbo.olist_orders_dataset_clean$ AS ord
       INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
       ON ord.customer_id = cli.customer_id 
       GROUP BY cli.customer_state
),
cte_VendedoresEstado AS(
       SELECT ven.seller_state AS Estado,
              COUNT(DISTINCT det.seller_id) AS "N° Vendedores"
       FROM dbo.olist_order_items_dataset_clean$ AS det
       INNER JOIN dbo.olist_sellers_dataset_clean$ AS ven
       ON det.seller_id = ven.seller_id
       GROUP BY ven.seller_state
)
SELECT Es_pe.Estado,
       "N° Pedidos",
       "N° Vendedores",
       CAST("N° Pedidos" AS DECIMAL(10,2)) / "N° Vendedores" AS Demanda_por_vendedor
FROM cte_PedidosEstado AS Es_pe
INNER JOIN cte_VendedoresEstado AS Es_ven
ON Es_pe.Estado = Es_ven.Estado
ORDER BY Demanda_por_vendedor DESC;

------------LOGÍSTICA Y OPERACIONES---------------------------
-- Q28. ¿Cuál es el tiempo promedio de entrega de los pedidos entregados?
SELECT AVG(DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date)
          ) AS "Tiempo Promedio de Entrega (días)"
FROM dbo.olist_orders_dataset_clean$;

-- Q29. ¿Qué porcentaje de los pedidos entregados presentó retraso respecto a la fecha estimada?
SELECT *,
       CAST(Entrega_Tarde AS DECIMAL(10,2)) 
       / NULLIF(Pedidos_Entregados, 0) * 100 AS Porcentaje
FROM (
    SELECT
        SUM(
            CASE
                WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) AS Entrega_Tarde,

        COUNT(order_delivered_customer_date) AS Pedidos_Entregados
    FROM dbo.olist_orders_dataset_clean$
    WHERE order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
) AS Entregas;

-- Q30. ¿Cuántos días de retraso tienen en promedio los pedidos tardíos?
SELECT AVG(DATEDIFF(
                DAY, 
                order_estimated_delivery_date, 
                order_delivered_customer_date)) AS Promedio
FROM dbo.olist_orders_dataset_clean$
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- Q31. ¿Qué 5 estados presentan el mayor tiempo promedio de entrega?
SELECT TOP 5
       cli.customer_state AS Estado,
       AVG(DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date)) AS Promedio_Entrega_Tiempo
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
ON ord.customer_id = cli.customer_id
GROUP BY cli.customer_state
ORDER BY Promedio_Entrega_Tiempo DESC;

-- Q32. ¿Cuál es el tiempo promedio de entrega de los pedidos asociados a cada vendedor?
WITH cte_PedidoVendedor AS(
    SELECT DISTINCT
           det.seller_id,
           det.order_id,
           DATEDIFF(
               DAY,
               ord.order_purchase_timestamp,
               ord.order_delivered_customer_date
           ) AS TiempoEntrega
    FROM dbo.olist_order_items_dataset_clean$ AS det
    INNER JOIN dbo.olist_orders_dataset_clean$ AS ord
        ON det.order_id = ord.order_id
    WHERE ord.order_purchase_timestamp IS NOT NULL
      AND ord.order_delivered_customer_date IS NOT NULL
)
SELECT TOP 5
       seller_id,
       AVG(TiempoEntrega) AS Tiempo_Promedio_Entrega
FROM cte_PedidoVendedor
GROUP BY seller_id
ORDER BY Tiempo_Promedio_Entrega DESC;

-- Q33. ¿Cuál es la cantidad y porcentaje de pedidos según su estado?
SELECT *,
       (CAST(EstadosPedidos.Cantidad AS DECIMAL(10,2)) / (
                   SELECT COUNT(*) AS Cantidad
                   FROM dbo.olist_orders_dataset_clean$
                   )) * 100 AS Porcentaje
FROM (SELECT order_status AS Estado,
             COUNT(*) AS Cantidad
      FROM dbo.olist_orders_dataset_clean$
      GROUP BY order_status) AS EstadosPedidos
ORDER BY Cantidad DESC;

-- Q34. ¿Cómo evolucionan las cancelaciones de pedidos a lo largo del tiempo?
WITH cte_Cancelados AS(
       SELECT YEAR(order_purchase_timestamp) AS Año,
              MONTH(order_purchase_timestamp) AS Mes,
              COUNT(order_id) AS Cancelados
       FROM dbo.olist_orders_dataset_clean$
       WHERE order_status = 'Canceled'
       GROUP BY YEAR(order_purchase_timestamp),
                MONTH(order_purchase_timestamp)
),
cte_Totales AS(
       SELECT YEAR(order_purchase_timestamp) AS Año,
              MONTH(order_purchase_timestamp) AS Mes,
              COUNT(order_id) AS TotalPedidos
       FROM dbo.olist_orders_dataset_clean$
       GROUP BY YEAR(order_purchase_timestamp),
                MONTH(order_purchase_timestamp)
)
SELECT
    C.Año,
    C.Mes,
    C.Cancelados,
    T.TotalPedidos,
    CAST(C.Cancelados AS DECIMAL(10,2))
        / T.TotalPedidos * 100 AS Porcentaje_Cancelacion
FROM cte_Cancelados AS C
INNER JOIN cte_Totales AS T
    ON C.Año = T.Año
    AND C.Mes = T.Mes
ORDER BY
    C.Año,
    C.Mes;

------------CALIDAD Y SATISFACCIÓN---------------------------
-- Q35. ¿Cuál es la puntuación promedio de las reviews?
SELECT AVG(review_score) AS Promedio
FROM dbo.olist_order_review_clean$;

-- Q36. ¿Cómo se distribuyen las puntuaciones de 1 a 5?
SELECT review_score AS Puntuacion, 
       COUNT(review_score) AS Cantidad
FROM dbo.olist_order_review_clean$
GROUP BY review_score
ORDER BY review_score;

-- Q37. ¿Cuáles son las 5 categorías asociadas a los pedidos con mejores valoraciones?
SELECT TOP 5
       pro.product_category_name AS Nombre,
       AVG(res.review_score) AS Promedio
FROM dbo.olist_order_items_dataset_clean$ AS det
INNER JOIN dbo.olist_products_dataset_clean$ AS pro
ON det.product_id = pro.product_id
INNER JOIN dbo.olist_order_review_clean$ AS res
ON det.order_id = res.order_id
GROUP BY pro.product_category_name
ORDER BY Promedio DESC;

-- Q38. ¿Cuáles son las 5 categorías asociadas a los pedidos con peores valoraciones?
SELECT TOP 5
       pro.product_category_name AS Nombre,
       AVG(  res.review_score) AS Promedio
FROM dbo.olist_order_items_dataset_clean$ AS det
INNER JOIN dbo.olist_products_dataset_clean$ AS pro
ON det.product_id = pro.product_id
INNER JOIN dbo.olist_order_review_clean$ AS res
ON det.order_id = res.order_id
GROUP BY pro.product_category_name
ORDER BY Promedio ASC;

-- Q39. ¿Cómo varía la puntuación promedio de las reseñas según el estado de entrega del pedido?
WITH cte_Retrasos AS(
     SELECT CASE
                WHEN order_delivered_customer_date > order_estimated_delivery_date 
                     THEN 'Tarde'
                ELSE 'A Tiempo'
            END AS EstadoEntrega,
            res.review_score
     FROM dbo.olist_orders_dataset_clean$ AS ord 
     INNER JOIN dbo.olist_order_review_clean$ AS res
     ON ord.order_id = res.order_id
     WHERE order_delivered_customer_date IS NOT NULL
     AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    EstadoEntrega,
    AVG(review_score) AS Promedio
FROM cte_Retrasos
GROUP BY EstadoEntrega;
