SELECT
    sales_agent,
    COUNT(*) AS opportunity_volume,
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_opportunities,
    ROUND(
        SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS win_rate
FROM fact_sales_pipeline
GROUP BY sales_agent
ORDER BY win_rate DESC;