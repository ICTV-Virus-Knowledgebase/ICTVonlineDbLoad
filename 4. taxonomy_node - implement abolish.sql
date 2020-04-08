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
join load_next_msl_33 src
on  src.prev_tax_id = taxonomy_node.taxnode_id
and src._action='abolish'
and out_change is null

-- mark these changes as done
update load_next_msl_33 set
--select *, 
	isDone = 1
from load_next_msl_33 
join  taxonomy_node as n
on  load_next_msl_33.prev_tax_id = n.taxnode_id
and load_next_msl_33._action='abolish'
and n.out_change = 'abolish'