
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[searchVisualTaxonomy]
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

	-- Search the taxonomy_node table and join the taxonomy_json table.
	SELECT 
		ictv_id,
		tj.id AS json_id,
		json_lineage,
		lineage,
		rank_name,
		release_number,
		search_text,
		results.taxnode_id,
		results.tree_id,
		tree_name

	FROM (
		SELECT
			tn.ictv_id AS ictv_id,
			tn.left_idx,
			REPLACE(ISNULL(tn.lineage,''),';','>') AS lineage,
			tl.name AS rank_name, 
			tn.msl_release_num AS release_number, 
			@searchText AS search_text,
			tn.taxnode_id AS taxnode_id, 
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

	) results
	JOIN taxonomy_json tj ON tj.taxnode_id = results.taxnode_id
	ORDER BY results.tree_id DESC, left_idx 

END
GO

