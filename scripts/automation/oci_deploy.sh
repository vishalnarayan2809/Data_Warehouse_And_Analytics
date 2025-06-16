#!/bin/bash
# Cloud Deployment Script for OCI (Oracle Cloud Infrastructure)
# This script helps deploy the data warehouse to Oracle Cloud Infrastructure

# Set variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$ROOT_DIR/config"
OCI_CONFIG="$CONFIG_DIR/oci_config.json"

# Function to display help
show_help() {
    echo "Data Warehouse OCI Deployment Tool"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  configure   - Configure OCI settings"
    echo "  deploy      - Deploy to OCI"
    echo "  status      - Check deployment status"
    echo "  destroy     - Destroy OCI resources"
    echo "  help        - Show this help message"
    echo ""
}

# Function to configure OCI settings
configure_oci() {
    mkdir -p $CONFIG_DIR
    
    echo "Configuring OCI deployment settings..."
    
    # Collect configuration information
    read -p "OCI Compartment ID: " compartment_id
    read -p "OCI Region: " region
    read -p "Database Type (ATP/ADW): " db_type
    read -p "Database Name: " db_name
    read -p "CPU Count: " cpu_count
    read -p "Storage (TB): " storage_tb
    read -p "Admin Username: " admin_username
    read -s -p "Admin Password: " admin_password
    echo ""
    
    # Create configuration file
    cat > $OCI_CONFIG <<EOF
{
    "compartment_id": "$compartment_id",
    "region": "$region",
    "db_type": "$db_type",
    "db_name": "$db_name",
    "cpu_count": $cpu_count,
    "storage_tb": $storage_tb,
    "admin_username": "$admin_username",
    "admin_password": "$admin_password",
    "tags": {
        "project": "datawarehouse",
        "environment": "production"
    }
}
EOF
    
    echo "Configuration saved to $OCI_CONFIG"
}

# Function to deploy to OCI
deploy_to_oci() {
    if [ ! -f "$OCI_CONFIG" ]; then
        echo "Error: OCI configuration not found. Run '$0 configure' first."
        exit 1
    fi
    
    echo "Deploying to Oracle Cloud Infrastructure..."
    
    # Check OCI CLI installation
    if ! command -v oci &> /dev/null; then
        echo "Error: OCI CLI not found."
        echo "Please install the OCI CLI before running this script: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
        exit 1
    fi
    
    # Check OCI CLI configuration
    if [ ! -f ~/.oci/config ]; then
        echo "Error: OCI CLI not configured."
        echo "Please run 'oci setup config' to configure the OCI CLI first."
        exit 1
    fi
    
    # Load configuration
    compartment_id=$(grep -o '"compartment_id": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    region=$(grep -o '"region": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    db_type=$(grep -o '"db_type": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    db_name=$(grep -o '"db_name": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    cpu_count=$(grep -o '"cpu_count": [0-9]*' $OCI_CONFIG | cut -d':' -f2 | tr -d ' ')
    storage_tb=$(grep -o '"storage_tb": [0-9]*' $OCI_CONFIG | cut -d':' -f2 | tr -d ' ')
    admin_username=$(grep -o '"admin_username": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    admin_password=$(grep -o '"admin_password": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    
    echo "Creating $db_type database instance: $db_name"
    
    # Build command based on database type
    if [ "$db_type" = "ATP" ]; then
        # Create Autonomous Transaction Processing database
        oci db autonomous-database create \
            --compartment-id "$compartment_id" \
            --db-name "$db_name" \
            --display-name "$db_name" \
            --cpu-core-count "$cpu_count" \
            --data-storage-size-in-tbs "$storage_tb" \
            --admin-password "$admin_password" \
            --db-workload OLTP \
            --is-free-tier false \
            --license-model LICENSE_INCLUDED
    elif [ "$db_type" = "ADW" ]; then
        # Create Autonomous Data Warehouse database
        oci db autonomous-database create \
            --compartment-id "$compartment_id" \
            --db-name "$db_name" \
            --display-name "$db_name" \
            --cpu-core-count "$cpu_count" \
            --data-storage-size-in-tbs "$storage_tb" \
            --admin-password "$admin_password" \
            --db-workload DW \
            --is-free-tier false \
            --license-model LICENSE_INCLUDED
    else
        echo "Error: Unknown database type: $db_type. Use ATP or ADW."
        exit 1
    fi
    
    echo "Database creation initiated. Run '$0 status' to check deployment status."
}

# Function to check deployment status
check_status() {
    if [ ! -f "$OCI_CONFIG" ]; then
        echo "Error: OCI configuration not found. Run '$0 configure' first."
        exit 1
    fi
    
    # Load configuration
    compartment_id=$(grep -o '"compartment_id": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    db_name=$(grep -o '"db_name": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    
    echo "Checking status of database: $db_name"
    
    # List all autonomous databases in the compartment
    oci db autonomous-database list \
        --compartment-id "$compartment_id" \
        --display-name "$db_name" \
        --all
}

# Function to destroy OCI resources
destroy_resources() {
    if [ ! -f "$OCI_CONFIG" ]; then
        echo "Error: OCI configuration not found. Run '$0 configure' first."
        exit 1
    fi
    
    # Load configuration
    compartment_id=$(grep -o '"compartment_id": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    db_name=$(grep -o '"db_name": "[^"]*' $OCI_CONFIG | cut -d'"' -f4)
    
    echo "WARNING: This will destroy the database: $db_name"
    read -p "Are you sure you want to proceed? (y/n) " confirm
    if [ "$confirm" != "y" ]; then
        echo "Operation cancelled."
        return 0
    fi
    
    # Get database OCID
    db_ocid=$(oci db autonomous-database list \
        --compartment-id "$compartment_id" \
        --display-name "$db_name" \
        --all \
        --query "data[0].id" \
        --raw-output)
    
    if [ -z "$db_ocid" ]; then
        echo "Error: Database not found: $db_name"
        exit 1
    fi
    
    echo "Deleting database: $db_name (OCID: $db_ocid)"
    
    # Delete the database
    oci db autonomous-database delete \
        --autonomous-database-id "$db_ocid" \
        --force
    
    echo "Database deletion initiated. Run '$0 status' to check status."
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    configure)
        configure_oci
        ;;
    deploy)
        deploy_to_oci
        ;;
    status)
        check_status
        ;;
    destroy)
        destroy_resources
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
