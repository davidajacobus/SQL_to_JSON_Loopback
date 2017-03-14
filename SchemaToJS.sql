/*
Loop over all tables
*/
DECLARE @tableName NVARCHAR(max)
DECLARE @command NVARCHAR(max)
DECLARE @schema varchar(8000);
DECLARE IdentityUpdate_Cursor CURSOR FOR

  --Get all tables and columns that utilize the LoginID as an Identity (legacy crap)
  SELECT DISTINCT t.name AS table_name
  FROM sys.tables AS t
  ORDER BY table_name

OPEN IdentityUpdate_Cursor
FETCH NEXT FROM IdentityUpdate_Cursor INTO @tableName

WHILE @@FETCH_STATUS = 0
  BEGIN

    SET @schema = ''
    SELECT @schema =  '''use strict''' +
            'module.exports = function(' + REPLACE(@tableName,'tbl','') + ') { };'

    PRINT @schema

    FETCH NEXT FROM IdentityUpdate_Cursor INTO @tableName
  END
CLOSE IdentityUpdate_Cursor
DEALLOCATE IdentityUpdate_Cursor
