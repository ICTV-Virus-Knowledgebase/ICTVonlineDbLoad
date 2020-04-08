print '-- '
print '-- fix MSL names, and rename-out_target values'
print '-- '


begin transaction
-- commit transaction
-- ROLLBACK transaction


select report='before', in_target, out_change, out_target, name, msl_release_num, tree_id 
from taxonomy_node 
where level_id=100
order by tree_id

select report='before, taxonomy_node_dx', *
from taxonomy_node_dx
where level_id = 100
order by tree_id

-- add a/b when 2 per year
update taxonomy_node set --select name, [update]='>>>',
name='1999a' from taxonomy_node where level_id = 100 and msl_release_num =18 and name like '____'

update taxonomy_node set --select name, [update]='>>>',
name='1999b' from taxonomy_node where level_id = 100 and msl_release_num =19 and name like '____'

update taxonomy_node set --select name, [update]='>>>',
name='2002a' from taxonomy_node where level_id = 100 and msl_release_num =20 and name like '____'

update taxonomy_node set --select name, [update]='>>>',
name='2002b' from taxonomy_node where level_id = 100 and msl_release_num =21 and name like '____'


update taxonomy_node set --select report='proposed', in_target, out_change, out_target, name, msl_release_num, tree_id, [updates]='>>>', 
	out_change='rename', out_target=(select top 1 name from taxonomy_node n where n.level_id=100 and  n.tree_id > taxonomy_node.tree_id order by n.tree_id asc)
	from taxonomy_node 
where level_id = 100 and msl_release_num is not null and (out_target is null or out_change is null)

select report='after', in_target, out_change, out_target, name, msl_release_num, tree_id 
from taxonomy_node 
where level_id=100
order by tree_id

-- MSL34 3m45s -- inside tx
exec rebuild_delta_nodes 34
exec rebuild_delta_nodes 33
exec rebuild_node_merge_split


select report='after, taxonomy_node_dx', *
from taxonomy_node_dx
where level_id = 100
order by tree_id

-- commit transaction
-- rollback transaction

