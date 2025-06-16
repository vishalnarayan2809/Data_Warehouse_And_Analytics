#!/bin/bash
# Test script to validate database scripts
# This script checks if all required SQL scripts exist and have proper syntax

echo "Validating database scripts..."

# Define the base directory
BASE_DIR="../../scripts"

# Define the layers to check
LAYERS=("bronze" "silver" "gold")

# Define the database types
DB_TYPES=("postgres" "oracle")

# Check if all required script directories exist
for layer in "${LAYERS[@]}"; do
    if [ -d "$BASE_DIR/$layer" ]; then
        echo "✓ $layer layer directory exists"
    else
        echo "Error: $layer layer directory not found"
        exit 1
    fi
done

# Check PostgreSQL scripts
echo "Checking PostgreSQL scripts..."
for layer in "${LAYERS[@]}"; do
    # Check for PostgreSQL-specific scripts
    if [ -f "$BASE_DIR/$layer/proc_load_${layer}_postgres.sql" ]; then
        echo "✓ $layer layer PostgreSQL procedure exists"
        
        # Check if file is not empty
        if [ -s "$BASE_DIR/$layer/proc_load_${layer}_postgres.sql" ]; then
            echo "  ✓ File has content"
        else
            echo "  Warning: File is empty"
        fi
        
        # Check for basic PostgreSQL syntax
        if grep -q "CREATE OR REPLACE FUNCTION" "$BASE_DIR/$layer/proc_load_${layer}_postgres.sql"; then
            echo "  ✓ Basic PostgreSQL syntax check passed"
        else
            echo "  Warning: File may not contain proper PostgreSQL function definition"
        fi
    else
        echo "Warning: $layer layer PostgreSQL procedure not found"
    fi
done

# Check Oracle scripts
echo "Checking Oracle scripts..."
for layer in "${LAYERS[@]}"; do
    # Check for Oracle-specific scripts
    if [ -f "$BASE_DIR/$layer/proc_load_${layer}_oracle.sql" ]; then
        echo "✓ $layer layer Oracle procedure exists"
        
        # Check if file is not empty
        if [ -s "$BASE_DIR/$layer/proc_load_${layer}_oracle.sql" ]; then
            echo "  ✓ File has content"
        else
            echo "  Warning: File is empty"
        fi
        
        # Check for basic Oracle syntax
        if grep -q "CREATE OR REPLACE PACKAGE" "$BASE_DIR/$layer/proc_load_${layer}_oracle.sql" || \
           grep -q "CREATE OR REPLACE PROCEDURE" "$BASE_DIR/$layer/proc_load_${layer}_oracle.sql"; then
            echo "  ✓ Basic Oracle syntax check passed"
        else
            echo "  Warning: File may not contain proper Oracle package/procedure definition"
        fi
    else
        echo "Warning: $layer layer Oracle procedure not found"
    fi
done

echo "Database script validation completed!"
