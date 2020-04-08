--
-- create new MSL in taxonomy_node
--

-- 
-- create the tree root
--
DECLARE @tree_id int; SET @tree_id=201850000
DECLARE @msl int; SET @msl=34

--
-- test
--
select 'test', * from taxonomy_toc where msl_release_num = @msl

--
-- CREATE
--
insert into taxonomy_toc (tree_id, msl_release_num)
values (@tree_id, @msl)

insert into taxonomy_node ( 
	taxnode_id, parent_id, tree_id, msl_release_num
	, level_id, name, ictV_id, notes, is_hidden
	, filename 
) 
select 
	taxnode_id=@tree_id
	, parent_id=@tree_id
	, tree_id = @tree_id
	, msl_release_num = @msl 
	, level_id
	, name = '2018b'
	, ictv_id
	, notes= 'EC 50, Washington, DC, July 2018; Email ratification February 2018 (MSL #34)'
	, is_hidden
	, filename = (select top 1 filename from load_next_msl)
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
	taxnode_id=taxnode_id+201850000-20180000 -- normally 100k, but we're jumping this time to 100k instead of 10k
	, parent_id=parent_id+201850000-20180000
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
-- skip stuff already copied
and not exists (select * from taxonomy_node as test where test.taxnode_id = taxonomy_node.taxnode_id+201850000-20180000)
-- skip things marked "abolish" 
-- DONT NEED TO - Step 7b will delete these 
--and (out_change is null or out_change not in ( 'abolish'))
order by left_idx