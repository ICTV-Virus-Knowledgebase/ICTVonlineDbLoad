/*
 * move 4 genera into family 'Rhabdoviridae'
 *
	 Barhavirus
	Lostrhavirus
	Sawgrhavirus
	Zarhavirus
*
*
From: Lefkowitz, Elliot J <elliotl@uab.edu>
Sent: Wednesday, 22 April 2020 11:05 AM
To: Peter Walker <peter.walker@uq.edu.au>
Cc: Kuhn, Jens (NIH/NIAID) [C] <kuhnjens@niaid.nih.gov>
Subject: Re: MSL#35 
 
Peter,

The problem is with the spreadsheet. For the new genus Mousrhavirus and Moussa mousrhavirus, the spreadsheet specifies that they belong in the family Rhabdoviridae. For all other taxa, no higher rank is specified, therefore that is where they were placed, unassigned to any higher rank.

Elliot

*/

--begin transaction 


select * 
from taxonomy_node 
where msl_release_num = 35
and name in (
	'Mousrhavirus' -- was put in the right place - pattern for filename
	, 	 'Barhavirus',
	'Lostrhavirus',
	'Sawgrhavirus',
	'Zarhavirus')
order by left_idx

select taxnode_id, parent_id, level_id, msl=msl_release_num, lineage, in_change, in_filename, in_notes, in_target,
--update taxonomy_node set 
	parent_id = (select taxnode_id from taxonomy_node where msl_release_num=35 and name ='Rhabdoviridae')
from taxonomy_node
where msl_release_num = 35
and name in (
 	 'Barhavirus',
	'Lostrhavirus',
	'Sawgrhavirus',
	'Zarhavirus')
and parent_id = tree_id


-- commit transaction

exec rebuild_delta_nodes
exec rebuild_node_merge_split