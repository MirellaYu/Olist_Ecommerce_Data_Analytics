# 📊 Resultados y Hallazgos del Análisis SQL

### **1. ¿Cuántos pedidos se realizaron en total?**

```sql
SELECT COUNT(DISTINCT order_id) AS "N° Pedidos"
FROM dbo.olist_orders_dataset_clean$;
```
**Hallazgos:** La cantidad total de pedidos realizados es de **99441**.
