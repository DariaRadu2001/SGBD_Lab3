-- Transaktion2 fur Deadlock

--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

EXEC Transaktion2

--asta da DEADLOCK
CREATE OR ALTER PROCEDURE Transaktion2
AS
BEGIN
	SET DEADLOCK_PRIORITY LOW
	BEGIN TRANSACTION T2
	UPDATE Casa_de_moda
	Set Designer_Name = 'cocolino'
	WHERE Name = 'Chanel'

	waitfor delay '00:00:10'

	UPDATE Modele
	Set Vor_Name = 'Isabella'
	WHERE Vor_Name = 'Bella' AND Nach_Name = 'Hadid'
	COMMIT TRANSACTION T2
END

-----------------------------------------------------
BEGIN TRY
	BEGIN TRANSACTION T3
	SET DEADLOCK_PRIORITY NORMAL
	UPDATE Casa_de_moda
	Set Designer_Name = 'cocolino'
	WHERE Name = 'Chanel'

	waitfor delay '00:00:10'

	--asta e deja schimbat de T1 din Bella in Isabella
	UPDATE Modele
	Set Vor_Name = 'Isabella'
	WHERE Vor_Name = 'Bella' AND Nach_Name = 'Hadid'
	COMMIT TRANSACTION T3
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION T3
	IF (ERROR_NUMBER() = 1205)	--eroare deadlock
		BEGIN
			SELECT 'Ups!' AS StatusT3
			WAITFOR DELAY '00:00:10'
		END
	BEGIN TRANSACTION T4
	SET DEADLOCK_PRIORITY NORMAL
	UPDATE Casa_de_moda
	Set Designer_Name = 'cocolino'
	WHERE Name = 'Chanel'

	waitfor delay '00:00:10'

	UPDATE Modele
	Set Vor_Name = 'Isabella'
	WHERE Vor_Name = 'Bella' AND Nach_Name = 'Hadid'
	COMMIT TRANSACTION T4
END CATCH