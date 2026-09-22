-- Your version, fixed table name, working correctly:
SELECT
    DATE_FORMAT(close_date, '%Y-%m') AS month,
    SUM(close_value) AS won_revenue
FROM fact_sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY DATE_FORMAT(close_date, '%Y-%m')
ORDER BY month;


-- Now add ONE window function on top: running total.
-- Notice we just wrap the same SUM() with OVER() — same aggregation,
-- but now also cumulative down the rows.
SELECT
    DATE_FORMAT(close_date, '%Y-%m') AS month,
    SUM(close_value) AS won_revenue,
    SUM(SUM(close_value)) OVER (ORDER BY DATE_FORMAT(close_date, '%Y-%m')) AS running_total
FROM fact_sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY DATE_FORMAT(close_date, '%Y-%m')
ORDER BY month;

-- Note the double SUM here: the inner SUM(close_value) is the normal
-- GROUP BY aggregation (revenue per month). The outer SUM(...) OVER()
-- takes that already-aggregated monthly number and adds a running
-- total on top of it. This pattern (aggregate, then window over the
-- aggregate) is common and worth recognizing.