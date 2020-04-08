/*
 * push metadata columns (isolate, abbrev, accession, molecule) 
 * from load_next_msl >>> taxonomy_node
 *
 */
 

--
-- first check all taxa were loaded.
--
declare @msl int; set @msl = (select MAX(dest_msl_release_num) from load_next_msl)
select 
	tnode.[table], tnode.msl, tnode.taxa_ct
	, case when tnode.taxa_ct = tload.taxa_ct then '= OK =' else '<<ERROR>>' end as [chk]
	,tload.taxa_ct, tload.msl, tload.[table]
 from (
	select 'taxonomy_node' as [table], max(msl_release_num) as msl, COUNT(*) as taxa_ct
	from taxonomy_node  where msl_release_num = @msl
	-- abolished taxa
	or (msl_release_num = (@msl-1) 
		and taxnode_id in (
			select src_taxnode_id 
			from load_next_msl 
			where src_out_change in ('merge', 'abolish'))
	)
) as tnode 
LEFT OUTER join
(
	select 'load_next_msl' as [table], dest_msl_release_num as msl, COUNT(*) as taxa_ct
	from load_next_msl 
	group by dest_msl_release_num
) as tload 
ON tload.msl = tnode.msl

-- investigate any extras
select tab='taxonomy_node', *
from taxonomy_node 
where taxnode_id not in (select dest_taxnode_id from load_next_msl)
and msl_release_num= @msl

select tab='load_next_msl', *
from load_next_msl 
where dest_taxnode_id not in (select taxnode_id from taxonomy_node where msl_release_num= @msl)
and not ( 
	-- discount merge/abolish
	src_out_change in ('merge', 'abolish') 
	and src_taxnode_id  in (select taxnode_id from taxonomy_node where msl_release_num= @msl-1 and out_change in ('merge', 'abolish'))
)

-- ------------------------------------------------------------------------------------------------------
--
-- TRANSFER extended properties from load table to taxonomy_node
-- fixes: removes quotes, converts semicolons->commas
--
-- ------------------------------------------------------------------------------------------------------
update taxonomy_node set
--select taxnode_id,  isolate_csv ,genbank_accession_csv , abbrev_csv ,molecule_id , '<<<<' as sets,
	 isolate_csv = isnull(isnull(
		(select replace(replace(dest_isolates,'"',''),';',',') from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id),
		(select replace(replace(src_isolates,'"',''),';',',') from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id)	
	), isolate_csv)
	, genbank_accession_csv = isnull(isnull(
		(select replace(replace(dest_ncbi_accessions,'"',''),';',',') from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id)
		,
		(select replace(replace(src_ncbi_accessions, '"',''),';',',') from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id)
	),isolate_csv)
	, abbrev_csv = isnull(isnull(
		(select replace(replace(dest_abbrevs,'"',''),';',',') from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id)
		,
		(select replace(replace(src_abbrevs, '"',''),';',',') from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id)
	), abbrev_csv)
	, molecule_id =isnull( isnull(
		(select id from taxonomy_molecule tm where (select dest_molecule from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id) in (tm.abbrev, tm.name, tm.balt_roman) ),
		(select id from taxonomy_molecule tm where (select src_molecule  from load_next_msl lnm where lnm.dest_taxnode_id = taxonomy_node.taxnode_id) in (tm.abbrev, tm.name, tm.balt_roman) )
	), molecule_id)
from taxonomy_node
where taxnode_id in (
	select dest_taxnode_id --select dest_taxnode_id, *
	from load_next_msl 
	where --dest_taxnode_id in (20150318) or 
	(
		dest_molecule is not null or dest_abbrevs is not null or dest_ncbi_accessions is not null or dest_isolates is not null	
		or
		src_molecule is not null or src_abbrevs	is not null or src_ncbi_accessions is not null or src_isolates is not null		
	)
)	


select molecule_id, count(*)
from taxonomy_node
where tree_id = (select max(tree_id) from taxonomy_node)
group by molecule_id

select * from taxonomy_node where tree_id=20170000 and molecule_id = 10 order by left_idx
select dest_molecule, src_molecule, * from load_next_msl where src_molecule = 'Single-stranded DNA - Positive-sense'