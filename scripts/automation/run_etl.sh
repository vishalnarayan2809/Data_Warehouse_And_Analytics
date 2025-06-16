#!/bin/bash
# Master ETL Script for Data Warehouse
# This script orchestrates the entire ETL process across all layers
# Author: Your Name
# Date: June 17, 2025

# Set variables
export POSTGRES_HOST="localhost"
export POSTGRES_PORT="5432"
export POSTGRES_DB="datawarehouse"
export POSTGRES_USER="dwh_user"
export POSTGRES_PASSWORD="dwh_password"

export ORACLE_HOST="localhost"
export ORACLE_PORT="1521"
export ORACLE_SID="XE"
export ORACLE_USER="dwh_user"
export ORACLE_PASSWORD="dwh_password"

# Default to PostgreSQL if not specified
DB_ENGINE=${1:-"postgres"}

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_DIR="$ROOT_DIR/logs"
CONFIG_DIR="$ROOT_DIR/config"

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Log file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/etl_run_${TIMESTAMP}.log"

# Function to log messages
log() {
    local message=$1
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" | tee -a $LOG_FILE
}

# Function to run a SQL script
run_sql_script() {
    local script_path=$1
    local script_name=$(basename "$script_path")
    
    log "Running script: $script_name"
    
    if [ "$DB_ENGINE" = "postgres" ]; then
        PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -f "$script_path" >> $LOG_FILE 2>&1
        local result=$?
    elif [ "$DB_ENGINE" = "oracle" ]; then
        # Modify script path to use the Oracle version if it exists
        local oracle_script="${script_path%.sql}_oracle.sql"
        if [ -f "$oracle_script" ]; then
            script_path="$oracle_script"
        fi
        
        sqlplus -S "$ORACLE_USER/$ORACLE_PASSWORD@$ORACLE_HOST:$ORACLE_PORT/$ORACLE_SID" @"$script_path" >> $LOG_FILE 2>&1
        local result=$?
    else
        log "Unsupported database engine: $DB_ENGINE"
        return 1
    fi
    
    if [ $result -eq 0 ]; then
        log "Script completed successfully: $script_name"
    else
        log "ERROR: Script failed: $script_name"
        return 1
    fi
    
    return 0
}

# Start ETL process
log "========================================"
log "Starting ETL Process with $DB_ENGINE engine"
log "========================================"

# Check database connectivity
log "Checking database connectivity..."
if [ "$DB_ENGINE" = "postgres" ]; then
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "ERROR: Cannot connect to PostgreSQL database"
        exit 1
    fi
elif [ "$DB_ENGINE" = "oracle" ]; then
    echo "SELECT 1 FROM DUAL;" | sqlplus -S "$ORACLE_USER/$ORACLE_PASSWORD@$ORACLE_HOST:$ORACLE_PORT/$ORACLE_SID" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "ERROR: Cannot connect to Oracle database"
        exit 1
    fi
fi

log "Database connectivity confirmed"

# Record start time
START_TIME=$(date +%s)

# 1. Bronze Layer: Load data from source files
log "----------------------------------------"
log "STEP 1: Loading Bronze Layer"
log "----------------------------------------"

if [ "$DB_ENGINE" = "postgres" ]; then
    run_sql_script "$ROOT_DIR/scripts/bronze/proc_load_bronze_postgres.sql" || { log "Bronze layer loading failed"; exit 1; }
elif [ "$DB_ENGINE" = "oracle" ]; then
    run_sql_script "$ROOT_DIR/scripts/bronze/proc_load_bronze_oracle.sql" || { log "Bronze layer loading failed"; exit 1; }
fi

# 2. Silver Layer: Transform and cleanse data
log "----------------------------------------"
log "STEP 2: Loading Silver Layer"
log "----------------------------------------"

if [ "$DB_ENGINE" = "postgres" ]; then
    run_sql_script "$ROOT_DIR/scripts/silver/proc_load_silver_postgres.sql" || { log "Silver layer loading failed"; exit 1; }
elif [ "$DB_ENGINE" = "oracle" ]; then
    run_sql_script "$ROOT_DIR/scripts/silver/proc_load_silver_oracle.sql" || { log "Silver layer loading failed"; exit 1; }
fi

# 3. Gold Layer: Create dimensional model
log "----------------------------------------"
log "STEP 3: Loading Gold Layer"
log "----------------------------------------"

if [ "$DB_ENGINE" = "postgres" ]; then
    run_sql_script "$ROOT_DIR/scripts/gold/ddl_gold_postgres.sql" || { log "Gold layer creation failed"; exit 1; }
elif [ "$DB_ENGINE" = "oracle" ]; then
    run_sql_script "$ROOT_DIR/scripts/gold/ddl_gold_oracle.sql" || { log "Gold layer creation failed"; exit 1; }
fi

# 4. Run data quality checks
log "----------------------------------------"
log "STEP 4: Running Data Quality Checks"
log "----------------------------------------"

if [ "$DB_ENGINE" = "postgres" ]; then
    run_sql_script "$ROOT_DIR/tests/quality_checks_silver_postgres.sql" || { log "WARNING: Silver layer quality checks found issues"; }
    run_sql_script "$ROOT_DIR/tests/quality_checks_gold_postgres.sql" || { log "WARNING: Gold layer quality checks found issues"; }
elif [ "$DB_ENGINE" = "oracle" ]; then
    run_sql_script "$ROOT_DIR/tests/quality_checks_silver_oracle.sql" || { log "WARNING: Silver layer quality checks found issues"; }
    run_sql_script "$ROOT_DIR/tests/quality_checks_gold_oracle.sql" || { log "WARNING: Gold layer quality checks found issues"; }
fi

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
HOURS=$((DURATION / 3600))
MINUTES=$(( (DURATION % 3600) / 60 ))
SECONDS=$((DURATION % 60))

log "========================================"
log "ETL Process Completed"
log "Total Duration: ${HOURS}h ${MINUTES}m ${SECONDS}s"
log "Log file: $LOG_FILE"
log "========================================"

exit 0
