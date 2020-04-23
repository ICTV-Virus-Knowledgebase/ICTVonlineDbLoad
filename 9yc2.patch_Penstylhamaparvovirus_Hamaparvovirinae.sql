/*
 * move genus 'Penstylhamaparvovirus' into subfamily 'Hamaparvovirinae'
 *
*

From: Lefkowitz, Elliot J <elliotl@uab.edu> 
Sent: Thursday, April 23, 2020 12:29 PM
To: Hendrickson, Curtis (Campus) <curtish@uab.edu>
Cc: Roland.Zell@med.uni-jena.de
Subject: Re: Parvoviridae taxonomy Last MSL 35 Change!

Hi Curtis,

Please move the genus, Penstylhamaparvovirus into the subfamily Hamaparvovirinae. Then regenerate the MSL and send me the code to fix the genus in production. 

This will then represent v1 of MSL35. Any additional changes will have to wait for v2. 

Elliot


*/

--begin transaction 

select report='prev MSL', * from taxonomy_node where taxnode_id=201854231

select report='cur MSL', * 
from taxonomy_node 
where msl_release_num = 35
and name in (
	'Penstylhamaparvovirus')
order by left_idx

update node  set 
--select node.taxnode_id, node.parent_id, node.level_id, msl=node.msl_release_num, node.lineage, node.in_change, node.in_filename, node.in_notes, node.in_target, upd='>>>', new_parent_lineage=parent.lineage,
	parent_id = parent.taxnode_id
from taxonomy_node node
join taxonomy_node parent on parent.msl_release_num = node.msl_release_num
where node.msl_release_num = 35
and node.name in ( 'Penstylhamaparvovirus')
and parent.name = 'Hamaparvovirinae'
and node.parent_id <> parent.taxnode_id

-- 
-- update out_target
--
update prevMSL set 
--select taxnode_id, level_id, lineage, out_change, out_target, 
	out_change='move',
	out_target = (select lineage from taxonomy_node node where node.msl_release_num=35 and node.name='Penstylhamaparvovirus')
from taxonomy_node prevMSL
where taxnode_id = 201854231
and out_change <> 'move'
--
-- check deltas
--
select * from taxonomy_node_dx where msl_release_num=35 and name='Penstylhamaparvovirus'

-- commit transaction

exec rebuild_delta_nodes
--exec rebuild_node_merge_split