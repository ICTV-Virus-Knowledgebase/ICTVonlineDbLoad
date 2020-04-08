-- 
-- implement abolish
--

-- set the proposal and abolish flags on prev MSL in taxonomy_node
update taxonomy_node set
--select lineage, src.change, 
	out_change='abolish'
	,out_filename=src.proposal
	,out_notes = src.change
from taxonomy_node
join load_next_msl src
on  src.prev_taxnode_id = taxonomy_node.taxnode_id
and src._action like 'abolish%'
and out_change is null
WHERE isWrong is NULL

-- mark these changes as done
update load_next_msl set
--select *, 
	isDone = 1
from load_next_msl
join  taxonomy_node as n
on  load_next_msl.prev_taxnode_id = n.taxnode_id
and load_next_msl._action like 'abolish%'
and n.out_change = 'abolish'
WHERE isWrong is NULL

select * from load_next_msl where isDone=1