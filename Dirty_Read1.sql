-- Transaktion 1 fur Dirty Read, die mit Update

BEGIN TRANSACTION T1
UPDATE Modele
Set Vor_Name = 'Isabella'
WHERE Vor_Name = 'Bella' AND Nach_Name = 'Hadid'
waitfor delay '00:00:10'
ROLLBACK TRANSACTION T1

/*
SELECT *
FROM Modele
WHERE Nach_Name = 'Hadid'
*/