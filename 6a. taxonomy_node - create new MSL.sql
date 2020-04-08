--
-- create new MSL in taxonomy_node
--

-- 
-- create the tree root
--
DECLARE @tree_id int; SET @tree_id=20180000
DECLARE @msl int; SET @msl=33

insert into taxonomy_node ( 
	taxnode_id, parent_id, tree_id, msl_release_num
	, level_id, name, ictV_id, notes, is_hidden
) 
select 
	taxnode_id=@tree_id
	, parent_id=@tree_id
	, tree_id = @tree_id
	, msl_release_num = @msl 
	, level_id
	, name = '2018'
	, ictv_id
	, notes= 'EC 50, Washington, DC, July 2018; Email ratification October 2018 (MSL #33)'
	, is_hidden
from taxonomy_node
where level_id = 100 and msl_release_num = (@msl-1)
and not exists (select * from taxonomy_node where tree_id = @tree_id)

-- 
-- copy over non-abolished nodes with a simple offset
--
insert into taxonomy_node ( 
	taxnode_id, parent_id, tree_id, msl_release_num
	, level_id, name, ictV_id, is_hidden, is_ref
) 
select 
	taxnode_id=taxnode_id+10000
	, parent_id=parent_id+10000
	, tree_id = @tree_id
	, msl_release_num = @msl 
	, level_id
	, name
	, ictv_id
	, is_hidden
	, is_ref
	-- TODO
	-- ADD molecule type, abbreviations, exemplars, accessions, etc.
from taxonomy_node
where  msl_release_num = (@msl-1)
and not exists (select * from taxonomy_node as test where test.taxnode_id = taxonomy_node.taxnode_id+10000)
order by left_idx