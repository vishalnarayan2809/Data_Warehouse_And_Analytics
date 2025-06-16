#!/bin/bash
# Docker Environment Setup and Management Script
# This script helps set up and manage the Docker environment for the Data Warehouse project

# Set variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
DOCKER_DIR="$ROOT_DIR/docker"

# Function to display help
show_help() {
    echo "Data Warehouse Docker Environment Management"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start       - Start all containers"
    echo "  stop        - Stop all containers"
    echo "  restart     - Restart all containers"
    echo "  status      - Show container status"
    echo "  logs        - Show container logs"
    echo "  postgres    - Connect to PostgreSQL CLI"
    echo "  oracle      - Connect to Oracle SQL*Plus"
    echo "  backup      - Backup database data"
    echo "  restore     - Restore database from backup"
    echo "  clean       - Remove all containers and volumes (WARNING: destroys all data)"
    echo "  help        - Show this help message"
    echo ""
}

# Function to start containers
start_containers() {
    echo "Starting Docker containers..."
    cd $DOCKER_DIR && docker-compose up -d
    
    # Wait for databases to be ready
    echo "Waiting for PostgreSQL to be ready..."
    until docker exec dwh_postgres pg_isready -U dwh_user -d datawarehouse &> /dev/null; do
        echo -n "."
        sleep 2
    done
    echo " PostgreSQL is ready!"
    
    echo "Waiting for Oracle to be ready..."
    until docker exec dwh_oracle bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -S dwh_user/dwh_password" &> /dev/null; do
        echo -n "."
        sleep 5
    done
    echo " Oracle is ready!"
    
    echo "All containers started successfully!"
    echo ""
    echo "Services:"
    echo "- PostgreSQL: localhost:5432"
    echo "- Oracle: localhost:1521"
    echo "- Jupyter Notebook: http://localhost:8888 (token: dwh)"
    echo "- Airflow: http://localhost:8080 (admin/admin)"
}

# Function to stop containers
stop_containers() {
    echo "Stopping Docker containers..."
    cd $DOCKER_DIR && docker-compose stop
    echo "All containers stopped."
}

# Function to restart containers
restart_containers() {
    echo "Restarting Docker containers..."
    cd $DOCKER_DIR && docker-compose restart
    echo "All containers restarted."
}

# Function to show container status
show_status() {
    echo "Container Status:"
    cd $DOCKER_DIR && docker-compose ps
}

# Function to show container logs
show_logs() {
    if [ -z "$2" ]; then
        echo "Please specify a container (postgres, oracle, jupyter, airflow)"
        return 1
    fi
    
    case "$2" in
        postgres)
            cd $DOCKER_DIR && docker-compose logs --tail=100 -f postgres
            ;;
        oracle)
            cd $DOCKER_DIR && docker-compose logs --tail=100 -f oracle
            ;;
        jupyter)
            cd $DOCKER_DIR && docker-compose logs --tail=100 -f jupyter
            ;;
        airflow)
            cd $DOCKER_DIR && docker-compose logs --tail=100 -f airflow
            ;;
        *)
            echo "Unknown container: $2"
            echo "Available containers: postgres, oracle, jupyter, airflow"
            return 1
            ;;
    esac
}

# Function to connect to PostgreSQL CLI
connect_postgres() {
    echo "Connecting to PostgreSQL CLI..."
    docker exec -it dwh_postgres psql -U dwh_user -d datawarehouse
}

# Function to connect to Oracle SQL*Plus
connect_oracle() {
    echo "Connecting to Oracle SQL*Plus..."
    docker exec -it dwh_oracle sqlplus dwh_user/dwh_password
}

# Function to backup databases
backup_databases() {
    BACKUP_DIR="$ROOT_DIR/backups"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    mkdir -p $BACKUP_DIR
    
    echo "Backing up PostgreSQL database..."
    docker exec dwh_postgres pg_dump -U dwh_user -d datawarehouse > "$BACKUP_DIR/postgres_backup_${TIMESTAMP}.sql"
    
    echo "Backing up Oracle database..."
    docker exec dwh_oracle bash -c "echo 'set heading off
set pagesize 0
set long 100000
set longchunksize 100000
set feedback off
set echo off
set linesize 1000
spool /tmp/oracle_backup.sql
select dbms_metadata.get_ddl(''TABLE'',table_name,''DWH_USER'') from user_tables;
select dbms_metadata.get_ddl(''VIEW'',view_name,''DWH_USER'') from user_views;
spool off
exit
' | sqlplus -S dwh_user/dwh_password" && \
    docker cp dwh_oracle:/tmp/oracle_backup.sql "$BACKUP_DIR/oracle_backup_${TIMESTAMP}.sql"
    
    echo "Backups completed:"
    echo "- PostgreSQL: $BACKUP_DIR/postgres_backup_${TIMESTAMP}.sql"
    echo "- Oracle: $BACKUP_DIR/oracle_backup_${TIMESTAMP}.sql"
}

# Function to restore databases
restore_databases() {
    if [ -z "$2" ]; then
        echo "Please specify a backup file"
        return 1
    fi
    
    BACKUP_FILE="$2"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "Backup file not found: $BACKUP_FILE"
        return 1
    fi
    
    if [[ "$BACKUP_FILE" == *postgres* ]]; then
        echo "Restoring PostgreSQL backup from $BACKUP_FILE..."
        cat "$BACKUP_FILE" | docker exec -i dwh_postgres psql -U dwh_user -d datawarehouse
        echo "PostgreSQL restore completed."
    elif [[ "$BACKUP_FILE" == *oracle* ]]; then
        echo "Restoring Oracle backup from $BACKUP_FILE..."
        docker cp "$BACKUP_FILE" dwh_oracle:/tmp/oracle_restore.sql
        docker exec dwh_oracle bash -c "echo '@/tmp/oracle_restore.sql
exit
' | sqlplus -S dwh_user/dwh_password"
        echo "Oracle restore completed."
    else
        echo "Unknown backup type. Filename should contain 'postgres' or 'oracle'."
        return 1
    fi
}

# Function to clean up all containers and volumes
clean_environment() {
    read -p "WARNING: This will remove all containers and volumes, destroying all data. Are you sure? (y/n) " confirm
    if [ "$confirm" != "y" ]; then
        echo "Operation cancelled."
        return 0
    fi
    
    echo "Removing all containers and volumes..."
    cd $DOCKER_DIR && docker-compose down -v
    echo "Environment cleaned successfully."
}

# Check if Docker is installed and running
if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker and/or Docker Compose are not installed."
    echo "Please install Docker and Docker Compose before running this script."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running."
    echo "Please start Docker and try again."
    exit 1
fi

# Parse command line arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    start)
        start_containers
        ;;
    stop)
        stop_containers
        ;;
    restart)
        restart_containers
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$@"
        ;;
    postgres)
        connect_postgres
        ;;
    oracle)
        connect_oracle
        ;;
    backup)
        backup_databases
        ;;
    restore)
        restore_databases "$@"
        ;;
    clean)
        clean_environment
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

exit 0
