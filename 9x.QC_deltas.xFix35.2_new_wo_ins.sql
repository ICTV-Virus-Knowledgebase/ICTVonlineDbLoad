--
-- delta issues: 
-- 
-- 35	ERROR DETAIL: MSL35 tax APPEARS with out a delta record
--
-- taxnode_id	ictv_id		rank	taxon			lineage
-- 201903684	19780010	family	Inoviridae		Monodnaviria;Loebvirae;Hofneiviricota;Faserviricetes;Tubulavirales;Inoviridae
-- +32 others
--
-- ::FIX::
-- problem was that a partial lineage was stored in out_target. 
-- Add _out_target_name and _out_target_parent to taxonomy_node,
-- then changed SP [rebuild_delta_nodes] to use _out_target_name=name to match, 
-- as well as out_target in (name, lineage)


--begin transaction 

select 
	report='load, prev, next details'
	, sep='dest>>', dest.taxnode_id, dest.ictv_id, dest.rank, dest.in_change, dest.in_target, dest.lineage 
	, sep='load>>>'
	, ld._action, ld.rank, prev_taxnode_id
	, sep='prev>>>'
	, prev.taxnode_id, prev.ictv_id, prev.rank, prev.out_change, prev.out_target, prev.lineage 
from taxonomy_node_names dest
left outer join load_next_msl ld on ld.dest_taxnode_id=dest.taxnode_id
left outer join taxonomy_node_names prev on prev.taxnode_id = ld.prev_taxnode_id
where 
	dest.msl_release_num=35
and
	dest.name in  ('Pseudomonas virus Pf1', 'Inoviridae')

-- Add _out_target_name and _out_target_parent to taxonomy_node,
-- then changed SP [rebuild_delta_nodes] to use _out_target_name=name to match, 
-- as well as out_target in (name, lineage)

EXEC [dbo].[rebuild_delta_nodes] NULL -- hits latest MSL automatically.
exec [dbo].[rebuild_node_merge_split]