USE [ICTVonlnie34]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_getMSL]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[udf_getMSL] (@tree_id as int = NULL)
RETURNS int 
as BEGIN
	--
	-- get the MSL_release_num of the latest MSL, or any other MSL
	-- for use by website code to constrain queries to current MSL
	--
	-- declare @tree_id int;-- set @tree_id = 20170000 -- debug
	
	-- if null, get the latest
	if @tree_id is null BEGIN
		RETURN (select max(msl_release_num) from taxonomy_toc)
	END

	-- otherwise, look it up
	DECLARE @msl int
	select @msl=msl_release_num 
	from taxonomy_toc 
	where @tree_id is null or tree_id = @tree_id
	order by msl_release_num

	--PRINT @msl -- debug
	RETURN @msl

	/*
	--
	-- test
	-- 
	print dbo.udf_getMSL(DEFAULT)
	print dbo.udf_getMSL(20170000) -- =32
	print isnull(dbo.udf_getMSL(10000),'-999') 
	*/

end 
GO
