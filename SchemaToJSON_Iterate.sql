
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

    SELECT @schema =

           COALESCE(@schema,'') + '"' + COLUMN_NAME + '": {"type":"' +
           CASE WHEN DATA_TYPE LIKE '%int%' THEN 'number' WHEN DATA_TYPE LIKE 'bit' THEN 'Boolean' WHEN DATA_TYPE = 'datetime' THEN 'date' ELSE 'string' END + '", "required":"' +
           CASE WHEN IS_NULLABLE = 'YES' THEN 'True' ELSE 'False' END
           + '"},'

    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @tableName

    SET @schema = LEFT(@schema,LEN(@schema)-1)

    SET @command = '{' +
      '"name":"' + REPLACE(@tableName,'tbl','') + '",' +
      '"plural":"' + CASE WHEN RIGHT(REPLACE(@tableName,'tbl',''),1) = 's' THEN REPLACE(@tableName,'tbl','') + 'es' ELSE  REPLACE(@tableName,'tbl','') + 's' END + '",' +
      '"base":"PersistedModel",
      "idInjection":true,
      "options":{
        "validateUpsert":true
        },
        "properties" : { ' +
               + @schema
               + '},"validations": [],
      "relations": {},
      "acls": [],
      "methods": {}
    }'

    PRINT @command
	SET @schema = ''
    
	FETCH NEXT FROM IdentityUpdate_Cursor INTO @tableName
  END
CLOSE IdentityUpdate_Cursor
DEALLOCATE IdentityUpdate_Cursor
