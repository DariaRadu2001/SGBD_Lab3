-- Transaktion 1 fur Unrepeatable Read, die mit Read
-- Aici e fara IsolationLvl

--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRANSACTION T1
SELECT * FROM Modele
WHERE Nach_Name = 'Hadid'
waitfor delay '00:00:10'
SELECT * FROM Modele
WHERE Nach_Name = 'Hadid'
COMMIT TRANSACTION T1


SELECT * FROM Modele
WHERE Nach_Name = 'Hadid'