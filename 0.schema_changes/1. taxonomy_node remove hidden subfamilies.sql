--
-- Remove all hidden SubFamilies
--
--
-- 1. reparent their children to their parents
-- 2. delete linked delta records
-- 3. delete tha  taxa
--

--rows=1830 
update taxonomy_node set
--select tn.taxnode_id, tn.parent_id, tn.tree_id, tn.msl_release_num, tn.level_id, tn.name, tn.lineage,
	parent_id = (select parent_id from taxonomy_node p where p.taxnode_id = tn.parent_id)
from taxonomy_node  tn
where tn.parent_id in 
( 
	select taxnode_id 
	from taxonomy_node subfam 
	where name is null
	and level_id = (select id from taxonomy_level where name='subfamily')
)

--
-- delete the now disconnected hidden subfamilies from the delta table
--
delete 
--select *
from taxonomy_node_delta 
where 
prev_taxid in (select taxnode_id from taxonomy_node where name is null and level_id = (select id from taxonomy_level where name='subfamily'))
or
new_taxid in (select taxnode_id from taxonomy_node where name is null and level_id = (select id from taxonomy_level where name='subfamily'))


--
-- delete the now disconnected hidden subfamilies
--
delete 
--select right_idx-left_idx-1 as child_ct, lineage, name, *
from taxonomy_node
where name is null
and level_id = (select id from taxonomy_level where name='subfamily')

--and tn.tree_id =19950000

--
-- check the results
--
select 'before',b.taxnode_id, b.parent_id, b.left_idx, b.right_idx, b.level_id, b.name, b.lineage
from taxonomy_node b
where (b.lineage like 'Unassigned;Coronaviridae;Unassigned%'
and b.tree_id = 19950000) or b.taxnode_id in (19950017,19950002,19950000,0)
order by b.tree_id, b.left_idx

