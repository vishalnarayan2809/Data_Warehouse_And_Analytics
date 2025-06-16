"""
Data Warehouse ETL DAG
----------------------
This DAG orchestrates the ETL process for the data warehouse, loading data through
the Bronze, Silver, and Gold layers.

Author: Vishal N
Date: June 17, 2025
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.oracle.operators.oracle import OracleOperator
from airflow.utils.task_group import TaskGroup
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.sensors.external_task import ExternalTaskSensor
import logging

# Default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# DAG definition
dag = DAG(
    'data_warehouse_etl',
    default_args=default_args,
    description='ETL process for data warehouse (Bronze -> Silver -> Gold)',
    schedule_interval='0 2 * * *',  # Run daily at 2 AM
    start_date=datetime(2025, 6, 1),
    catchup=False,
    tags=['data_warehouse', 'etl'],
)

# Database connection configuration
# The database can be toggled between PostgreSQL and Oracle
db_type = "postgres"  # Options: "postgres" or "oracle"

# Task to check database connectivity
def check_db_connection(**kwargs):
    if db_type == "postgres":
        hook = PostgresHook(postgres_conn_id="postgres_dwh")
        conn = hook.get_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if result and result[0] == 1:
            logging.info("PostgreSQL connection successful")
            return True
        else:
            raise Exception("PostgreSQL connection failed")
    else:
        # Oracle connection check would be implemented here
        logging.info("Oracle connection check not implemented yet")
        return True

check_connection = PythonOperator(
    task_id='check_db_connection',
    python_callable=check_db_connection,
    dag=dag,
)

# Log start of ETL process
start_etl = BashOperator(
    task_id='start_etl',
    bash_command='echo "Starting ETL process at $(date)"',
    dag=dag,
)

# Bronze layer ETL tasks
with TaskGroup(group_id='bronze_layer', dag=dag) as bronze_layer:
    if db_type == "postgres":
        # PostgreSQL tasks
        truncate_bronze_tables = PostgresOperator(
            task_id='truncate_bronze_tables',
            postgres_conn_id='postgres_dwh',
            sql="""
                TRUNCATE TABLE bronze.crm_cust_info;
                TRUNCATE TABLE bronze.crm_prd_info;
                TRUNCATE TABLE bronze.crm_sales_details;
                TRUNCATE TABLE bronze.erp_cust_az12;
                TRUNCATE TABLE bronze.erp_loc_a101;
                TRUNCATE TABLE bronze.erp_px_cat_g1v2;
            """,
        )
        
        load_bronze = PostgresOperator(
            task_id='load_bronze',
            postgres_conn_id='postgres_dwh',
            sql="SELECT bronze.load_bronze();",
        )
        
        truncate_bronze_tables >> load_bronze
    
    else:
        # Oracle tasks
        load_bronze_oracle = OracleOperator(
            task_id='load_bronze_oracle',
            oracle_conn_id='oracle_dwh',
            sql="""
                BEGIN
                  bronze_etl.load_bronze;
                END;
            """,
        )

# Silver layer ETL tasks
with TaskGroup(group_id='silver_layer', dag=dag) as silver_layer:
    if db_type == "postgres":
        # PostgreSQL tasks
        load_silver = PostgresOperator(
            task_id='load_silver',
            postgres_conn_id='postgres_dwh',
            sql="SELECT silver.load_silver();",
        )
    else:
        # Oracle tasks
        load_silver_oracle = OracleOperator(
            task_id='load_silver_oracle',
            oracle_conn_id='oracle_dwh',
            sql="""
                BEGIN
                  silver_etl.load_silver;
                END;
            """,
        )

# Gold layer ETL tasks
with TaskGroup(group_id='gold_layer', dag=dag) as gold_layer:
    if db_type == "postgres":
        # PostgreSQL tasks
        refresh_gold = PostgresOperator(
            task_id='refresh_gold_views',
            postgres_conn_id='postgres_dwh',
            sql="""
                -- The Gold layer consists of views, so we just need to ensure they're up to date
                -- This can include materialized view refreshes if implemented
                SELECT 1;
            """,
        )
        
        validate_gold_data = PostgresOperator(
            task_id='validate_gold_data',
            postgres_conn_id='postgres_dwh',
            sql="SELECT * FROM gold.validate_data_quality();",
        )
        
        refresh_gold >> validate_gold_data
    
    else:
        # Oracle tasks
        refresh_gold_oracle = OracleOperator(
            task_id='refresh_gold_views_oracle',
            oracle_conn_id='oracle_dwh',
            sql="""
                BEGIN
                  gold_etl.refresh_materialized_views;
                END;
            """,
        )

# Data quality checks
data_quality_checks = BashOperator(
    task_id='run_data_quality_checks',
    bash_command='cd /opt/airflow/scripts && python run_data_quality_checks.py',
    dag=dag,
)

# Log end of ETL process
end_etl = BashOperator(
    task_id='end_etl',
    bash_command='echo "ETL process completed at $(date)"',
    dag=dag,
)

# Define task dependencies
check_connection >> start_etl >> bronze_layer >> silver_layer >> gold_layer >> data_quality_checks >> end_etl
