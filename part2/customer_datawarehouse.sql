CREATE DATABASE customer_datawarehouse;

USE customer_datawarehouse;

CREATE TABLE dim_customers (
    customerNumber INT PRIMARY KEY,     
    customerName VARCHAR(255),         
    contactLastName VARCHAR(255),      
    contactFirstName VARCHAR(255),     
    phone VARCHAR(50),             
    addressLine1 VARCHAR(255),          
    addressLine2 VARCHAR(255),          
    city VARCHAR(100),                 
    state VARCHAR(100),                 
    postalCode VARCHAR(15),             
    country VARCHAR(100),              
    salesRepEmployeeNumber INT,        
    creditLimit DECIMAL(10, 2)         
);

CREATE TABLE dim_products (
    productCode VARCHAR(50) PRIMARY KEY, 
    productName VARCHAR(255),             
    productLine VARCHAR(255),            
    productScale VARCHAR(50),              
    productVendor VARCHAR(255),           
    productDescription TEXT,              
    quantityInStock INT,                   
    buyPrice DECIMAL(10, 2),                
    MSRP DECIMAL(10, 2)                     
);

CREATE TABLE dim_employees (
    employeeNumber INT PRIMARY KEY,         
    lastName VARCHAR(255),                 
    firstName VARCHAR(255),                
    extension VARCHAR(10),                 
    email VARCHAR(100),                  
    officeCode VARCHAR(10),                 
    jobTitle VARCHAR(100)                  
);

CREATE TABLE dim_offices (
    officeCode VARCHAR(10) PRIMARY KEY,   
    city VARCHAR(255),                   
    phone VARCHAR(50),                   
    addressLine1 VARCHAR(255),                         
    country VARCHAR(50),                   
    postalCode VARCHAR(15),                
    territory VARCHAR(50)                   
);

CREATE TABLE fact_orders_payments_interactions_reviews (
    orderNumber INT,                    
    orderDate DATE,                   
    requiredDate DATE,                 
    shippedDate DATE,                 
    status VARCHAR(50),              
    comments TEXT,                   
    customerNumber INT,                
    productCode VARCHAR(50),          
    quantityOrdered INT,              
    priceEach DECIMAL(10, 2),         
    orderLineNumber SMALLINT,        
    paymentDate DATE,                  
    amount DECIMAL(10, 2),              
    interactionID INT,                  
    interactionType VARCHAR(255),       
    interactionDate DATE,               
    reviewID INT,                      
    reviewDate DATE,                    
    rating INT,                          
    reviewText TEXT,                    
    employeeNumber INT,                
    officeCode VARCHAR(10),              
    FOREIGN KEY (customerNumber) REFERENCES dim_customers(customerNumber),
    FOREIGN KEY (productCode) REFERENCES dim_products(productCode),
    FOREIGN KEY (employeeNumber) REFERENCES dim_employees(employeeNumber),
    FOREIGN KEY (officeCode) REFERENCES dim_offices(officeCode)
);
