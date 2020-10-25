/*When an error occurs, I use StackOverflow and MicDocs to self-evaluate,
if that doesn't work, I ask my senior for a solution to avoid wasting time. 
I understand this DB can be optimized, but is in 3NF and intended as an example to showcase conceptual understanding.*/


USE master
CREATE DATABASE Marvel;

--To delete the entire RDBS 
USE master
DROP DATABASE IF EXISTS Marvel;

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

TRUNCATE TABLE Superhero; --To clear tables faster than a 'DELETE * FROM' statement

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

/* To check if relationships are connected

select S.HeroName, E.PublishedPeriod
	from Superhero S
	inner join Era E on S.EraID = E.EraID
*/

ALTER TABLE Superhero  
	ADD CONSTRAINT FK_Superhero_EraID 
	FOREIGN KEY (EraID) REFERENCES Era(EraID);

ALTER TABLE Superhero 
	ADD CONSTRAINT FK_Superhero_UniverseID
	FOREIGN KEY (UniverseID) REFERENCES Universe(UniverseID);

ALTER TABLE Superhero  
	ADD CONSTRAINT FK_SSN
	FOREIGN KEY(RealIdentity) REFERENCES RealIdentity(SSN);

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

CREATE SCHEMA OwnedBy AUTHORIZATION StanLee
	GRANT SELECT ON SCHEMA::OwnedBy TO JackKirby;
