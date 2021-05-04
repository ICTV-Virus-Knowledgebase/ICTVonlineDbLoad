
-- 
-- set metadata for NEW TREE ROOT

select * from taxonomy_toc
--
DECLARE @msl int;                 SET @msl=/*>>*/ '36'/*<<*/
DECLARE @root_name varchar(50);   SET @root_name= '2020'
DECLARE @tree_id int;             select @tree_id=tree_id from taxonomy_toc where msl_release_num=@msl 
DECLARE @root_notes varchar(150); SET @root_notes='EC 52, Online, October 2020; Email ratification March 2021 (MSL #'+rtrim(@msl)+')'

print 'MSL='+rtrim(@msl)
print 'NAME='+@root_name
print 'NOTES='+@root_notes
print 'TREE_ID='+rtrim(@tree_id)


--
-- INSERT:  TAXONOMY_NODE (root node)
-- 
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
	, name = @root_name
	, ictv_id
	, notes= @root_notes
	, is_hidden
	, filename = (select top 1 filename from load_next_msl)
from taxonomy_node
where level_id = 100 and msl_release_num = (@msl-1)
and not exists (select * from taxonomy_node where tree_id = @tree_id)

