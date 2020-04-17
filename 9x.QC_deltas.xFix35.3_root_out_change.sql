--
-- prevMSL root node is missing it's out_target
-- 
select top 5 
	taxnode_id, name, in_change, in_target, out_change, out_target 
from taxonomy_node 
where tree_id=taxnode_id 
order by tree_id desc

select * from taxonomy_node where taxnode_id in (201900000,201850000,20180000)
select * from taxonomy_node_delta where new_taxid in (201900000,201850000,20180000)

--
-- set out_target on root node for MSL34 to point to MSL35
--
update taxonomy_node set out_target = '2019' where taxnode_id =201850000


EXEC [dbo].[rebuild_delta_nodes] NULL -- hits latest MSL automatically.