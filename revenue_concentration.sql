--- 1.Total won revenue
SELECT 
    SUM(close_value) AS total_won_revenue
FROM fact_sales_pipeline
WHERE deal_stage = 'Won'; 

--- 2. Revenue by account 
SELECT
    account,
    SUM(close_value) AS account_revenue
FROM fact_sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY account
ORDER BY account_revenue DESC; 

--- 3. Revenue share % 
SELECT
    account,
    SUM(close_value) AS account_revenue,
    ROUND(
        SUM(close_value) /
        (SELECT SUM(close_value)
         FROM fact_sales_pipeline
         WHERE deal_stage = 'Won') * 100,
        2
    ) AS revenue_share_pct
FROM fact_sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY account
ORDER BY account_revenue DESC;

--- 4. Cummulative Revenue % 
WITH account_revenue AS (
    SELECT
        account,
        SUM(close_value) AS revenue
    FROM fact_sales_pipeline
    WHERE deal_stage = 'Won'
    GROUP BY account
)

SELECT
    account,
    revenue,
    ROUND(
        revenue / SUM(revenue) OVER () * 100,
        2
    ) AS revenue_share_pct,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        / SUM(revenue) OVER () * 100,
        2
    ) AS cumulative_revenue_pct
FROM account_revenue
ORDER BY revenue DESC;

