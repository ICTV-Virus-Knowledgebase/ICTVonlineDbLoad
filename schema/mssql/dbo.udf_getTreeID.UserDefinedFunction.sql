USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[udf_getTreeID] (@msl as int = NULL)
RETURNS int 
as BEGIN
	--
	-- get the TREE_ID of the latest MSL, or any other MSL
	-- for use by website code to constrain queries to current MSL
	--
	-- declare @msl int;-- set @msl = 32 -- debug

	-- if null, get the latest
	if @msl is null RETURN (select max(tree_id) from taxonomy_toc)

	-- else look up what they asked for
	DECLARE @tree_id int
	select @tree_id=tree_id 
	from taxonomy_toc 
	where msl_release_num is not null 
	and (@msl is null or msl_release_num = @msl)
	order by msl_release_num

	--PRINT @tree_id -- debug
	RETURN @tree_id

	
	/*
	--
	-- test
	-- 
	print dbo.udf_getTreeId(DEFAULT)
	print dbo.udf_getTreeId(32) -- =20170000
	print isnull(dbo.udf_getTreeId(-1),'-999') 
	*/
end 
GO

-- Test

-- Test Case 1: @msl is NULL
-- SELECT dbo.udf_getTreeID(NULL) AS latest_tree_id;

-- Test Case 2: @msl exists
-- SELECT dbo.udf_getTreeID(32) AS tree_id_for_msl;

-- Test Case 3: @msl does not exist
-- SELECT ISNULL(dbo.udf_getTreeID(-1), -999) AS tree_id_for_msl;

