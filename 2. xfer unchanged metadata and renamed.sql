--
-- Tranfer data from load_new_msl =>taxonomy_node
--

-- 
-- FIRST: no-change and rename
--



-- -----------------------------------------------------------------------------
--
-- INSERT unchanged and rename nodes
--
-- -----------------------------------------------------------------------------

select 'transfering '+rtrim(count(*))+' src_out_change='+isnull(srC_out_change,'unchanged')+' records'
from load_next_msl as src
where 
	(src.dest_in_change is null and src.src_out_change is null)
	or
	(src.dest_in_change is null and src.src_out_change in ('rename', 'type','metadata'))
group by src_out_change

--
-- check is_type values
--
select title='2.1 check is type', src_is_type, dest_is_type, count(*)
from load_next_msl
group by src_is_type, dest_is_type
select * from load_next_msl where src_is_type=0 or dest_is_type is null
if @@ROWCOUNT = 0  raiserror('ERROR test 2.1; problems mapping is_type ', 18, 1) else print('PASS is type')


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
	notes	
	--in_change, in_filename, in_notes
	--out_change, out_filename, out_notes
) 
select 
	taxnode_id = src.dest_taxnode_id
	, tree_id = src.dest_tree_id
	, parent_id = dest_parent_id /* (
			select dest_taxnode_id
			from load_next_msl as psrc
			join taxonomy_node nsrc on nsrc.taxnode_id = src.src_taxnode_id
			where psrc.src_taxnode_id = nsrc.parent_id
		)*/
	,name = isnull(replace(dest_name,'"',''), src.src_name)
	,level_id = (select id from taxonomy_level where name=src.src_level)
	,is_ref = isnull(src.dest_is_type, src.src_is_type)
	,is_hidden = isnull(NULL/*src.dest_is_hidden @@*/, src.src_is_hidden)
	,ictv_id = src.src_ictv_id
	, msl_release_num = src.dest_msl_release_num
	-- for tree, set the notes to be the meeting that ratified the changes
	, notes=(case when src.src_level ='tree' then replace(src.ref_notes,'"','') + ' (MSL #' +rtrim(src.dest_msl_release_num)+')' end)
from load_next_msl as src
where  (
	(src.dest_in_change is null and src.src_out_change is null)
	or
	(src.dest_in_change is null and src.src_out_change in ('rename', 'type','metadata'))
) and (
	-- RE-ENTRANT prevent double-inserts
	src.dest_taxnode_id not in (select taxnode_id from taxonomy_node where tree_id = src.dest_tree_id)
)
order by src_left_idx

-- select * from taxonomy_node where taxnode_id in (20161546,20161650,20162971,20163098) or parent_id in (20161546,20161650,20162971,20163098)  order by left_idx
--
-- update out_change in taxonomy_node of prev MSL
--
update taxonomy_node set
-- select
	out_change = 'rename'
	, out_target = src.dest_target
	, out_filename = ref_filename
	, out_notes = ref_notes
from taxonomy_node 
join load_next_msl as src on src.src_taxnode_id = taxonomy_node.taxnode_id
and src.src_out_change = 'rename'

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
	, is_renamed
	, is_now_type
) 
select 	
	prev_taxid=src.src_taxnode_id, new_taxid=src.dest_taxnode_id
	, proposal=src.ref_filename, notes=src.ref_notes
	, is_renamed=case when msl1.name <> msl2.name then 1 else 0 end
	, is_now_type=msl2.is_ref - msl1.is_ref
from load_next_msl as src
join taxonomy_node msl1 on msl1.taxnode_id=src.src_taxnode_id
join taxonomy_node msl2 on msl2.taxnode_id=src.dest_taxnode_id
where 
	(src.dest_in_change is null and src.src_out_change is null)
	or
	(src.dest_in_change is null and src.src_out_change in ('rename', 'type'))
order by src_left_idx
*/

/*
 delete from taxonomy_node_delta where new_taxid in (
 select 	
	src.dest_taxnode_id
from load_next_msl as src
where 
	(src.dest_in_change is null and src.src_out_change is null)
	or
	(src.dest_in_change is null and src.src_out_change in ('rename', 'type'))
	)
*/