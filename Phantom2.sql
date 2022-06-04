--Transaktion 2 fur Phatom, die mit Insert


BEGIN TRANSACTION T2
INSERT INTO Modele(Vor_Name,Nach_Name)
Values('Dariana','Hadid')
COMMIT TRANSACTION T2

/*
DELETE FROM Modele
WHERE Vor_Name = 'Dariana' AND Nach_Name = 'Hadid'
*/