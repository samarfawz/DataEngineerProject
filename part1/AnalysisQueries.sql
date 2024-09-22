--Write SQL queries to extract, update, and analyze data.

--1-This query identifies the top 10 customers based on their total payments, which helps in understanding who the most valuable customers are.
SELECT TOP 10 c.customerName, SUM(p.amount) AS TotalPayments
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY TotalPayments DESC;

--2-This query shows the total sales per month, helping to identify seasonal trends and peak sales periods.
SELECT FORMAT(o.orderDate, 'yyyy-MM') AS SalesMonth, 
       SUM(od.quantityOrdered * od.priceEach) AS MonthlySales
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY FORMAT(o.orderDate, 'yyyy-MM')
ORDER BY SalesMonth;


--3-This query lists products that are running low on stock, which is essential for inventory management.
SELECT p.productCode, p.productName, p.quantityInStock, p.MSRP
FROM products p
WHERE p.quantityInStock < 60
ORDER BY p.quantityInStock ASC;

--4-This query identifies the most popular product based on the quantity ordered,
--which can help with product marketing and stocking strategies.
WITH TopProduct AS (
    SELECT TOP 1 p.productCode
    FROM products p
    JOIN orderdetails od ON p.productCode = od.productCode
    GROUP BY p.productCode
    ORDER BY SUM(od.quantityOrdered) DESC)

SELECT p.productCode,
       p.productName,
       p.productLine,
       p.productScale,
       p.productVendor,
       p.productDescription,
       p.quantityInStock,
       p.buyPrice,
       p.MSRP,
       pl.textDescription AS ProductLineDescription,
       SUM(od.quantityOrdered) AS TotalQuantityOrdered,
       SUM(od.quantityOrdered * od.priceEach) AS TotalSalesValue
FROM products p
JOIN TopProduct tp ON p.productCode = tp.productCode
JOIN orderdetails od ON p.productCode = od.productCode
JOIN productlines pl ON p.productLine = pl.productLine
GROUP BY p.productCode, p.productName, p.productLine, p.productScale, 
         p.productVendor, p.productDescription, p.quantityInStock, 
         p.buyPrice, p.MSRP, pl.textDescription;

--5-Identifies employees who have not made any sales, which could help in addressing performance issues or reassigning tasks to improve overall efficiency.
SELECT e.employeeNumber, e.firstName + ' ' + e.lastName AS EmployeeName
FROM employees e
LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
WHERE o.orderNumber IS NULL
GROUP BY e.employeeNumber, e.firstName, e.lastName;  -- Lists employees with no sales activity

--6-This query identifies the most profitable products by calculating the total profit (sales minus cost) 
--for each product, helping the business focus on high-margin items.
SELECT TOP 5 p.productName, 
       SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) AS TotalProfit
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName
ORDER BY TotalProfit DESC;  -- Orders by profit to highlight top-performing products

--7-This query analyzes payment behavior by comparing average payment amounts across different customers, 
--which helps in identifying reliable payers and those who may need follow-up or credit adjustments.
SELECT c.customerName, 
       COUNT(p.amount) AS NumberOfPayments,
       AVG(p.amount) AS AveragePaymentAmount,
       SUM(p.amount) AS TotalPayments
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY AveragePaymentAmount DESC;  -- Orders by average payment amount to highlight payment behavior







