USE [ICTVonlnie34]
GO
/****** Object:  View [dbo].[MSL_export_fast]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[MSL_export_fast] as
select 
	-- basic MSL - one line per species
	 --tn.tree_id, tn.msl_release_num, tn.left_idx,tn.taxnode_id, tn.ictv_id -- debugging
	 tn.left_idx
	-- ranks
	--,[tree]   = isnull([tree].name,'')
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
	, is_type_species = tn.is_ref
	--,molecule = isnull(mol.abbrev,'')
	,inher_molecule = isnull(imol.abbrev,'')
	-- this should get pushed to the trigger.
	,inher_molecule_src = (select top 1 [rank] from taxonomy_node_names tns where tns.tree_id = tn.tree_id and tn.left_idx between tns.left_idx and tns.right_idx and tns.molecule_id = tn.inher_molecule_id order by tns.node_depth desc)
	-- add info on most recent change to that taxon (or it's ancestors)
	, last_change=isnull((select top 1 tag_csv from taxonomy_node_delta where new_taxid = tn.taxnode_id),'')
	, last_change_msl=(case when (select top 1 tag_csv from taxonomy_node_delta where new_taxid = tn.taxnode_id) <> '' then rtrim(tn.msl_release_num) else '' end)
	, last_change_proposal=isnull((select top 1 proposal from taxonomy_node_delta where new_taxid = tn.taxnode_id),'')
	, history_url = '=HYPERLINK("http://ictvonline.org/taxonomy/p/taxonomy-history?taxnode_id='+rtrim(tn.taxnode_id)+'","ICTVonline='+rtrim(tn.taxnode_id)+'")'
	-- these columns are not currently released in the official MSL
	-- ICTV does not OFFICIALLY track abbreviations 
	, FYI_last_abbrev=isnull(tn.abbrev_csv,'')
	-- add info on most recent change to that taxon
	--,tn.taxnode_id, tn.ictv_id, 
	-- select msl_release_num, ictV_id, name, abbrev from taxonomy_node where abbrev is not null
	,last_ncbi=isnull(tn.genbank_accession_csv,'')
	,last_isolates=isnull(tn.isolate_csv,'')
	-- add info on most recent molecule type designation to that taxon (or it's ancestors)
	-- add tree and msl for joining
	,tn.tree_id
	,tn.msl_release_num
from taxonomy_node tn
-- join all ranks
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
left outer join taxonomy_molecule mol on mol.id = tn.molecule_id
left outer join taxonomy_molecule imol on imol.id = tn.inher_molecule_id
where tn.is_deleted = 0 and tn.is_hidden = 0 and tn.is_obsolete=0
and tn.level_id = 600 /* species */
--and tn.msl_release_num=33
--and tn.in_filename is not null
--order by left_idx

/*
-- test
select * from [MSL_export_fast] where tree_id=(select max(tree_id) from taxonomy_toc)
*/
GO
