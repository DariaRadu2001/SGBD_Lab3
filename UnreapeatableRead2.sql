--Transaktion 2 fur Unrepeatable Read, die mit Update

BEGIN TRANSACTION T2
UPDATE Modele
Set Vor_Name = 'Isabella'
WHERE Vor_Name = 'Bella' AND Nach_Name = 'Hadid'
COMMIT TRANSACTION T2

/*
UPDATE Modele
Set Vor_Name = 'Bella'
WHERE Vor_Name = 'Isabella' AND Nach_Name = 'Hadid'
*/