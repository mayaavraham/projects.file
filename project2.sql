----------1------------

WITH t
AS
(

  SELECT YEAR(so.OrderDate) AS "Year",
	     SUM(sol.UnitPrice*sol.Quantity) AS IncomePerYear,
         COUNT(DISTINCT MONTH(so.OrderDate)) AS NumberOfDistinctMonths,
	     SUM(sol.UnitPrice*sol.Quantity)/COUNT(DISTINCT MONTH(so.OrderDate))*12 AS YearlyLinearIncome

  FROM   [Sales].[Orders] so
  JOIN   [Sales].[OrderLines] sol ON sol.OrderID = so.OrderID
  JOIN   [Sales].[Invoices] si ON si.OrderID = so.OrderID

  GROUP BY YEAR(so.OrderDate)
)


SELECT Year,
       FORMAT(IncomePerYear,'#,#.00') AS IncomePerYear,
	   NumberOfDistinctMonths,
	   FORMAT(YearlyLinearIncome,'#,#.00') AS YearlyLinearIncome,
	   FORMAT(ROUND(((YearlyLinearIncome/LAG( YearlyLinearIncome) OVER(ORDER BY Year))-1)*100,2),'F2') AS GrowthRate

FROM t;



----------2------------

WITH RankedSales 
AS 
(
 SELECT   YEAR(so.OrderDate) AS year,
          DATEPART(QUARTER, so.OrderDate) AS quarter,
          sc.CustomerName,
          SUM(sol.UnitPrice * sol.Quantity) AS total_spent,
          RANK() OVER (PARTITION BY YEAR(so.OrderDate), DATEPART(QUARTER, so.OrderDate) 
                       ORDER BY SUM(sol.UnitPrice * sol.Quantity) DESC) AS rnk

 FROM     [Sales].[Orders] so
 JOIN     [Sales].[Customers] sc ON so.CustomerID = sc.CustomerID
 JOIN     [Sales].[OrderLines] sol ON sol.OrderID = so.OrderID
 JOIN     [Sales].[Invoices] si ON si.OrderID = so.OrderID

 GROUP BY sc.CustomerID,
          sc.CustomerName,
          YEAR(so.OrderDate),
          DATEPART(QUARTER, so.OrderDate)
)


SELECT    YEAR AS TheYear,
          QUARTER AS TheQuarter,
          CustomerName,
          total_spent AS IncomePerQ,
          rnk

FROM      RankedSales

WHERE     rnk <= 5

ORDER BY  TheYear, 
          TheQuarter, 
          rnk;


----------3------------

SELECT    TOP 10 WITH TIES iv.StockItemID,
          it.StockItemName,
		  FORMAT(SUM(iv.ExtendedPrice-iv.TaxAmount),'#,#.00') AS TotalProfit

FROM      [Sales].[InvoiceLines] iv

LEFT JOIN [Warehouse].[StockItems] it ON it.StockItemID = iv.StockItemID

GROUP BY  iv.StockItemID,
          it.StockItemName

ORDER BY  SUM(iv.ExtendedPrice-iv.TaxAmount) DESC;




----------4------------

SELECT   ROW_NUMBER()OVER(ORDER BY RecommendedRetailPrice - UnitPrice DESC) AS RN,
         StockItemID,
         StockItemName,
	     UnitPrice,
	     RecommendedRetailPrice,
	     RecommendedRetailPrice - UnitPrice AS NominalProductProfit,
	     DENSE_RANK() OVER (ORDER BY RecommendedRetailPrice - UnitPrice DESC) AS DNR

FROM     [Warehouse].[StockItems]

WHERE    ValidTo > GETDATE()

ORDER BY NominalProductProfit DESC;



----------5------------

SELECT    CONCAT(it.SupplierID, ' - ', su.SupplierName) AS SupplierInfo,
          STRING_AGG(CONCAT(it.StockItemID, ' ', it.StockItemName), ' /, ') AS ItemInfo
FROM      [Warehouse].[StockItems] it
LEFT JOIN [Purchasing].[Suppliers] su ON su.SupplierID = it.SupplierID
GROUP BY  it.SupplierID, su.SupplierName
ORDER BY  it.SupplierID;




----------6------------

SELECT    TOP 5 sc.CustomerID,
	   	  cit.CityName,
		  cou.CountryName,
		  cou.Continent,
		  cou.Region,
		  FORMAT(SUM(sil.ExtendedPrice),'#,#.00') AS TotalExtendedPrice 

FROM      [Sales].[Orders] so
JOIN      [Sales].[Invoices] si             ON si.OrderID = so.OrderID
JOIN      [Sales].[Customers] sc            ON so.CustomerID = sc.CustomerID
JOIN      [Sales].[InvoiceLines] sil        ON sil.InvoiceID = si.InvoiceID
LEFT JOIN [Application].[Cities] cit        ON cit.CityID = sc.PostalCityID
LEFT JOIN [Application].[StateProvinces] sp ON sp.StateProvinceID = cit.StateProvinceID
LEFT JOIN [Application].[Countries] cou     ON cou.CountryID = sp.CountryID

GROUP BY sc.CustomerID,
         cit.CityName,
		 cou.CountryName,
		 cou.Continent,
		 cou.Region

ORDER BY SUM(sil.ExtendedPrice) DESC;



----------7------------


WITH cte1 AS
(
    SELECT     YEAR(so.OrderDate) AS OrderYear,
               MONTH(so.OrderDate) AS OrderMonth,
               SUM(sol.UnitPrice * sol.Quantity) AS MonthlyTotal,
               SUM(SUM(sol.UnitPrice * sol.Quantity)) OVER (ORDER BY YEAR(so.OrderDate), MONTH(so.OrderDate)) AS RunningTotal
    FROM      [Sales].[Orders] so
    JOIN      [Sales].[OrderLines] sol ON sol.OrderID = so.OrderID
    JOIN      [Sales].[Invoices] si ON si.OrderID = so.OrderID
    GROUP BY  YEAR(so.OrderDate), MONTH(so.OrderDate)
),

cte2 AS 
(
    SELECT   Orderyear, 
             CASE 
                 WHEN OrderMonth IS NULL THEN 't' 
                 ELSE CAST(OrderMonth AS VARCHAR)
             END AS OrderMonth, 
             FORMAT(MonthlyTotal, '#,0.00') AS MonthlyTotal,  
             FORMAT(RunningTotal, '#,0.00') AS RunningTotal,
             CASE 
                 WHEN OrderMonth IS NULL THEN 999 
                 ELSE OrderMonth 
             END AS OrderMonthForOrdering

    FROM     cte1

    UNION ALL

    SELECT   OrderYear, 
             'Grand Total' AS OrderMonth,  
             FORMAT(SUM(MonthlyTotal), '#,0.00') AS MonthlyTotal,  
             FORMAT(SUM(MonthlyTotal), '#,0.00') AS RunningTotal,  
             999 AS OrderMonthForOrdering  
    FROM     cte1
    GROUP BY orderyear
)

SELECT   OrderYear, 
         OrderMonth, 
         MonthlyTotal, 
         RunningTotal
FROM     cte2
ORDER BY orderyear, OrderMonthForOrdering;






----------8------------


SELECT ordermonth, [2013], [2014], [2015], [2016]
FROM (
      SELECT YEAR(OrderDate) AS yy,
             MONTH(OrderDate) AS ordermonth,
             orderid
      FROM [Sales].[Orders]

      ) AS t

PIVOT ( COUNT(orderid) FOR yy IN ([2013], [2014], [2015], [2016]) ) AS pvt
ORDER BY ordermonth;





----------9------------
WITH t1 AS (
    
SELECT SC.CustomerID, 
       SC.CustomerName,
       SO.OrderDate, 
       LAG(SO.OrderDate, 1) OVER(PARTITION BY SC.CustomerID ORDER BY SO.OrderDate) AS PreviousOrderDate,
	   MAX(so.orderdate)OVER(PARTITION BY sc.CustomerID) AS lastorder,
       DATEDIFF(DD, LAG(SO.OrderDate, 1) OVER(PARTITION BY SC.CustomerID ORDER BY SO.OrderDate), MAX(so.orderdate)OVER(PARTITION BY sc.CustomerID)) AS DaysSinceLastOrder

FROM   [Sales].[Orders] SO
JOIN   [Sales].[Customers] SC ON SO.CustomerID = SC.CustomerID

),


t2 AS (

SELECT CustomerID, 
       CustomerName,
       OrderDate, 
	   PreviousOrderDate,
	   lastorder,
	   DATEDIFF(DD,  lastorder, MAX(orderdate)OVER() ) AS DaysSinceLastOrder,
       AVG(DATEDIFF(DD, PreviousOrderDate, orderdate )) OVER (PARTITION BY customerid ) AS AVGDaysBetweenOrders

FROM   t1


)


SELECT   CustomerID,
         CustomerName,
         OrderDate,
		 PreviousOrderDate,
         DaysSinceLastOrder,
         AVGDaysBetweenOrders,
         IIF(DaysSinceLastOrder>AVGDaysBetweenOrders*2, 'Potential Churn', 'Active') AS CustomerStatus
FROM     t2

ORDER BY CustomerID,OrderDate;





----------10------------



WITH cte AS 
(
SELECT   cat.CustomerCategoryName,  
         cat.CustomerCategoryID,
         COUNT(cus.CustomerID) AS CustCount
FROM     [Sales].[Customers] cus
JOIN     [Sales].[CustomerCategories] cat 
ON       cat.CustomerCategoryID = cus.CustomerCategoryID
WHERE    cus.CreditLimit IS NOT NULL
GROUP BY cat.CustomerCategoryName, 
         cat.CustomerCategoryID
),

SpecialCustomers AS
(
SELECT 
-- Count one for all customers starting with 'tailspin%' and one for all starting with 'wingtip%'
(CASE WHEN EXISTS (SELECT 1 FROM [Sales].[Customers] cus WHERE cus.CustomerName LIKE 'tailspin%') THEN 1 ELSE 0 END) +
(CASE WHEN EXISTS (SELECT 1 FROM [Sales].[Customers] cus WHERE cus.CustomerName LIKE 'wingtip%') THEN 1 ELSE 0 END) AS SpecialCustCount
)

SELECT  cte.CustomerCategoryName,
        cte.CustomerCategoryID,
    
        IIF(cte.CustomerCategoryID = 3, cte.CustCount + (SELECT SpecialCustCount FROM SpecialCustomers), cte.CustCount) AS CustCountWithSpecial,
        
		SUM(IIF(cte.CustomerCategoryID = 3, cte.CustCount + (SELECT SpecialCustCount FROM SpecialCustomers), cte.CustCount)) OVER () AS TotalCustCount,
        
		CONCAT(CAST(
                    (IIF(cte.CustomerCategoryID = 3, cte.CustCount + (SELECT SpecialCustCount FROM SpecialCustomers), cte.CustCount)   * 100.0) / 
                     SUM(IIF(cte.CustomerCategoryID = 3, cte.CustCount + (SELECT SpecialCustCount FROM SpecialCustomers), cte.CustCount)) OVER () AS NUMERIC(10,2)), '%'
					) 
    AS PercentageOfTotal
FROM 
    cte;

