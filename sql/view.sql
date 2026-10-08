/*
    Superstore Sales Analytics
    Analytical SQL View

    Database: SQL Server
    Purpose: Prepare a clean dataset for Power BI analysis
*/


CREATE OR ALTER VIEW dbo.vw_superstore_analysis
AS

SELECT
    [Row ID] AS Row_ID,
    [Order ID] AS Order_ID,
    [Order Date] AS Order_Date,
    [Ship Date] AS Ship_Date,
    [Ship Mode] AS Ship_Mode,

    [Customer ID] AS Customer_ID,
    [Customer Name] AS Customer_Name,
    [Segment] AS Segment,

    [Country] AS Country,
    [City] AS City,
    [State] AS State,
    [Postal Code] AS Postal_Code,
    [Market] AS Market,
    [Region] AS Region,

    [Product ID] AS Product_ID,
    [Category] AS Category,
    [Sub-Category] AS Sub_Category,
    [Product Name] AS Product_Name,

    [Sales] AS Sales,
    [Quantity] AS Quantity,
    [Discount] AS Discount,
    [Profit] AS Profit,

    CASE
        WHEN [Profit] > 0 THEN 'Profit'
        WHEN [Profit] < 0 THEN 'Loss'
        ELSE 'Break-even'
    END AS Profit_Status

FROM dbo.Superstore;
GO