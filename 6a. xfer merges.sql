--
-- Tranfer data from load_new_msl =>taxonomy_node
--

-- 
-- Fifth: xfer merges
--

select 
	message='transfering '+rtrim(count(*))+' src_out_change='+src.src_out_change
	, errors=''
-- select * 
from load_next_msl as src
where 
	(src.dest_in_change is null and src.src_out_change in ('merge'))
group by src.src_out_change

--
-- no nodes to insert!!!
--

--
-- update out_change in taxonomy_node of prev MSL
--
update taxonomy_node set
-- select
	out_change = 'merge'
	, out_target = src.dest_target
	, out_filename = ref_filename
	, out_notes = ref_notes
from taxonomy_node 
join load_next_msl as src on src.src_taxnode_id = taxonomy_node.taxnode_id
where
	(src.dest_in_change is null and src.src_out_change in ('merge'))

/*******************************************************************************
 * moved delta node creation to a single script
 * 9a. rebuild delta nodes
 *******************************************************************************
--
-- create delta nodes
--
insert into taxonomy_node_delta (
	prev_taxid, new_taxid
	, proposal, notes
	, is_merged
	, is_now_type	
) 
select 	
	prev_taxid=src.src_taxnode_id, new_taxid=msl2.taxnode_id
	, proposal=src.ref_filename, notes=src.ref_notes
	, is_merged=1
--	, is_renamed=case when msl1.name <> msl2.name then 1 else 0 end
	, is_now_type=msl2.is_ref - msl1.is_ref
-- select src.src_lineage, src.dest_target, msl2.lineage
from load_next_msl as src
join taxonomy_node msl1 on msl1.taxnode_id=src.src_taxnode_id
join taxonomy_node msl2 on msl2.tree_id=src.dest_tree_id
	and msl2.name = src.dest_target
where 
	(src.dest_in_change is null and src.src_out_change in ('merge'))
order by src_left_idx
*/

/*******************************************************************************
 * moved merge creation to a single script
 * 9b. rebuild merge-split table
 *******************************************************************************
--
-- create merge/split transitive closure entries
--
insert into taxonomy_node_merge_split (
	prev_ictv_id
	, next_ictv_id
	, is_merged
	, is_split
	, dist
)
select 	
	prev_ictv_id=msl1.ictv_id
	, next_ictv_id=msl2.ictv_id
	, is_merged=1
	, is_split=0
	, dist=1 -- hope this is the right initial distance!
from load_next_msl as src
join taxonomy_node msl1 on msl1.taxnode_id=src.src_taxnode_id
join taxonomy_node msl2 on msl2.tree_id=src.dest_tree_id
	and msl2.name = src.dest_target
where 
	(src.dest_in_change is null and src.src_out_change in ('merge'))
*/