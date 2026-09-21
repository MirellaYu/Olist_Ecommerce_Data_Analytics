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
**Hallazgos:** Se observa un crecimiento sostenido en el volumen de pedidos desde el año 2017, alcanzando su mayor nivel en noviembre con **7,544 pedidos**.

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
**Hallazgos:** Los ingresos muestran una tendencia creciente desde 2017, alcanzando su punto máximo en noviembre de 2017 con **$1.01 millones**.

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
**Hallazgos:** El ticket promedio varió entre los meses, manteniéndose generalmente entre **$125 y $150** durante 2017 y 2018.

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
**Hallazgos:** La variación mensual de los ingresos presenta fluctuaciones importantes, con el mayor crecimiento porcentual en enero de 2017**(+1,103,687.8%)** y el mayor incremento absoluto en noviembre de 2017 **(+$346,051.94; +52.10%)**. Durante 2017 y 2018 se alternan períodos de crecimiento y contracción.

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
**Hallazgos:** Los pedidos se concentran principalmente en **Sao Paulo (SP)**, con **41,746 pedidos**, seguidos por Río de Janeiro (RJ), Minas Gerais (MG), Rio Grande do Sul (RS) y Paraná (PR), evidenciando una fuerte concentración de la demanda en estos cinco estados.

| customer_state | N° de pedidos |
| -------------- | ------------: |
| SP             |        41,746 |
| RJ             |        12,852 |
| MG             |        11,635 |
| RS             |         5,466 |
| PR             |         5,045 |

Representan los cinco estados que concentran una parte importante del volumen total registradas en el dataset.

## Q9. 

```sql

```
**Hallazgos:** 

## Q10. 

```sql

```
**Hallazgos:** 

## Q11. 

```sql

```
**Hallazgos:** 

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
