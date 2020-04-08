--
-- try to find ictv_id's with no "New" root node
--

-- example: Cherry rasp leaf virus

select msl_release_num, taxnode_id, ictv_id, in_change, in_target, in_filename, lineage
from taxonomy_node
where taxnode_id in (
	-- root taxa for each ictv_ID 
	select min(taxnode_id)
	from taxonomy_node
	where msl_release_num is not null
	group by ictv_id
)
and level_id > 100
and (in_change is null or in_filename is null)
order by msl_release_num, left_idx

select msl_release_num, in_change, in_target, in_filename, lineage
from taxonomy_node
where ictV_id = 20140192
order by msl_release_num

select target_taxnode_id, msl_release_num, taxnode_id, ictv_id, in_change, in_target, in_filename, lineage
from taxonomy_node_x
where target_taxnode_id in (
	-- things w/o new
	select target_taxnode_id
	from taxonomy_node_x
	where msl_release_num is not null
	group by target_taxnode_id
	having count(case when in_change='new' then 1 else null end) = 0
)
and msl_release_num is not null
and target_name = 'Cherry rasp leaf virus'
order by msl_release_num, target_taxnode_id

select target_taxnode_id, msl_release_num, taxnode_id, ictv_id, in_change, in_target, in_filename, out_change, out_target, out_filename, lineage
from taxonomy_node_x
where target_name =  'Cherry rasp leaf virus'
and msl_release_num is not null
order by msl_release_num, target_taxnode_id
