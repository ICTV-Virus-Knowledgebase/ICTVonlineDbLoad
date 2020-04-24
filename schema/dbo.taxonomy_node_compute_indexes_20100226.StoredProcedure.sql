USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[taxonomy_node_compute_indexes_20100226] 
	@taxnode_id int,
	@left_idx  int = 1,
	@right_idx int = NULL OUTPUT,
	@node_depth     int = 1,
	@order_id int = NULL,
	@subfamily_id int = NULL,
	@family_id int = NULL,
	@genus_id int = NULL,
	@species_id int = NULL
AS	

	-- find the root, if it is not specified 
	-- REMOVED: can't function if multiple trees in db (w/o cursor)
	/*IF @taxnode_id IS NULL 
		SELECT TOP 1 @taxnode_id=taxnode_id 
		FROM taxonomy_node self
		JOIN taxonomy_level level on level.id = self.level_id
		WHERE level.name =  'tree'
	*/
	-- debug
	--print str(@node_depth) + '==>' + str(@taxnode_id)

	-- set our cached levels, if not set
	IF @order_id IS NULL
		SELECT @order_id = self.taxnode_id
		FROM taxonomy_node self 
		JOIN taxonomy_level level on level.id = self.level_id
		WHERE	level.name =  'order'
		AND		self.taxnode_id = @taxnode_id

	IF @family_id IS NULL
		SELECT @family_id = self.taxnode_id
		FROM taxonomy_node self 
		JOIN taxonomy_level level on level.id = self.level_id
		WHERE	level.name =  'family'
		AND		self.taxnode_id = @taxnode_id

	IF @subfamily_id IS NULL
		SELECT @subfamily_id = self.taxnode_id
		FROM taxonomy_node self 
		JOIN taxonomy_level level on level.id = self.level_id
		WHERE	level.name =  'subfamily'
		AND		self.taxnode_id = @taxnode_id

	IF @genus_id IS NULL
		SELECT @genus_id = self.taxnode_id
		FROM taxonomy_node self 
		JOIN taxonomy_level level on level.id = self.level_id
		WHERE	level.name =  'genus'
		AND		self.taxnode_id = @taxnode_id

	IF @species_id IS NULL
		SELECT @species_id = self.taxnode_id
		FROM taxonomy_node self 
		JOIN taxonomy_level level on level.id = self.level_id
		WHERE	level.name =  'species'
		AND		self.taxnode_id = @taxnode_id

	-- set our LEFT index & cached parent taxa
	UPDATE taxonomy_node
	SET 
		left_idx=@left_idx
		, node_depth=@node_depth
		, order_id=@order_id
		, family_id=@family_id
		, subfamily_id=@subfamily_id
		, genus_id=@genus_id
		, species_id=@species_id
	WHERE taxnode_id = @taxnode_id


	--
	-- walk our children, recusing
	--
	
	-- clear our children's indexes
	UPDATE taxonomy_node 
	SET left_idx=null, right_idx=null 
	WHERE parent_id = @taxnode_id AND taxnode_id <> @taxnode_id

	DECLARE @child_taxnode_id int
	
	DECLARE @child_depth int
	SET @child_depth = @node_depth + 1

	SET @right_idx = @left_idx + 1

	-- get next child (repeated inside loop)
	SET @child_taxnode_id = NULL
	SELECT TOP 1 @child_taxnode_id = taxnode_id
		FROM taxonomy_node
		WHERE parent_id = @taxnode_id
		AND taxnode_id <> @taxnode_id
		AND left_idx IS NULL
		ORDER BY name 

	WHILE @child_taxnode_id IS NOT NULL
	BEGIN
		-- recuse into child
		EXEC [taxonomy_node_compute_indexes] 
			@taxnode_id = @child_taxnode_id, 
			@left_idx   = @right_idx, 
			@right_idx  = @right_idx OUTPUT, 
			@node_depth = @child_depth,
			@order_id  = @order_id,
			@family_id  = @family_id,
			@subfamily_id  = @subfamily_id,
			@genus_id	= @genus_id,
			@species_id = @species_id

		-- compute left_idx for next sibling
		SET @right_idx = @right_idx + 1

		-- get next child (repeated before loop)
		SET @child_taxnode_id = NULL		
		SELECT TOP 1 @child_taxnode_id = taxnode_id
			FROM taxonomy_node
			WHERE parent_id = @taxnode_id
			AND taxnode_id <> @taxnode_id
			AND left_idx IS NULL
			ORDER BY name 

	END	

	-- set our RIGHT index
	UPDATE taxonomy_node
	SET right_idx = @right_idx
	WHERE taxnode_id = @taxnode_id

	-- debug
	--print str(@node_depth) + '<==' + str(@taxnode_id)

GO
