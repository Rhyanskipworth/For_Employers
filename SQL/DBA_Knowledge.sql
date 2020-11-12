/* Data migration techniques,
	1st option: Back up the source data files then restore '.bak' files onto the destination server DB.
	2nd option: Detach DB '.mdf' & '.ldf' data files then attach to target server
	3rd option: Script the entire DB via Tasks --> Generate and Publish Scripts */

-- To auto-replicate DBs to another server, use the Replication Manager (via GUI) to create a publisher and subscriber.

-- Creates a DB snapshot for temporary period-over-period analyses/reporting and restoration (dbss should NOT replace standard backup and restore strategy).

	USE AdventureWorksDW2019
	GO
	
	CREATE DATABASE AdventureWorksDW2019_dbss ON
		( NAME = AdventureWorksDW2017,							-- Found on DB properties: Files --> Logical Name
	  	  FILENAME ='C:\Program Files\Microsoft SQL Server\AdventureWorksDW2019.ss' 
		) AS SNAPSHOT OF AdventureWorksDW2019;
	
	RESTORE DATABASE [AdventureWorksDW2019]
	FROM DATABASE_SNAPSHOT = 'AdventureWorksDW2019_dbss'
	
		/* To verify dbss name */
		   SELECT * FROM sys.databases   [or]   SELECT * FROM sysdatabases

-- Creates a stored procedure to view each sales rep's overall revenue ordered by country.

	USE [Northwind]
	GO

	ALTER PROCEDURE [dbo].[CustomerOrderByCountry]

	@Country varchar(15),
	@DateFrom date,
	@DateTo date

	AS

	/*
	11/10/2020	RS	created inital procedure
	11/11/2020	RS	Added date parameters, handled nulls, and changed data type for o.OrderDate
	*/

	SELECT
		CONCAT(e.FirstName, ' ', e.LastName) Employee,
		c.ContactName Customer,
		SUM(o.Freight) OrderAmt,
		o.ShipCountry,
		CAST(o.OrderDate as date) OrderDate			-- Converted o.OrderDate from DateTime to Date
	FROM Orders o
		INNER JOIN Customers c
			ON o.CustomerID = c.CustomerID
		INNER JOIN Employees e
			ON e.EmployeeID = o.EmployeeID
	WHERE (o.ShipCountry = @Country					-- Set parameter = NULL to allow end-user input and retrieve all dates as default.
			OR @Country IS NULL)
	 	AND (o.OrderDate BETWEEN @DateFrom AND @DateTo
				OR @DateFrom IS NULL
					OR @DateTo IS NULL)
	GROUP BY 
		e.FirstName, 
		e.LastName, 
		c.ContactName, 
		o.ShipCountry,
		O.OrderDate
	ORDER BY OrderAmt DESC

-- Creates and/or deletes Marvel DB.
 /* 'Marvel' is an original RDBMS I created for educational purposes. I understand it can be optimized, but it's in 3NF and intended to showcase conceptual understanding. */

	USE master
	CREATE DATABASE Marvel;

	USE master				 
	DROP DATABASE IF EXISTS Marvel;

     -- T-SQL scripts for creating tables within "Marvel" DB.

	USE Marvel
	CREATE TABLE Superhero 
	(
  	HeroID int IDENTITY(1,1) NOT NULL,
 	HeroName varchar(150) UNIQUE NOT NULL,
 	PowerType varchar(45)  NOT NULL,
    	HeroType varchar(15)  NULL,
    	EraID int  NOT NULL,
    	UniverseID int  NOT NULL,
    	RealIdentity int  NOT NULL,
	
	CONSTRAINT PK_Superhero PRIMARY KEY CLUSTERED (HeroID)
	);

	ALTER TABLE Superhero
	ALTER COLUMN RealIdentity varchar(100);

	INSERT INTO Superhero
	VALUES ('Black Panther', 'Physical', 'Hero', 2, 1, 'T''Challa'),
		('Iron Man', 'Physical', 'Hero', 2, 1, 'Tony Stark'),
		('Captain America', 'Physical', 'Hero', 1, 1, 'Steve Rogers'),
		('Deadpool', 'Physical', 'Anti-Hero', 4, 1, 'Ryan Reynolds'),
		('Rocket Racoon', 'Physical', 'Hero', 3, 2, 'Rocket'),
		('Spider Man', 'Physical', 'Hero', 2, 1, 'Peter Parker');

	CREATE TABLE RealIdentity 
	(
    	SSN int UNIQUE NOT NULL, --SSNs are a natural key
    	FirstName varchar(45)  NOT NULL,
    	LastName varchar(45)  NULL,
    	Email varchar(45)  NOT NULL,
    	PhoneNumber char(10)  NOT NULL,

    	CONSTRAINT PK_SSN PRIMARY KEY CLUSTERED (SSN)
	);

	CREATE TABLE Universe 
	(
    	UniverseID int IDENTITY(1,1) NOT NULL,
    	Franchise Varchar(45)  NOT NULL,
    	Location Varchar(45)  NOT NULL,
    	State Char(2)  NULL,
    	Zip Char(9)  NULL,

    	CONSTRAINT PK_Universe PRIMARY KEY CLUSTERED (UniverseID)
	);

	INSERT INTO Universe (Franchise,Location)
	VALUES ('Avengers', 'Earth-616'),
		('Guardians of the Galaxy', 'Universe');

	CREATE TABLE Era 
	(
    	EraID Int IDENTITY(1,1) NOT NULL,
    	PublishedPeriod varchar(15)  NOT NULL,
	DateDescription varchar(45) NOT NULL
    
    	CONSTRAINT PK_Era PRIMARY KEY CLUSTERED (EraID)
	);

	INSERT INTO Era
	VALUES ('GoldenAge', '1938 – 1956'),
		('SilverAge', '1956 – 1970'),
		('BronzeAge', '1970 – 1985'),
		('ModernAge', '1985 – PresentDay');

     --To clear tables faster than a 'DELETE * FROM' statement
	TRUNCATE TABLE Superhero; 

     -- T-SQL scripts to create relationships (via foreign keys) between each table.

	ALTER TABLE Superhero  
		ADD CONSTRAINT FK_Superhero_EraID 
		FOREIGN KEY (EraID) REFERENCES Era(EraID);

	ALTER TABLE Superhero 
		ADD CONSTRAINT FK_Superhero_UniverseID
		FOREIGN KEY (UniverseID) REFERENCES Universe(UniverseID);

	ALTER TABLE Superhero  
		ADD CONSTRAINT FK_SSN
		FOREIGN KEY(RealIdentity) REFERENCES RealIdentity(SSN);
	
		/* Query to check if relationships are connected */
		
			SELECT S.HeroName, E.PublishedPeriod
			FROM Superhero S
			INNER JOIN Era E ON S.EraID = E.EraID



/*
Jack Kirby (comic artist) and Stan Lee (movie producer) were the creators of Marvel INC. 
Once Marvel became extremely lucrative, the two conflicted over Marvel ownership and contract royalties.
The syntax below jokingly shows this fued as administrative duties for Marvel RDBS.
*/

	USE Marvel
	CREATE USER StanLee FOR LOGIN StanLee;
	CREATE USER JackKirby FOR LOGIN JackKirby;

	CREATE LOGIN StanLee   
    	WITH PASSWORD = 'MarvelisMINE';  

	CREATE LOGIN JackKirby   
    	WITH PASSWORD = 'MarvelisOURS'; 
	
	ALTER AUTHORIZATION ON Database:: Marvel TO [StanLee];

	CREATE SCHEMA OwnedBy AUTHORIZATION StanLee
		GRANT SELECT ON SCHEMA::OwnedBy TO JackKirby;
		

