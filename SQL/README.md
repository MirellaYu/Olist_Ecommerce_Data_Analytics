# 📊 Resultados y Hallazgos del Análisis SQL

## Q1. ¿Cuántos pedidos se realizaron?

```sql
SELECT COUNT(DISTINCT order_id) AS "N° Pedidos"
FROM dbo.olist_orders_dataset_clean$;
```
**Hallazgos:** La cantidad de pedidos que se realizaron es de **99,441 pedidos**, lo que establece el volumen total de operaciones.

## Q2.¿Cuántos pedidos se realizaron por mes y año?

```sql
SELECT  YEAR(order_purchase_timestamp) AS Año,
        MONTH(order_purchase_timestamp) AS MES,
        COUNT(order_id) AS "N° Pedidos"
FROM dbo.olist_orders_dataset_clean$
GROUP BY YEAR(order_purchase_timestamp), 
         MONTH(order_purchase_timestamp)
ORDER BY Año,Mes;
```
**Hallazgo:** El volumen de pedidos muestra un crecimiento marcado desde 2017, alcanzando su máximo en **noviembre de 2017** con **7,544 pedidos**. Durante **2018**, el volumen se mantiene en niveles elevados, generalmente por encima de **6,000 pedidos** mensuales hasta agosto.

**Insight:** La evolución evidencia una expansión significativa del volumen de pedidos entre **2017 y 2018**, alcanzando niveles superiores a los registrados durante 2017 en varios meses de 2018. Los valores excepcionalmente bajos de septiembre y octubre de 2018 deben considerarse como posibles datos incompletos o atípicos antes de utilizarlos para interpretar la tendencia final del período.

## Q3. ¿Cuál es el ingreso total generado por la venta de productos?

```sql
SELECT SUM(price) AS "Ingreso Total"
FROM dbo.olist_order_items_dataset_clean$;
```
**Hallazgos:** Se generaron **$13.59 millones** en ingresos por la venta de productos durante el período analizado (2016 al 2018).

## Q4. ¿Cómo evolucionan los ingresos por mes y año?

```sql
SELECT YEAR(p.order_purchase_timestamp) AS Año,
       MONTH(p.order_purchase_timestamp) AS Mes,
       SUM(d.price) AS Ingreso
FROM dbo.olist_orders_dataset_clean$ AS p
INNER JOIN dbo.olist_order_items_dataset_clean$ AS d
ON p.order_id = d.order_id
GROUP BY YEAR(p.order_purchase_timestamp),  
         MONTH(p.order_purchase_timestamp)
ORDER BY Año,Mes;
```
**Hallazgos:** Los ingresos aumentan significativamente desde 2017 y presentan fluctuaciones mensuales durante 2017 y 2018. Alcanzando su punto máximo en noviembre de 2017 con **$1.01 millones**. En 2018, los ingresos se mantienen cercanos al millón de dólares entre marzo y mayo, antes de presentar una disminución en los meses siguientes.

**Insight:** El comportamiento mensual evidencia un crecimiento importante del nivel de ingresos respecto a los primeros registros de 2016, aunque con períodos alternados de crecimiento y contracción. Los ingresos de septiembre de 2018 con **$145** presentan una caída excepcional frente a agosto con **$854,686.33**, por lo que este último registro debe validarse antes de utilizarlo para interpretar la tendencia final del período.

## Q5. ¿Cuál es el ticket promedio por pedido?

```sql
SELECT SUM(price) / COUNT(DISTINCT order_id) AS "Ticket Promedio"
FROM dbo.olist_order_items_dataset_clean$;
```
**Hallazgos:** El ticket promedio por pedido es de **$137.75**, lo que significa el valor promedio generado por cada pedido.

## Q6. ¿Cómo evoluciona el ticket promedio por mes y año?

```sql
SELECT YEAR(p.order_purchase_timestamp) AS Año,
       MONTH(p.order_purchase_timestamp) AS Mes,
       SUM(d.price) / COUNT(DISTINCT d.order_id) AS "Ticket Promedio"
FROM dbo.olist_orders_dataset_clean$ AS p
INNER JOIN dbo.olist_order_items_dataset_clean$ AS d
ON p.order_id = d.order_id
GROUP BY YEAR(p.order_purchase_timestamp), 
         MONTH(p.order_purchase_timestamp)
ORDER BY Año,Mes;
```
**Hallazgos:** El ticket promedio se mantuvo relativamente estable durante **2017 y 2018**, oscilando principalmente entre **$125 y $152**. El valor más alto de este período se registró en **Enero de 2017 con $152.49**, mientras que el menor fue en **Julio de 2017 con $125.48**.

**Insight:** El comportamiento del ticket promedio muestra una **variación moderada** en el valor de compra por pedido, sin una tendencia sostenida de crecimiento o disminución durante 2017 y 2018.

## Q7. ¿Cuál fue la variación mensual de los ingresos respecto al mes anterior?

```sql
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
```
**Hallazgos:** Los ingresos presentan fluctuaciones mensuales a lo largo del período analizado. En 2017, el **mayor incremento absoluto** se registró en **noviembre** con **(+$346,051.94; +52.10%)**, mientras que en **diciembre** se produjo una contracción de **26.36%**. En 2018 se mantienen variaciones alternadas, con un **crecimiento de 16.47% en marzo** y una **caída de 13.19% en junio**.

**Insight:** La evolución mensual evidencia un comportamiento variable de los ingresos, con períodos consecutivos de crecimiento y contracción. El crecimiento porcentual excepcional de enero de 2017 (+1,103,687.8%) debe interpretarse con cautela, debido al bajo nivel de ingresos registrado en diciembre de 2016 ($10.90), que genera una base de comparación atípica.

## Q8. ¿Qué 5 estados concentran la mayor cantidad de pedidos?

```sql
SELECT TOP 5
       cli.customer_state,
       COUNT(ord.order_id) AS "N° de pedidos"
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
ON ord.customer_id = cli.customer_id
GROUP BY cli.customer_state
ORDER BY COUNT(ord.order_id) DESC;
```
| customer_state | N° de pedidos |
| -------------- | ------------: |
| SP             |        41,746 |
| RJ             |        12,852 |
| MG             |        11,635 |
| RS             |         5,466 |
| PR             |         5,045 |

**Hallazgos:** Los pedidos se concentran principalmente en **Sao Paulo (SP)**, con **41,746 pedidos**, seguidos por **Río de Janeiro (RJ)**, **Minas Gerais (MG)**, **Rio Grande do Sul (RS)** y **Paraná (PR)**, evidenciando una fuerte concentración de la demanda en estos cinco estados.

**Insight:** São Paulo concentra una proporción claramente superior de los pedidos frente a los demás estados del top 5, posicionándose como el principal mercado geográfico por volumen de pedidos dentro del conjunto analizado.

## Q9. ¿Cuáles son los 5 estados que generan mayores ingresos?

```sql
SELECT TOP 5
       cli.customer_state,
       SUM(pay.payment_value) AS "Ingresos"
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
    ON ord.customer_id = cli.customer_id
INNER JOIN dbo.olist_order_payments_datase_cle$ AS pay
    ON ord.order_id = pay.order_id
GROUP BY cli.customer_state
ORDER BY SUM(pay.payment_value) DESC;
```
| customer_state |      Ingresos |
| -------------- | ------------: |
| SP             | $5,998,226.96 |
| RJ             | $2,144,379.69 |
| MG             | $1,872,257.26 |
| RS             |   $890,898.54 |
| PR             |   $811,156.38 |

**Hallazgos:** Los ingresos se concentran principalmente en **Sao Paulo (SP)** con aproximadamente **$6.0 millones**, seguido por **Río de Janeiro (RJ)** y **Minas Gerias (MG)**. Los cinco estados concentran una parte importante del valor total de pagos registrados.

**Insight:** São Paulo concentra el mayor valor de pagos entre los estados analizados, superando ampliamente al resto de estados del top 5 y constituyendo el principal mercado geográfico por ingresos dentro del conjunto de datos.

## Q10. ¿Qué formas de pago concentran mayor cantidad de transacciones?

```sql
SELECT payment_type,
       COUNT(payment_type) AS cantidad
FROM dbo.olist_order_payments_datase_cle$
GROUP BY payment_type
ORDER BY COUNT(payment_type) DESC;
```
| payment_type   | Cantidad |
| -------------- | -------: |
| Credit Card    | 76795    |
| Boleto         | 19784    |
| Voucher        | 5775     |
| Debit Card     | 1529     |
| Not Defined    | 3        |

**Hallazgos:** Las transacciones se concentran principalmente en **Tarjetas de Crédito**, con **76,795 registros**, seguidas por **Boleto** con 19,784. Las demás formas de pago presentan una participación considerablemente menor.

**Insight:** El pago con tarjeta de crédito constituye el principal medio utilizado en las transacciones analizadas, mostrando una clara concentración del comportamiento de pago hacia este método.

## Q11. ¿Cuáles son las 5 categorías con mayor volumen de productos vendidos?

```sql
SELECT TOP 5
       pro.product_category_name AS Categoria,
       COUNT( ord.product_id) AS Productos_Vendidos
FROM dbo.olist_order_items_dataset_clean$ AS ord
INNER JOIN dbo.olist_products_dataset_clean$ AS pro
ON ord.product_id = pro.product_id
GROUP BY pro.product_category_name
ORDER BY Productos_Vendidos DESC;
```
| Ranking | Categoría              | Productos vendidos |
| ------: | ---------------------- | -----------------: |
|       1 | Cama Mesa Banho        |             11,115 |
|       2 | Beleza Saude           |              9,670 |
|       3 | Esporte Lazer          |              8,641 |
|       4 | Moveis Decoracao       |              8,334 |
|       5 | Informatica Acessorios |              7,827 |

**Hallazgos:** **Cama, Mesa y Baño** lidera el volumen de productos vendidos con **11,115 unidades**, seguida por **Belleza y Salud** con **9,970** y **Deporte y ocio** con **8,641**.

**Insight:** **Cama, Mesa y Baño concentra el mayor volumen de productos comercializados**, por lo que representa una categoría relevante para monitorear su comportamiento y evolución.

## Q12. ¿Cuáles son las 5 categorías con mayor cantidad de pedidos?

```sql
SELECT TOP 5
       pro.product_category_name AS Categoria,
       COUNT(DISTINCT ord.order_id) AS "Cantidad de pedidos"
FROM dbo.olist_order_items_dataset_clean$ AS ord
INNER JOIN dbo.olist_products_dataset_clean$ AS pro
    ON ord.product_id = pro.product_id
GROUP BY pro.product_category_name
ORDER BY COUNT(DISTINCT ord.order_id) DESC;
```
| Ranking | Categoría              | Cantidad de pedidos |
| ------: | ---------------------- | ------------------: |
|       1 | Cama Mesa Banho        |           **9,417** |
|       2 | Beleza Saude           |           **8,836** |
|       3 | Esporte Lazer          |           **7,720** |
|       4 | Informatica Acessorios |           **6,689** |
|       5 | Moveis Decoracao       |           **6,449** |

**Hallazgos:** **Cama, Mesa y Baño** registra la mayor cantidad de pedidos, con **9,417**, seguida de **Belleza y Salud** con **8,836** y **Deporte y ocio** con **7,720**. **Accesorios de informática** y **Muebles y decoración** completan las cinco categorías con mayor volumen de pedidos.

**Insight:** Las categorías con mayor presencia en los pedidos se concentran principalmente en **Cama, Mesa y Baño** y **Belleza y Salud**, lo que evidencia una mayor frecuencia de compra en estas categorías.

## Q13. ¿Cuáles son las 5 categorías que generan mayores ingresos?

```sql
SELECT TOP 5
       pro.product_category_name AS Categoria,
       SUM(ord.price) AS Suma
FROM dbo.olist_order_items_dataset_clean$ AS ord
INNER JOIN dbo.olist_products_dataset_clean$ AS pro
ON ord.product_id = pro.product_id
GROUP BY pro.product_category_name
ORDER BY SUM(ord.price) DESC;
```
| Ranking | Categoría              |          Ingresos |
| ------: | ---------------------- | ----------------: |
|       1 | Beleza Saude           | **$1,258,681.34** |
|       2 | Relogios Presentes     | **$1,205,005.68** |
|       3 | Cama Mesa Banho        | **$1,036,988.68** |
|       4 | Esporte Lazer          |   **$988,048.97** |
|       5 | Informatica Acessorios |   **$911,954.32** |

**Hallazgos:** **Belleza y Salud** genera los mayores ingresos, con **$1.26 millones**, seguida de **Relojes y Regalos** con **$1.21 millones** y **Ropa de Cama, Mesa y Baño** con **$1.04 millones**. **Deporte y Ocio** e **Informática y Accesorios** completan el top 5.
**Insight:** Las cinco categorías concentran un volumen importante de ingresos dentro del marketplace, destacando Belleza y Salud y Relojes como las categorías con mayor valor de ventas.

## Q14. ¿Qué 5 categorías tienen mayor participación en los ingresos?

```sql
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
```
| Ranking | Categoría              |          Ingresos | Participación |
| ------: | ---------------------- | ----------------: | ------------: |
|       1 | Beleza Saude           | **$1,258,681.34** |     **9.26%** |
|       2 | Relogios Presentes     | **$1,205,005.68** |     **8.87%** |
|       3 | Cama Mesa Banho        | **$1,036,988.68** |     **7.63%** |
|       4 | Esporte Lazer          |   **$988,048.97** |     **7.27%** |
|       5 | Informatica Acessorios |   **$911,954.32** |     **6.71%** |

**Hallazgos:** **Belleza y Salud** presenta la mayor participación en los ingresos, con **9.26%** del total, seguida de **Relojes y Regalos** con **8.87%** y **Ropa de Cama, Mesa y Baño** con **7.63%**. Las cinco principales categorías concentran participaciones individuales de entre **6.71% y 9.26%**.

**Insight:** Las categorías con mayor participación representan una parte relevante de los ingresos, destacando **Belleza y Salud** y **Relojes y Regalos** por su mayor contribución individual al ingreso total.

## Q15. ¿Cuáles son las 3 principales categorías por ingresos de cada mes?

```sql
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
```
**Hallazgo:** Las categorías líderes varían según el mes. Durante 2017, diferentes categorías ocuparon el primer lugar, destacando **Relojes y Regalos** en Noviembre con **$97,724.57**. En 2018, se observa una mayor presencia de **Belleza y Salud** y R**Relojes y Regalos** entre las categorías con mayores ingresos, alcanzando **Belleza y Salud** con **$120,803.94** en Agosto y **Relojes y Regalos** con **$123,872.66** en Mayo.

**Insight:** El ranking mensual evidencia que la composición de las categorías con mayores ingresos no es constante y cambia a lo largo del período. Sin embargo, **Belleza y Salud**, **Relojes y Regalos**, **Ropa de Cama, Mesa y Baño**, **Deporte y Ocio** e **Informática y Accesorios** aparecen recurrentemente entre las principales categorías, por lo que representan segmentos relevantes para el seguimiento mensual de ingresos.

## Q16. ¿Cuántos clientes únicos realizaron compras?

```sql
SELECT COUNT(DISTINCT c.customer_unique_id) AS Cantidad
FROM dbo.olist_orders_dataset_clean$ AS o
INNER JOIN dbo.olist_customers_dataset_clean$ AS c
    ON o.customer_id = c.customer_id;
```
| Cantidad | 
| -------: |
|  96096   |

**Hallazgo:** Se identificaron **96,096 clientes únicos** que realizaron al menos una compra durante el período analizado, utilizando customer_unique_id para evitar contabilizar varias veces a un mismo cliente.

## Q17. ¿Cuántos clientes nuevos hubo por mes?

```sql
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
```
**Hallazgo:** Los clientes nuevos alcanzan su **máximo en Noviembre de 2017**, con **7,304 clientes**, y se mantienen en niveles elevados durante Enero-Agosto de 2018. Septiembre y Octubre de 2018 presentan valores atípicamente bajos.

**Insight:** La captación de clientes muestra un crecimiento importante entre 2017 y 2018, aunque los últimos registros de 2018 deben validarse antes de interpretar la tendencia final.

## Q18. ¿Cuántos clientes realizaron una sola compra?

```sql
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

```
| Clientes con una sola compra | 
| ---------------------------: |
|             93099            |

**Hallazgo:** De los 96,096 clientes únicos, **93,099 realizaron una sola compra**, lo que representa aproximadamente el **96.9%** del total.

**Insight:** La elevada proporción de clientes con una única compra evidencia una baja recurrencia dentro del período analizado, aspecto relevante para evaluar posteriormente la retención y fidelización de clientes.

## Q19. ¿Cuántos clientes son recurrentes?

```sql
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
```

| Clientes recurrentes | 
| -------------------: |
|         2997         |

**Hallazgo:** De los **96,096 clientes únicos**, **2,997 realizaron más de una compra**, equivalente aproximadamente al **3.1%** del total.

**Insight:** La proporción de clientes recurrentes es reducida frente al total de clientes, lo que evidencia una baja recurrencia de compra durante el período analizado.

## Q20. ¿Cómo se distribuyen los clientes según su gasto?

```sql
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
```
| Segmento | Cantidad de clientes | Gasto mínimo | Gasto máximo |
| -------- | -------------------: | -----------: | -----------: |
| Bajo     |               23,984 |        $0.85 |       $47.90 |
| Medio    |               47,600 |       $47.91 |      $155.00 |
| Alto     |               23,836 |      $155.06 |   $13,440.00 |

**Hallazgo:** El segmento **Medio** concentra la mayor cantidad de clientes, con **47,600** representando un **49.5%**, seguido de **Bajo con 23,984** representando un **25.0%** y **Alto con 23,836** representando un **24.8%**. El gasto máximo registrado en el segmento Alto alcanza $13,440.

**Insight:** La distribución muestra una concentración de clientes en el segmento de gasto Medio, mientras que el segmento Alto presenta una mayor amplitud en el valor gastado, reflejando diferencias importantes en el comportamiento de compra.

## Q21. 

```sql

```
**Hallazgo:**

**Insight:**

## Q22. 

```sql

```
**Hallazgo:**

**Insight:**

## Q23. 

```sql

```
**Hallazgo:**

**Insight:**

## Q24. 

```sql

```
**Hallazgo:**

**Insight:**

## Q25. 

```sql

```
**Hallazgo:**

**Insight:**

## Q26. 

```sql

```
**Hallazgo:**

**Insight:**

## Q27. 

```sql

```
**Hallazgo:**

**Insight:**

## Q28. 

```sql

```
**Hallazgo:**

**Insight:**

## Q29. 

```sql

```
**Hallazgo:**

**Insight:**

## Q30. 

```sql

```
**Hallazgo:**

**Insight:**
