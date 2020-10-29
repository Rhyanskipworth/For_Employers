USE WideWorldImportersDW
GO

-- Concatenating query result into one column to allow SSIS data flow to automate data extraction package by preventing manual "metadata error" with comma delimiter.

	SELECT CONCAT_WS
	(
		',',
		CAST(FS.[Invoice Date Key] AS nvarchar (40)),
		CAST(SUM(FS.Quantity) AS nvarchar (40)),
		CAST(SUM(FS.Profit) AS nvarchar (40)),
		CAST(SUM(FS.[Tax Amount]) AS nvarchar (40)),
		CAST(SUM(FS.[Total Including Tax]) AS nvarchar (40)),
		CAST(SUM(FS.[Total Excluding Tax]) AS nvarchar (40))
	) AS Result
	FROM [Fact].[Sale] FS
	GROUP BY FS.[Invoice Date Key]
	ORDER BY FS.[Invoice Date Key]



USE AdventureWorks2019
GO 

-- Removes duplicate values from Production.TransactionHistory table. Showcases data cleansing.

	WITH  DuplicateValues AS  
 		( SELECT  PTH.TransactionID, 
		   	  PTH.ProductID, 
		  	  ROW_NUMBER() OVER ( PARTITION BY PTH.TransactionID, 
		   	  PTH.ProductID ORDER BY PTH.TransactionID) AS Duplicates 
		  FROM  production.TransactionHistory PTH ) 
		  
  	DELETE  FROM DuplicateValues  
  	WHERE  Duplicates > 1  

-- How many Employees (EEs) are working in AdventureWorks2019? Showcases my logical analysis with new datasets. 

	SELECT * 					--290 rows returned, which means there are 290 EEs in total
	FROM HumanResources.Employee 			

	SELECT COUNT(*) as Total_Employees, 		--To identify all person classifications
		PersonType 
	FROM Person.Person 
	GROUP BY PersonType 				

	SELECT * 					--Returns all 290 EEs
	FROM Person.Person 
	WHERE PersonType IN ('EM', 'SP') 
	
	/* 
	Taken from 'datado.com/AdventureWorks.pdf'
	SP = Sales person, 
	EM = Employee (non-sales)
	*/


-- Generates a report that provides full name of highest paid EEs, Job Title, AnnualSalary and WorkShift. Showcases INNER JOIN.

	SELECT MIN(StartDate) 
	FROM HumanResources.EmployeeDepartmentHistory 

	SELECT HRE.BusinessEntityID, 
		CONCAT_WS(' ', Title, FirstName, LastName) Employee, 
		HRE.JobTitle, 
		HRE.LoginID,
		((convert(money, HRP.Rate, 1)) * 2080) AnnualSalary,
		HRS.Name as WorkShift
	from HumanResources.Employee HRE
		INNER JOIN Person.Person P
			ON P.BusinessEntityID = HRE.BusinessEntityID
		INNER JOIN HumanResources.EmployeePayHistory HRP
			ON HRP.BusinessEntityID = P.BusinessEntityID
		INNER JOIN HumanResources.EmployeeDepartmentHistory HREDH
			ON HRP.BusinessEntityID = HREDH.BusinessEntityID
		INNER JOIN HumanResources.Shift HRS
			ON HREDH.ShiftID = HRS.ShiftID
	WHERE ((CONVERT(MONEY, HRP.Rate, 1)) * 2080) > '70000'
		AND StartDate > '2006-06-30'
	ORDER BY BusinessEntityID
	
	
-- Creates a table for BestSellingProducts. Showcases Analytic Functions.
	
	SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail 				-- Confirms 266/504 total products were sold
	SELECT SUM(OrderQty) FROM Sales.SalesOrderDetail WHERE ProductID = '707' 	--Error check to verify quanity sold per product
	
	SELECT DISTINCT SSOD.ProductID,
		ProdP.Name ProductName,
		ProdP.ListPrice,
		SUM(OrderQty) UnitsSold,
		(ProdP.ListPrice * SUM(OrderQty)) SalesRevenue,
		PERCENT_RANK() OVER(ORDER BY (ProdP.ListPrice * SUM(OrderQty))) PercentRankOfSalesRevenue 	--Ranks the most profitable Product 
	FROM Sales.SalesOrderDetail SSOD
		INNER JOIN Production.Product ProdP
			ON SSOD.ProductID = ProdP.ProductID
	GROUP BY SSOD.ProductID,
		ProdP.Name,
		ProdP.ListPrice
	ORDER BY SalesRevenue DESC


-- Shows which products are selling higher than average amounts. Showcases SUBQUERIES.

	SELECT *
	FROM
		(SELECT DISTINCT SSOD.ProductID,			
			ProdP.Name ProductName,
			ProdP.ListPrice,
			SUM(OrderQty) UnitsSold,
			(ProdP.ListPrice * SUM(OrderQty)) SalesRevenue,
			PERCENT_RANK() OVER(ORDER BY (ProdP.ListPrice * SUM(OrderQty))) PercentRankOfSalesRevenue 
		FROM Sales.SalesOrderDetail SSOD
			INNER JOIN Production.Product ProdP
				ON SSOD.ProductID = ProdP.ProductID
		GROUP BY SSOD.ProductID,
			ProdP.Name,
			ProdP.ListPrice) BestSellingProducts
	WHERE UnitsSold >= (SELECT AVG(UnitsSold) AvgUnitsSold				--This subquery calculates which products are selling at higher than avg amounts as AvgQuanityAmnt 
				FROM (SELECT DISTINCT SSOD.ProductID,
						SUM(OrderQty) UnitsSold
					FROM Sales.SalesOrderDetail SSOD
					GROUP BY SSOD.ProductID) as AvgQuanityAmnt)
  		 AND
		SalesRevenue >= (SELECT AVG(salesrevenue) 
				FROM	(SELECT DISTINCT SSOD.ProductID,		--This subquery calculates which products generated the most sales revenue on avg as AvgHighestProfitProducts
							ProdP.Name ProductName,
							ProdP.ListPrice,
							SUM(OrderQty) UnitsSold,
							(ProdP.ListPrice * SUM(OrderQty)) SalesRevenue
					FROM Sales.SalesOrderDetail SSOD
						INNER JOIN Production.Product ProdP
							ON SSOD.ProductID = ProdP.ProductID
					GROUP BY SSOD.ProductID,
							ProdP.Name,
							ProdP.ListPrice) AvgHighestProfitProducts)
	ORDER BY PercentRankOfSalesRevenue DESC

