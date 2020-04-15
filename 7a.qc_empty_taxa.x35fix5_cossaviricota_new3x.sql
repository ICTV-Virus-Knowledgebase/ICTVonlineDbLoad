-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Monodnaviria;Shotokuvirae;Cossaviricota
--
-- phylum Cossaviricota created 3 times: sort=173, 177, 181. Will keep just the first. 
--
-- * some taxa moved into each, must move all kids to 173 to start
-- * all have correct in_* metadata.
-- --------------------------------------------------------------------------------------------------
BEGIN TRANSACTION 

select 
	report='details on selected sort IDs',
	sort, _src_taxon_name, isWrong=left(isWRong,20), action=_action, _dest_parent_name, dest_taxon_name=_dest_taxon_name, dest_taxnode_id
	, in_change, in_filename, in_notes, in_target
	, dest._numKids 
from load_next_msl src
left outer join taxonomy_node_names dest on dest.taxnode_id = src.dest_taxnode_id
where sort in (173, 177, 181) 
order by dest_taxon_name, action


select report='descendants', n.taxnode_id, n.rank,n.lineage
from taxonomy_node t
join taxonomy_node_names n on n.left_idx between t.left_idx and t.right_idx and n.tree_id = t.tree_id
where t.name in ('Cossaviricota') and t.msl_release_num=35
and n.level_id < 200
order by n.left_idx

--
-- isWrong the bad records
--
update load_next_msl set
	isWrong='phylum Cossaviricota created 3 times: sort=173, 177, 181. Will keep just the first.'
	from load_next_msl
where sort in (177, 181) 
and isWrong is null

-- move kids of (soon to be deleted) "extra new" nodes to the correct "new" node
-- change parantage

-- this only affects N=1: Monodnaviria;Shotokuvirae;Cossaviricota;Mouviricetes

select taxnode_id, parent_id, level_id, lineage, in_target, ssep='>>', correct._dest_lineage,
--RUN-- update taxonomy_node set 	
	parent_id = correct.dest_taxnode_id
from taxonomy_node
join load_nexT_msl correct on correct.sort=173/*primary*/ and taxonomy_node.msl_release_num = correct.dest_msl_release_num
where parent_id in (select dest_taxnode_id from  load_next_msl wrong where wrong.sort in (177, 181))
--END-RUN -- skip order during  update
order by lineage


-- remove the incorrect taxa that were created by the split
select taxnode_id, level_id, name, lineage, _numKids from taxonomy_node
--RUN-- delete from taxonomy_node
where taxnode_id in (
	select dest_taxnode_id	
	from load_next_msl wrong 
	where wrong.sort in (177, 181)
	and isWrong is not NULL
)
--
--
-- NULL the dest_taxnode_id for "new"s
--
select sort, _action, _dest_lineage, dest_taxnode_id, isWrong
--RUN-- update wrong set dest_taxnode_id=NULL
from load_next_msl wrong
where wrong.sort in (177, 181) 

-- COMMIT transaction
-- ROLLBACK transaction