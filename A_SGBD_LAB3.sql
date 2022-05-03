--sa nu uit sa adaug coleana de categorie la produse dupa labul asta pt ca am nevoie de ea la lab 2

Create Table LogDatei
(
	Id_Transaktion int identity(1,1),
	Datum DATE,
	Zeit TIME,
	Name_operation VARCHAR(20),
	statuss VARCHAR(20),
	tabel1 VARCHAR(20),
	tabel2 VARCHAR(20),
	tabel3 VARCHAR(20),
	Primary Key(Id_Transaktion)
)

-- trebuie sa am: cantitatea >= 600
--                Name not NULL
--                Costuri < 1000
CREATE OR ALTER FUNCTION ValidationMateriale(@Cantitate int, @Name Varchar(20), @Costuri int)
RETURNS INT
AS 
BEGIN
	DECLARE @BOOL INT

	IF (@Cantitate < 600 OR @Cantitate IS NULL) OR (@Name is NULL) OR (@Costuri >= 1000 OR @Costuri IS NULL)
		SET @BOOL = 0
	ELSE
		SET @BOOL = 1

	RETURN @BOOL
END

PRINT dbo.ValidationMateriale('650', 'Catifea', '999') -- 1
PRINT dbo.ValidationMateriale('601', 'Catifea', '777') -- 1
PRINT dbo.ValidationMateriale('555', 'Catifea', '999') -- 0 de la catitate
PRINT dbo.ValidationMateriale('650', NULL , '999') -- 0 de la Name
PRINT dbo.ValidationMateriale('650', NULL , '1000') -- 0 de la costuri
PRINT dbo.ValidationMateriale('3', NULL, '1111') -- 0 de la tot
PRINT dbo.ValidationMateriale(NULL, NULL, NULL) -- 0 de la tot


-- trebuie sa am: Name not NULL
--                culoare not NULL AND IN (roz, albastru, negru, alb, rosu, lila)//not key sensitiv
--                Marime not NULL AND IN (xxs,xs,s,m,l,xl,xxl)//not key sensitiv
--                cantitate >= 2000
--                pret >= 1000
CREATE OR ALTER FUNCTION ValidationProduse(@Name Varchar(20), @Culoare Varchar(10), @Marime Varchar(4), @Cantitate int, @Pret int)
RETURNS INT
AS 
BEGIN
	DECLARE @BOOL INT

	IF (@Name is NULL) OR (@Culoare IS NULL OR @Culoare not in ('roz', 'albastru', 'negru', 'alb', 'rosu', 'lila'))
		OR (@Marime is NULL or @Marime not in ('xxs', 'xs', 's', 'm', 'l', 'xl', 'xxl')) OR (@Cantitate < 2000 OR @Cantitate IS NULL)
		OR (@Pret is NULL or @Pret <1000)
		SET @BOOL = 0
	ELSE
		SET @BOOL = 1

	RETURN @BOOL
END

PRINT dbo.ValidationProduse('bluza', 'roz', 'm', '2001', '1000') -- 1
PRINT dbo.ValidationProduse('jeans', 'aLb', 'L', '2000', '7777') -- 1
PRINT dbo.ValidationProduse('rochie', 'lila', 'XXXL', '3000', '9999') -- 0 de la marime
PRINT dbo.ValidationProduse(NULL,'negru','s', '2002', '1999') -- 0 de la Name
PRINT dbo.ValidationProduse('jeans','negRUtu','s', '2002', '1999') -- 0 de la @Culoare
PRINT dbo.ValidationProduse('jeans','negru','s', '1999', '1999') -- 0 de la @Cantitate
PRINT dbo.ValidationProduse('jeans','negru','s', '2002', '1') -- 0 de la @Cantitate
PRINT dbo.ValidationProduse(NULL, NULL, NULL, NULL, NULL) -- 0 de la tot


-- trebuie sa am: cantitate >= 2000
CREATE OR ALTER FUNCTION ValidationFabricatie(@Cantitate int)
RETURNS INT
AS 
BEGIN
	DECLARE @BOOL INT

	IF(@Cantitate < 2000 OR @Cantitate IS NULL)
		SET @BOOL = 0
	ELSE
		SET @BOOL = 1

	RETURN @BOOL
END

PRINT dbo.ValidationFabricatie('2010') -- 1
PRINT dbo.ValidationFabricatie('2000') -- 1
PRINT dbo.ValidationFabricatie('201') -- 0
PRINT dbo.ValidationFabricatie(NULL) -- 0

-- PROCEDURA DE INSERT INTR-O RELATIE M:M
-- @Cantitate int, @Name Varchar(20), @Costuri int --> MATERIALE
-- @Name_Produs Varchar(20), @Culoare Varchar(10), @Marime Varchar(4), @Cantitate_Produs int, @Pret int --> PRODUSE
-- @Cantitate_Fabricatie int --> FABRICATIE
CREATE OR ALTER PROCEDURE EINFUGEN(@Cantitate int, @Name Varchar(20), @Costuri int,
								   @Name_Produs Varchar(20), @Culoare Varchar(10), @Marime Varchar(4), @Cantitate_Produs int, @Pret int,
								   @Cantitate_Fabricatie int)
AS
BEGIN

	DECLARE @validMaterial AS INT
	DECLARE @validProdus AS INT
	DECLARE @validFabricatie AS INT

	SET @validMaterial = dbo.ValidationMateriale(@Cantitate, @Name, @Costuri)
	SET @validProdus = dbo.ValidationProduse(@Name_Produs, @Culoare, @Marime, @Cantitate_Produs, @Pret)
	SET @validFabricatie = dbo.ValidationFabricatie(@Cantitate_Fabricatie)

	BEGIN TRANSACTION T
	BEGIN TRY
	----------Insert Material
		IF @validMaterial = 1
			BEGIN
				INSERT INTO Materiale(Cantitate, Nume, Costuri) VALUES(@Cantitate, @Name, @Costuri)
			END
		ELSE BEGIN RAISERROR('INSERT ERROR',16,1); END
	----------Insert Produs
		IF @validProdus = 1
			BEGIN
				INSERT INTO Produse(Nume, Culoare, Marime, Cantitate, Pret) VALUES(@Name_Produs, @Culoare, @Marime, @Cantitate_Produs, @Pret)
			END
		ELSE BEGIN RAISERROR('INSERT ERROR',16,1); END
	----------Insert Fabricatie
		IF @validFabricatie = 1
			BEGIN
				DECLARE @MaterialID AS INT;
				DECLARE @ProdusID AS INT;

				SET @MaterialID = (SELECT TOP 1 M_ID FROM Materiale ORDER BY M_ID DESC)
				SET @ProdusID = (SELECT TOP 1 P_ID FROM Produse ORDER BY P_ID DESC)

				INSERT INTO Fabricatie(M_ID, P_ID, Cantitate) VALUES(@MaterialID, @ProdusID, @Cantitate_Fabricatie)
			END
		ELSE BEGIN RAISERROR('INSERT ERROR',16,1); END

		INSERT INTO LogDatei (Datum, Zeit, Name_operation, statuss, tabel1, tabel2, tabel3) Values(GETDATE(),CONVERT(TIME,GETDATE()),'insert','commited','Materiale','Produse','Fabricatie')
		COMMIT TRANSACTION T
	END TRY
	BEGIN CATCH
		print 'Die Daten waren nicht eingefugt!!!'
		ROLLBACK TRANSACTION T
		INSERT INTO LogDatei (Datum, Zeit, Name_operation, statuss, tabel1, tabel2, tabel3) Values(GETDATE(),CONVERT(TIME,GETDATE()),'insert','abort', NULL, NULL, NULL)
	END CATCH
END


SELECT * FROM LogDatei
SELECT * FROM Materiale
SELECT * FROM Produse
SELECT * FROM Fabricatie

-------BSP bun executat deja
EXEC EINFUGEN '650', 'catifea', '200',
			  'rochie', 'roz', 's', '2100', '1200',
			  '3000'

EXEC EINFUGEN '750', 'bumbac', '750',
			  'hanorac', 'lila', 'm', '3500', '5000',
			  '5000'

-------BSP rau executat
EXEC EINFUGEN '50', 'bumbac', '750',
			  'hanorac_frumos', 'lila', 'm', '3500', '5000',
			  '5000' --error beim ValdationMaterial

EXEC EINFUGEN '750', 'bumbacel', '750',
			  'hanorac', 'bej', 'm', '3500', '5000',
			  '5000' --error beim ValdationProduse

EXEC EINFUGEN '750', 'bumbacel', '750',
			  'hanorac_frumos', 'lila', 'm', '3500', '5000',
			  '500' --error beim ValdationFabricatie

EXEC EINFUGEN '50', 'bumbac', '750',
			  'hanorac', 'lila', 'mic', '300', '500',
			  '500' --error alle

DELETE FROM LogDatei WHERE Id_Transaktion in (2,3,4,5,6)
DELETE FROM Fabricatie WHERE P_ID in (115, 116)
DELETE FROM Produse WHERE P_ID in (112,113,114,115,116)
DELETE FROM Materiale WHERE M_ID in (10, 11, 12, 13, 14)

Drop Table LogDatei