/*
    Superstore Sales Analytics
    Business Analysis Queries

    Database: SQL Server
    Source: vw_superstore_analysis
*/


-- 1. Total Sales

SELECT
    SUM(Sales) AS Total_Sales
FROM dbo.vw_superstore_analysis;


-- 2. Total Profit

SELECT
    SUM(Profit) AS Total_Profit
FROM dbo.vw_superstore_analysis;


-- 3. Total Orders

SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM dbo.vw_superstore_analysis;


-- 4. Total Customers

SELECT
    COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM dbo.vw_superstore_analysis;


-- 5. Average Order Value

SELECT
    SUM(Sales) * 1.0 /
    NULLIF(COUNT(DISTINCT Order_ID), 0) AS AOV
FROM dbo.vw_superstore_analysis;


-- 6. Profit Margin

SELECT
    SUM(Profit) * 100.0 /
    NULLIF(SUM(Sales), 0) AS Profit_Margin_Pct
FROM dbo.vw_superstore_analysis;


-- 7. Revenue by Region

SELECT
    Region,
    SUM(Sales) AS Total_Sales
FROM dbo.vw_superstore_analysis
GROUP BY Region
ORDER BY Total_Sales DESC;


-- 8. Revenue by Category

SELECT
    Category,
    SUM(Sales) AS Total_Sales
FROM dbo.vw_superstore_analysis
GROUP BY Category
ORDER BY Total_Sales DESC;


-- 9. Profit by Category

SELECT
    Category,
    SUM(Profit) AS Total_Profit
FROM dbo.vw_superstore_analysis
GROUP BY Category
ORDER BY Total_Profit DESC;


-- 10. Monthly Revenue

SELECT
    DATEFROMPARTS(
        YEAR(Order_Date),
        MONTH(Order_Date),
        1
    ) AS Revenue_Month,
    SUM(Sales) AS Monthly_Revenue
FROM dbo.vw_superstore_analysis
GROUP BY
    DATEFROMPARTS(
        YEAR(Order_Date),
        MONTH(Order_Date),
        1
    )
ORDER BY Revenue_Month;


-- 11. Top 10 Products by Revenue

SELECT TOP (10)
    Product_ID,
    Product_Name,
    SUM(Sales) AS Total_Sales
FROM dbo.vw_superstore_analysis
GROUP BY
    Product_ID,
    Product_Name
ORDER BY Total_Sales DESC;


-- 12. Top 10 Customers by Revenue

SELECT TOP (10)
    Customer_ID,
    Customer_Name,
    SUM(Sales) AS Total_Sales
FROM dbo.vw_superstore_analysis
GROUP BY
    Customer_ID,
    Customer_Name
ORDER BY Total_Sales DESC;


-- 13. Profit Status Distribution

SELECT
    Profit_Status,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM dbo.vw_superstore_analysis
GROUP BY Profit_Status
ORDER BY Total_Orders DESC;


-- 14. Loss-Making Products

SELECT
    Product_ID,
    Product_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.vw_superstore_analysis
GROUP BY
    Product_ID,
    Product_Name
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


-- 15. Customer Ranking by Revenue

WITH Customer_Revenue AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Sales) AS Total_Sales
    FROM dbo.vw_superstore_analysis
    GROUP BY
        Customer_ID,
        Customer_Name
)

SELECT
    Customer_ID,
    Customer_Name,
    Total_Sales,
    RANK() OVER (
        ORDER BY Total_Sales DESC
    ) AS Customer_Rank
FROM Customer_Revenue
ORDER BY Customer_Rank;


-- 16. Top 3 Products by Revenue

WITH Product_Revenue AS
(
    SELECT
        Product_ID,
        Product_Name,
        SUM(Sales) AS Total_Sales
    FROM dbo.vw_superstore_analysis
    GROUP BY
        Product_ID,
        Product_Name
),
Product_Ranking AS
(
    SELECT
        Product_ID,
        Product_Name,
        Total_Sales,
        RANK() OVER (
            ORDER BY Total_Sales DESC
        ) AS Product_Rank
    FROM Product_Revenue
)

SELECT
    Product_ID,
    Product_Name,
    Total_Sales,
    Product_Rank
FROM Product_Ranking
WHERE Product_Rank <= 3
ORDER BY Product_Rank;


-- 17. Running Total Revenue

WITH Monthly_Revenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(Order_Date),
            MONTH(Order_Date),
            1
        ) AS Revenue_Month,
        SUM(Sales) AS Monthly_Revenue
    FROM dbo.vw_superstore_analysis
    GROUP BY
        DATEFROMPARTS(
            YEAR(Order_Date),
            MONTH(Order_Date),
            1
        )
)

SELECT
    Revenue_Month,
    Monthly_Revenue,
    SUM(Monthly_Revenue) OVER (
        ORDER BY Revenue_Month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Revenue
FROM Monthly_Revenue
ORDER BY Revenue_Month;


-- 18. Monthly Growth Analysis

WITH Monthly_Revenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(Order_Date),
            MONTH(Order_Date),
            1
        ) AS Revenue_Month,
        SUM(Sales) AS Monthly_Revenue
    FROM dbo.vw_superstore_analysis
    GROUP BY
        DATEFROMPARTS(
            YEAR(Order_Date),
            MONTH(Order_Date),
            1
        )
),
Monthly_Growth AS
(
    SELECT
        Revenue_Month,
        Monthly_Revenue,
        LAG(Monthly_Revenue) OVER (
            ORDER BY Revenue_Month
        ) AS Previous_Month_Revenue
    FROM Monthly_Revenue
)

SELECT
    Revenue_Month,
    Monthly_Revenue,
    Previous_Month_Revenue,
    ROUND(
        (Monthly_Revenue - Previous_Month_Revenue) * 100.0
        / NULLIF(Previous_Month_Revenue, 0),
        2
    ) AS Growth_Pct
FROM Monthly_Growth
ORDER BY Revenue_Month;
