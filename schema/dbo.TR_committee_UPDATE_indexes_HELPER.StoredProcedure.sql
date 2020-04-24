USE [ICTVonlnie34]
GO
/****** Object:  StoredProcedure [dbo].[TR_committee_UPDATE_indexes_HELPER]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE 
procedure [dbo].[TR_committee_UPDATE_indexes_HELPER] 
	@node_id int = NULL,
	@left_idx  int = 1,
	@right_idx int = NULL OUTPUT,
	@node_depth     int = 1
AS

	-- find the root, if it is not specified
	IF @node_id IS NULL 
		SELECT TOP 1 @node_id=committee_id 
		FROM committee 
		WHERE committee_id = parent_id
	
	-- debug
	--print str(@node_depth) + '==>' + str(@node_id)

	-- set our LEFT index
	UPDATE committee
	SET left_idx = @left_idx, node_depth=@node_depth
	WHERE committee_id = @node_id

	--
	-- walk our children, recusing
	--
	
	-- clear our children's indexes
	UPDATE committee 
	SET left_idx=null, right_idx=null 
	WHERE parent_id = @node_id AND committee_id <> @node_id

	DECLARE @child_committee_id int
	
	DECLARE @child_level int
	SET @child_level = @node_depth + 1

	SET @right_idx = @left_idx + 1

	-- get next child (repeated inside loop)
	SET @child_committee_id = NULL
	SELECT TOP 1 @child_committee_id = committee_id
		FROM committee
		WHERE parent_id = @node_id
		AND committee_id <> @node_id
		AND left_idx IS NULL
		ORDER BY name 

	WHILE @child_committee_id IS NOT NULL
	BEGIN
		-- recuse into child
		EXEC [TR_committee_UPDATE_indexes_HELPER] 
			@node_id = @child_committee_id, 
			@left_idx   = @right_idx, 
			@right_idx  = @right_idx OUTPUT, 
			@node_depth      = @child_level

		-- compute left_idx for next sibling
		SET @right_idx = @right_idx + 1

		-- get next child (repeated before loop)
		SET @child_committee_id = NULL		
		SELECT TOP 1 @child_committee_id = committee_id
			FROM committee
			WHERE parent_id = @node_id
			AND committee_id <> @node_id
			AND left_idx IS NULL
			ORDER BY name 

	END	

	-- set our RIGHT index
	UPDATE committee
	SET right_idx = @right_idx
	WHERE committee_id = @node_id

	-- debug
	--print str(@node_depth) + '<==' + str(@node_id)


SET ANSI_NULLS ON
GO
