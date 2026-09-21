# Olist E-Commerce Analytics

## Descripción del proyecto

Este proyecto desarrolla un análisis integral del desempeño de un
e-commerce utilizando el Brazilian E-Commerce Public Dataset by Olist.

El objetivo es transformar datos transaccionales en información útil
para el análisis de ventas, clientes, productos, vendedores, geografía,
logística y satisfacción del cliente.

El proyecto sigue un flujo de análisis de datos de extremo a extremo:

**Excel / Power Query → SQL Server → Power BI → Python**

A través de este proceso se realizó la limpieza y transformación de
los datos, la construcción del modelo relacional, el análisis mediante
consultas SQL y la creación de un dashboard interactivo para explorar
los principales indicadores del negocio.

---

## Objetivos del análisis

- Analizar la evolución de las ventas y los pedidos.
- Identificar las principales categorías y productos.
- Analizar el comportamiento y recurrencia de los clientes.
- Analizar el desempeño y distribución de los vendedores.
- Examinar la distribución geográfica de clientes y vendedores.
- Evaluar tiempos de entrega y cancelaciones.
- Analizar la satisfacción del cliente mediante las reseñas.
- Construir indicadores que faciliten la interpretación del desempeño
  del negocio.

---

## Herramientas utilizadas

| Herramienta | Uso |
|---|---|
| **Excel** | Preparación, limpieza y validación inicial de datos |
| **Power Query** | Limpieza y transformación de datos |
| **Power Pivot** | Modelo de datos, relaciones y medidas |
| **SQL Server** | Modelado relacional y análisis de datos |
| **Power BI** | Dashboard, KPIs y visualización interactiva |
| **Python** | Análisis complementario y exploración de datos |
| **GitHub** | Documentación y control del proyecto |

---

## Dataset

**Brazilian E-Commerce Public Dataset by Olist**

El dataset contiene información de pedidos realizados en una plataforma
de comercio electrónico de Brasil, incluyendo clientes, pedidos,
productos, vendedores, pagos, reseñas y geolocalización.

El análisis utiliza las relaciones entre estas entidades para construir
una visión integral del comportamiento del negocio.

---

## Modelo de datos

El proyecto utiliza un modelo relacional compuesto por tablas de:

- Clientes
- Pedidos
- Detalles de pedidos
- Productos
- Vendedores
- Pagos
- Reseñas
- Geolocalización

Se definieron claves primarias, claves foráneas y relaciones entre las
tablas para mantener la integridad del modelo y facilitar el análisis.

---

## Análisis SQL

Se desarrollaron **39 consultas de análisis de negocio**, organizadas
en las siguientes áreas:

- Ventas y crecimiento
- Productos y categorías
- Clientes
- Vendedores
- Geografía
- Logística y operaciones
- Calidad y satisfacción

Entre las técnicas utilizadas se encuentran:

- `JOIN`
- `GROUP BY`
- `HAVING`
- Subconsultas
- CTEs
- `CASE WHEN`
- Funciones de agregación
- `LAG`
- `RANK`
- `PERCENTILE_CONT`
- `DATEDIFF`
- Cálculos porcentuales
- Análisis temporal
- Rankings y segmentación

[Ver consultas SQL](SQL/Olist_Ecommerce_Analytics.sql)

---

## Dashboard en Power BI

El dashboard permite explorar el desempeño del negocio mediante
indicadores y visualizaciones interactivas.

### Principales áreas

**Dashboard**
- Ingresos
- Beneficio
- Margen
- Pedidos entregados
- Cancelaciones
- Evolución temporal

**Clientes**
- Clientes únicos
- Clientes recurrentes
- Adquisición
- Frecuencia de compra
- Ingresos por cliente

**Productos**
- Ingresos por categoría
- Margen
- Volumen de pedidos
- Tendencias semanales

**Vendedores**
- Ingresos
- Pedidos
- Vendedores activos
- Distribución por volumen

**Ubicación**
- Distribución de clientes
- Distribución de vendedores
- Cobertura geográfica
- Relación entre pedidos y vendedores

---

## Análisis en Excel

El archivo Excel documenta la etapa de preparación y análisis mediante
Power Query y Power Pivot.

Incluye:

- Limpieza y transformación de datos.
- Modelo de datos.
- Relaciones entre tablas.
- Medidas y KPIs.
- Tablas dinámicas.
- Segmentadores.
- Validación de resultados.

[Acceder al archivo Excel](ENLACE_DE_GOOGLE_DRIVE)

---

## Estructura del proyecto

```text
Olist_Ecommerce_Analytics/
│
├── README.md
│
├── Excel/
│   └── README.md
│
├── SQL/
│   └── Olist_Ecommerce_Analytics.sql
│
├── PowerBI/
│   └── README.md
│
├── Python/
│   └── ...
│
└── images/
    ├── dashboard.png
    ├── clientes.png
    ├── productos.png
    ├── vendedores.png
    └── ubicacion.png
