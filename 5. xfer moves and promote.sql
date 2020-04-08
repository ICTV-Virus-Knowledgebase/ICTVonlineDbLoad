--
-- Tranfer data from load_new_msl =>taxonomy_node
--

-- 
-- Fourth: xfer move, move_type and move_rename, promote 
--

select 
	message='transfering '+rtrim(count(*))+' src_out_change='+src.src_out_change
	, errors=''
-- select * 
from load_next_msl as src
where 
	(src.dest_in_change is null and (src.src_out_change like 'move%' or src.src_out_change in ('promote')) )
group by src.src_out_change



insert into taxonomy_node (
	taxnode_id,
	tree_id,
	parent_id,
	name,
	level_id,
	is_ref,
	is_hidden,
	ictv_id,
	msl_release_num,
	--in_change, in_filename, in_notes, in_target,
	--out_change, out_filename, out_notes
	notes
) 
select 
	--src.src_out_change, -- debug
	taxnode_id = src.dest_taxnode_id
	, tree_id = src.dest_tree_id
	-- figure out new taxid of parent (assume target is the lineage of the parent or the new name, with semi-colons)
	, parent_id = dest_parent_id /*(
		-- parent nodes already inserted into taxonomy_node
		select taxnode_id=parent.taxnode_id 
		from taxonomy_node parent 
		where (
			parent.lineage=src.dest_parent_lineage -- if target was lineage of target
			or
			parent.lineage=src.dest_target -- if target was lineage of target parent
			or 
			(parent.name <> 'Unassigned' and parent.name = src.dest_target) -- if target was un-decorated name of parent
		)
		and parent.tree_id = src.dest_tree_id
		and parent.level_id = dplevel.id 
	
		union
		
		-- parent nodes still in load_next_msl
		select taxnode_id=parent.dest_taxnode_id
		from load_next_msl as parent
		where (
			parent.dest_target=src.dest_parent_lineage -- if target was lineage of target
			or
			parent.dest_target=src.dest_target -- if target was lineage of target parent
		)
		and isnull(parent.dest_level,parent.src_level) = dplevel.name 
		--and (dest_in_change in ('new','split') or src_out_change like 'move%')
	)*/
	-- assume it's a lineage, and get what's after the last semi-colon
	,name = dest_name
	,level_id = (select id from taxonomy_level where name=rtrim(isnull(src.dest_level,src.src_level)) or rtrim(id)=isnull(src.dest_level,src.src_level))
	,is_ref = isnull(isnull(src.dest_is_type, src.src_is_type),0)
	,is_hidden = isnull(src.dest_is_hidden, 0)
	,ictv_id = src.src_ictv_id
	,msl_release_num = src.dest_msl_release_num
	--,in_change = src.dest_in_change
	--,in_filename = src.ref_filename
	--,in_notes = src.ref_notes
	--,in_target = src.dest_target
	,notes = case when src.ref_problems='' then null else src.ref_problems end
from load_next_msl as src
-- destination level
left outer join taxonomy_level dlevel on dlevel.name=isnull(src.dest_level,src.src_level)
-- destination parent level
left outer join taxonomy_level dplevel on dplevel.id = dlevel.parent_id
WHERE
	(src.dest_in_change is null and (src.src_out_change like 'move%' or src.src_out_change in ('promote')) )
AND
	-- reentrant: skip ones already inserted
	(src.dest_taxnode_id NOT in (select n.taxnode_id from taxonomy_node as n where n.tree_id=src.dest_tree_id))
ORDER BY level_id, dest_target

-- move 20151066 (ICTV 19960123) has null parent_id
-- move-rename : subquery error

--
-- update out_change in taxonomy_node of prev MSL
--
update taxonomy_node set
-- select
	out_change = (case when src.src_out_change like 'move%' then 'move' else src.src_out_change end) 
	, out_target = src.dest_target
	, out_filename = ref_filename
	, out_notes = ref_notes
from taxonomy_node 
join load_next_msl as src on src.src_taxnode_id = taxonomy_node.taxnode_id
where
	(src.dest_in_change is null and (src.src_out_change like 'move%' or src.src_out_change in ('promote')) )

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
	, is_moved
	, is_renamed
	, is_now_type	
) 
select 	
	prev_taxid=src.src_taxnode_id, new_taxid=src.dest_taxnode_id
	, proposal=src.ref_filename, notes=src.ref_notes
	, is_moved=1
	, is_renamed=case when msl1.name <> msl2.name then 1 else 0 end
	, is_now_type=msl2.is_ref - msl1.is_ref
from load_next_msl as src
join taxonomy_node msl1 on msl1.taxnode_id=src.src_taxnode_id
join taxonomy_node msl2 on msl2.taxnode_id=src.dest_taxnode_id
where 
	(src.dest_in_change is null and src.src_out_change in ('move', 'move_rename'))
order by src_left_idx
*/