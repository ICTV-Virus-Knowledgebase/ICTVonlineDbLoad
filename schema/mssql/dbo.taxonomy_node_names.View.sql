USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[taxonomy_node_names] as
select 
	-- the underlying table
	 tn.* 
	-- ranks
	,[rank]   = isnull([rank].name, '')
	,[tree]   = isnull([tree].name,'')
	,[realm]   = isnull([realm].name,'')
	,[subrealm]   = isnull([subrealm].name,'')
	,[kingdom]   = isnull([kingdom].name,'')
	,[subkingdom]   = isnull([subkingdom].name,'')
	,[phylum]   = isnull([phylum].name,'')
	,[subphylum]   = isnull([subphylum].name,'')
	,[class]   = isnull([class].name,'')
	,[subclass]   = isnull([subclass].name,'')
	,[order]   = isnull([order].name,'')
	,[suborder]   = isnull([suborder].name,'')
	,[family]   = isnull([family].name,'')
	,[subfamily]   = isnull([subfamily].name,'')
	,[genus]   = isnull([genus].name,'')
	,[subgenus]   = isnull([subgenus].name,'')
	,[species]   = isnull([species].name,'')
	,molecule = isnull(mol.abbrev,'')
	,inher_molecule = isnull(imol.abbrev,'')
from taxonomy_node tn
-- join all ranks
left outer join taxonomy_level [rank] on [rank].id=tn.level_id
left outer join taxonomy_node [tree] on [tree].taxnode_id=tn.tree_id
left outer join taxonomy_node [realm] on [realm].taxnode_id=tn.realm_id
left outer join taxonomy_node [subrealm] on [subrealm].taxnode_id=tn.subrealm_id
left outer join taxonomy_node [kingdom] on [kingdom].taxnode_id=tn.kingdom_id
left outer join taxonomy_node [subkingdom] on [subkingdom].taxnode_id=tn.subkingdom_id
left outer join taxonomy_node [phylum] on [phylum].taxnode_id=tn.phylum_id
left outer join taxonomy_node [subphylum] on [subphylum].taxnode_id=tn.subphylum_id
left outer join taxonomy_node [class] on [class].taxnode_id=tn.class_id
left outer join taxonomy_node [subclass] on [subclass].taxnode_id=tn.subclass_id
left outer join taxonomy_node [order] on [order].taxnode_id=tn.order_id
left outer join taxonomy_node [suborder] on [suborder].taxnode_id=tn.suborder_id
left outer join taxonomy_node [family] on [family].taxnode_id=tn.family_id
left outer join taxonomy_node [subfamily] on [subfamily].taxnode_id=tn.subfamily_id
left outer join taxonomy_node [genus] on [genus].taxnode_id=tn.genus_id
left outer join taxonomy_node [subgenus] on [subgenus].taxnode_id=tn.subgenus_id
left outer join taxonomy_node [species] on [species].taxnode_id=tn.species_id
-- other controlled vocabularies
left outer join taxonomy_molecule mol on mol.id = tn.molecule_id
left outer join taxonomy_molecule imol on imol.id = tn.inher_molecule_id
-- filter out historical junk
where tn.is_deleted = 0 and tn.is_hidden = 0 and tn.is_obsolete=0

GO
