describe fact_sales_pipeline; 

--- Spot-check that dates and numbers are REAL dates/numbers, not text
-- If these run without error, the types are correct
SELECT MIN(engage_date), MAX(engage_date) FROM fact_sales_pipeline;
SELECT MIN(close_date), MAX(close_date) FROM fact_sales_pipeline;
SELECT AVG(close_value), MAX(close_value) FROM fact_sales_pipeline; 

-- This should work cleanly if engage_date/close_date are real DATE type
SELECT opportunity_id, DATEDIFF(close_date, engage_date) AS days_to_close
FROM fact_sales_pipeline
WHERE close_date IS NOT NULL AND engage_date IS NOT NULL
LIMIT 10;
 
 -- ============================================================
-- Query 1: Overall win rate
-- This is your baseline number — every other analysis compares
-- back to this. "Win rate" = closed-won / all CLOSED deals
-- (we exclude still-open deals, since they haven't won or lost yet).
-- ============================================================

SELECT
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_count,
    SUM(CASE WHEN deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_count,
    SUM(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END) AS total_closed,
    ROUND(
        SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN deal_stage IN ('Won','Lost') THEN 1 ELSE 0 END) * 100
    , 2) AS win_rate_pct
FROM fact_sales_pipeline; 