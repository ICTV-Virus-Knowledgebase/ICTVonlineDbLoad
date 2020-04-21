--
-- 9ya1. remove genus Unyawo & species "Xylella virus Paz"
--
-- Elliot Lefkowitz & Evelien Adriaenssens <Evelien.Adriaenssens@quadram.ac.uk>

--begin transaction

-- view context
select report='before', n.taxnode_id, n.level_id, n.lineage, n._numKids, targ=(case when n.name in ('Unyawo', 'Xylella virus Paz') then '<<<===' else '' end)
from taxonomy_node n
join taxonomy_node t on n.left_idx between t.left_idx and t.right_idx and t.tree_id = n.tree_id
where t.name in ('Autographiviridae')
order by n.left_idx

-- 
-- test target
--
delete 
-- select taxnode_id, level_id, lineage, _numKids
from taxonomy_node 
where msl_release_num=dbo.udf_getMSL(NULL) 
and name in ('Unyawo', 'Xylella virus Paz')

-- view context
select report='before', n.taxnode_id, n.level_id, n.lineage, n._numKids, targ=(case when n.name in ('Unyawo', 'Xylella virus Paz') then '<<<===' else '' end)
from taxonomy_node n
join taxonomy_node t on n.left_idx between t.left_idx and t.right_idx and t.tree_id = n.tree_id
where t.name in ('Autographiviridae')
order by n.left_idx

--exec rebuild_delta_nodes
exec rebuild_node_merge_split


--commit transaction 
