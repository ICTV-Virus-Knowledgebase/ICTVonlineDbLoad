
-- 
-- set metadata for NEW TREE ROOT

select * from taxonomy_toc
--
DECLARE @msl int;                 SET @msl=/*>>*/ '37'/*<<*/
DECLARE @root_name varchar(50);   SET @root_name= '2021'
DECLARE @tree_id int;             select @tree_id=tree_id from taxonomy_toc where msl_release_num=@msl 
DECLARE @root_notes varchar(150); SET @root_notes='EC 53, Online, July 2021; Email ratification March 2022 (MSL #'+rtrim(@msl)+')'

print 'MSL='+rtrim(@msl)
print 'NAME='+@root_name
print 'NOTES='+@root_notes
print 'TREE_ID='+rtrim(@tree_id)



--
-- UPDATE/FIX (post hoc, root node)
--
select [QC: are root node notes NULL/wrong?]='ERROR', taxnode_id, msl_release_num, name, 
-- update taxonomy_node set 
	notes = @root_notes
from taxonomy_node
where level_id = 100 and msl_release_num = @msl
and (notes is null or notes <> @root_notes)


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

--
-- QC 
-- 
select qc_report='added tree root', msl_release_num, tree_id, taxnode_id, ictv_id, name
	, notes=
		(case when left(rtrim(tree_id),4) <> name then 'ERROR: name does not match tree_id - please doublecheck' else '' end)
from taxonomy_node
where taxnode_id in (select max(tree_id) from taxonomy_toc)
