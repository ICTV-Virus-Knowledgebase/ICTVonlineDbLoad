USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[refresh_views]
AS

DECLARE @view_name AS varchar(100)
DECLARE @sql as NVARCHAR(200)

DECLARE check_sp_cursor SCROLL CURSOR FOR
SELECT [table_name] 
FROM INFORMATION_SCHEMA.TABLES
WHERE 
	[TABLE_TYPE] = 'VIEW'
AND 
	[TABLE_NAME] NOT LIKE '[_]%'
ORDER BY [table_name]

OPEN check_sp_cursor

-- Perform the first fetch.
FETCH NEXT FROM check_sp_cursor INTO @view_name

-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
WHILE @@FETCH_STATUS = 0
BEGIN
	--
	-- DO GRANT TO [PUBLIC]
	--
  SET @sql = 'EXEC sp_refreshview ['+@view_name+']'
  PRINT 'SQL: ' + @sql
  EXEC sp_executesql @statement=@sql

   -- This is executed as long as the previous fetch succeeds.
   FETCH NEXT FROM check_sp_cursor
   INTO @view_name
END

CLOSE check_sp_cursor
DEALLOCATE check_sp_cursor
GO
