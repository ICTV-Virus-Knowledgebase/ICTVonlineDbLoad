
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[udf_getTaxNodeChildInfo]
(
	-- Parameter(s)
	@taxnode_id as int
)
RETURNS varchar(max)
AS
BEGIN
	DECLARE @child_info AS VARCHAR(128) = '';
	DECLARE @child_info_result AS VARCHAR(512);

	-- Note: there should be no more than 2 rows and a result of 2 rows is a special case (subfamily and genus).
	DECLARE child_cursor CURSOR FOR
	
		select dbo.udf_singularOrPluralTaxLevelNames(level_count, level_id)
		from (
			select distinct taxlevel_id as level_id, count(taxlevel_id) AS level_count 
			from ( 
				/* Get children of hidden nodes */ 
				select tn3.level_id as taxlevel_id 
				from taxonomy_node tn2 
				join taxonomy_node tn3 on tn3.parent_id = tn2.taxnode_id
				where tn2.parent_id = @taxnode_id
				and tn2.is_hidden = 1 
				and tn2.is_deleted=0 
				and tn3.is_deleted=0 
				and tn3.name <> 'unassigned' 

				union all  

				/* Get visible children */
				select tn1.level_id as taxlevel_id 
				from taxonomy_node tn1 
				where tn1.parent_id = @taxnode_id 
				and tn1.parent_id <> tn1.taxnode_id 
				and tn1.is_hidden = 0 
			) levelCount 
			group by taxlevel_id
		) level_and_count
		order by level_id ASC

	OPEN child_cursor
	
	-- Perform the first fetch.
	FETCH NEXT FROM child_cursor INTO @child_info
	
	IF @child_info IS NOT NULL AND @child_info <> ''
	BEGIN
		SET @child_info_result = @child_info;

		-- Clear child info for use by the next row.
		SET @child_info = NULL;

		-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
		IF @@FETCH_STATUS = 0
		BEGIN
		   FETCH NEXT FROM child_cursor INTO @child_info

		   IF @child_info IS NOT NULL AND @child_info <> ''
		   SET @child_info_result = @child_info_result +', '+@child_info
		END
	END

	CLOSE child_cursor
	DEALLOCATE child_cursor

	RETURN(@child_info_result)
END

GO

