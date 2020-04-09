/*
 * move existing [load_next_msl] out of hte way
 * keep around for history
 */

GO

SELECT name, SCHEMA_NAME(schema_id) AS schema_name, type_desc, type  
FROM sys.objects  
WHERE parent_object_id = (OBJECT_ID('load_next_msl'))   
AND type IN ('D','C','F', 'PK');   
GO  

--
-- rename default constraints - that's a global namespace (ICK!)
--
exec sp_rename 'DF_load_next_msl__msl_release_num', 'DF_load_next_msl__msl_release_num_34b';  
exec sp_rename 'DF_load_next_msl_isDone', 'DF_load_next_msl_isDone_34b';  
GO

-- 
-- rename table
EXEC sp_rename 'load_next_msl', 'load_next_msl_34b';  
--EXEC sp_rename 'load_next_msl_34b', 'load_next_msl';  

go