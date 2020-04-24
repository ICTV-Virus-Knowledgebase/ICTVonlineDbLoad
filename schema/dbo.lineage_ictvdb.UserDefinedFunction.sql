USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[lineage_ictvdb] (
	@taxnode_id int,
	@seperator varchar(50) = ';'

)
RETURNS VARCHAR(8000)
AS
	-- Create a single string with lineage of a given taxnode_id
	-- Two formats are supported:
	--   a. separated list of taxonomy names (ie: Poxviridae/Orthopoxvirus/Vaccinia Virus)
	--   b. separated name-value pairs (ie: Family=Poxviridae/Genus=Orthopoxvirus/Species=Vaccinia Virus)
	-- Any number or ordering of levels can be handled. Only a single, rather simple query is run.

/*
	-- testing code (use to run the code outside of the function call
	declare @taxnode_id as int
	set @taxnode_id = 10090071
	declare @seperator as varchar(50)
	set @seperator = ','
*/
BEGIN
	declare @lineage varchar(2000)
	declare @cur_sep varchar(50)
	declare @list_format as varchar(50)
	set @list_format = ''--'named'
	set @lineage = NULL
	set @cur_sep = ''

	DECLARE @node_name AS varchar(100)
	DECLARE @level_name AS varchar(100)
	DECLARE @xref AS varchar(100)
	DECLARE @is_hidden AS int
	
	
	--
	-- The QUERY
	--
	DECLARE my_cursor  CURSOR FOR
	select 
		lineage.name, 
		level.name,
		lineage.is_hidden,
		lineage.xref
	from taxonomy_node AS src
	join taxonomy_node AS lineage on (
		src.left_idx between lineage.left_idx and lineage.right_idx
		and
		lineage.parent_id <> lineage.taxnode_id
		and
		lineage.tree_id = src.tree_id
	)
	join taxonomy_level AS [level] on ( level.id = lineage.level_id)
	where src.taxnode_id =@taxnode_id
	order by (lineage.right_idx - lineage.left_idx) desc

	OPEN my_cursor
	
	--
	-- PROCESS the RESULTS
	--
	
	-- Perform the first fetch.
	FETCH NEXT FROM my_cursor INTO @node_name, @level_name, @is_hidden, @xref
	
	-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   -- DO WORK HERE
	  --IF  @is_hidden = 0 BEGIN 
		SET @lineage = CASE
			WHEN @list_format = 'named' THEN
				ISNULL(@lineage,'') + @cur_sep + @level_name + '='
			ELSE
				ISNULL(@lineage,'') + @cur_sep
			END
			SET @lineage = @lineage 
				+ ISNULL((CASE WHEN @node_name='- unnamed -' and @xref is not null THEN '['+@xref+']' ELSE @node_name END),'NULL')
		 --PRINT 'LINEAGE: ' + @lineage
		 SET @cur_sep = @seperator
	   --END
	   -- This is executed as long as the previous fetch succeeds.
	   FETCH NEXT FROM my_cursor
	   INTO @node_name, @level_name, @is_hidden, @xref
	END
	
	CLOSE my_cursor
	DEALLOCATE my_cursor

	--print 'result: '+ISNULL(@lineage,'NULL')
	RETURN(@lineage)
ENd

--select top 1 * from taxonomy_node where level_id = 500
GO
