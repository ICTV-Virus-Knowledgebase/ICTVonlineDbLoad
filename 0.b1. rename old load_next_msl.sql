/*
 * move existing [load_next_msl] out of hte way
 * keep around for history
 */

GO
DECLARE @OLD_MSL varchar(32); SET @OLD_MSL='36'

SELECT name, SCHEMA_NAME(schema_id) AS schema_name, type_desc, type, '>>>>>>', old_msl=@OLD_MSL  
FROM sys.objects  
WHERE parent_object_id = (OBJECT_ID('load_next_msl'))   
AND type IN ('D','C','F', 'PK');   
 

--
-- rename default constraints - that's a global namespace (ICK!)
--
DECLARE @NEW_DF varchar(200); SET @NEW_DF='DF_load_next_msl__msl_release_num_'+@OLD_MSL
exec sp_rename 'DF_load_next_msl__msl_release_num', @NEW_DF;  


-- 
-- rename table
DECLARE @NEW_TAB varchar(200); SET @NEW_TAB='load_next_msl_'+@OLD_MSL
EXEC sp_rename 'load_next_msl',@NEW_TAB ;  



--
-- Verify
--
SELECT name, SCHEMA_NAME(schema_id) AS schema_name, type_desc, type  
FROM sys.objects  
WHERE parent_object_id = (OBJECT_ID('load_next_msl_'+@OLD_MSL))   
AND type IN ('D','C','F', 'PK');   
GO 