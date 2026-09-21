# 📊 Resultados y Hallazgos del Análisis SQL

## Q1. ¿Cuántos pedidos se realizaron?

```sql
SELECT COUNT(DISTINCT order_id) AS "N° Pedidos"
FROM dbo.olist_orders_dataset_clean$;
```
**Hallazgos:** La cantidad de pedidos que se realizaron es de **99,441 pedidos**, lo que establece el volumen total de operaciones
