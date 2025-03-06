
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[view_taxa_level_counts_by_release] AS
-- by Don Dempsey
SELECT 
release.tree_id, 
release.notes,
release.msl_release_num,
release.name AS [year],

ISNULL(realm, 0) AS realms, 
ISNULL(subrealm, 0) AS subrealms,
ISNULL(kingdom, 0) AS kingdoms,
ISNULL(subkingdom, 0) AS subkingdoms,
ISNULL(phylum, 0) AS phyla,
ISNULL(subphylum, 0) AS subphyla, 
ISNULL(class, 0) AS classes,
ISNULL(subclass, 0) AS subclasses,
ISNULL([order], 0) AS orders,  
ISNULL(suborder, 0) AS suborders,  
ISNULL(family, 0) AS families,  
ISNULL(subfamily, 0) AS subfamilies,  
ISNULL(genus, 0) AS genera,  
ISNULL(subgenus, 0) AS subgenera,  
ISNULL(species, 0) AS species 

FROM (
	SELECT 
	tree_id, 
	realm,
	subrealm,
	kingdom,
	subkingdom,
	phylum,
	subphylum,
	class,
	subclass,
	[order],
	suborder,
	family,
	subfamily,
	genus,
	subgenus,
	species
	FROM (
		SELECT count_by_level, tl.name, tree_id
		FROM (
			SELECT 
			COUNT(tn.level_id) AS count_by_level,
			tn.level_id,
			tn.tree_id
			FROM taxonomy_node tn
			WHERE tn.is_hidden = 0
			AND tn.msl_release_num IS NOT NULL
			AND tn.name NOT LIKE 'unassigned'
			GROUP BY tn.tree_id, tn.level_id
		) levelCounts
		JOIN taxonomy_level tl ON tl.id = level_id
	) levelCounts
	PIVOT (
		MAX(count_by_level)
		FOR name in (
			realm,
			subrealm,
			kingdom,
			subkingdom,
			phylum,
			subphylum,
			class,
			subclass,
			[order],
			suborder,
			family,
			subfamily,
			genus,
			subgenus,
			species
		)
	) pivotData
) pivotedData
JOIN taxonomy_node release ON (release.tree_id = pivotedData.tree_id AND release.level_id = 100)
WHERE release.msl_release_num IS NOT NULL
AND release.name NOT LIKE 'unassigned'

GO

