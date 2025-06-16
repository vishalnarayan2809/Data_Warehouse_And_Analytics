# Tableau Integration

This directory contains Tableau workbooks and resources for visualizing the data warehouse. The dashboards provide valuable business insights across different domains:

## Dashboards

### 1. Sales Performance Dashboard
The Sales Performance Dashboard provides a comprehensive view of sales trends, product performance, and revenue metrics.

- **Key Metrics:**
  - Sales Revenue by Product Line
  - Monthly Sales Trends
  - Top Performing Products
  - Revenue by Customer Segment

### 2. Customer Analysis Dashboard
The Customer Analysis Dashboard offers insights into customer behavior, segmentation, and lifetime value.

- **Key Metrics:**
  - Customer Acquisition by Month
  - Customer Segmentation Analysis
  - Purchase Frequency
  - Customer Lifetime Value (CLV)

### 3. Product Performance Dashboard
The Product Performance Dashboard helps identify high-performing products and potential areas for improvement.

- **Key Metrics:**
  - Product Profitability
  - Inventory Turnover
  - Product Category Analysis
  - Supplier Performance

## Connection Guide

### Connecting to PostgreSQL

1. Open Tableau Desktop
2. Select "PostgreSQL" as the data source
3. Enter connection details:
   - Server: localhost (or your server address)
   - Port: 5432
   - Database: datawarehouse
   - Username: dwh_user
   - Password: dwh_password
4. Select the "gold" schema to access the business-ready data models

### Connecting to Oracle

1. Open Tableau Desktop
2. Select "Oracle" as the data source
3. Enter connection details:
   - Server: localhost (or your server address)
   - Port: 1521
   - Service: XE
   - Username: dwh_user
   - Password: dwh_password
4. Use the views with the "gold_" prefix to access the business-ready data models

## Best Practices

- **Use Extract Mode:** For better performance, use Tableau's extract mode rather than live connections
- **Leverage Custom SQL:** For complex queries, use custom SQL to optimize data retrieval
- **Implement Row-Level Filters:** Apply appropriate filters to ensure users only see data relevant to them
- **Create Hierarchies:** Implement hierarchies for drill-down analysis (e.g., Year > Quarter > Month)
- **Use Parameters:** Create interactive dashboards with parameters for user-driven analysis

## Data Refresh Schedule

To ensure dashboards display the most up-to-date information, schedule data refreshes as follows:

1. **Daily Refresh:** Sales and inventory metrics (refreshed nightly)
2. **Weekly Refresh:** Customer metrics and product performance (refreshed on Mondays)
3. **Monthly Refresh:** Trend analysis and forecasting models (refreshed on the 1st of each month)

## Performance Tuning

For optimal dashboard performance:

1. Minimize the number of worksheets per dashboard
2. Use context filters to reduce the dataset size
3. Aggregate measures when possible
4. Limit the use of table calculations
5. Consider using Tableau Server for centralized management and improved performance
