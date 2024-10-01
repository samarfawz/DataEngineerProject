# Project Title
Customer Data Management and Analysis
## Description
This project includes a series of SQL queries for creating tables,
inserting data, and performing basic analysis. It also provides the results of the analysis in PDF format,
along with the Entity-Relationship Diagram (ERD).

## Part1  (database)
1-CreateQueries.sql: 
               -Open SSMS and connect to your server.
               -Open CreateQueries.sql.
               -Execute the script to create the database and insert the data.

2-database.bacpac: -Alternative first step , you can import the provided database.bacpac file 
                     if you want to restore the database:
                  - Open SSMS, right-click on "Databases," and select Import Data-tier Application.
                  -Follow the wizard and select the database.bacpac file to import the database.

3-ERD: Includes a picture (ERD.png) and file (ERD.pdf) that represent the Entity-Relationship Diagram (ERD) of the database.

4-AnalysisQueries.sql: 
                     -Open AnalysisQueries.sql in SSMS.
                     -Execute the script to retrieve the analysis results.
                     
5-Analysis (PDF): Analysis results in a PDF document (Analysis.pdf).

## Part2   (warehouse)
1-CreateDatawarehouse_Queries.sql: 
                                 -Open SSMS and connect to your server.
                                 -Open CreateDatawarehouse_Queries.sql.
                                 -Execute the script to create the data warehouse.

2-customer_datawarehouse.bacpac: -Alternative first step ,you can also restore the data warehouse using the provided customer_datawarehouse :
                                 -Open SSMS, right-click on "Databases," and select Import Data-tier Application.
                                 -Follow the wizard and import customer_datawarehouse.bacpac.

3-datawarehouse_erd:Check the datawarehouse_erd folder for the Entity-Relationship Diagram of the data warehouse. This will help you understand the structure of the warehouse.

4-ETL_Script.sql: Script Run the ETL Process
                  Use the ETL_Script.sql to transfer data from the operational database to the data warehouse 

5-business_analysis.py:file contains Python code that uses the following libraries to visualize and analyze the data from the data warehouse:
                     -Pandas for data manipulation.
                     -Matplotlib and Seaborn for data visualization.

6-AnalysisFigures: A folder containing figures and visualizations related to the analysis.

## part3
## part 4
