-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Riboviria;Gammanucleorhabdovirus
--
-- split (sort=814.2) and create (sort=832) both create the genus, 
-- but in different places (realm:Riboviria, family: Rhabdoviridae, respectively)
--
-- IsWrong the create, and update the destintation for the split.
--
-- --------------------------------------------------------------------------------------------------
BEGIN TRANSACTION 

select 
	sort, _src_taxon_name, isWrong=left(isWRong,20), action=_action, _dest_parent_name, dest_taxon_name=_dest_taxon_name, dest_parent_id, _dest_parent_name
	, prev='>>>', prev.taxnode_id, prev.out_change, prev.out_filename
	, dest='>>>', dest.taxnode_id, prev.in_change, prev.in_filename, dest.lineage
	, destParent='byNameOrId>>>', destp.taxnode_id, destp.lineage
from load_next_msl src
left outer join taxonomy_node_names prev on prev.taxnode_id = src.prev_taxnode_id
left outer join taxonomy_node_names dest on dest.taxnode_id = src.dest_taxnode_id
left outer join taxonomy_node_names destp on destp.taxnode_id = src.dest_parent_id or (destp.msl_release_num=src.dest_msl_release_num and destp.name=src._dest_parent_name)
where sort in (814.2,832,833) 
order by dest_taxon_name, action

select report='ancestors', n.parent_id, n.taxnode_id, n.rank, n.name, n.lineage, n.in_change, n.in_filename
from taxonomy_node t
join taxonomy_node_names n on t.left_idx between n.left_idx and n.right_idx and n.tree_id = t.tree_id
where t.msl_release_num = (select max(msl_release_num) from taxonomy_toc) and t.name = 'Rhabdoviridae'
order by n.level_id 

-- isWrong the NEW
update load_next_msl set
	isWrong='split (sort=814.2) and create (sort=832) both create the genus, '
	+' but in different places (realm:Riboviria, family: Rhabdoviridae, respectively)'
	+'IsWrong the create, and update the destintation for the split.'
from load_next_msl
where sort in (832) 

-- update DEST in split

update load_next_msl set
	family='Rhabdoviridae'
	, dest_parent_id=(select taxnode_id from taxonomy_node where msl_release_num=dest_msl_release_num and name='Rhabdoviridae')
from load_next_msl
where sort in (814.2) 
and family is null


-- change parantage
--
-- ASSUMES we FIRST corrected the dest_parent_id above in load_next_msl
--
select taxnode_id, parent_id, level_id, lineage, in_change, in_filename, in_notes,in_target, ssep='>>',
--RUN-- update dest set 	
	parent_id = src.dest_parent_id
from taxonomy_node dest
join load_nexT_msl src on src.dest_taxnode_id = dest.taxnode_id
where src.sort in (814.2) 


--
-- why still empty? 
--

select report='descendants', n.taxnode_id, n.parent_id, n.ictv_id, n.rank,n.lineage, n._numKids, n.in_change, n.in_filename, n.in_notes, n.in_target
from taxonomy_node t
join taxonomy_node_names n on n.left_idx between t.left_idx and t.right_idx and n.tree_id = t.tree_id
where t.name in ('Gammanucleorhabdovirus') and t.msl_release_num=35
order by n.left_idx


--
-- move kids
--
update taxonomy_node set parent_id = 201907680 where parent_id =201907689


--
-- remove extra copy of 'Gammanucleorhabdovirus'
---
delete from taxonomy_node
where taxnode_id in (
	select  dest_taxnode_id 
	from load_next_msl
	where sort=832 and isWrong is not NULL
	)



commit transaction
