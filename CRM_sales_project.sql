Create database crm_sales; 
use crm_sales; 

----------- Dimension: Product ----------
CREATE TABLE dim_product (
    product        VARCHAR(50) PRIMARY KEY,
    series         VARCHAR(20),
    sales_price    DECIMAL(10,2)
); 

---------- Dimension: Account ----------
CREATE TABLE dim_account (
    account            VARCHAR(100) PRIMARY KEY,
    sector             VARCHAR(50),
    year_established   INT,
    revenue            DECIMAL(12,2),
    employees          INT,
    office_location    VARCHAR(100),
    subsidiary_of      VARCHAR(100)
);
 
  ---------- Dimension: Sales Agent (with manager/region rolled in) ----------
CREATE TABLE dim_agent (
    sales_agent        VARCHAR(100) PRIMARY KEY,
    manager            VARCHAR(100),
    regional_office     VARCHAR(50)
); 

---------- Fact: Sales Pipeline ----------
CREATE TABLE fact_sales_pipeline (
    opportunity_id   VARCHAR(20) PRIMARY KEY,
    sales_agent      VARCHAR(100),
    product          VARCHAR(50),
    account          VARCHAR(100) NULL,       -- can be NULL, see data notes
    deal_stage       VARCHAR(20),
    engage_date      DATE NULL,
    close_date       DATE NULL,
    close_value      DECIMAL(10,2) NULL,
    FOREIGN KEY (sales_agent) REFERENCES dim_agent(sales_agent),
    FOREIGN KEY (product) REFERENCES dim_product(product)
    -- NOTE: no FK on account -> dim_account, because 1,425 rows have NULL account.
    -- Enforcing it would block the load. Handle the join as LEFT JOIN in queries. 
    
    );  
    
    DROP TABLE IF EXISTS dim_account;
    
create TABLE dim_account (
    account            VARCHAR(100) PRIMARY KEY,
    sector             VARCHAR(50),
    year_established   INT,
    revenue            DECIMAL(12,2),
    employees          INT,
    office_location    VARCHAR(100),
    subsidiary_of      VARCHAR(100)
);
 
 SELECT COUNT(*) FROM dim_account; 
 
 
 
    