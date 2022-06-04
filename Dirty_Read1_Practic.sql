
BEGIN TRANSACTION T1
UPDATE Kind
Set Name = 'Dariana'
WHERE Name = 'Daria'
waitfor delay '00:00:10'
ROLLBACK TRANSACTION T1


/*
UPDATE Kind
Set Name = 'Daria'
WHERE Name = 'Dariana'

SELECT * 
FROM Kind
*/