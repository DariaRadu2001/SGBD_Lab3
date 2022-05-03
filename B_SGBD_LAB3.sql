-- PROCEDURA DE INSERT INTR-O RELATIE M:M
-- @Cantitate int, @Name Varchar(20), @Costuri int --> MATERIALE
-- @Name_Produs Varchar(20), @Culoare Varchar(10), @Marime Varchar(4), @Cantitate_Produs int, @Pret int --> PRODUSE
-- @Cantitate_Fabricatie int --> FABRICATIE
CREATE OR ALTER PROCEDURE EINFUGEN2(@Cantitate int, @Name Varchar(20), @Costuri int,
								   @Name_Produs Varchar(20), @Culoare Varchar(10), @Marime Varchar(4), @Cantitate_Produs int, @Pret int,
								   @Cantitate_Fabricatie int)
AS
BEGIN

	DECLARE @validMaterial AS INT
	DECLARE @validProdus AS INT
	DECLARE @validFabricatie AS INT
	DECLARE @tabel1 AS VARCHAR(20)
	DECLARE @tabel2 AS VARCHAR(20)
	DECLARE @tabel3 AS VARCHAR(20)

	SET @tabel1 = 'Materiale'
	SET @tabel2 = 'Produse'
	SET @tabel3 = 'Fabricatie'

	SET @validMaterial = dbo.ValidationMateriale(@Cantitate, @Name, @Costuri)
	SET @validProdus = dbo.ValidationProduse(@Name_Produs, @Culoare, @Marime, @Cantitate_Produs, @Pret)
	SET @validFabricatie = dbo.ValidationFabricatie(@Cantitate_Fabricatie)

	BEGIN TRANSACTION T2
	BEGIN TRY
	----------Insert Material
		IF @validMaterial = 1
			BEGIN
				INSERT INTO Materiale(Cantitate, Nume, Costuri) VALUES(@Cantitate, @Name, @Costuri)
				SAVE TRANSACTION T2
			END
		ELSE 
			BEGIN
				SET @tabel1 = NULL
			END
	----------Insert Produs
		IF @validProdus = 1
			BEGIN
				INSERT INTO Produse(Nume, Culoare, Marime, Cantitate, Pret) VALUES(@Name_Produs, @Culoare, @Marime, @Cantitate_Produs, @Pret)
				SAVE TRANSACTION T2
			END
		ELSE 
			BEGIN
				SET @tabel2 = NULL
			END
	----------Insert Fabricatie
		IF @validFabricatie = 1 AND @validMaterial = 1 AND @validProdus = 1
			BEGIN
				DECLARE @MaterialID AS INT;
				DECLARE @ProdusID AS INT;

				-- mai bn cu scope identity pt ca am avut id manual initial
				-- SELECT IDENT_CURRENT('Materiale') ---> da ultimul id inserat in tabelul dat
				SET @MaterialID = (SELECT TOP 1 M_ID FROM Materiale ORDER BY M_ID DESC) 
				SET @ProdusID = (SELECT TOP 1 P_ID FROM Produse ORDER BY P_ID DESC)

				INSERT INTO Fabricatie(M_ID, P_ID, Cantitate) VALUES(@MaterialID, @ProdusID, @Cantitate_Fabricatie)
				INSERT INTO LogDatei (Datum, Zeit, Name_operation, statuss, tabel1, tabel2, tabel3) Values(GETDATE(),CONVERT(TIME,GETDATE()),'insert','commited', @tabel1, @tabel2, @tabel3)
			END
		ELSE 
			BEGIN
				SET @tabel3 = NULL
				RAISERROR('INSERT ERROR',16,1)
			END

		
	END TRY
	BEGIN CATCH
		print 'Nicht alle Daten waren eingefugt!!!'
		INSERT INTO LogDatei (Datum, Zeit, Name_operation, statuss, tabel1, tabel2, tabel3) Values(GETDATE(),CONVERT(TIME,GETDATE()),'insert','abort', @tabel1, @tabel2, @tabel3)
	END CATCH
COMMIT TRANSACTION T2
END
---------------------------------------
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

DROP TABLE LogDatei

SELECT * FROM LogDatei
SELECT * FROM Materiale
SELECT * FROM Produse
SELECT * FROM Fabricatie

DELETE FROM Fabricatie WHERE Cantitate in (6000, 7000, 8000)
DELETE FROM Materiale WHERE nume in ('bumbac1', 'bumbac2', 'bumbac3', 'bumbac4')
DELETE FROM Produse WHERE Nume in ('hanorac1', 'hanorac2', 'hanorac3', 'hanorac4')

---------------------------------------
------BSP rau executat
EXEC EINFUGEN2 '50', 'bumbac1', '750',
			  'hanorac1', 'lila', 'm', '3500', '5000',
			  '6000' --error beim ValdationMaterial

EXEC EINFUGEN2 '750', 'bumbac2', '750',
			  'hanorac2', 'bej', 'm', '3500', '5000',
			  '7000' --error beim ValdationProduse

EXEC EINFUGEN2 '750', 'bumbac3', '750',
			  'hanorac3', 'lila', 'm', '3500', '5000',
			  '500' --error beim ValdationFabricatie

-----BSP bun executat
EXEC EINFUGEN2 '750', 'bumbac4', '750',
			  'hanorac4', 'lila', 'm', '3500', '5000',
			  '8000'


