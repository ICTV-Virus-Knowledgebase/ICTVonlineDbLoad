--
-- Remove all "Unassigned" taxa that aren't genera.
--
--
-- 1. reparent their children to their parents or grandparents
-- 2. delete linked delta records
-- 3. delete tha  taxa
--

--rows=1830 
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
	and level_id <> (select id from taxonomy_level where name='genus')
)

--
-- delete the now disconnected hidden subfamilies from the delta table
--
delete 
--select *
from taxonomy_node_delta 
where 
prev_taxid in (select taxnode_id from taxonomy_node where name ='Unassigned' and level_id <> (select id from taxonomy_level where name='genus'))
or
new_taxid in (select taxnode_id from taxonomy_node where name='Unassigned' and level_id <> (select id from taxonomy_level where name='genus'))


--
-- delete the now disconnected hidden subfamilies
--
delete 
--select lineage, name, *
from taxonomy_node
where name ='Unassigned'
and level_id <> (select id from taxonomy_level where name='genus')

--and tn.tree_id =19950000

--
-- check the results
--
select 'before',b.taxnode_id, b.parent_id, b.left_idx, b.right_idx, b.level_id, b.name, b.lineage--, (case when a.lineage=b.lineage then '===' end), a.lineage ,a.name,  a.level_id, a.left_idx, a.right_idx, 'after'
from taxonomy_node b --_before b
---left outer join taxonomy_node a on b.taxnode_id = a.taxnode_id
where (b.lineage like 'Unassigned;Coronaviridae;Unassigned%'
and b.tree_id = 19950000) or b.taxnode_id in (19950017,19950002,19950000,0) or b.parent_id in (19950017,19950002,19950000,0)
order by b.tree_id, b.left_idx

