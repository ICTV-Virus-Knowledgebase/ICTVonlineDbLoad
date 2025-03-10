
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[searchTaxonomy]
	@currentMslRelease AS INT,
	@includeAllReleases AS BIT,
	@searchText AS NVARCHAR(100),
	@selectedMslRelease AS INT

AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON

	-- Validate the current MSL release
	IF ISNULL(@currentMslRelease, 0) < 1 RAISERROR('Please enter a valid current MSL release', 18, 1)

	-- Validate the search text
	SET @searchText = TRIM(@searchText)
	IF @searchText IS NULL OR LEN(@searchText) < 1 RAISERROR('Please enter non-empty search text', 18, 1)

	-- Replace the same characters that were replaced in the cleaned_name column.
	DECLARE @filteredSearchText AS VARCHAR(100) = (CONVERT([varchar](100),replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@searchText,'í','i'),'é','e'),'ó','o'),'ú','u'),'á','a'),'ì','i'),'è','e'),'ò','o'),'ù','u'),'à','a'),'î','i'),'ê','e'),'ô','o'),'û','u'),'â','a'),'ü','u'),'ö','o'),'ï','i'),'ë','e'),'ä','a'),'ç','c'),'ñ','n'),'‘',''''),'’',''''),'`',' '),'  ',' '),N'ā','a'),N'ī','i'),N'ĭ','i'),N'ǎ','a'),N'ē','e'),N'ō','o'),(0)))

	-- Make sure "include all releases" isn't null.
	IF @includeAllReleases IS NULL SET @includeAllReleases = 0

	-- If we aren't including all releases and the MSL release number is null, default to the current release.
	IF @includeAllReleases = 0 AND @selectedMslRelease IS NULL SET @selectedMslRelease = @currentMslRelease

	-- Search the taxonomy_node table
	SELECT
		display_order = (
			SELECT TOP 1 display_order
			FROM (
				-- Sorted siblings of the taxonomy node search result (same parent ID, same rank)
				SELECT
					CAST(DENSE_RANK() OVER (ORDER BY siblingTN.left_idx ASC) AS INT) AS display_order,
					siblingTN.taxnode_id
				FROM taxonomy_node siblingTN					
				WHERE siblingTN.parent_id = tn.parent_id
				AND siblingTN.level_id = tn.level_id
				AND siblingTN.taxnode_id <> siblingTN.tree_id
			) sortedSiblings
			WHERE sortedSiblings.taxnode_id = tn.taxnode_id
		),
		tn.ictv_id AS ictv_id,
		REPLACE(ISNULL(tn.lineage,''),';','>') AS lineage,
		tn.parent_id AS parent_taxnode_id,
		tl.name AS rank_name,
		tn.msl_release_num AS release_number,
		@searchText AS search_text,
		tn.taxnode_id AS taxnode_id,
		(
			CAST(tn.tree_id AS VARCHAR(12))
			+ CASE WHEN tn.realm_id IS NOT NULL THEN ','+CAST(tn.realm_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.subrealm_id IS NOT NULL THEN ','+CAST(tn.subrealm_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.kingdom_id IS NOT NULL THEN ','+CAST(tn.kingdom_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.subkingdom_id IS NOT NULL THEN ','+CAST(tn.subkingdom_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.phylum_id IS NOT NULL THEN ','+CAST(tn.phylum_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.subphylum_id IS NOT NULL THEN ','+CAST(tn.subphylum_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.class_id IS NOT NULL THEN ','+CAST(tn.class_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.subclass_id IS NOT NULL THEN ','+CAST(tn.subclass_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.order_id IS NOT NULL THEN ','+CAST(tn.order_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.suborder_id IS NOT NULL THEN ','+CAST(tn.suborder_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.family_id IS NOT NULL THEN ','+CAST(tn.family_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.subfamily_id IS NOT NULL THEN ','+CAST(tn.subfamily_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.genus_id IS NOT NULL THEN ','+CAST(tn.genus_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.subgenus_id IS NOT NULL THEN ','+CAST(tn.subgenus_id AS VARCHAR(12)) ELSE '' END
			+ CASE WHEN tn.species_id IS NOT NULL THEN ','+CAST(tn.species_id AS VARCHAR(12)) ELSE '' END
		) AS taxnode_lineage,
		tn.tree_id AS tree_id,
		tree.name AS tree_name

	FROM taxonomy_node tn 
	JOIN taxonomy_level tl ON tl.id = tn.level_id 
	JOIN taxonomy_node tree ON (
		tree.taxnode_id = tn.tree_id 
		AND tree.msl_release_num IS NOT NULL
	)
	WHERE tn.cleaned_name LIKE '%'+@filteredSearchText+'%'
	AND tn.is_hidden = 0 
	AND tn.is_deleted = 0

	-- Either include all releases or limit to the selected release.
	AND (@includeAllReleases = 1 OR tn.msl_release_num = @selectedMslRelease)

	-- Make sure the MSL release is no more recent than the current release.
	AND tn.msl_release_num <= @currentMslRelease

	ORDER BY tn.tree_id DESC, tn.left_idx 

END
GO

