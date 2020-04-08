--
-- Remove all "Unassigned" genera
--
--
-- 1. reparent their children to their parents or grandparents
-- 2. delete linked delta records
-- 3. delete tha  taxa
--
-- !!!!WARNING!!!!
--
-- This fails, as some genera's taxnode_id are used to define ictv_id's, and, as such, are the primary for FK, and can't be deleted.
--

--
-- move children of 'Unassigned' to parent or grandparent taxa
--
update taxonomy_node set
--select tn.taxnode_id, tn.parent_id, tn.tree_id, tn.msl_release_num, tn.level_id, tn.name, tn.lineage,
	parent_id = isnull(
		(select p.parent_id from taxonomy_node gp join taxonomy_node p on gp.taxnode_id = p.parent_id where p.taxnode_id = tn.parent_id and gp.name <> 'Unassigned')
		,
		(select gp.parent_id from taxonomy_node gp join taxonomy_node p on gp.taxnode_id = p.parent_id where p.taxnode_id = tn.parent_id ) -- don't check great grandparent name, we know we don't have triple Unassigned
		)
from taxonomy_node  tn
where tn.parent_id in 
( 
	select taxnode_id 
	-- select tree_id, left_idx, msl_release_num, level_id, lineage
	from taxonomy_node unass 
	where name = 'Unassigned'
	--and level_id <> (select id from taxonomy_level where name='genus')
)

--
-- delete the now disconnected hidden subfamilies from the delta table
--
delete 
--select *
from taxonomy_node_delta 
where 
prev_taxid in (select taxnode_id from taxonomy_node where name ='Unassigned' ) --and level_id <> (select id from taxonomy_level where name='genus'))
or
new_taxid in (select taxnode_id from taxonomy_node where name='Unassigned') -- and level_id <> (select id from taxonomy_level where name='genus'))


--
-- delete the now disconnected hidden taxa - MSL by MSL
--
DECLARE @id int
DECLARE foreach_cursor SCROLL CURSOR FOR 
	SELECT msl_release_num
	from taxonomy_node
	group by msl_release_num
	order by msl_release_num desc

OPEN foreach_cursor
FETCH NEXT FROM foreach_cursor INTO @id
WHILE @@FETCH_STATUS = 0 BEGIN
	-- WORK
	delete 
	--select msl_release_num,  right_idx - left_idx as subtreeSize, lineage, name, *
	from taxonomy_node
	where name ='Unassigned'
	and msl_release_num =@id

	-- next
	FETCH NEXT FROM foreach_cursor INTO  @id
END
CLOSE foreach_cursor; DEALLOCATE foreach_cursor

--
-- delete the now disconnected hidden taxa - one by one
--
DECLARE @id int
DECLARE foreach_cursor SCROLL CURSOR FOR 
	SELECT taxnode_id
	from taxonomy_node
	where name ='Unassigned'

OPEN foreach_cursor
FETCH NEXT FROM foreach_cursor INTO @id
WHILE @@FETCH_STATUS = 0 BEGIN
	-- WORK
	delete 
	--select msl_release_num,  right_idx - left_idx as subtreeSize, lineage, name, *
	from taxonomy_node
	where name ='Unassigned'
	and taxnode_id =@id

	-- next
	FETCH NEXT FROM foreach_cursor INTO  @id
END
CLOSE foreach_cursor; DEALLOCATE foreach_cursor


--
-- genera that can't be deleted
-- their taxnode_id defines a ictv_id!
--
