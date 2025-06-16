/*
===============================================================================
PL/SQL Package: Load Bronze Layer (Source -> Bronze) for Oracle
===============================================================================
Script Purpose:
    This package loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses external tables and SQL*Loader to load data from CSV files.
    - Records execution metrics and errors in the logging table.

Usage Example:
    BEGIN
      bronze_etl.load_bronze;
    END;
    /
===============================================================================
*/

-- Create package specification
CREATE OR REPLACE PACKAGE bronze_etl AS
    PROCEDURE load_bronze;
    PROCEDURE load_crm_cust_info;
    PROCEDURE load_crm_prd_info;
    PROCEDURE load_crm_sales_details;
    PROCEDURE load_erp_cust_az12;
    PROCEDURE load_erp_loc_a101;
    PROCEDURE load_erp_px_cat_g1v2;
END bronze_etl;
/

-- Create package body
CREATE OR REPLACE PACKAGE BODY bronze_etl AS
    -- Procedure to log ETL start
    PROCEDURE log_start(p_process_name IN VARCHAR2) IS
    BEGIN
        INSERT INTO bronze_etl_logging (process_name, start_time, status)
        VALUES (p_process_name, SYSTIMESTAMP, 'RUNNING');
    END;
    
    -- Procedure to log ETL success
    PROCEDURE log_success(p_process_name IN VARCHAR2, p_start_time IN TIMESTAMP, p_records IN NUMBER) IS
    BEGIN
        INSERT INTO bronze_etl_logging (process_name, start_time, end_time, status, records_processed)
        VALUES (p_process_name, p_start_time, SYSTIMESTAMP, 'SUCCESS', p_records);
    END;
    
    -- Procedure to log ETL error
    PROCEDURE log_error(p_process_name IN VARCHAR2, p_start_time IN TIMESTAMP, p_error_message IN VARCHAR2) IS
    BEGIN
        INSERT INTO bronze_etl_logging (process_name, start_time, end_time, status, error_message)
        VALUES (p_process_name, p_start_time, SYSTIMESTAMP, 'ERROR', p_error_message);
    END;
    
    -- Procedure to load CRM Customer Info
    PROCEDURE load_crm_cust_info IS
        v_start_time TIMESTAMP;
        v_rows_affected NUMBER;
    BEGIN
        v_start_time := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('>> Truncating Table: bronze_crm_cust_info');
        EXECUTE IMMEDIATE 'TRUNCATE TABLE bronze_crm_cust_info';
        
        DBMS_OUTPUT.PUT_LINE('>> Inserting Data Into: bronze_crm_cust_info');
        
        -- Create external table for loading
        BEGIN
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE DIRECTORY CSV_DIR AS ''/datasets/source_crm''';
            
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW ext_crm_cust_info AS
            SELECT *
            FROM EXTERNAL (
                (
                    cst_id              NUMBER,
                    cst_key             VARCHAR2(50),
                    cst_firstname       VARCHAR2(50),
                    cst_lastname        VARCHAR2(50),
                    cst_marital_status  VARCHAR2(50),
                    cst_gndr            VARCHAR2(50),
                    cst_create_date     DATE
                )
                TYPE ORACLE_LOADER
                DEFAULT DIRECTORY CSV_DIR
                ACCESS PARAMETERS (
                    RECORDS DELIMITED BY NEWLINE
                    SKIP 1
                    FIELDS TERMINATED BY '',''
                    OPTIONALLY ENCLOSED BY ''"''
                    MISSING FIELD VALUES ARE NULL
                    DATE_FORMAT DATE_FORMAT MASK "YYYY-MM-DD"
                )
                LOCATION (''cust_info.csv'')
                REJECT LIMIT UNLIMITED
            )';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignore errors if views already exist
        END;
        
        -- Insert data
        INSERT INTO bronze_crm_cust_info
        SELECT * FROM ext_crm_cust_info;
        
        v_rows_affected := SQL%ROWCOUNT;
        
        DBMS_OUTPUT.PUT_LINE('>> Loaded ' || v_rows_affected || ' records');
        DBMS_OUTPUT.PUT_LINE('>> Load Duration: ' || 
            ROUND(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)), 2) || ' seconds');
        DBMS_OUTPUT.PUT_LINE('>> -------------');
        
        log_success('bronze_etl.load_crm_cust_info', v_start_time, v_rows_affected);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('>> ERROR: ' || SQLERRM);
            log_error('bronze_etl.load_crm_cust_info', v_start_time, SQLERRM);
            RAISE;
    END;
    
    -- Procedure to load CRM Product Info
    PROCEDURE load_crm_prd_info IS
        v_start_time TIMESTAMP;
        v_rows_affected NUMBER;
    BEGIN
        v_start_time := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('>> Truncating Table: bronze_crm_prd_info');
        EXECUTE IMMEDIATE 'TRUNCATE TABLE bronze_crm_prd_info';
        
        DBMS_OUTPUT.PUT_LINE('>> Inserting Data Into: bronze_crm_prd_info');
        
        -- Create external table for loading
        BEGIN
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW ext_crm_prd_info AS
            SELECT *
            FROM EXTERNAL (
                (
                    prd_id       NUMBER,
                    prd_key      VARCHAR2(50),
                    prd_nm       VARCHAR2(50),
                    prd_cost     NUMBER,
                    prd_line     VARCHAR2(50),
                    prd_start_dt TIMESTAMP,
                    prd_end_dt   TIMESTAMP
                )
                TYPE ORACLE_LOADER
                DEFAULT DIRECTORY CSV_DIR
                ACCESS PARAMETERS (
                    RECORDS DELIMITED BY NEWLINE
                    SKIP 1
                    FIELDS TERMINATED BY '',''
                    OPTIONALLY ENCLOSED BY ''"''
                    MISSING FIELD VALUES ARE NULL
                    DATE_FORMAT TIMESTAMP MASK "YYYY-MM-DD HH24:MI:SS"
                )
                LOCATION (''prd_info.csv'')
                REJECT LIMIT UNLIMITED
            )';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignore errors if views already exist
        END;
        
        -- Insert data
        INSERT INTO bronze_crm_prd_info
        SELECT * FROM ext_crm_prd_info;
        
        v_rows_affected := SQL%ROWCOUNT;
        
        DBMS_OUTPUT.PUT_LINE('>> Loaded ' || v_rows_affected || ' records');
        DBMS_OUTPUT.PUT_LINE('>> Load Duration: ' || 
            ROUND(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)), 2) || ' seconds');
        DBMS_OUTPUT.PUT_LINE('>> -------------');
        
        log_success('bronze_etl.load_crm_prd_info', v_start_time, v_rows_affected);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('>> ERROR: ' || SQLERRM);
            log_error('bronze_etl.load_crm_prd_info', v_start_time, SQLERRM);
            RAISE;
    END;
    
    -- Procedure to load CRM Sales Details
    PROCEDURE load_crm_sales_details IS
        v_start_time TIMESTAMP;
        v_rows_affected NUMBER;
    BEGIN
        v_start_time := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('>> Truncating Table: bronze_crm_sales_details');
        EXECUTE IMMEDIATE 'TRUNCATE TABLE bronze_crm_sales_details';
        
        DBMS_OUTPUT.PUT_LINE('>> Inserting Data Into: bronze_crm_sales_details');
        
        -- Create external table for loading
        BEGIN
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW ext_crm_sales_details AS
            SELECT *
            FROM EXTERNAL (
                (
                    sls_ord_num  VARCHAR2(50),
                    sls_prd_key  VARCHAR2(50),
                    sls_cust_id  NUMBER,
                    sls_order_dt NUMBER,
                    sls_qty      NUMBER,
                    sls_unit_prc NUMBER,
                    sls_amt      NUMBER,
                    sls_loc_id   NUMBER
                )
                TYPE ORACLE_LOADER
                DEFAULT DIRECTORY CSV_DIR
                ACCESS PARAMETERS (
                    RECORDS DELIMITED BY NEWLINE
                    SKIP 1
                    FIELDS TERMINATED BY '',''
                    OPTIONALLY ENCLOSED BY ''"''
                    MISSING FIELD VALUES ARE NULL
                )
                LOCATION (''sales_details.csv'')
                REJECT LIMIT UNLIMITED
            )';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignore errors if views already exist
        END;
        
        -- Insert data
        INSERT INTO bronze_crm_sales_details
        SELECT * FROM ext_crm_sales_details;
        
        v_rows_affected := SQL%ROWCOUNT;
        
        DBMS_OUTPUT.PUT_LINE('>> Loaded ' || v_rows_affected || ' records');
        DBMS_OUTPUT.PUT_LINE('>> Load Duration: ' || 
            ROUND(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)), 2) || ' seconds');
        DBMS_OUTPUT.PUT_LINE('>> -------------');
        
        log_success('bronze_etl.load_crm_sales_details', v_start_time, v_rows_affected);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('>> ERROR: ' || SQLERRM);
            log_error('bronze_etl.load_crm_sales_details', v_start_time, SQLERRM);
            RAISE;
    END;
    
    -- Procedure to load ERP Customer Data
    PROCEDURE load_erp_cust_az12 IS
        v_start_time TIMESTAMP;
        v_rows_affected NUMBER;
    BEGIN
        v_start_time := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('>> Truncating Table: bronze_erp_cust_az12');
        EXECUTE IMMEDIATE 'TRUNCATE TABLE bronze_erp_cust_az12';
        
        DBMS_OUTPUT.PUT_LINE('>> Inserting Data Into: bronze_erp_cust_az12');
        
        -- Create external table for loading
        BEGIN
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE DIRECTORY ERP_DIR AS ''/datasets/source_erp''';
            
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW ext_erp_cust_az12 AS
            SELECT *
            FROM EXTERNAL (
                (
                    cid       VARCHAR2(50),
                    gen       VARCHAR2(1),
                    bdate     DATE,
                    vip_flg   NUMBER,
                    income_b  VARCHAR2(50)
                )
                TYPE ORACLE_LOADER
                DEFAULT DIRECTORY ERP_DIR
                ACCESS PARAMETERS (
                    RECORDS DELIMITED BY NEWLINE
                    SKIP 1
                    FIELDS TERMINATED BY '',''
                    OPTIONALLY ENCLOSED BY ''"''
                    MISSING FIELD VALUES ARE NULL
                    DATE_FORMAT DATE MASK "YYYY-MM-DD"
                )
                LOCATION (''CUST_AZ12.csv'')
                REJECT LIMIT UNLIMITED
            )';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignore errors if views already exist
        END;
        
        -- Insert data
        INSERT INTO bronze_erp_cust_az12
        SELECT * FROM ext_erp_cust_az12;
        
        v_rows_affected := SQL%ROWCOUNT;
        
        DBMS_OUTPUT.PUT_LINE('>> Loaded ' || v_rows_affected || ' records');
        DBMS_OUTPUT.PUT_LINE('>> Load Duration: ' || 
            ROUND(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)), 2) || ' seconds');
        DBMS_OUTPUT.PUT_LINE('>> -------------');
        
        log_success('bronze_etl.load_erp_cust_az12', v_start_time, v_rows_affected);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('>> ERROR: ' || SQLERRM);
            log_error('bronze_etl.load_erp_cust_az12', v_start_time, SQLERRM);
            RAISE;
    END;
    
    -- Procedure to load ERP Location Data
    PROCEDURE load_erp_loc_a101 IS
        v_start_time TIMESTAMP;
        v_rows_affected NUMBER;
    BEGIN
        v_start_time := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('>> Truncating Table: bronze_erp_loc_a101');
        EXECUTE IMMEDIATE 'TRUNCATE TABLE bronze_erp_loc_a101';
        
        DBMS_OUTPUT.PUT_LINE('>> Inserting Data Into: bronze_erp_loc_a101');
        
        -- Create external table for loading
        BEGIN
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW ext_erp_loc_a101 AS
            SELECT *
            FROM EXTERNAL (
                (
                    lid    NUMBER,
                    cid    VARCHAR2(50),
                    cntry  VARCHAR2(50),
                    ctg    VARCHAR2(50)
                )
                TYPE ORACLE_LOADER
                DEFAULT DIRECTORY ERP_DIR
                ACCESS PARAMETERS (
                    RECORDS DELIMITED BY NEWLINE
                    SKIP 1
                    FIELDS TERMINATED BY '',''
                    OPTIONALLY ENCLOSED BY ''"''
                    MISSING FIELD VALUES ARE NULL
                )
                LOCATION (''LOC_A101.csv'')
                REJECT LIMIT UNLIMITED
            )';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignore errors if views already exist
        END;
        
        -- Insert data
        INSERT INTO bronze_erp_loc_a101
        SELECT * FROM ext_erp_loc_a101;
        
        v_rows_affected := SQL%ROWCOUNT;
        
        DBMS_OUTPUT.PUT_LINE('>> Loaded ' || v_rows_affected || ' records');
        DBMS_OUTPUT.PUT_LINE('>> Load Duration: ' || 
            ROUND(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)), 2) || ' seconds');
        DBMS_OUTPUT.PUT_LINE('>> -------------');
        
        log_success('bronze_etl.load_erp_loc_a101', v_start_time, v_rows_affected);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('>> ERROR: ' || SQLERRM);
            log_error('bronze_etl.load_erp_loc_a101', v_start_time, SQLERRM);
            RAISE;
    END;
    
    -- Procedure to load ERP Product Category Data
    PROCEDURE load_erp_px_cat_g1v2 IS
        v_start_time TIMESTAMP;
        v_rows_affected NUMBER;
    BEGIN
        v_start_time := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('>> Truncating Table: bronze_erp_px_cat_g1v2');
        EXECUTE IMMEDIATE 'TRUNCATE TABLE bronze_erp_px_cat_g1v2';
        
        DBMS_OUTPUT.PUT_LINE('>> Inserting Data Into: bronze_erp_px_cat_g1v2');
        
        -- Create external table for loading
        BEGIN
            EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW ext_erp_px_cat_g1v2 AS
            SELECT *
            FROM EXTERNAL (
                (
                    px_id      VARCHAR2(50),
                    cat_code   VARCHAR2(50),
                    cat_name   VARCHAR2(100),
                    prod_cst   NUMBER(10,2),
                    sup_id     NUMBER,
                    sup_name   VARCHAR2(100),
                    sup_cntry  VARCHAR2(50)
                )
                TYPE ORACLE_LOADER
                DEFAULT DIRECTORY ERP_DIR
                ACCESS PARAMETERS (
                    RECORDS DELIMITED BY NEWLINE
                    SKIP 1
                    FIELDS TERMINATED BY '',''
                    OPTIONALLY ENCLOSED BY ''"''
                    MISSING FIELD VALUES ARE NULL
                )
                LOCATION (''PX_CAT_G1V2.csv'')
                REJECT LIMIT UNLIMITED
            )';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignore errors if views already exist
        END;
        
        -- Insert data
        INSERT INTO bronze_erp_px_cat_g1v2
        SELECT * FROM ext_erp_px_cat_g1v2;
        
        v_rows_affected := SQL%ROWCOUNT;
        
        DBMS_OUTPUT.PUT_LINE('>> Loaded ' || v_rows_affected || ' records');
        DBMS_OUTPUT.PUT_LINE('>> Load Duration: ' || 
            ROUND(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)), 2) || ' seconds');
        DBMS_OUTPUT.PUT_LINE('>> -------------');
        
        log_success('bronze_etl.load_erp_px_cat_g1v2', v_start_time, v_rows_affected);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('>> ERROR: ' || SQLERRM);
            log_error('bronze_etl.load_erp_px_cat_g1v2', v_start_time, SQLERRM);
            RAISE;
    END;
    
    -- Main procedure to load all bronze tables
    PROCEDURE load_bronze IS
        v_batch_start_time TIMESTAMP;
        v_error_message VARCHAR2(4000);
    BEGIN
        v_batch_start_time := SYSTIMESTAMP;
        
        -- Log start of process
        log_start('bronze_etl.load_bronze');
        
        DBMS_OUTPUT.PUT_LINE('================================================');
        DBMS_OUTPUT.PUT_LINE('Loading Bronze Layer');
        DBMS_OUTPUT.PUT_LINE('================================================');
        
        -- Load CRM Tables
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Loading CRM Tables');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        
        load_crm_cust_info;
        load_crm_prd_info;
        load_crm_sales_details;
        
        -- Load ERP Tables
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Loading ERP Tables');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        
        load_erp_cust_az12;
        load_erp_loc_a101;
        load_erp_px_cat_g1v2;
        
        -- Update main process log
        UPDATE bronze_etl_logging
        SET end_time = SYSTIMESTAMP,
            status = 'SUCCESS'
        WHERE process_name = 'bronze_etl.load_bronze'
          AND start_time = v_batch_start_time;
          
        DBMS_OUTPUT.PUT_LINE('================================================');
        DBMS_OUTPUT.PUT_LINE('Bronze Layer Loading Completed');
        DBMS_OUTPUT.PUT_LINE('================================================');
        
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('ERROR in bronze_etl.load_bronze: ' || v_error_message);
            
            -- Update main process log with error
            UPDATE bronze_etl_logging
            SET end_time = SYSTIMESTAMP,
                status = 'ERROR',
                error_message = v_error_message
            WHERE process_name = 'bronze_etl.load_bronze'
              AND start_time = v_batch_start_time;
            
            RAISE;
    END;
    
END bronze_etl;
/
