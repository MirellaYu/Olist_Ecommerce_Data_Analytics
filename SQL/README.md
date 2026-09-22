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
| Bajo     |               24,025 |        $0.00 |       $63.12 |
| Medio    |               48,049 |       $63.13 |      $183.53 |
| Alto     |               24,021 |      $183.54 |   $13,664.08 |


**Hallazgo:** El segmento **Medio** concentra la mayor cantidad de clientes, con **48,049** representando un **50.0%**, seguido de **Bajo con 24,025** representando un **25.0%** y **Alto con 24,021** representando un **25.0%**. El gasto acumulado por cliente oscila entre **$0 y $13,664.08**, con puntos de corte de **$63.12 y $183.53** para los segmentos Bajo, Medio y Alto.

**Insight:** La distribución muestra una segmentación equilibrada entre los niveles Bajo y Alto, mientras que la mitad de los clientes se concentra en el segmento Medio. Esta clasificación permite diferenciar grupos según su nivel de gasto y facilita posteriores análisis de comportamiento y valor de clientes.

## Q21. ¿Cuántos vendedores realizaron ventas?

```sql
SELECT COUNT(DISTINCT seller_id) AS "N° Vendedores"
FROM dbo.olist_order_items_dataset_clean$;
```
| N° Vendedores | 
| ------------: |
|     3095      |

**Hallazgo:** Se identificaron **3,095 vendedores** que realizaron al menos una venta durante el período analizado.

## Q22. ¿Cuáles son los 6 vendedores que generan mayores ingresos?

```sql
SELECT TOP 6
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
```
| Ranking | Ciudad           | Estado |        Ingresos |
| ------: | ---------------- | ------ | --------------: |
|       1 | Guariba          | SP     | **$229,472.63** |
|       2 | Lauro De Freitas | BA     | **$222,776.05** |
|       3 | Ibitinga         | SP     | **$200,472.92** |
|       4 | Sumare           | SP     | **$194,042.03** |
|       5 | Itaquaquecetuba  | SP     | **$187,923.89** |
|       6 | Barueri          | SP     | **$176,431.87** |

**Hallazgo:** Los seis vendedores con mayores ingresos registran valores entre **$176,431.87** y **$229,472.63**. El vendedor ubicado en **Guariba (SP)** ocupa el primer lugar con **$229,472.63**, seguido por un vendedor de **Lauro De Freitas (BA)** con **$222,776.05**. Cuatro de los seis vendedores principales se encuentran en el estado de São Paulo.

**Insight:** Los mayores ingresos se concentran principalmente en vendedores ubicados en **São Paulo**, aunque también destaca un vendedor de **Lauro De Freitas (BA)**.

## Q23. ¿Cuáles son los 5 vendedores tienen mayor cantidad de pedidos?

```sql
SELECT TOP 5
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
```
| Ranking | Ciudad                | Estado | Cantidad de pedidos |
| ------: | --------------------- | ------ | ------------------: |
|       1 | Sao Paulo             | SP     |           **1,854** |
|       2 | Ibitinga              | SP     |           **1,806** |
|       3 | Santo Andre           | SP     |           **1,706** |
|       4 | Sao Jose Do Rio Preto | SP     |           **1,404** |
|       5 | Piracicaba            | SP     |           **1,314** |

**Hallazgo:** Los cinco vendedores con mayor cantidad de pedidos registran entre **1,314** y **1,854 pedidos**. El vendedor ubicado en **Sao Paulo (SP)** ocupa el primer lugar con **1,854 pedidos**, seguido de **Ibitinga** con **1,806 pedidos** y **Santo Andre** con **1,706 pedidos**. Los cinco vendedores pertenecen al estado de São Paulo.

**Insight:** Los vendedores con mayor volumen de pedidos presentan una marcada concentración geográfica en São Paulo, lo que evidencia que este estado reúne a los vendedores con mayor cantidad de pedidos dentro del top 5 analizado.

## Q24. ¿Qué porcentaje de los ingresos totales generan los 5 principales vendedores?

```sql
WITH cte_IngresosPorVendedor AS(
     SELECT 
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
```
|         Ranking | Ciudad           | Estado |          Ingresos | Participación |
| --------------: | ---------------- | ------ | ----------------: | ------------: |
|               1 | Guariba          | SP     |   **$229,472.63** |     **1.69%** |
|               2 | Lauro De Freitas | BA     |   **$222,776.05** |     **1.64%** |
|               3 | Ibitinga         | SP     |   **$200,472.92** |     **1.47%** |
|               4 | Sumare           | SP     |   **$194,042.03** |     **1.43%** |
|               5 | Itaquaquecetuba  | SP     |   **$187,923.89** |     **1.38%** |

**Hallazgo:** Los cinco principales vendedores generan conjuntamente **$1.03 millones**, equivalentes aproximadamente al **7.61% de los ingresos totales**. De manera individual, su participación oscila entre **1.38%** y **1.69%**, siendo el vendedor ubicado en **Guariba (SP)** quien presenta la mayor contribución, con **1.69%**.

**Insight:** Los ingresos presentan una distribución relativamente diversificada entre los vendedores, ya que los cinco principales concentran aproximadamente **7.61% del ingreso total**, mientras que el porcentaje restante corresponde al resto de vendedores.

## Q25. ¿Cuáles son los 5 estados que concentran mayor cantidad de clientes?

```sql
SELECT  TOP 5
        customer_state AS Estados,
        COUNT(DISTINCT customer_unique_id) AS Cantidad
FROM dbo.olist_customers_dataset_clean$
GROUP BY customer_state
ORDER BY Cantidad DESC;
```
| Ranking | Estado | Clientes únicos |
| ------: | ------ | --------------: |
|       1 | SP     |      **40,302** |
|       2 | RJ     |      **12,384** |
|       3 | MG     |      **11,259** |
|       4 | RS     |       **5,277** |
|       5 | PR     |       **4,882** |

**Hallazgo:** **São Paulo (SP)** concentra la mayor cantidad de clientes únicos, con **40,302 clientes**, seguido de **Río de Janeiro (RJ) con 12,384 clientes** y **Minas Gerais (MG) con 11,259 clientes**. Rio Grande do Sul (RS) y Paraná (PR) completan los cinco estados con mayor cantidad de clientes.

**Insight:** La distribución de clientes presenta una marcada concentración en São Paulo, que reúne una cantidad de clientes considerablemente superior a los demás estados del top 5. Esto identifica a SP como el principal mercado geográfico por número de clientes dentro del período analizado.

## Q26. ¿Cuáles son los 5 estados que concentran mayor cantidad de pedidos e ingresos?

```sql
SELECT TOP 5
       cli.customer_state AS Estados,
       COUNT(DISTINCT ord.order_id) AS Cantidad_Pedidos,
       SUM(det.price) AS Ingresos
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
ON ord.customer_id = cli.customer_id
INNER JOIN dbo.olist_order_items_dataset_clean$ AS det
ON ord.order_id = det.order_id
GROUP BY cli.customer_state
ORDER BY Cantidad_Pedidos DESC, Ingresos DESC;
```
| Ranking | Estado | Cantidad de pedidos |          Ingresos |
| ------: | ------ | ------------------: | ----------------: |
|       1 | SP     |          **41,375** | **$5,202,955.05** |
|       2 | RJ     |          **12,762** | **$1,824,092.67** |
|       3 | MG     |          **11,544** | **$1,585,308.03** |
|       4 | RS     |           **5,432** |   **$750,304.02** |
|       5 | PR     |           **4,998** |   **$683,083.76** |

**Hallazgo:** **São Paulo (SP)** concentra el mayor volumen de pedidos, con **41,375 pedidos**, y también registra los mayores ingresos, con aproximadamente **$5.20 millones**. Le siguen **Río de Janeiro (RJ)** y **Minas Gerais (MG)**, tanto en cantidad de pedidos como en ingresos. Los cinco estados del ranking presentan una correspondencia entre mayor volumen de pedidos y mayor nivel de ingresos.

**Insight:** Los resultados muestran una concentración geográfica de la actividad comercial en los principales estados del ranking. São Paulo destaca por reunir simultáneamente el mayor volumen de pedidos y de ingresos, mientras que los demás estados presentan niveles progresivamente menores en ambas métricas.

## Q27. ¿Cuáles son los 5 estados que concentran mayor cantidad de vendedores?

```sql
SELECT  TOP 5
        seller_state AS Estados,
        COUNT(seller_id) AS Cantidad
FROM dbo.olist_sellers_dataset_clean$
GROUP BY seller_state
ORDER BY COUNT(seller_id) DESC;
```
| Ranking | Estado | Cantidad de vendedores |
| ------: | ------ | ---------------------: |
|       1 | SP     |              **1,849** |
|       2 | PR     |                **349** |
|       3 | MG     |                **244** |
|       4 | SC     |                **190** |
|       5 | RJ     |                **171** |

**Hallazgo:** **São Paulo (SP)** concentra la mayor cantidad de vendedores, con **1,849**, seguido de **Paraná (PR)** con **349** y **Minas Gerais (MG)** con **244**. **Santa Catarina (SC)** y **Río de Janeiro (RJ)** completan el top 5 con **190 y 171 vendedores**, respectivamente.

**Insight:** La distribución de vendedores presenta una marcada concentración en São Paulo, que reúne una cantidad considerablemente superior de vendedores respecto a los demás estados del top 5.

## Q28. ¿Cuáles son los 5 estados que presentan alta demanda frente a una baja oferta de vendedores?

```sql
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
SELECT TOP 5
       Es_pe.Estado,
       "N° Pedidos",
       "N° Vendedores",
       CAST("N° Pedidos" AS DECIMAL(10,2)) / "N° Vendedores" AS Demanda_por_vendedor
FROM cte_PedidosEstado AS Es_pe
INNER JOIN cte_VendedoresEstado AS Es_ven
ON Es_pe.Estado = Es_ven.Estado
ORDER BY Demanda_por_vendedor DESC;
```
| Ranking | Estado | Pedidos | Vendedores | Pedidos por vendedor |
| ------: | ------ | ------: | ---------: | -------------------: |
|       1 | PA     |     975 |          1 |           **975.00** |
|       2 | MA     |     747 |          1 |           **747.00** |
|       3 | PI     |     495 |          1 |           **495.00** |
|       4 | MT     |     907 |          4 |           **226.75** |
|       5 | PE     |   1,652 |          9 |           **183.56** |

**Hallazgo:** **Pará (PA)** presenta la mayor relación pedidos/vendedor, con **975**, seguido de **Maranhão (MA)** con **747** y **Piauí (PI)** con **495**.

**Insight:** Los resultados identifican estados con alta demanda relativa frente a una baja oferta de vendedores. Sin embargo, los primeros puestos corresponden a estados con muy pocos vendedores, por lo que este indicador debe analizarse junto con el volumen absoluto de pedidos.

## Q29. ¿Cuál es el tiempo promedio de entrega de los pedidos entregados?

```sql
SELECT AVG(DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date)
          ) AS "Tiempo Promedio de Entrega (días)"
FROM dbo.olist_orders_dataset_clean$
WHERE order_delivered_customer_date IS NOT NULL;
```
**Hallazgo:** El tiempo promedio de entrega de los pedidos con fecha de entrega registrada es de **12 días** desde la compra hasta la entrega al cliente.

## Q30. ¿Qué porcentaje de los pedidos entregados presentó retraso respecto a la fecha estimada?

```sql
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
```
| Entrega_Tarde | Pedidos_Entregados | Porcentaje_Retrasos |
| ------------: | -----------------: | ------------------: |
|         7,827 |             96,476 |           **8.11%** |

**Hallazgo:** De los **96,476 pedidos entregados**, **7,827 presentaron retraso** respecto a la fecha estimada, equivalente al **8.11%**.

**Insight:** La mayoría de los pedidos se entregó dentro o antes de la fecha estimada, mientras que aproximadamente 8 de cada 100 pedidos registraron retraso.

## Q31. ¿Cuántos días de retraso tienen en promedio los pedidos tardíos?

```sql
SELECT AVG(DATEDIFF(
                DAY, 
                order_estimated_delivery_date, 
                order_delivered_customer_date
          )
       ) AS "Retraso Promedio (días)"
FROM dbo.olist_orders_dataset_clean$
WHERE order_delivered_customer_date > order_estimated_delivery_date;
```

**Hallazgo:** Los pedidos que fueron entregados después de la fecha estimada presentaron un **retraso promedio de 8 días**.

## Q32. ¿Cuáles son los 5 estados que presentan el mayor tiempo promedio de entrega?

```sql
SELECT TOP 5
       cli.customer_state AS Estado,
       AVG(DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date)) AS Promedio_Entrega_Tiempo
FROM dbo.olist_orders_dataset_clean$ AS ord
INNER JOIN dbo.olist_customers_dataset_clean$ AS cli
ON ord.customer_id = cli.customer_id
WHERE ord.order_delivered_customer_date IS NOT NULL
GROUP BY cli.customer_state
ORDER BY Promedio_Entrega_Tiempo DESC;
```
| Ranking | Estado | Tiempo promedio de entrega |
| ------: | ------ | -------------------------: |
|       1 | RR     |                    29 días |
|       2 | AP     |                    27 días |
|       3 | AM     |                    26 días |
|       4 | AL     |                    24 días |
|       5 | PA     |                    23 días |

**Hallazgo:** **Roraima (RR)** presenta el mayor tiempo promedio de entrega, con **29 días**, seguido de **Amapá (AP)** con **27 días**, **Amazonas (AM)** con **26 días**, **Alagoas (AL)** con **24 días** y **Pará (PA)** con **23 días**.

**Insight:** Los estados del top 5 presentan tiempos promedio de entrega superiores al resto de estados analizados, con períodos que alcanzan hasta **29 días**. Estos resultados permiten identificar regiones que requieren un análisis más detallado del desempeño logístico.

## Q33. ¿Cuáles son los 5 vendedores que presentan el mayor tiempo promedio de entrega?

```sql
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
```
| Ranking | Seller ID                        | Tiempo promedio de entrega |
| ------: | -------------------------------- | -------------------------: |
|       1 | df683dfda87bf71ac3fc63063fba369d |               **190 días** |
|       2 | 8e670472e453ba34a379331513d6aab1 |                **86 días** |
|       3 | 586a871d4f1221763fddb6ceefdeb95e |                **69 días** |
|       4 | 4fb41dff7c50136976d1a5cf004a42e2 |                **66 días** |
|       5 | 8629a7efec1aab257e58cda559f03ba7 |                **59 días** |

**Hallazgo:** Los cinco vendedores con mayor tiempo promedio de entrega presentan valores entre **59 y 190 días**. El vendedor registra el promedio más alto, con **190 días**, seguido por con **86 días**.

## Q34. ¿Cuál es la cantidad y porcentaje de pedidos según su estado?

```sql
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
```
| Estado      |   Cantidad |  Porcentaje |
| ----------- | ---------: | ----------: |
| Delivered   |     96,478 |      97.02% |
| Shipped     |      1,107 |       1.11% |
| Canceled    |        625 |       0.63% |
| Unavailable |        609 |       0.61% |
| Invoiced    |        314 |       0.32% |
| Processing  |        301 |       0.30% |
| Created     |          5 |       0.01% |
| Approved    |          2 |       0.00% |
| **Total**   | **99,441** | **100.00%** |

**Hallazgo:** El **97.02%** de los pedidos fueron entregados, con **96,478 registros**. Los estados **Shipped**, **Canceled** y **Unavailable** representan porcentajes considerablemente menores, con **1.11%, 0.63% y 0.61%**, respectivamente.

**Insight:** La distribución muestra una alta concentración de pedidos en el estado Delivered, mientras que los estados asociados a cancelación, indisponibilidad y procesos pendientes representan una proporción reducida del total de pedidos.

## Q35. ¿Cómo evolucionan las cancelaciones de pedidos a lo largo del tiempo?

```sql
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
```

**Hallazgo:** La tasa mensual de cancelación se mantiene generalmente por debajo del **1.3%** durante **2017 y 2018**. El valor más alto dentro de los meses con volúmenes normales se registra en **Agosto** de **2018**, con **1.29%**, seguido de **Marzo** de **2017** con **1.23%** y **Febrero** de **2018** con **1.09%**.

**Insight:** La tasa de cancelación presenta niveles relativamente bajos durante la mayor parte del período analizado. Los valores excepcionalmente altos de septiembre y octubre de 2018 deben interpretarse con cautela, debido al reducido número de pedidos registrados en esos meses.

## Q36. ¿Cuál es la puntuación promedio de las reviews?

```sql
SELECT AVG(review_score) AS Promedio
FROM dbo.olist_order_review_clean$;
```

**Hallazgo:** La puntuación **promedio** de las reviews es de **4.11 sobre 5**, considerando las valoraciones registradas en el período analizado.

## Q37. ¿Cómo se distribuyen las puntuaciones de 1 a 5?

```sql
SELECT review_score AS Puntuacion, 
       COUNT(review_score) AS Cantidad
FROM dbo.olist_order_review_clean$
GROUP BY review_score
ORDER BY review_score;
```
| Puntuación | Cantidad |
| ---------: | -------: |
|          1 |   10,242 |
|          2 |    2,875 |
|          3 |    7,715 |
|          4 |   18,368 |
|          5 |   54,787 |

**Hallazgo:** La puntuación de **5 estrellas** concentra la mayor cantidad de reviews, con **54,787 valoraciones**, seguida de **4 estrellas** con **18,368**. Las puntuaciones de 1, 2 y 3 estrellas presentan volúmenes considerablemente menores.

**Insight:** La distribución de las valoraciones se concentra principalmente en las puntuaciones altas, especialmente en 5 estrellas, mientras que las valoraciones bajas representan una proporción menor del total de reviews.

## Q38. ¿Cuáles son las 5 categorías asociadas a los pedidos con mejores valoraciones?

```sql
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
```
| Ranking | Categoría                     | Puntuación promedio |
| ------: | ----------------------------- | ------------------: |
|       1 | Cds Dvds Musicais             |            **4.64** |
|       2 | Flores                        |            **4.55** |
|       3 | Livros Importados             |            **4.53** |
|       4 | Fashion Roupa Infanto Juvenil |            **4.50** |
|       5 | Livros Interesse Geral        |            **4.47** |

**Hallazgo:** Las cinco categorías con mayor puntuación promedio presentan valoraciones entre **4.47** y **4.64** sobre 5. **Cds Dvds Musicais** registra el promedio más alto con **4.64 puntuación promedio**, seguido de **Flores** con **4.55 puntuación promedio** y **Livros Importados** con **4.53 puntuación promedio**.

**Insight:** Las categorías del top 5 presentan una valoración promedio elevada, lo que evidencia una percepción favorable entre los clientes que registraron reviews asociadas a estas categorías.

## Q39. ¿Cuáles son las 5 categorías asociadas a los pedidos con peores valoraciones?

```sql
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
```
| Ranking | Categoría                                     | Puntuación promedio |
| ------: | --------------------------------------------- | ------------------: |
|       1 | Seguros E Servicos                            |            **2.50** |
|       2 | Portateis Cozinha E Preparadores De Alimentos |            **3.08** |
|       3 | Fraldas Higiene                               |            **3.26** |
|       4 | Pc Gamer                                      |            **3.33** |
|       5 | Moveis Escritorio                             |            **3.56** |

**Hallazgo:** Las cinco categorías con menor puntuación promedio presentan valoraciones entre **2.50 de puntuación promedio** y **3.56 de puntuación promedio** sobre 5. **Seguros E Servicos** registra el promedio más bajo, con **2.50 puntuación promedio**, seguido de **Portateis Cozinha E Preparadores De Alimentos** con **3.08 de puntuación promedio** y **Fraldas Higiene** con **3.26 de puntuación promedio**.

Insight: Estas categorías presentan las valoraciones promedio más bajas del conjunto analizado, lo que permite identificar segmentos que requieren un análisis más detallado de la experiencia del cliente.

**Insight:** 

## Q40. ¿Cómo varía la puntuación promedio de las reseñas según el estado de entrega del pedido?

```sql
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
    AVG(review_score) AS Puntuacion_Promedio
FROM cte_Retrasos
GROUP BY EstadoEntrega;
```
| Estado de entrega | Puntuación promedio |
| ----------------- | ------------------: |
| A Tiempo          |            **4.32** |
| Tarde             |            **2.59** |

**Hallazgo:** Los **pedidos entregados a tiempo** presentan una **puntuación promedio de 4.32** sobre 5, mientras que los **pedidos entregados con retraso** alcanzan un **promedio de 2.59**. Esto representa una **diferencia** de aproximadamente **1.72** puntos en la valoración promedio.

**Insight:** Los resultados muestran una asociación clara entre el estado de entrega y la valoración registrada por los clientes, ya que los pedidos entregados tarde presentan una puntuación promedio considerablemente menor. Esto evidencia que el cumplimiento de los tiempos estimados constituye un aspecto relevante de la experiencia del cliente.
