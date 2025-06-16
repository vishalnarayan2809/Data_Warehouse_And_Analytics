#!/bin/bash
# Oracle Database Initialization Script

# Create tablespaces and users
sqlplus / as sysdba <<EOF
-- Create tablespaces
CREATE TABLESPACE dwh_data DATAFILE 'dwh_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
CREATE TABLESPACE dwh_idx DATAFILE 'dwh_idx01.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE UNLIMITED;

-- Create user
CREATE USER dwh_user IDENTIFIED BY dwh_password 
DEFAULT TABLESPACE dwh_data
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON dwh_data
QUOTA UNLIMITED ON dwh_idx;

-- Grant permissions
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE, CREATE MATERIALIZED VIEW TO dwh_user;
ALTER USER dwh_user DEFAULT ROLE ALL;

CONNECT dwh_user/dwh_password

-- Create schemas (in Oracle, these are implemented as separate users with permissions)
-- For this implementation, we'll use table prefixes instead

-- Create bronze tables
CREATE TABLE bronze_crm_cust_info (
    cst_id              NUMBER,
    cst_key             VARCHAR2(50),
    cst_firstname       VARCHAR2(50),
    cst_lastname        VARCHAR2(50),
    cst_marital_status  VARCHAR2(50),
    cst_gndr            VARCHAR2(50),
    cst_create_date     DATE
);

CREATE TABLE bronze_crm_prd_info (
    prd_id       NUMBER,
    prd_key      VARCHAR2(50),
    prd_nm       VARCHAR2(50),
    prd_cost     NUMBER,
    prd_line     VARCHAR2(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt   TIMESTAMP
);

CREATE TABLE bronze_crm_sales_details (
    sls_ord_num  VARCHAR2(50),
    sls_prd_key  VARCHAR2(50),
    sls_cust_id  NUMBER,
    sls_order_dt NUMBER,
    sls_qty      NUMBER,
    sls_unit_prc NUMBER,
    sls_amt      NUMBER,
    sls_loc_id   NUMBER
);

CREATE TABLE bronze_erp_cust_az12 (
    cid       VARCHAR2(50),
    gen       VARCHAR2(1),
    bdate     DATE,
    vip_flg   NUMBER,
    income_b  VARCHAR2(50)
);

CREATE TABLE bronze_erp_loc_a101 (
    lid    NUMBER,
    cid    VARCHAR2(50),
    cntry  VARCHAR2(50),
    ctg    VARCHAR2(50)
);

CREATE TABLE bronze_erp_px_cat_g1v2 (
    px_id      VARCHAR2(50),
    cat_code   VARCHAR2(50),
    cat_name   VARCHAR2(100),
    prod_cst   NUMBER(10,2),
    sup_id     NUMBER,
    sup_name   VARCHAR2(100),
    sup_cntry  VARCHAR2(50)
);

-- Create logging table for ETL
CREATE TABLE bronze_etl_logging (
    log_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    process_name    VARCHAR2(100) NOT NULL,
    start_time      TIMESTAMP NOT NULL,
    end_time        TIMESTAMP,
    status          VARCHAR2(20),
    records_processed NUMBER,
    error_message   CLOB
);

-- Create ETL monitoring view
CREATE VIEW bronze_etl_monitor AS
SELECT 
    process_name,
    start_time,
    end_time,
    status,
    records_processed,
    EXTRACT(DAY FROM (end_time - start_time))*86400 + 
    EXTRACT(HOUR FROM (end_time - start_time))*3600 + 
    EXTRACT(MINUTE FROM (end_time - start_time))*60 + 
    EXTRACT(SECOND FROM (end_time - start_time)) AS duration_seconds
FROM bronze_etl_logging
WHERE end_time IS NOT NULL
ORDER BY start_time DESC;

-- Create directories for external table loading
CREATE OR REPLACE DIRECTORY DATA_DIR AS '/datasets';
GRANT READ, WRITE ON DIRECTORY DATA_DIR TO dwh_user;

EXIT;
EOF

echo "Oracle database initialization completed!"
