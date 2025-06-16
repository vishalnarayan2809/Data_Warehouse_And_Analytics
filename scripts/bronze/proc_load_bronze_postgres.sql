/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze) for PostgreSQL
===============================================================================
Script Purpose:
    This script loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the PostgreSQL COPY command to load data from CSV files to bronze tables.
    - Records execution metrics and errors in the logging table.

Usage Example:
    SELECT bronze.load_bronze();
===============================================================================
*/

-- Create function to load bronze layer
CREATE OR REPLACE FUNCTION bronze.load_bronze()
RETURNS void AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_batch_start_time TIMESTAMP;
    v_records INTEGER;
    v_error_message TEXT;
BEGIN
    v_batch_start_time := CURRENT_TIMESTAMP;
    
    -- Log start of process
    INSERT INTO bronze.etl_logging (process_name, start_time, status)
    VALUES ('bronze.load_bronze', v_batch_start_time, 'RUNNING');
    
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    -- Load CRM Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    BEGIN
        -- Load CRM Customer Info
        v_start_time := CURRENT_TIMESTAMP;
        RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        
        RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
        EXECUTE 'COPY bronze.crm_cust_info FROM ''/datasets/source_crm/cust_info.csv'' WITH (FORMAT CSV, HEADER, DELIMITER '','')';
        
        GET DIAGNOSTICS v_records = ROW_COUNT;
        v_end_time := CURRENT_TIMESTAMP;
        
        RAISE NOTICE '>> Loaded % records', v_records;
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));
        RAISE NOTICE '>> -------------';
        
        -- Log successful load
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, records_processed)
        VALUES ('bronze.load_crm_cust_info', v_start_time, v_end_time, 'SUCCESS', v_records);
    EXCEPTION WHEN OTHERS THEN
        v_error_message := SQLERRM;
        RAISE NOTICE '>> ERROR: %', v_error_message;
        
        -- Log error
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, error_message)
        VALUES ('bronze.load_crm_cust_info', v_start_time, CURRENT_TIMESTAMP, 'ERROR', v_error_message);
    END;

    BEGIN
        -- Load CRM Product Info
        v_start_time := CURRENT_TIMESTAMP;
        RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        
        RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
        EXECUTE 'COPY bronze.crm_prd_info FROM ''/datasets/source_crm/prd_info.csv'' WITH (FORMAT CSV, HEADER, DELIMITER '','')';
        
        GET DIAGNOSTICS v_records = ROW_COUNT;
        v_end_time := CURRENT_TIMESTAMP;
        
        RAISE NOTICE '>> Loaded % records', v_records;
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));
        RAISE NOTICE '>> -------------';
        
        -- Log successful load
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, records_processed)
        VALUES ('bronze.load_crm_prd_info', v_start_time, v_end_time, 'SUCCESS', v_records);
    EXCEPTION WHEN OTHERS THEN
        v_error_message := SQLERRM;
        RAISE NOTICE '>> ERROR: %', v_error_message;
        
        -- Log error
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, error_message)
        VALUES ('bronze.load_crm_prd_info', v_start_time, CURRENT_TIMESTAMP, 'ERROR', v_error_message);
    END;

    BEGIN
        -- Load CRM Sales Details
        v_start_time := CURRENT_TIMESTAMP;
        RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        
        RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
        EXECUTE 'COPY bronze.crm_sales_details FROM ''/datasets/source_crm/sales_details.csv'' WITH (FORMAT CSV, HEADER, DELIMITER '','')';
        
        GET DIAGNOSTICS v_records = ROW_COUNT;
        v_end_time := CURRENT_TIMESTAMP;
        
        RAISE NOTICE '>> Loaded % records', v_records;
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));
        RAISE NOTICE '>> -------------';
        
        -- Log successful load
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, records_processed)
        VALUES ('bronze.load_crm_sales_details', v_start_time, v_end_time, 'SUCCESS', v_records);
    EXCEPTION WHEN OTHERS THEN
        v_error_message := SQLERRM;
        RAISE NOTICE '>> ERROR: %', v_error_message;
        
        -- Log error
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, error_message)
        VALUES ('bronze.load_crm_sales_details', v_start_time, CURRENT_TIMESTAMP, 'ERROR', v_error_message);
    END;

    -- Load ERP Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    BEGIN
        -- Load ERP Customer Data
        v_start_time := CURRENT_TIMESTAMP;
        RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        
        RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
        EXECUTE 'COPY bronze.erp_cust_az12 FROM ''/datasets/source_erp/CUST_AZ12.csv'' WITH (FORMAT CSV, HEADER, DELIMITER '','')';
        
        GET DIAGNOSTICS v_records = ROW_COUNT;
        v_end_time := CURRENT_TIMESTAMP;
        
        RAISE NOTICE '>> Loaded % records', v_records;
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));
        RAISE NOTICE '>> -------------';
        
        -- Log successful load
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, records_processed)
        VALUES ('bronze.load_erp_cust_az12', v_start_time, v_end_time, 'SUCCESS', v_records);
    EXCEPTION WHEN OTHERS THEN
        v_error_message := SQLERRM;
        RAISE NOTICE '>> ERROR: %', v_error_message;
        
        -- Log error
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, error_message)
        VALUES ('bronze.load_erp_cust_az12', v_start_time, CURRENT_TIMESTAMP, 'ERROR', v_error_message);
    END;

    BEGIN
        -- Load ERP Location Data
        v_start_time := CURRENT_TIMESTAMP;
        RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        
        RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
        EXECUTE 'COPY bronze.erp_loc_a101 FROM ''/datasets/source_erp/LOC_A101.csv'' WITH (FORMAT CSV, HEADER, DELIMITER '','')';
        
        GET DIAGNOSTICS v_records = ROW_COUNT;
        v_end_time := CURRENT_TIMESTAMP;
        
        RAISE NOTICE '>> Loaded % records', v_records;
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));
        RAISE NOTICE '>> -------------';
        
        -- Log successful load
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, records_processed)
        VALUES ('bronze.load_erp_loc_a101', v_start_time, v_end_time, 'SUCCESS', v_records);
    EXCEPTION WHEN OTHERS THEN
        v_error_message := SQLERRM;
        RAISE NOTICE '>> ERROR: %', v_error_message;
        
        -- Log error
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, error_message)
        VALUES ('bronze.load_erp_loc_a101', v_start_time, CURRENT_TIMESTAMP, 'ERROR', v_error_message);
    END;

    BEGIN
        -- Load ERP Product Category Data
        v_start_time := CURRENT_TIMESTAMP;
        RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        
        RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        EXECUTE 'COPY bronze.erp_px_cat_g1v2 FROM ''/datasets/source_erp/PX_CAT_G1V2.csv'' WITH (FORMAT CSV, HEADER, DELIMITER '','')';
        
        GET DIAGNOSTICS v_records = ROW_COUNT;
        v_end_time := CURRENT_TIMESTAMP;
        
        RAISE NOTICE '>> Loaded % records', v_records;
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));
        RAISE NOTICE '>> -------------';
        
        -- Log successful load
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, records_processed)
        VALUES ('bronze.load_erp_px_cat_g1v2', v_start_time, v_end_time, 'SUCCESS', v_records);
    EXCEPTION WHEN OTHERS THEN
        v_error_message := SQLERRM;
        RAISE NOTICE '>> ERROR: %', v_error_message;
        
        -- Log error
        INSERT INTO bronze.etl_logging (process_name, start_time, end_time, status, error_message)
        VALUES ('bronze.load_erp_px_cat_g1v2', v_start_time, CURRENT_TIMESTAMP, 'ERROR', v_error_message);
    END;

    -- Update main process log
    UPDATE bronze.etl_logging
    SET end_time = CURRENT_TIMESTAMP,
        status = 'SUCCESS'
    WHERE process_name = 'bronze.load_bronze'
      AND start_time = v_batch_start_time;
      
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Bronze Layer Loading Completed';
    RAISE NOTICE '================================================';
    
EXCEPTION WHEN OTHERS THEN
    v_error_message := SQLERRM;
    RAISE NOTICE 'ERROR in bronze.load_bronze: %', v_error_message;
    
    -- Update main process log with error
    UPDATE bronze.etl_logging
    SET end_time = CURRENT_TIMESTAMP,
        status = 'ERROR',
        error_message = v_error_message
    WHERE process_name = 'bronze.load_bronze'
      AND start_time = v_batch_start_time;
END;
$$ LANGUAGE plpgsql;
