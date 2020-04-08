--
-- Tranfer data from load_new_msl =>taxonomy_node
--

-- 
-- FIRST: no-change and rename
--

select 'transfering '+rtrim(count(*))+' abolished records'
from load_next_msl as src 
where 
	(src.dest_in_change is null and src.src_out_change = 'abolish')
	
--
-- update out_change in taxonomy_node of prev MSL
--
update taxonomy_node set
-- select
	out_change = 'abolish'
	, out_target = NULL
	, out_filename = ref_filename
	, out_notes = ref_notes
from taxonomy_node 
join load_next_msl as src on src.src_taxnode_id = taxonomy_node.taxnode_id
and src.src_out_change = 'abolish'

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
	, is_deleted
) 
select 	
	prev_taxid=src.src_taxnode_id, new_taxid=NULL
	, proposal=src.ref_filename, notes=src.ref_notes
	, is_deleted = 1
	--, already=(select d.prev_taxid from taxonomy_node_delta as d where d.prev_taxid=src.src_taxnode_id)
from load_next_msl as src
join taxonomy_node msl1 on msl1.taxnode_id=src.src_taxnode_id
where 
	(src.dest_in_change is null and src.src_out_change = 'abolish')
order by src.src_taxnode_id--src_left_idx
*/

/*
-- delete this step

delete -- select *
from taxonomy_node_delta
where prev_taxid between 20120000 and 20129999 
and new_taxid is null
and is_deleted=1
*/