CREATE DATABASE customer_management;

CREATE TABLE productlines (
    productLine VARCHAR(50) PRIMARY KEY,
    textDescription NVARCHAR(MAX),
    htmlDescription NVARCHAR(MAX),
    image VARBINARY(MAX)
);

CREATE TABLE products (
    productCode VARCHAR(15) PRIMARY KEY,
    productName VARCHAR(70),
    productLine VARCHAR(50),
    productScale VARCHAR(10),
    productVendor VARCHAR(50),
    productDescription NVARCHAR(MAX),
    quantityInStock INT,
    buyPrice DECIMAL(10, 2),
    MSRP DECIMAL(10, 2),
    CONSTRAINT FK_ProductLine FOREIGN KEY (productLine) REFERENCES productlines(productLine)
);
CREATE TABLE offices (
    officeCode VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50),
    phone VARCHAR(50),
    addressLine1 VARCHAR(50),
    addressLine2 VARCHAR(50) NULL,
    state VARCHAR(50),
    country VARCHAR(50),
    postalCode VARCHAR(15),
    territory VARCHAR(50)
);

CREATE TABLE employees (
    employeeNumber INT PRIMARY KEY,
    lastName VARCHAR(50),
    firstName VARCHAR(50),
    extension VARCHAR(10),
    email VARCHAR(100),
    officeCode VARCHAR(10),
    reportsTo INT NULL,
    jobTitle VARCHAR(50),
    CONSTRAINT FK_ReportsTo FOREIGN KEY (reportsTo) REFERENCES employees(employeeNumber),
    CONSTRAINT FK_OfficeCode FOREIGN KEY (officeCode) REFERENCES offices(officeCode)
);



CREATE TABLE customers (
    customerNumber INT PRIMARY KEY,
    customerName VARCHAR(50),
    contactLastName VARCHAR(50),
    contactFirstName VARCHAR(50),
    phone VARCHAR(50),
    addressLine1 VARCHAR(50),
    addressLine2 VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postalCode VARCHAR(15),
    country VARCHAR(50),
    salesRepEmployeeNumber INT,
    creditLimit DECIMAL(10, 2),
    CONSTRAINT FK_SalesRepEmployee FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees(employeeNumber)
);

CREATE TABLE orders (
    orderNumber INT PRIMARY KEY,
    orderDate DATE,
    requiredDate DATE,
    shippedDate DATE,
    status VARCHAR(15),
    comments NVARCHAR(MAX) NULL,
    customerNumber INT,
    CONSTRAINT FK_CustomerNumber FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);




CREATE TABLE orderdetails (
    orderNumber INT,
    productCode VARCHAR(15),
    quantityOrdered INT,
    priceEach DECIMAL(10, 2),
    orderLineNumber INT,
    PRIMARY KEY (orderNumber, productCode),
    CONSTRAINT FK_OrderNumber FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber),
    CONSTRAINT FK_ProductCode FOREIGN KEY (productCode) REFERENCES products(productCode)
);


CREATE TABLE payments (
    customerNumber INT,
    checkNumber VARCHAR(50),
    paymentDate DATE,
    amount DECIMAL(10, 2),
    PRIMARY KEY (customerNumber, checkNumber),
    CONSTRAINT FK_PaymentCustomerNumber FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);


CREATE TABLE interactions (
    interactionID INT IDENTITY(1,1) PRIMARY KEY,
    customerNumber INT,
    employeeNumber INT,
    interactionType VARCHAR(50),
    interactionDate DATE,
    interactionDetails NVARCHAR(MAX),
    CONSTRAINT FK_InteractionCustomerNumber FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber),
    CONSTRAINT FK_InteractionEmployeeNumber FOREIGN KEY (employeeNumber) REFERENCES employees(employeeNumber)
);


CREATE TABLE productReviews (
    reviewID INT IDENTITY(1,1) PRIMARY KEY,
    productCode VARCHAR(15),
    customerNumber INT,
    reviewRating INT CHECK (reviewRating BETWEEN 1 AND 5),
    reviewText NVARCHAR(MAX),
    reviewDate DATE,
    CONSTRAINT FK_ReviewProductCode FOREIGN KEY (productCode) REFERENCES products(productCode),
    CONSTRAINT FK_ReviewCustomerNumber FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);


CREATE PROCEDURE InsertRealisticOffices
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @RandomCity NVARCHAR(50);
    DECLARE @RandomPhone NVARCHAR(20);
    DECLARE @RandomAddress NVARCHAR(100);
    DECLARE @RandomCountry NVARCHAR(50);
    DECLARE @RandomPostalCode NVARCHAR(15);
    DECLARE @PhonePrefix VARCHAR(3);

    -- Array of realistic cities and countries
    DECLARE @CitiesArray TABLE (City NVARCHAR(50), Country NVARCHAR(50), PostalCode NVARCHAR(15));
    INSERT INTO @CitiesArray VALUES 
        ('New York', 'USA', '10001'),
        ('London', 'UK', 'SW1A 1AA'),
        ('Tokyo', 'Japan', '100-0001'),
        ('Paris', 'France', '75001'),
        ('Berlin', 'Germany', '10115');

    -- Start the loop to insert realistic offices
    WHILE @Counter <= @RecordCount
    BEGIN
        -- Select random city, country, and postal code
        SELECT TOP 1 
            @RandomCity = City,
            @RandomCountry = Country,
            @RandomPostalCode = PostalCode
        FROM @CitiesArray ORDER BY NEWID();

        -- Generate random phone number
        SET @PhonePrefix = '123'; -- Adjust the prefix for each country as needed
        SET @RandomPhone = @PhonePrefix + '-456-' + RIGHT('000' + CAST(FLOOR(RAND() * 1000) AS VARCHAR), 3);

        -- Generate random address
        SET @RandomAddress = '123 Main St, ' + @RandomCity;

        -- Insert realistic office data
        INSERT INTO offices (
            officeCode,
            city,
            phone,
            addressLine1,
            addressLine2,
            state,
            country,
            postalCode,
            territory
        )
        VALUES (
            CAST(@Counter AS VARCHAR),
            @RandomCity,
            @RandomPhone,
            @RandomAddress,
            NULL,
            NULL,
            @RandomCountry,
            @RandomPostalCode,
            'NA'
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;

-- Run the procedure
EXEC InsertRealisticOffices @RecordCount = 1000;

-- Check the inserted data
SELECT * FROM offices;


CREATE PROCEDURE InsertRealisticEmployees
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @MaxEmployeeNumber INT;
    DECLARE @RandomPhone VARCHAR(50);
    DECLARE @RandomOfficeCode VARCHAR(10);
    DECLARE @JobTitle NVARCHAR(50);
    DECLARE @LastNames NVARCHAR(50);
    DECLARE @FirstNames NVARCHAR(50);

    -- Array of realistic job titles
    DECLARE @JobTitles TABLE (JobTitle NVARCHAR(50));
    INSERT INTO @JobTitles VALUES ('Sales Manager'), ('Engineer'), ('Marketing Specialist'), ('HR Coordinator'), ('Accountant');

    DECLARE @LastNamesArray TABLE (LastName NVARCHAR(50));
    INSERT INTO @LastNamesArray VALUES ('Smith'), ('Johnson'), ('Williams'), ('Jones'), ('Brown'), ('Davis');

    DECLARE @FirstNamesArray TABLE (FirstName NVARCHAR(50));
    INSERT INTO @FirstNamesArray VALUES ('James'), ('John'), ('Robert'), ('Michael'), ('William'), ('David');

    -- Get the current maximum employeeNumber in the table
    SELECT @MaxEmployeeNumber = ISNULL(MAX(employeeNumber), 0) FROM employees;

    -- Start the loop from the next available employeeNumber
    SET @Counter = @MaxEmployeeNumber + 1;

    WHILE @Counter <= @MaxEmployeeNumber + @RecordCount
    BEGIN
        -- Random phone number generation (use different formats based on country/region)
        SET @RandomPhone = '987-654-' + RIGHT('000' + CAST(FLOOR(RAND() * 1000) AS VARCHAR), 3);
        
        -- Select random job title
        SELECT TOP 1 @JobTitle = JobTitle FROM @JobTitles ORDER BY NEWID();

        -- Select random names
        SELECT TOP 1 @LastNames = LastName FROM @LastNamesArray ORDER BY NEWID();
        SELECT TOP 1 @FirstNames = FirstName FROM @FirstNamesArray ORDER BY NEWID();
        
        -- Select random office code from the offices table
        SELECT TOP 1 @RandomOfficeCode = officeCode FROM offices ORDER BY NEWID();

        -- Insert realistic employee data
        INSERT INTO employees (
            employeeNumber, 
            lastName, 
            firstName, 
            extension, 
            email, 
            officeCode, 
            reportsTo, 
            jobTitle
        )
        VALUES (
            @Counter,  -- Unique employeeNumber
            @LastNames,  -- lastName
            @FirstNames,  -- firstName
            'EXT' + RIGHT('000' + CAST(FLOOR(RAND() * 1000) AS VARCHAR), 3),  -- extension
            @FirstNames + '.' + @LastNames + '@company.com',  -- email
            @RandomOfficeCode,  -- officeCode (select from existing offices)
            NULL,  -- reportsTo (can be filled later if needed)
            @JobTitle  -- jobTitle (random selection)
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;

EXEC InsertRealisticEmployees @RecordCount = 1000;

-- عرض البيانات
SELECT * FROM employees;

CREATE PROCEDURE InsertRealisticProductLines3
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @RandomTextDescription NVARCHAR(255);
    DECLARE @RandomHTMLDescription NVARCHAR(4000);
    DECLARE @RandomImage VARCHAR(255);
    DECLARE @BaseProductLine NVARCHAR(50);

    -- Array of base product line names
    DECLARE @ProductLinesArray TABLE (ProductLine NVARCHAR(50));
    INSERT INTO @ProductLinesArray VALUES ('Classic Cars'), ('Motorcycles'), ('Planes'), ('Ships'), ('Trains');

    -- Start the loop to insert realistic product lines
    WHILE @Counter <= @RecordCount
    BEGIN
        -- Select random base product line
        SELECT TOP 1 @BaseProductLine = ProductLine FROM @ProductLinesArray ORDER BY NEWID();

        -- Create a unique product line by appending the counter
        SET @RandomTextDescription = @BaseProductLine + ' ' + CAST(@Counter AS NVARCHAR);

        -- Generate random HTML description and image path
        SET @RandomHTMLDescription = '<p>High-quality ' + @RandomTextDescription + '.</p>';
        SET @RandomImage = 'images/' + @BaseProductLine + '.jpg';

        -- Insert realistic product line data
        INSERT INTO productlines (
            productLine,
            textDescription,
            htmlDescription,
            image
        )
        VALUES (
            @RandomTextDescription,            -- Unique productLine
            'Description for ' + @RandomTextDescription, -- textDescription
            @RandomHTMLDescription,            -- htmlDescription
            CONVERT(VARBINARY(MAX), @RandomImage) -- image as VARBINARY
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;

-- Run the procedure to insert 1000 rows
EXEC InsertRealisticProductLines3 @RecordCount = 1000;
SELECT * FROM productlines;


CREATE PROCEDURE InsertRealisticProducts1
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @ProductCode VARCHAR(15);
    DECLARE @ProductName VARCHAR(70);
    DECLARE @ProductLine VARCHAR(50);
    DECLARE @ProductScale VARCHAR(10);
    DECLARE @ProductVendor VARCHAR(50);
    DECLARE @ProductDescription NVARCHAR(MAX);
    DECLARE @QuantityInStock INT;
    DECLARE @BuyPrice DECIMAL(10, 2);
    DECLARE @MSRP DECIMAL(10, 2);

    -- Loop to insert realistic products
    WHILE @Counter <= @RecordCount
    BEGIN
        SET @ProductCode = 'PRD' + RIGHT('0000' + CAST(@Counter AS VARCHAR), 5);  -- Product code in format PRD00001
        SET @ProductName = 'Product ' + CAST(@Counter AS VARCHAR);  -- Example: Product 1, Product 2, ...
        
        -- Randomly assign one of the available product lines
        SET @ProductLine = (
            SELECT TOP 1 productLine FROM productlines 
            ORDER BY NEWID()
        );
        
        -- Use realistic scale for products (e.g., 1:18, 1:24, 1:50)
        SET @ProductScale = CASE 
            WHEN @Counter % 3 = 0 THEN '1:18'
            WHEN @Counter % 3 = 1 THEN '1:24'
            ELSE '1:50'
        END;

        -- Randomly assign vendor names (e.g., global product vendors)
        SET @ProductVendor = CASE 
            WHEN @Counter % 3 = 0 THEN 'Vendor A'
            WHEN @Counter % 3 = 1 THEN 'Vendor B'
            ELSE 'Vendor C'
        END;

        -- Realistic product descriptions
        SET @ProductDescription = 'High-quality product ' + CAST(@Counter AS VARCHAR) + ', designed for performance and durability.';

        -- Set realistic stock quantities (e.g., between 50 and 1000 units)
        SET @QuantityInStock = FLOOR(50 + RAND() * 951);  -- Random number between 50 and 1000

        -- Set realistic buy prices (e.g., between 10 and 1000 USD)
        SET @BuyPrice = ROUND(10 + RAND() * 990, 2);  -- Random number between 10 and 1000

        -- Set realistic MSRP (markup over buy price, e.g., 20% to 50%)
        SET @MSRP = ROUND(@BuyPrice * (1.2 + RAND() * 0.3), 2);  -- Random markup between 20% and 50%

        -- Insert into products table
        INSERT INTO products (
            productCode, 
            productName, 
            productLine, 
            productScale, 
            productVendor, 
            productDescription, 
            quantityInStock, 
            buyPrice, 
            MSRP
        )
        VALUES (
            @ProductCode, 
            @ProductName, 
            @ProductLine, 
            @ProductScale, 
            @ProductVendor, 
            @ProductDescription, 
            @QuantityInStock, 
            @BuyPrice, 
            @MSRP
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;


-- To execute the procedure:
EXEC InsertRealisticProducts1 @RecordCount = 1000;
-- Select data
SELECT * FROM products;


CREATE PROCEDURE InsertRealisticCustomers7
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @MaxCustomerNumber INT;
    DECLARE @RandomCreditLimit DECIMAL(10, 2);
    DECLARE @RandomSalesRepEmployeeNumber INT;
    DECLARE @RandomPhone VARCHAR(50);
    DECLARE @RandomCountry VARCHAR(50);
    DECLARE @RandomCity VARCHAR(50);
    DECLARE @RandomState VARCHAR(50);
    DECLARE @LastNames NVARCHAR(50);
    DECLARE @FirstNames NVARCHAR(50);
    DECLARE @PhonePrefix VARCHAR(3);

    -- Array of realistic values for countries, cities, and names
    DECLARE @Countries TABLE (Country VARCHAR(50));
    INSERT INTO @Countries VALUES ('USA'), ('Canada'), ('UK'), ('Germany'), ('France'), ('Italy');

    DECLARE @Cities TABLE (City VARCHAR(50), State VARCHAR(50));
    INSERT INTO @Cities VALUES 
    ('New York', 'NY'), ('Los Angeles', 'CA'), ('Chicago', 'IL'),
    ('Berlin', 'Berlin'), ('Paris', 'Île-de-France'), ('Rome', 'Lazio');

    DECLARE @LastNamesArray TABLE (LastName NVARCHAR(50));
    INSERT INTO @LastNamesArray VALUES ('Smith'), ('Johnson'), ('Williams'), ('Jones'), ('Brown'), ('Davis');

    DECLARE @FirstNamesArray TABLE (FirstName NVARCHAR(50));
    INSERT INTO @FirstNamesArray VALUES ('James'), ('John'), ('Robert'), ('Michael'), ('William'), ('David');

    -- Get the current maximum customerNumber in the table
    SELECT @MaxCustomerNumber = ISNULL(MAX(customerNumber), 0) FROM customers;

    -- Start the loop from the next available customerNumber
    SET @Counter = @MaxCustomerNumber + 1;

    WHILE @Counter <= @MaxCustomerNumber + @RecordCount
    BEGIN
        -- Random credit limit between 500 and 50000
        SET @RandomCreditLimit = ROUND(500 + (RAND() * 49500), 2);
        
        -- Select a valid sales representative employee number from the employees table
        SELECT TOP 1 @RandomSalesRepEmployeeNumber = employeeNumber 
        FROM employees
        ORDER BY NEWID();
        
        -- Random phone number generation
        SET @PhonePrefix = '123';
        SET @RandomPhone = @PhonePrefix + '-456-' + RIGHT('000' + CAST(FLOOR(RAND() * 1000) AS VARCHAR), 3);
        
        -- Select random country, city, and state
        SELECT TOP 1 @RandomCountry = Country FROM @Countries ORDER BY NEWID();
        SELECT TOP 1 @RandomCity = City, @RandomState = State FROM @Cities ORDER BY NEWID();
        
        -- Select random names
        SELECT TOP 1 @LastNames = LastName FROM @LastNamesArray ORDER BY NEWID();
        SELECT TOP 1 @FirstNames = FirstName FROM @FirstNamesArray ORDER BY NEWID();
        
        -- Insert realistic customer data
        INSERT INTO customers (
            customerNumber, 
            customerName, 
            contactLastName, 
            contactFirstName, 
            phone, 
            addressLine1, 
            addressLine2, 
            city, 
            state, 
            postalCode, 
            country, 
            salesRepEmployeeNumber, 
            creditLimit
        )
        VALUES (
            @Counter,  -- Unique customerNumber
            @FirstNames + ' ' + @LastNames + ' LLC',  -- customerName
            @LastNames,  -- contactLastName
            @FirstNames,  -- contactFirstName
            @RandomPhone,  -- phone
            '123 Main St',  -- addressLine1 (can be more dynamic)
            'Suite ' + CAST(FLOOR(RAND() * 100) AS VARCHAR),  -- addressLine2
            @RandomCity,  -- city
            @RandomState,  -- state
            'ZIP' + CAST(10000 + @Counter AS VARCHAR),  -- postalCode
            @RandomCountry,  -- country
            @RandomSalesRepEmployeeNumber,  -- salesRepEmployeeNumber (select from existing employees)
            @RandomCreditLimit  -- creditLimit
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;

EXEC InsertRealisticCustomers7 @RecordCount = 1000;

select * from customers 

Go
CREATE PROCEDURE InsertRealisticOrders
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @MaxOrderNumber INT;
    DECLARE @RandomStatus VARCHAR(15);
    DECLARE @CustomerNumber INT;
    DECLARE @OrderDate DATE;
    DECLARE @RequiredDate DATE;
    DECLARE @ShippedDate DATE;

    -- Array of realistic order statuses
    DECLARE @Statuses TABLE (Status NVARCHAR(15));
    INSERT INTO @Statuses VALUES ('Shipped'), ('Pending'), ('Cancelled'), ('In Process');

    -- Get the current maximum orderNumber in the table
    SELECT @MaxOrderNumber = ISNULL(MAX(orderNumber), 0) FROM orders;

    -- Start the loop from the next available orderNumber
    SET @Counter = @MaxOrderNumber + 1;

    WHILE @Counter <= @MaxOrderNumber + @RecordCount
    BEGIN
        -- Select random status
        SELECT TOP 1 @RandomStatus = Status FROM @Statuses ORDER BY NEWID();

        -- Select random customerNumber from customers table
        SELECT TOP 1 @CustomerNumber = customerNumber FROM customers ORDER BY NEWID();

        -- Generate realistic dates
        SET @OrderDate = DATEADD(DAY, -FLOOR(RAND() * 100), GETDATE());  -- order date in the past 100 days
        SET @RequiredDate = DATEADD(DAY, 7, @OrderDate);  -- required date 7 days after order date
        SET @ShippedDate = CASE WHEN @RandomStatus = 'Shipped' THEN DATEADD(DAY, 2, @OrderDate) ELSE NULL END;  -- shipped date 2 days after order date if shipped

        -- Insert realistic order data
        INSERT INTO orders (
            orderNumber, 
            orderDate, 
            requiredDate, 
            shippedDate, 
            status, 
            comments, 
            customerNumber
        )
        VALUES (
            @Counter,  -- Unique orderNumber
            @OrderDate,  -- orderDate
            @RequiredDate,  -- requiredDate
            @ShippedDate,  -- shippedDate
            @RandomStatus,  -- status
            'Order placed by customer ' + CAST(@CustomerNumber AS VARCHAR),  -- comments
            @CustomerNumber  -- customerNumber (select from existing customers)
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;
Go
EXEC InsertRealisticOrders @RecordCount = 1000;
Go
-- عرض البيانات
SELECT * FROM orders;

Go
CREATE PROCEDURE InsertRealisticOrderDetails1
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @OrderNumber INT;
    DECLARE @ProductCode VARCHAR(15);
    DECLARE @QuantityOrdered INT;
    DECLARE @PriceEach DECIMAL(10, 2);
    DECLARE @OrderLineNumber INT;

    -- Check if there are any products
    IF EXISTS (SELECT 1 FROM products)
    BEGIN
        -- Get existing orders and products
        DECLARE @Orders TABLE (OrderNumber INT);
        DECLARE @Products TABLE (ProductCode VARCHAR(15));
        INSERT INTO @Orders SELECT orderNumber FROM orders;
        INSERT INTO @Products SELECT productCode FROM products;

        WHILE @Counter <= @RecordCount
        BEGIN
            -- Select random order and product, ensure non-null values
            SELECT TOP 1 @OrderNumber = OrderNumber FROM @Orders ORDER BY NEWID();
            SELECT TOP 1 @ProductCode = ProductCode FROM @Products ORDER BY NEWID();

            -- Ensure that we have a valid product code
            IF @ProductCode IS NOT NULL
            BEGIN
                -- Generate realistic values
                SET @QuantityOrdered = FLOOR(1 + RAND() * 100);
                SET @PriceEach = ROUND(10 + (RAND() * 90), 2);
                SET @OrderLineNumber = 1;

                -- Insert order details
                INSERT INTO orderdetails (
                    orderNumber, 
                    productCode, 
                    quantityOrdered, 
                    priceEach, 
                    orderLineNumber
                )
                VALUES (
                    @OrderNumber,  -- orderNumber
                    @ProductCode,  -- productCode
                    @QuantityOrdered,  -- quantityOrdered
                    @PriceEach,  -- priceEach
                    @OrderLineNumber  -- orderLineNumber
                );
            END

            SET @Counter = @Counter + 1;
        END
    END
    ELSE
    BEGIN
        PRINT 'No products available in the products table!';
    END
END;
Go
-- To execute
EXEC InsertRealisticOrderDetails1 @RecordCount = 1000;
Go
-- Select data
SELECT * FROM orderdetails;


CREATE PROCEDURE InsertRealisticPayments
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @CustomerNumber INT;
    DECLARE @CheckNumber VARCHAR(50);
    DECLARE @PaymentDate DATE;
    DECLARE @Amount DECIMAL(10, 2);

    -- Get existing customer numbers
    DECLARE @CustomerNumbers TABLE (CustomerNumber INT);
    INSERT INTO @CustomerNumbers SELECT customerNumber FROM customers;

    WHILE @Counter <= @RecordCount
    BEGIN
        -- Select random customer
        SELECT TOP 1 @CustomerNumber = CustomerNumber FROM @CustomerNumbers ORDER BY NEWID();

        -- Generate realistic values
        SET @CheckNumber = 'CHK' + RIGHT('000' + CAST(FLOOR(RAND() * 10000) AS VARCHAR), 4);
        SET @PaymentDate = DATEADD(DAY, -FLOOR(RAND() * 100), GETDATE());
        SET @Amount = ROUND(100 + (RAND() * 4900), 2);

        -- Insert payment data
        INSERT INTO payments (
            customerNumber, 
            checkNumber, 
            paymentDate, 
            amount
        )
        VALUES (
            @CustomerNumber,  -- customerNumber
            @CheckNumber,  -- checkNumber
            @PaymentDate,  -- paymentDate
            @Amount  -- amount
        );

        SET @Counter = @Counter + 1;
    END
END;

-- To execute
EXEC InsertRealisticPayments @RecordCount = 1000;
-- Select data
SELECT * FROM payments;

CREATE PROCEDURE InsertRealisticInteractions
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @CustomerNumber INT;
    DECLARE @EmployeeNumber INT;
    DECLARE @InteractionType NVARCHAR(50);
    DECLARE @InteractionDate DATE;
    DECLARE @InteractionDetails NVARCHAR(MAX);

    -- Array of interaction types
    DECLARE @InteractionTypes TABLE (InteractionType NVARCHAR(50));
    INSERT INTO @InteractionTypes VALUES ('Phone Call'), ('Email'), ('In-Person Meeting'), ('Online Chat');

    -- Start the loop to insert realistic interactions
    WHILE @Counter <= @RecordCount
    BEGIN
        -- Select random customer and employee
        SELECT TOP 1 @CustomerNumber = customerNumber FROM customers ORDER BY NEWID();
        SELECT TOP 1 @EmployeeNumber = employeeNumber FROM employees ORDER BY NEWID();

        -- Select random interaction type
        SELECT TOP 1 @InteractionType = InteractionType FROM @InteractionTypes ORDER BY NEWID();

        -- Generate random interaction date and details
        SET @InteractionDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()); -- Random date within the last year
        SET @InteractionDetails = 'Details about ' + @InteractionType + ' with customer ' + CAST(@CustomerNumber AS NVARCHAR);

        -- Insert realistic interaction data
        INSERT INTO interactions (
            customerNumber,
            employeeNumber,
            interactionType,
            interactionDate,
            interactionDetails
        )
        VALUES (
            @CustomerNumber,
            @EmployeeNumber,
            @InteractionType,
            @InteractionDate,
            @InteractionDetails
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;

-- Run the procedure to insert 1000 rows
EXEC InsertRealisticInteractions @RecordCount = 1000;

-- Check the inserted data
SELECT * FROM interactions;

CREATE PROCEDURE InsertRealisticProductReviews
    @RecordCount INT
AS
BEGIN
    DECLARE @Counter INT = 1;
    DECLARE @ProductCode NVARCHAR(15);
    DECLARE @CustomerNumber INT;
    DECLARE @ReviewRating INT;
    DECLARE @ReviewText NVARCHAR(MAX);
    DECLARE @ReviewDate DATE;

    -- Array of possible review texts
    DECLARE @ReviewTexts TABLE (ReviewText NVARCHAR(MAX));
    INSERT INTO @ReviewTexts VALUES 
        ('Excellent product! Highly recommended.'), 
        ('Good quality, but a bit expensive.'), 
        ('Average product, could be better.'), 
        ('Not satisfied, would not buy again.'),
        ('Fantastic! Exceeded my expectations.');

    -- Start the loop to insert realistic product reviews
    WHILE @Counter <= @RecordCount
    BEGIN
        -- Select random product and customer
        SELECT TOP 1 @ProductCode = productCode FROM products ORDER BY NEWID();
        SELECT TOP 1 @CustomerNumber = customerNumber FROM customers ORDER BY NEWID();

        -- Generate random review rating, review text, and review date
        SET @ReviewRating = ABS(CHECKSUM(NEWID()) % 5) + 1; -- Random rating between 1 and 5
        SELECT TOP 1 @ReviewText = ReviewText FROM @ReviewTexts ORDER BY NEWID(); -- Random review text
        SET @ReviewDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()); -- Random date within the last year

        -- Insert realistic product review data
        INSERT INTO productReviews (
            productCode,
            customerNumber,
            reviewRating,
            reviewText,
            reviewDate
        )
        VALUES (
            @ProductCode,
            @CustomerNumber,
            @ReviewRating,
            @ReviewText,
            @ReviewDate
        );

        -- Increment counter
        SET @Counter = @Counter + 1;
    END
END;

-- Run the procedure to insert 1000 rows
EXEC InsertRealisticProductReviews @RecordCount = 1000;

-- Check the inserted data
SELECT * FROM productReviews;


select * from customers
select * from employees
select * from interactions
select * from offices
select * from interactions
select * from orderdetails
select * from orders
select * from payments
select * from productlines
select * from productReviews
select * from products
