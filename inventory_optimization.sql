-- Calibrated Inventory Optimization Engine
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
        -- Lead Time Demand = Daily Sales * Supplier Wait Time
        ROUND(d.avg_daily_sales * p.supplier_lead_time, 2) AS lead_time_demand,
        -- Safety Stock = 50% buffer of Lead Time Demand
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