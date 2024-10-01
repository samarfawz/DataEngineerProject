import pandas as pd
from sqlalchemy import create_engine

# Connection parameters using SQLAlchemy
engine_mgmt = create_engine('mssql+pyodbc://localhost/customer_management?driver=ODBC+Driver+17+for+SQL+Server')
engine_dw = create_engine('mssql+pyodbc://localhost/customer_datawarehouse?driver=ODBC+Driver+17+for+SQL+Server')



# Function to transfer data using Pandas and SQLAlchemy
def transfer_data(query_select, table_name, engine_source, engine_target):
    # Load data into a DataFrame
    df = pd.read_sql(query_select, engine_source)

# Main block to manage connections
with engine_mgmt.connect() as conn_mgmt, engine_dw.connect() as conn_dw:
    
    # # Transfer customers
    transfer_data(
        query_select="SELECT customerNumber, customerName, contactLastName, contactFirstName, phone, addressLine1, addressLine2, city, state, postalCode, country, salesRepEmployeeNumber, creditLimit FROM customers",
        table_name='dim_customers',
        engine_source=engine_mgmt,
        engine_target=engine_dw
    )

    # Transfer products
    transfer_data(
        query_select="SELECT productCode, productName, productLine, productScale, productVendor, productDescription, quantityInStock, buyPrice, MSRP FROM products",
        table_name='dim_products',
        engine_source=engine_mgmt,
        engine_target=engine_dw
    )

    # Transfer offices
    transfer_data(
        query_select="SELECT officeCode, city, phone, addressLine1, country, postalCode FROM offices",
        table_name='dim_offices',
        engine_source=engine_mgmt,
        engine_target=engine_dw
    )

    # Transfer employees
    transfer_data(
        query_select="SELECT employeeNumber, lastName, firstName, extension, email, officeCode, jobTitle FROM employees",
        table_name='dim_employees',
        engine_source=engine_mgmt,
        engine_target=engine_dw
    )

    # Transfer fact_orders_payments_interactions_reviews data
    transfer_data(
        query_select="""
        SELECT 
            o.[orderNumber], 
            o.[orderDate], 
            o.[requiredDate], 
            o.[shippedDate], 
            o.[status], 
            o.[comments], 
            o.[customerNumber], 
            od.[productCode], 
            od.[quantityOrdered], 
            od.[priceEach], 
            od.[orderLineNumber], 
            pay.[paymentDate], 
            pay.[amount], 
            i.[interactionID], 
            i.[interactionType], 
            i.[interactionDate], 
            r.[reviewID], 
            r.[reviewDate], 
            r.[reviewRating] AS rating, 
            r.[reviewText], 
            e.[employeeNumber], 
            e.[officeCode]
        FROM [customer_management].[dbo].[orders] o
        JOIN [customer_management].[dbo].[orderdetails] od ON o.[orderNumber] = od.[orderNumber]
        JOIN [customer_management].[dbo].[customers] c ON o.[customerNumber] = c.[customerNumber] 
        JOIN [customer_management].[dbo].[products] p ON od.[productCode] = p.[productCode]
        LEFT JOIN [customer_management].[dbo].[payments] pay ON c.[customerNumber] = pay.[customerNumber] 
        JOIN [customer_management].[dbo].[employees] e ON c.[salesRepEmployeeNumber] = e.[employeeNumber]
        LEFT JOIN [customer_management].[dbo].[interactions] i ON c.[customerNumber] = i.[customerNumber]
        LEFT JOIN [customer_management].[dbo].[productReviews] r ON p.[productCode] = r.[productCode]
        """,
        table_name='fact_orders_payments_interactions_reviews',
        engine_source=engine_mgmt,
        engine_target=engine_dw
    )

print("Data cleaning, analysis, and transfer completed.")
