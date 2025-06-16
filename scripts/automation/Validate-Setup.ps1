# PowerShell script to validate the setup
# This script checks if all required components of the data warehouse project are present

Write-Host "Validating Data Warehouse project setup..." -ForegroundColor Cyan

# Define the base directory
$baseDir = "D:\Github Repo\Data_Warehouse_And_Analytics"

# Check if all required directories exist
$requiredDirs = @(
    "airflow",
    "airflow\dags",
    "datasets",
    "docker",
    "docker\init-scripts",
    "docker\init-scripts\postgres",
    "docker\init-scripts\oracle",
    "docs",
    "notebooks",
    "scripts",
    "scripts\automation",
    "scripts\bronze",
    "scripts\silver",
    "scripts\gold",
    "tableau",
    "tests"
)

$allDirsExist = $true
foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path -Path $baseDir -ChildPath $dir
    if (Test-Path -Path $fullPath -PathType Container) {
        Write-Host "✓ Directory exists: $dir" -ForegroundColor Green
    } else {
        Write-Host "✗ Directory missing: $dir" -ForegroundColor Red
        $allDirsExist = $false
    }
}

if (-not $allDirsExist) {
    Write-Host "Warning: Some required directories are missing" -ForegroundColor Yellow
} else {
    Write-Host "All required directories are present" -ForegroundColor Green
}

# Check if all required files exist
$requiredFiles = @(
    "docker\docker-compose.yml",
    "docker\Dockerfile.postgres",
    "docker\Dockerfile.oracle",
    "docker\init-scripts\postgres\01-init-schemas.sh",
    "docker\init-scripts\oracle\01-init-schemas.sql",
    "scripts\bronze\proc_load_bronze_postgres.sql",
    "scripts\bronze\proc_load_bronze_oracle.sql",
    "airflow\dags\data_warehouse_etl.py",
    "scripts\automation\docker_env.sh",
    "scripts\automation\run_etl.sh",
    "scripts\automation\oci_deploy.sh",
    "README.md"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path -Path $baseDir -ChildPath $file
    if (Test-Path -Path $fullPath -PathType Leaf) {
        Write-Host "✓ File exists: $file" -ForegroundColor Green
        
        # Check file size
        $fileInfo = Get-Item $fullPath
        if ($fileInfo.Length -eq 0) {
            Write-Host "  Warning: File is empty" -ForegroundColor Yellow
        } else {
            Write-Host "  File size: $($fileInfo.Length) bytes" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "✗ File missing: $file" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "Warning: Some required files are missing" -ForegroundColor Yellow
} else {
    Write-Host "All required files are present" -ForegroundColor Green
}

# Check Docker Compose file syntax
$dockerComposeFile = Join-Path -Path $baseDir -ChildPath "docker\docker-compose.yml"
if (Test-Path -Path $dockerComposeFile -PathType Leaf) {
    $dockerComposeContent = Get-Content -Path $dockerComposeFile -Raw
    if ($dockerComposeContent -match "version:") {
        Write-Host "✓ docker-compose.yml has valid version field" -ForegroundColor Green
    } else {
        Write-Host "✗ docker-compose.yml may have syntax issues" -ForegroundColor Red
    }
    
    if ($dockerComposeContent -match "services:") {
        Write-Host "✓ docker-compose.yml has services defined" -ForegroundColor Green
    } else {
        Write-Host "✗ docker-compose.yml doesn't contain services" -ForegroundColor Red
    }
}

# Summary
Write-Host "`nValidation Summary:" -ForegroundColor Cyan
if ($allDirsExist -and $allFilesExist) {
    Write-Host "✓ All required components are present. The project structure looks good!" -ForegroundColor Green
} else {
    Write-Host "⚠ Some components are missing. Please check the warnings above." -ForegroundColor Yellow
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. If Docker is installed, you can start the environment with:" -ForegroundColor White
Write-Host "   cd 'D:\Github Repo\Data_Warehouse_And_Analytics\scripts\automation'" -ForegroundColor DarkGray
Write-Host "   .\docker_env.sh start" -ForegroundColor DarkGray
Write-Host "2. Run the ETL process with:" -ForegroundColor White
Write-Host "   .\run_etl.sh postgres  # For PostgreSQL" -ForegroundColor DarkGray
Write-Host "   # or" -ForegroundColor DarkGray
Write-Host "   .\run_etl.sh oracle    # For Oracle" -ForegroundColor DarkGray
