/*
* QC: load_next_msl.* for suffixes
*/

/* 
 * legal suffixes defined here
 */
SELECT 'legal suffices in suffix_ columns:', *
  FROM [ICTVonline36].[dbo].[taxonomy_level]


/*
 * QC taxonomy_node.name suffixes
 */
select [load_next_msl suffix QC], [sort], _action, _dest_lineage
	, status=(case when errors='' then 'OK' else 'ERROR' end)
	, raw_errors = errors
from (
	select  [load_next_msl suffix QC]='load_next_msl', [sort], _action, _dest_lineage
		, errors=
			(case when not (n.realm like '%'+realm.suffix or n.realm like '%'+realm.suffix_viroid or n.realm like '%'+realm.suffix_nuc_acid) then 'realm:'+n.realm+';' else '' end)
			+(case when not (n.subrealm like '%'+subrealm.suffix  or n.subrealm like '%'+subrealm.suffix_viroid or n.subrealm like '%'+subrealm.suffix_nuc_acid) then 'subrealm:'+n.subrealm+';' else '' end)
			+(case when not (n.kingdom like '%'+kingdom.suffix  or n.kingdom like '%'+kingdom.suffix_viroid or n.kingdom like '%'+kingdom.suffix_nuc_acid) then 'kingdom:'+n.kingdom+';' else '' end)
			+(case when not (n.subkingdom like '%'+subkingdom.suffix  or n.subkingdom like '%'+subkingdom.suffix_viroid or n.subkingdom like '%'+subkingdom.suffix_nuc_acid) then 'subkingdom:'+n.subkingdom+';' else '' end)
			+(case when not (n.phylum like '%'+phylum.suffix  or n.phylum like '%'+phylum.suffix_viroid or n.phylum like '%'+phylum.suffix_nuc_acid) then 'phylum:'+n.phylum+';' else '' end)
			+(case when not (n.subphylum like '%'+subphylum.suffix  or n.subphylum like '%'+subphylum.suffix_viroid or n.subphylum like '%'+subphylum.suffix_nuc_acid) then 'subphylum:'+n.subphylum+';' else '' end)
			+(case when not (n.class like '%'+class.suffix  or n.class like '%'+class.suffix_viroid or n.class like '%'+class.suffix_nuc_acid) then 'class:'+n.class+';' else '' end)
			+(case when not (n.subclass like '%'+subclass.suffix  or n.subclass like '%'+subclass.suffix_viroid or n.subclass like '%'+subclass.suffix_nuc_acid) then 'subclass:'+n.subclass+';' else '' end)
			+(case when not (n.[order] like '%'+[order].suffix  or n.[order] like '%'+[order].suffix_viroid or n.[order] like '%'+[order].suffix_nuc_acid) then 'order:'+n.[order]+';' else '' end)
			+(case when not (n.suborder like '%'+suborder.suffix  or n.suborder like '%'+suborder.suffix_viroid or n.suborder like '%'+suborder.suffix_nuc_acid) then 'suborder:'+n.suborder+';' else '' end)
			+(case when not (n.family like '%'+family.suffix  or n.family like '%'+family.suffix_viroid or n.family like '%'+family.suffix_nuc_acid) then 'family:'+n.family+';' else '' end)
			+(case when not (n.subfamily like '%'+subfamily.suffix  or n.subfamily like '%'+subfamily.suffix_viroid or n.subfamily like '%'+subfamily.suffix_nuc_acid) then 'subfamily:'+n.subfamily+';' else '' end)
			+(case when not (n.genus like '%'+genus.suffix  or n.genus like '%'+genus.suffix_viroid or n.genus like '%'+genus.suffix_nuc_acid) then 'genus:'+n.genus+';' else '' end)
			+(case when not (n.subgenus like '%'+subgenus.suffix  or n.subgenus like '%'+subgenus.suffix_viroid or n.subgenus like '%'+subgenus.suffix_nuc_acid) then 'subgenus:'+n.subgenus+';' else '' end)
	from load_nexT_msl n
		join taxonomy_level realm on realm.name = 'realm'
		join taxonomy_level subrealm on subrealm.name = 'subrealm'
		join taxonomy_level kingdom on kingdom.name = 'kingdom'
		join taxonomy_level subkingdom on subkingdom.name = 'subkingdom'
		join taxonomy_level phylum on phylum.name = 'phylum'
		join taxonomy_level subphylum on subphylum.name = 'subphylum'
		join taxonomy_level class on class.name = 'class'
		join taxonomy_level subclass on subclass.name = 'subclass'
		join taxonomy_level [order] on [order].name = 'order'
		join taxonomy_level suborder on suborder.name = 'suborder'
		join taxonomy_level family on family.name = 'family'
		join taxonomy_level subfamily on subfamily.name = 'subfamily'
		join taxonomy_level genus on genus.name = 'genus'
		join taxonomy_level subgenus on subgenus.name = 'subgenus'
--where n.genus='Tunggulviirus'
--order by errors desc
) as src
order by status, [sort]