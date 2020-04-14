-- =====================================================================================================================================
-- Author:		don dempsey
-- Created on:	03/17/20
-- Description:	Return a count for every taxonomy level by MSL Release
-- Updated on:
-- =====================================================================================================================================

-- Delete any existing versions of the view.
--IF OBJECT_ID('dbo.view_taxa_level_counts_by_release') IS NOT NULL
--	DROP VIEW dbo.view_taxa_level_counts_by_release
--GO

CREATE OR ALTER VIEW view_taxa_level_counts_by_release AS
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

CREATE OR ALTER VIEW view_taxa_level_counts_by_release_simplified AS
-- 20200414 CurtisH (simplified)
select  
	-- release
	release.tree_id, release.notes, release.msl_release_num, year=release.name
	-- taxons
    , realm=	count(case when rank.name='realm' then 1 else NULL end)
    , subrealm=	count(case when rank.name='subrealm' then 1 else NULL end)
    ,kingdom=	count(case when rank.name='kingdom' then 1 else NULL end)
    ,subkingdom=count(case when rank.name='subkingdom' then 1 else NULL end)
    ,phylum=	count(case when rank.name='phylum' then 1 else NULL end)
    ,subphylum=	count(case when rank.name='subphylum' then 1 else NULL end)
    ,class=		count(case when rank.name='class' then 1 else NULL end)
    ,subclass=	count(case when rank.name='subclass' then 1 else NULL end)
    ,[order]=	count(case when rank.name='order' then 1 else NULL end)
    ,suborder=	count(case when rank.name='suborder' then 1 else NULL end)
    ,family=	count(case when rank.name='family' then 1 else NULL end)
    ,subfamily=	count(case when rank.name='subfamily' then 1 else NULL end)
    ,genus=		count(case when rank.name='genus' then 1 else NULL end)
    ,subgenus=	count(case when rank.name='subgenus' then 1 else NULL end)
    ,species=	count(case when rank.name='species' then 1 else NULL end)
from taxonomy_toc toc
join taxonomy_node release on release.taxnode_id = toc.tree_id and release.msl_release_num is not null
join taxonomy_node n on n.tree_id = release.tree_id and n.level_id > 100 and n.is_hidden = 0 and n.name <> 'unassigned'
join taxonomy_level rank on rank.id = n.level_id
group by release.tree_id, release.notes, release.msl_release_num, release.name

GO


