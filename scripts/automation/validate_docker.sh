#!/bin/bash
# Test script to validate Docker setup
# This script checks if Docker and Docker Compose are installed and functional

echo "Validating Docker environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
else
    echo "✓ Docker is installed"
    docker --version
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed or not in PATH"
    exit 1
else
    echo "✓ Docker Compose is installed"
    docker-compose --version
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running"
    exit 1
else
    echo "✓ Docker daemon is running"
fi

# Validate docker-compose.yml
if [ -f "../../docker/docker-compose.yml" ]; then
    echo "✓ docker-compose.yml exists"
    
    # Optional: Use docker-compose config to validate the file
    if docker-compose -f "../../docker/docker-compose.yml" config &> /dev/null; then
        echo "✓ docker-compose.yml is valid"
    else
        echo "Warning: docker-compose.yml may have syntax errors"
    fi
else
    echo "Error: docker-compose.yml not found"
    exit 1
fi

echo "Checking initialization scripts..."

# Check PostgreSQL init scripts
if [ -d "../../docker/init-scripts/postgres" ]; then
    echo "✓ PostgreSQL initialization scripts exist"
    ls -la "../../docker/init-scripts/postgres"
else
    echo "Warning: PostgreSQL initialization scripts not found"
fi

# Check Oracle init scripts
if [ -d "../../docker/init-scripts/oracle" ]; then
    echo "✓ Oracle initialization scripts exist"
    ls -la "../../docker/init-scripts/oracle"
else
    echo "Warning: Oracle initialization scripts not found"
fi

echo "Docker environment validation completed successfully!"
