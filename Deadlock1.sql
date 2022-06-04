-- Transaktion 1 fur Deadlock

--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

EXEC Transaktion1

CREATE OR ALTER PROCEDURE Transaktion1
AS
BEGIN
	SET DEADLOCK_PRIORITY HIGH
	BEGIN TRANSACTION T1
	UPDATE Modele
	Set Vor_Name = 'Isabella2'
	WHERE Vor_Name = 'Bella' AND Nach_Name = 'Hadid'

	waitfor delay '00:00:10'

	UPDATE Casa_de_moda
	Set Designer_Name = 'cocolino2'
	WHERE Name = 'Chanel'
	COMMIT TRANSACTION T1
	SELECT 'Very Good, Very Nice!' AS StatusT1
END

/*
SELECT *
FROM Modele
WHERE Nach_Name = 'Hadid'

SELECT *
FROM Casa_de_moda
*/

/*
UPDATE Modele
Set Vor_Name = 'Bella'
WHERE Vor_Name = 'Isabella2' AND Nach_Name = 'Hadid'

UPDATE Casa_de_moda
Set Designer_Name = 'Coco Chanel'
WHERE Name = 'Chanel'
*/