--
-- set load_new_msl_33.prev_taxnode_id and dest_taxnode_id
--

update load_next_msl_33 set 
--select 	n.lineage, n.taxnode_id, dest._src_taxon_name, dest._action, dest.*,
	prev_taxnode_id = n.taxnode_id
	, dest_taxnode_id = (case when dest._action not in ('new','split') then n.taxnode_id+10000 else dest.dest_taxnode_id end)
from load_next_msl_33 as dest
left outer join taxonomy_node n on
	n.msl_release_num = 32
	and
	n.name=dest._src_taxon_name
where 
dest._action not in ('new', 'split')
and n.taxnode_id is not null
and (dest.prev_taxnode_id is null or dest.prev_taxnode_id <> n.taxnode_id)