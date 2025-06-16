#!/bin/bash
# Initialize PostgreSQL database with schema structure

set -e

echo "Creating schemas for DataWarehouse..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create schemas
    CREATE SCHEMA bronze;
    CREATE SCHEMA silver;
    CREATE SCHEMA gold;
    
    -- Set search path
    ALTER DATABASE datawarehouse SET search_path TO bronze, silver, gold, public;
    
    -- Create bronze tables
    CREATE TABLE bronze.crm_cust_info (
        cst_id              INTEGER,
        cst_key             VARCHAR(50),
        cst_firstname       VARCHAR(50),
        cst_lastname        VARCHAR(50),
        cst_marital_status  VARCHAR(50),
        cst_gndr            VARCHAR(50),
        cst_create_date     DATE
    );
    
    CREATE TABLE bronze.crm_prd_info (
        prd_id       INTEGER,
        prd_key      VARCHAR(50),
        prd_nm       VARCHAR(50),
        prd_cost     INTEGER,
        prd_line     VARCHAR(50),
        prd_start_dt TIMESTAMP,
        prd_end_dt   TIMESTAMP
    );
    
    CREATE TABLE bronze.crm_sales_details (
        sls_ord_num  VARCHAR(50),
        sls_prd_key  VARCHAR(50),
        sls_cust_id  INTEGER,
        sls_order_dt INTEGER,
        sls_qty      INTEGER,
        sls_unit_prc INTEGER,
        sls_amt      INTEGER,
        sls_loc_id   INTEGER
    );
    
    CREATE TABLE bronze.erp_cust_az12 (
        cid       VARCHAR(50),
        gen       VARCHAR(1),
        bdate     DATE,
        vip_flg   INTEGER,
        income_b  VARCHAR(50)
    );
    
    CREATE TABLE bronze.erp_loc_a101 (
        lid    INTEGER,
        cid    VARCHAR(50),
        cntry  VARCHAR(50),
        ctg    VARCHAR(50)
    );
    
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        px_id      VARCHAR(50),
        cat_code   VARCHAR(50),
        cat_name   VARCHAR(100),
        prod_cst   NUMERIC(10,2),
        sup_id     INTEGER,
        sup_name   VARCHAR(100),
        sup_cntry  VARCHAR(50)
    );
    
    -- Create logging table for ETL
    CREATE TABLE bronze.etl_logging (
        log_id          SERIAL PRIMARY KEY,
        process_name    VARCHAR(100) NOT NULL,
        start_time      TIMESTAMP NOT NULL,
        end_time        TIMESTAMP,
        status          VARCHAR(20),
        records_processed INTEGER,
        error_message   TEXT
    );
    
    -- Create view for ETL monitoring
    CREATE VIEW bronze.etl_monitor AS
    SELECT 
        process_name,
        start_time,
        end_time,
        status,
        records_processed,
        EXTRACT(EPOCH FROM (end_time - start_time)) AS duration_seconds
    FROM bronze.etl_logging
    WHERE end_time IS NOT NULL
    ORDER BY start_time DESC;
    
    -- Grant permissions
    GRANT ALL PRIVILEGES ON SCHEMA bronze TO dwh_user;
    GRANT ALL PRIVILEGES ON SCHEMA silver TO dwh_user;
    GRANT ALL PRIVILEGES ON SCHEMA gold TO dwh_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA bronze TO dwh_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA silver TO dwh_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA gold TO dwh_user;
EOSQL

echo "PostgreSQL database initialization completed!"
