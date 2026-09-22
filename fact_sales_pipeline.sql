-- ============================================================
-- Alternative approach: staging table + Import Wizard
-- Avoids LOAD DATA LOCAL INFILE permission problems entirely.
-- ============================================================

USE crm_sales;

-- Step 1: drop the old fact table completely
DROP TABLE IF EXISTS fact_sales_pipeline;
DROP TABLE IF EXISTS staging_sales_pipeline;

-- Step 2: create a STAGING table where every column is text.
-- Text columns accept blank values without any conversion error,
-- so the Import Wizard cannot silently drop rows here.
CREATE TABLE staging_sales_pipeline (
    opportunity_id   VARCHAR(20),
    sales_agent      VARCHAR(100),
    product          VARCHAR(50),
    account          VARCHAR(100),
    deal_stage       VARCHAR(20),
    engage_date      VARCHAR(20),
    close_date       VARCHAR(20),
    close_value      VARCHAR(20)
);

-- ============================================================
-- STOP HERE. Now do this in Workbench (not SQL):
-- Right-click staging_sales_pipeline -> Table Data Import Wizard
-- -> select cleaned_sales_pipeline.csv -> Next -> Finish
-- Then come back and run the rest below.
-- ============================================================

-- Step 3 (run AFTER the wizard import above): check staging loaded fully
SELECT COUNT(*) AS staging_row_count FROM staging_sales_pipeline;
-- must be 8800 -- text columns should not drop any rows

-- Step 4: create the real fact table with proper types
CREATE TABLE fact_sales_pipeline (
    opportunity_id   VARCHAR(20) PRIMARY KEY,
    sales_agent      VARCHAR(100),
    product          VARCHAR(50),
    account          VARCHAR(100) NULL,
    deal_stage       VARCHAR(20),
    engage_date      DATE NULL,
    close_date       DATE NULL,
    close_value      DECIMAL(10,2) NULL,
    FOREIGN KEY (sales_agent) REFERENCES dim_agent(sales_agent),
    FOREIGN KEY (product) REFERENCES dim_product(product)
);

-- Step 5: move data from staging into the real table,
-- converting blank strings to proper NULLs as we go
INSERT INTO fact_sales_pipeline
    (opportunity_id, sales_agent, product, account, deal_stage,
     engage_date, close_date, close_value)
SELECT
    opportunity_id,
    sales_agent,
    product,
    NULLIF(account, ''),
    deal_stage,
    NULLIF(engage_date, ''),
    NULLIF(close_date, ''),
    NULLIF(close_value, '')
FROM staging_sales_pipeline;

-- Step 6: verify — should be 8800
SELECT COUNT(*) AS row_count FROM fact_sales_pipeline;

-- Step 7: verify null counts
SELECT
    SUM(account IS NULL) AS null_accounts,        -- expect 1425
    SUM(close_date IS NULL) AS null_close_dates,   -- expect 2089
    SUM(close_value IS NULL) AS null_close_values  -- expect 2089
FROM fact_sales_pipeline;

-- Step 8: verify stage breakdown — should show all 4 stages this time
SELECT deal_stage, COUNT(*) AS n
FROM fact_sales_pipeline
GROUP BY deal_stage;
-- expect: Won 4238, Lost 2473, Engaging 1589, Prospecting 500

-- Step 9: cleanup — staging table no longer needed
DROP TABLE staging_sales_pipeline; 