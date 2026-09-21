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

**Hallazgos:** Cama, Mesa y Baño lidera el volumen de productos vendidos con **11,115 unidades**, seguida por Belleza y Salud con 9,970 y Deporte y ocio con 8,641.

**Insight:** **Cama, Mesa y Baño concentra el mayor volumen de productos comercializados**, por lo que representa una categoría relevante para monitorear su comportamiento y evolución.

## Q12. 

```sql

```
**Hallazgos:** 

## Q13. 

```sql

```
**Hallazgos:** 

## Q14. 

```sql

```
**Hallazgos:** 

## Q15. 

```sql

```
**Hallazgos:** 
