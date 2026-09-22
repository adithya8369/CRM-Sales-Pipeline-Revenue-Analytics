-- ============================================================
-- Query 2: Win rate by sales agent (and their manager/region)
-- Same win-rate logic as Query 1, but broken down per agent.
-- Joins to dim_agent to pull in manager + region for free.
-- ============================================================

SELECT
    f.sales_agent,
    a.manager,
    a.regional_office,
    SUM(CASE WHEN f.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_count,
    SUM(CASE WHEN f.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_count,
    SUM(CASE WHEN f.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END) AS total_closed,
    ROUND(
        SUM(CASE WHEN f.deal_stage = 'Won' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN f.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END) * 100
    , 2) AS win_rate_pct,
    ROUND(SUM(CASE WHEN f.deal_stage = 'Won' THEN f.close_value ELSE 0 END), 2) AS total_revenue_won
FROM fact_sales_pipeline f
JOIN dim_agent a ON f.sales_agent = a.sales_agent
GROUP BY f.sales_agent, a.manager, a.regional_office
ORDER BY win_rate_pct DESC;


-- ============================================================
-- Query 2b: Same thing, rolled up to manager/region level
-- Useful to check: is one region/manager systematically
-- stronger, or is it just a couple of standout individuals?
-- ============================================================

SELECT
    a.manager,
    a.regional_office,
    COUNT(DISTINCT f.sales_agent) AS num_agents,
    SUM(CASE WHEN f.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_count,
    SUM(CASE WHEN f.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END) AS total_closed,
    ROUND(
        SUM(CASE WHEN f.deal_stage = 'Won' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN f.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END) * 100
    , 2) AS win_rate_pct
FROM fact_sales_pipeline f
JOIN dim_agent a ON f.sales_agent = a.sales_agent
GROUP BY a.manager, a.regional_office
ORDER BY win_rate_pct DESC;  