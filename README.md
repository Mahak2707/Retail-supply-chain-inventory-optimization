# 📦 Supply Chain Inventory Optimization & Operations Dashboard

## 📌 Business Problem Overview
A retail distributor is experiencing lost revenue due to frequent stockouts on high-demand items, while simultaneously wasting warehouse budget by overstocking low-velocity products. 

This project builds a relational database pipeline and an interactive executive dashboard to monitor inventory health, calculate mathematical **Reorder Points (ROP)**, and flag real-time supply chain vulnerabilities.

---

## 🛠️ Tech Stack & Technical Skills
* **Database Management:** PostgreSQL (Schema Design, Multi-Table Data Ingestion)
* **Advanced Analytical SQL:** Common Table Expressions (CTEs), Relational JOINs, Conditional Logic (`CASE WHEN`)
* **Business Intelligence:** Tableau Public (Interactive Dashboarding, Operational KPI Tracking)

---

## 📐 Operations Optimization Framework
To systematically eliminate warehouse stockouts, the following production-grade formulas were coded directly into our live relational database engine:

* **Lead Time Demand:** Measures expected unit sales during the period between placing a purchase order and receiving the goods.
* **Safety Stock:** Acts as a statistical buffer against unexpected surges in demand or shipping delays.
* **Reorder Point (ROP):** The precise inventory threshold that triggers an automated purchase order.

---

## 💻 SQL Implementation: Reorder Point Calculation Engine
```sql
WITH DailySalesVelocity AS (
    SELECT 
        product_id,
        SUM(quantity) AS total_units_sold,
        ROUND(SUM(quantity) / 90.0, 2) AS avg_daily_sales
    FROM orders
    GROUP BY product_id
),
OptimizedMetrics AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        i.current_stock,
        p.supplier_lead_time,
        d.avg_daily_sales,
        ROUND(d.avg_daily_sales * p.supplier_lead_time, 2) AS lead_time_demand,
        ROUND((d.avg_daily_sales * p.supplier_lead_time) * 0.5, 2) AS safety_stock
    FROM products p
    JOIN inventory i ON p.product_id = i.product_id
    JOIN DailySalesVelocity d ON p.product_id = d.product_id
)
SELECT 
    product_id,
    product_name,
    category,
    current_stock,
    avg_daily_sales,
    (lead_time_demand + safety_stock) AS calculated_reorder_point,
    CASE 
        WHEN current_stock <= (lead_time_demand + safety_stock) THEN '🚨 REORDER NOW'
        WHEN current_stock <= (lead_time_demand + safety_stock) * 1.5 THEN '🟡 LOW STOCK'
        WHEN current_stock >= 150 THEN '⚠️ OVERSTOCKED'
        ELSE '✅ HEALTHY'
    END AS inventory_status
FROM OptimizedMetrics
ORDER BY calculated_reorder_point DESC;

An end-to-end SQL and Tableau project analyzing retail sales velocity, calculating Reorder Points (ROP), and tracking warehouse stock levels.

---

## 📊 Dashboard Insights & Business Impact
By connecting this database pipeline directly to Tableau, corporate logistics managers get an instant visual assessment of supply chain exposure.

### Key Deliverables:
1. **Capital Recovery:** Successfully isolated overstocked SKUs taking up excessive warehouse space (e.g., `LuminaDesk LED Lamp` sitting at 210 units against a calculated reorder point of 8.34). This allows the firm to pause purchasing cycles and recover holding costs.
2. **Stockout Prevention:** Established a dynamic buffer rule using 90-day trailing sales velocity combined with supplier lead times to accurately map baseline safety stock needs.
3. **Data Democratization:** Translated thousands of raw row-and-column order logs into a crisp, color-coded dashboard built for non-technical retail executives.

### 🖼️ Operational Dashboard Preview
![Inventory Optimization Dashboard](https://github.com/user-attachments/assets/c46b4c22-6f77-4159-a49e-56f387f5f06e)
