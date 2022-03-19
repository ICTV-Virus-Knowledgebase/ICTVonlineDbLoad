/* 
 * check change stats on current and preceeding MSL
 */
select 'prev MSL out_change summary' as issue, 
	tree_id, out_change, COUNT(*) as ct 
from taxonomy_node 
where msl_release_num = (select max(msl_release_num)-1 from taxonomy_node)
and (out_change is not null)
group by tree_id, out_change

select 'current MSL in_change summary' as issue, 
	tree_id, in_change, COUNT(*) as ct, COUNT(case when parent_id IS NULL  then 1 else null end) from taxonomy_node where tree_id = (select MAX(tree_id) from taxonomy_node) 
group by tree_id, in_change

select 'parent_id is NULL' as problem, 
	* 
from taxonomy_node 
where parent_id is null order by tree_id,left_idx


