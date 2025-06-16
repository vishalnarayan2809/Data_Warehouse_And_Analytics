# Data Exploration and Analysis Notebooks

This directory contains Jupyter notebooks for exploring and analyzing data from the data warehouse. 
The notebooks demonstrate various analytics techniques and insights derived from the data.

## Notebooks

### 1. `data_exploration.ipynb`
- Initial exploration of the dataset
- Data profiling and quality assessment
- Distribution analysis of key metrics

### 2. `customer_segmentation.ipynb`
- Customer segmentation using clustering techniques
- Behavior analysis across different customer segments
- Recommendations for targeted marketing strategies

### 3. `sales_analysis.ipynb`
- Time series analysis of sales data
- Seasonal patterns and trend identification
- Forecasting future sales using statistical models

### 4. `product_analytics.ipynb`
- Product performance metrics
- Market basket analysis to identify product affinities
- Product lifecycle analysis

### 5. `geo_analysis.ipynb`
- Geographical distribution of sales
- Regional performance comparisons
- Market penetration analysis

## Usage

These notebooks are designed to work with both PostgreSQL and Oracle databases. The connection details are 
configured in the `config.py` file, which should be updated with your database credentials.

### Prerequisites

- Python 3.8+
- Jupyter Notebook or JupyterLab
- Required Python packages:
  - pandas
  - numpy
  - matplotlib
  - seaborn
  - scikit-learn
  - sqlalchemy
  - psycopg2 (for PostgreSQL)
  - cx_Oracle (for Oracle)

### Running the Notebooks

1. Start the Jupyter server:
   ```
   jupyter notebook
   ```
   or
   ```
   jupyter lab
   ```

2. Navigate to the desired notebook and open it

3. Update the database connection parameters if necessary

4. Run the cells sequentially to reproduce the analysis

## Best Practices

- Keep data preprocessing steps separate from analysis
- Document insights and findings within markdown cells
- Include visualizations to support conclusions
- Ensure reproducibility by setting random seeds where applicable
- Optimize database queries for performance
