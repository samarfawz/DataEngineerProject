import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt
import seaborn as sns

# Function to fetch data from a table
def fetch_data(engine, table_name):
    query = f"SELECT * FROM {table_name}"
    return pd.read_sql(query, engine)

# Fetch all main tables
def fetch_all_data(engine):
    customers_df = fetch_data(engine, 'dim_customers')
    products_df = fetch_data(engine, 'dim_products')
    employees_df = fetch_data(engine, 'dim_employees')
    offices_df = fetch_data(engine, 'dim_offices')
    orders_df = fetch_data(engine, 'fact_orders_payments_interactions_reviews')
    
    return customers_df, products_df, employees_df, offices_df, orders_df

# Descriptive analysis for each table
def descriptive_analysis(df, table_name):
    print(f"Analysis of {table_name}:")
    print(df.describe(include='all'))
    print("\nNull values:")
    print(df.isnull().sum())
    print("\n")

# Analyze relationships between data
def analyze_relations(orders_df, customers_df, products_df):
    # Relationship between customers and sales
    customer_sales = orders_df.groupby('customerNumber')['amount'].sum().reset_index()
    customer_sales = customer_sales.merge(customers_df[['customerNumber', 'customerName']], on='customerNumber')
    
    print("Top 5 customers by sales:")
    print(customer_sales.sort_values(by='amount', ascending=False).head(5))

    # Relationship between products and orders
    product_orders = orders_df.groupby('productCode')['quantityOrdered'].sum().reset_index()
    product_orders = product_orders.merge(products_df[['productCode', 'productName']], on='productCode')

    print("Top 5 products by quantity ordered:")
    print(product_orders.sort_values(by='quantityOrdered', ascending=False).head(5))

# Plotting data with more visualizations
def plot_data(orders_df, customers_df, products_df):
    # Distribution of customer ratings
    sns.histplot(orders_df['rating'], bins=10)
    plt.title("Customer Ratings Distribution")
    plt.show()

    # Top 10 customers by sales
    customer_sales = orders_df.groupby('customerNumber')['amount'].sum().reset_index()
    sns.barplot(x='customerNumber', y='amount', data=customer_sales.head(10))
    plt.title("Top 10 Customers by Sales")
    plt.show()

    # Top 10 products by quantity ordered
    product_orders = orders_df.groupby('productCode')['quantityOrdered'].sum().reset_index()
    product_orders = product_orders.merge(products_df[['productCode', 'productName']], on='productCode')
    sns.barplot(x='productName', y='quantityOrdered', data=product_orders.head(10))
    plt.title("Top 10 Products by Quantity Ordered")
    plt.xticks(rotation=45)
    plt.show()

    # Pie chart for product distribution by sales amount
    product_sales = orders_df.groupby('productCode')['amount'].sum().reset_index()
    product_sales = product_sales.merge(products_df[['productCode', 'productName']], on='productCode')
    top_5_products = product_sales.sort_values(by='amount', ascending=False).head(5)
    plt.pie(top_5_products['amount'], labels=top_5_products['productName'], autopct='%1.1f%%')
    plt.title("Top 5 Products by Sales Amount")
    plt.show()

# Prepare monthly sales data
def prepare_monthly_sales_data(orders_df):
    # Convert orderDate column to datetime format
    orders_df['orderDate'] = pd.to_datetime(orders_df['orderDate'])
    
    # Extract year and month from orderDate
    orders_df['year_month'] = orders_df['orderDate'].dt.to_period('M')
    
    # Group sales by month
    monthly_sales = orders_df.groupby('year_month')['amount'].sum().reset_index()
    
    return monthly_sales

# Plot monthly sales
def plot_monthly_sales(monthly_sales):
    plt.figure(figsize=(10, 6))
    plt.plot(monthly_sales['year_month'].astype(str), monthly_sales['amount'], marker='o', color='b', linestyle='--')
    plt.xticks(rotation=45)
    plt.title('Monthly Sales Over Time')
    plt.xlabel('Month')
    plt.ylabel('Sales Amount')
    plt.grid(True)
    plt.tight_layout()
    plt.show()

    # Bar chart for monthly sales
    plt.figure(figsize=(10, 6))
    sns.barplot(x='year_month', y='amount', data=monthly_sales)
    plt.xticks(rotation=45)
    plt.title("Monthly Sales (Bar Chart)")
    plt.xlabel('Month')
    plt.ylabel('Sales Amount')
    plt.tight_layout()
    plt.show()

# Run the full analysis
def run_analysis():
    engine = create_engine('mssql+pyodbc://localhost/customer_datawarehouse?driver=ODBC+Driver+17+for+SQL+Server')

    # Fetch data
    customers_df, products_df, employees_df, offices_df, orders_df = fetch_all_data(engine)
    
    # Perform descriptive analysis
    descriptive_analysis(customers_df, 'Customers')
    descriptive_analysis(products_df, 'Products')
    descriptive_analysis(employees_df, 'Employees')
    descriptive_analysis(orders_df, 'Orders')
    
    # Analyze relationships
    analyze_relations(orders_df, customers_df, products_df)
    
    # Plot visualizations
    plot_data(orders_df, customers_df, products_df)

    # Analyze and plot monthly sales
    monthly_sales = prepare_monthly_sales_data(orders_df)
    plot_monthly_sales(monthly_sales)

# Start the analysis
run_analysis()
