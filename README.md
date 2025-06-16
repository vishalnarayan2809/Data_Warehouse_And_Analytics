# Enterprise Data Warehouse and Analytics Platform

Welcome to the **Enterprise Data Warehouse and Analytics Platform** repository! 🚀  
This project demonstrates a modern, scalable data warehousing and analytics solution that implements industry best practices in data engineering, cloud deployment, and visualization. The platform is designed to handle diverse data sources, process them efficiently, and deliver actionable business insights.

---
## 🏗️ Modern Data Architecture

The architecture follows the Medallion Architecture with **Bronze**, **Silver**, and **Gold** layers, deployed across containerized environments with support for multiple database platforms:

1. **Bronze Layer**: Ingests raw data as-is from source systems via automated ETL pipelines.
2. **Silver Layer**: Implements data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Provides business-ready dimensional models (star schema) optimized for reporting and analytics.

---

### ERD
![erd](https://github.com/user-attachments/assets/dcc67c84-5b74-49a1-b42f-123370d6ed44)


## 📖 Project Overview

This enterprise-grade platform includes:

1. **Multi-Database Support**: Works seamlessly with PostgreSQL and Oracle databases.
2. **Containerized Deployment**: Docker-based architecture for consistent development and deployment.
3. **Automated Data Pipelines**: Orchestrated ETL workflows using Apache Airflow.
4. **Cloud Deployment**: Infrastructure-as-Code (IaC) for Oracle Cloud Infrastructure (OCI).
5. **Data Visualization**: Tableau integration for interactive dashboards and reports.
6. **Data Quality**: Comprehensive validation and monitoring throughout the data lifecycle.

🎯 This repository showcases expertise in:
- Database Development (PostgreSQL & Oracle)
- Cloud Architecture
- Data Engineering & ETL
- Container Orchestration
- Infrastructure Automation
- Data Modeling & Optimization
- Analytics & Visualization
- Performance Tuning

---

## 🛠️ Technologies & Tools

### Database Platforms
- **PostgreSQL**: Open-source relational database with advanced analytics capabilities
- **Oracle Database**: Enterprise-grade database with high performance and scalability

### Development & Deployment
- **Docker & Docker Compose**: Containerization for consistent environments
- **Shell Scripting**: Automation of deployment and maintenance tasks
- **Apache Airflow**: Workflow orchestration and scheduling

### Cloud & Infrastructure
- **Oracle Cloud Infrastructure (OCI)**: Enterprise cloud platform
- **Autonomous Database**: Self-driving, self-securing, self-repairing database

### Visualization & Analytics
- **Tableau**: Business intelligence and data visualization
- **Jupyter Notebooks**: Interactive data exploration and analysis

## 🚀 Project Requirements

### Data Warehousing & Integration
- Develop a multi-database, containerized data warehouse solution
- Support for both PostgreSQL and Oracle database backends
- Automated data ingestion from various source systems
- Implement data quality checks and validation rules

### Cloud Deployment
- Infrastructure-as-Code (IaC) for Oracle Cloud Infrastructure
- Support for Autonomous Database deployment
- Scalable architecture to handle growing data volumes
- Security best practices for data protection

### Analytics & Reporting
- Create Tableau dashboards for key business metrics:
  - Customer insights
  - Product performance
  - Sales trends
  - Market analysis
- Interactive data exploration capabilities
- Scheduled report distribution

For more details, refer to [docs/requirements.md](docs/requirements.md).

## 📂 Repository Structure
```
enterprise-data-warehouse/
│
├── airflow/                            # Apache Airflow DAGs and plugins
│   └── dags/                           # ETL workflow definitions
│
├── datasets/                           # Sample datasets for development
│   ├── source_crm/                     # CRM source data
│   └── source_erp/                     # ERP source data
│
├── docker/                             # Docker configuration
│   ├── docker-compose.yml              # Multi-container setup
│   └── init-scripts/                   # Database initialization scripts
│       ├── postgres/                   # PostgreSQL init scripts
│       └── oracle/                     # Oracle init scripts
│
├── docs/                               # Project documentation
│   ├── data_architecture.png           # Architecture diagrams
│   ├── data_catalog.md                 # Data catalog
│   ├── data_flow.png                   # Data flow diagrams
│   └── data_model.png                  # Data models
│
├── notebooks/                          # Jupyter notebooks for analysis
│
├── scripts/                            # SQL and shell scripts
│   ├── automation/                     # Shell scripts for automation
│   ├── bronze/                         # Bronze layer scripts
│   ├── silver/                         # Silver layer scripts
│   └── gold/                           # Gold layer scripts
│
├── tableau/                            # Tableau workbooks and resources
│
├── tests/                              # Data quality tests
│
├── README.md                           # Project overview
└── LICENSE                             # License information
```

## 🚀 Getting Started

### Prerequisites
- Docker and Docker Compose
- Git
- PostgreSQL client (optional)
- Oracle client (optional)
- Tableau Desktop or Public (for visualization)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/enterprise-data-warehouse.git
   cd enterprise-data-warehouse
   ```

2. **Start the Docker environment:**
   ```bash
   cd scripts/automation
   ./docker_env.sh start
   ```

3. **Run the ETL process:**
   ```bash
   ./run_etl.sh postgres  # For PostgreSQL
   # OR
   ./run_etl.sh oracle    # For Oracle
   ```

4. **Access the services:**
   - Jupyter Notebook: http://localhost:8888 (token: dwh)
   - Airflow: http://localhost:8080 (admin/admin)
   - PostgreSQL: localhost:5432
   - Oracle: localhost:1521

### Cloud Deployment

To deploy to Oracle Cloud Infrastructure:

1. **Configure OCI settings:**
   ```bash
   ./oci_deploy.sh configure
   ```

2. **Deploy to OCI:**
   ```bash
   ./oci_deploy.sh deploy
   ```

## 📊 Data Model

The data warehouse implements a star schema design in the Gold layer:

- **Fact Tables**:
  - `fact_sales`: Contains sales transactions with foreign keys to dimensions
  - `fact_inventory`: Tracks product inventory levels over time

- **Dimension Tables**:
  - `dim_customers`: Customer information
  - `dim_products`: Product details
  - `dim_dates`: Date dimension for time-based analysis
  - `dim_locations`: Geographical hierarchy

## 📈 Performance Optimization

The platform implements several performance optimization techniques:

1. **Database Indexing Strategy**: Carefully designed indexes on frequently queried columns
2. **Partition Strategy**: Large tables are partitioned by date for improved query performance
3. **Materialized Views**: Pre-aggregated data for common analytical queries
4. **Query Optimization**: Optimized SQL queries with execution plans
5. **Resource Management**: Configured resource allocation based on workload patterns

## 🔒 Security

Data security is implemented at multiple levels:

1. **Authentication**: Role-based access control (RBAC)
2. **Encryption**: Data-at-rest and data-in-transit encryption
3. **Audit Logging**: Comprehensive audit trails for data access and changes
4. **Data Masking**: Sensitive data is masked for non-privileged users

## 🤝 Contributing

Contributions to improve the platform are welcome. Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this code with appropriate attribution.

---

## 📞 Contact

Project Maintainer: [Your Name](mailto:your.email@example.com)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/yourusername)
