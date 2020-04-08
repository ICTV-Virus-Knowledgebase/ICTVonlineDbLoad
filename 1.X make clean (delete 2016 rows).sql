--use ictvonlineDEV

--
-- delete MSL a tree for re-loading 
--

declare @target_tree int
declare @prev_tree int
declare @next_tree int
-----------------------------------------------
set @target_tree=2017*10000  --     MSL 32=2017
-----------------------------------------------
set @prev_tree=@target_tree-10000
set @next_tree=@target_tree+10000

--truncate table load_next_msl;

--update taxonomy_node set parent_id = null where tree_id=@target_tree

delete 
 --select * 
from taxonomy_node
where tree_id=@target_tree

update taxonomy_node set
--select *,
	out_change=null
	, out_target=null
	, out_filename=null
	, out_notes=null
from taxonomy_node
where tree_id=@prev_tree
and (
	out_change is not null
	or out_target is not null
	or out_filename is not null
	or out_notes is not null
	)

delete 
--select count(*), 'to be deleted from taxonomy_node_delta'
from taxonomy_node_delta 
where new_taxid between @target_tree and @next_tree-1
or	  prev_taxid between @prev_tree and @target_tree-1

select max(tree_id) from taxonomy_node

--delete from taxonomy_node where taxnode_id=20170000