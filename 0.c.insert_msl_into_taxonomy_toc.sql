/*
 * register our new MSL into taxonomy_toc
 *
 * defines MSL & tree_id 
 *
 */

--
-- FIRST: look at recent releases
--
 select top 5 m='5 most recent hightest msls', * 
 from taxonomy_toc_dx
 order by msl_release_num desc


-- 
-- set metadata for NEW TREE ROOT
--
DECLARE @msl int;                 SET @msl=/*>>*/ '37'/*<<*/
DECLARE @root_name varchar(50);   SET @root_name= '2021'
DECLARE @tree_id int;             SET @tree_id=cast(left(@root_name,4) as int)*(100*1000)


print 'MSL='+rtrim(@msl)
print 'NAME='+@root_name
print 'TREE_ID='+rtrim(@tree_id)


--
-- INSERT: TAXONOMY_TOC
--
insert into taxonomy_toc (tree_id, msl_release_num)
values (@tree_id, @msl)
