USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[taxonomy_node_compute_indexes_20180616] 
	@taxnode_id int,
	@left_idx  int = 1,
	@right_idx int = NULL OUTPUT,
	@node_depth     int = 1,
	@order_id int = NULL,
	@subfamily_id int = NULL,
	@family_id int = NULL,
	@genus_id int = NULL,
	@species_id int = NULL,
	@inher_molecule_id int = NULL,
	@lineage varchar(1000) = NULL
AS	
	DECLARE @hidden_as_unassigned int; 
	DECLARE @use_my_lineage int; 
	DECLARE @my_lineage varchar(1000);

	-- 
	-- display hidden nodes (mostly subfamilies)
	-- as "Unassigned"
	-- 
	SET @hidden_as_unassigned = 1

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

	-- update data for this node
	SELECT 
		-- update computed cached levels, if not already set
		 @order_id     = ISNULL(@order_id,     case when level.name='order'     then self.taxnode_id else NULL end)
		,@family_id    = ISNULL(@family_id,    case when level.name='family'    then self.taxnode_id else NULL end)
		,@subfamily_id = ISNULL(@subfamily_id, case when level.name='subfamily' then self.taxnode_id else NULL end)
		,@genus_id     = ISNULL(@genus_id,     case when level.name='genus'     then self.taxnode_id else NULL end)
		,@species_id   = ISNULL(@species_id,   case when level.name='species'   then self.taxnode_id else NULL end)
		-- update molcule type, even if already set
		,@inher_molecule_id   = ISNULL(self.molecule_id,ISNULL(@inher_molecule_id,self.inher_molecule_id))
		-- update running lineage
		,@use_my_lineage = case 
				when self.taxnode_id = self.tree_id then 0 -- don't include tree name in lineage!
				when @hidden_as_unassigned=1 then 1
				when self.is_hidden=1 or self.name is null then 0 
				else 1 end
		,@my_lineage = 
			ISNULL(@lineage,'')
			+(case when len(@lineage)>0 then ';' else '' end)
			+(case when self.is_hidden=1 and @hidden_as_unassigned=0 then '[' else '' end)
			+ISNULL(self.name,(case when @hidden_as_unassigned=1 then 'Unassigned' else '- unnamed -' end) )
			+(case when self.is_hidden=1 and @hidden_as_unassigned=0 then ']' else '' end)
	FROM taxonomy_node self 
	LEFT OUTER JOIN taxonomy_level level on level.id = self.level_id
	WHERE	self.taxnode_id = @taxnode_id
	
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
		, inher_molecule_id=@inher_molecule_id
		, lineage = @my_lineage
	WHERE taxnode_id = @taxnode_id
	and (
		-- don't update unchanged nodes
		(left_idx <> @left_idx or (left_idx is null and @left_idx is not null))
	or (node_depth <> @node_depth or (node_depth is null and @node_depth is not null))
	or (order_id <> @order_id or (order_id is null and @order_id is not null))
	or (family_id <> @family_id or (family_id is null and @family_id is not null))
	or (subfamily_id <> @subfamily_id or (subfamily_id is null and @subfamily_id is not null))
	or (genus_id <> @genus_id or (genus_id is null and @genus_id is not null))
	or (species_id <> @species_id or (species_id is null and @species_id is not null))
	or (inher_molecule_id <> @inher_molecule_id or (inher_molecule_id is null and @inher_molecule_id is not null))
	or (lineage <> @lineage or (lineage is null and @lineage is not null))
	)

	-- if we're NOT a hidden node, then include me in my children's lineage
	IF @use_my_lineage = 1 SET @lineage = @my_lineage

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
		ORDER BY  -- name
			case when start_num_sort is null then isnull(name,'ZZZZ') else left(name,start_num_sort) end -- alpha, force unassigned to bottom
			, case when start_num_sort is null then null else floor(ltrim(substring(name,start_num_sort+1,50))) end -- numeric


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
			@species_id = @species_id,
			@inher_molecule_id = @inher_molecule_id,
			@lineage = @lineage

		-- compute left_idx for next sibling
		SET @right_idx = @right_idx + 1

		-- get next child (repeated before loop)
		SET @child_taxnode_id = NULL		
		SELECT TOP 1 @child_taxnode_id = taxnode_id
			FROM taxonomy_node
			WHERE parent_id = @taxnode_id
			AND taxnode_id <> @taxnode_id
			AND left_idx IS NULL
			ORDER BY -- name 
				case when start_num_sort is null then isnull(name,'ZZZZ') else left(name,start_num_sort) end -- alpha
				, case when start_num_sort is null then null else floor(ltrim(substring(name,start_num_sort+1,50))) end -- numeric

	END	

	-- set our RIGHT index
	UPDATE taxonomy_node
	SET right_idx = @right_idx
	WHERE taxnode_id = @taxnode_id

	-- debug
	--print str(@node_depth) + '<==' + str(@taxnode_id)

/*
exec [taxonomy_node_compute_indexes] 10090000
exec [taxonomy_node_compute_indexes] 20070000
exec [taxonomy_node_compute_indexes] 20080000
exec [taxonomy_node_compute_indexes] 20090000
exec [taxonomy_node_compute_indexes] 20110000

select top 30 taxnode_id, left_idx, right_idx, 
	replicate('  ', node_depth)+isnull(name,'NULL')
	, is_hidden, lineage
	, dbo.lineage(taxnode_id, DEFAULT)
	, order_id, family_id, subfamily_id, genus_id, species_id
from taxonomy_node 
where tree_id=10090000 and left_idx is not null
order by left_idx
*/


GO
