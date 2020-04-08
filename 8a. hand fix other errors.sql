--
-- the history for 'Apple latent spherical virus' 
-- had no 'new' link. 
--
-- Node was missing in_change, in_filename. 
-- add the in_* and create a delta node. 
--

-- MSL34
--
-- sort in (14,25,28): These were created in same MSL. Move it under Riboviria by hand, and leave it's original NEW/proposal in tact
-- name in Botourmiaviridae, Kitaviridae, Matonaviridae
select report='target list', * from load_next_msl where [sort] in (14,25, 28) or dest_taxnode_id is nULL

select report='before', msl_release_num, lineage, in_change, in_filename , in_target,
	msg=(case when lineage<>in_target then 'ERROR: '+lineage+' <> '+in_target else 'OK' end)
from taxonomy_node
where msl_release_num=(select max(msl_release_num) from taxonomy_toc)
and name in ('Botourmiaviridae', 'Kitaviridae', 'Matonaviridae')


select [PROPOSED CHANGE LIST]='proposed change', *, 
--update taxonomy_node set
	parent_id=(select taxnode_id from taxonomy_node p where p.name='Riboviria' and p.tree_id =taxonomy_node.tree_id)
from taxonomy_node
where msl_release_num=(select max(msl_release_num) from taxonomy_toc)
and name in ('Botourmiaviridae', 'Kitaviridae', 'Matonaviridae')
and lineage not like '%Riboviria%'

select [PROPOSED CHANGE LIST]='proposed change', *, 
--update taxonomy_node set
	in_target=lineage
from taxonomy_node
where msl_release_num=(select max(msl_release_num) from taxonomy_toc)
and name in ('Botourmiaviridae', 'Kitaviridae', 'Matonaviridae')
and in_target not like '%Riboviria%'


select report='after', msl_release_num, lineage, in_change, in_filename , in_target,
	msg=(case when lineage<>in_target then 'ERROR: '+lineage+' <> '+in_target else 'OK' end)
from taxonomy_node
where msl_release_num=(select max(msl_release_num) from taxonomy_toc)
and name in ('Botourmiaviridae', 'Kitaviridae', 'Matonaviridae')


/*
insert into taxonomy_node_delta (new_taxid, proposal, is_new)
select taxnode_id, in_filename, 1
from taxonomy_node
where msl_release_num=22
and name='Apple latent spherical virus'

select * from taxonomy_node_delta
where new_taxid in (select taxnode_id from taxonomy_node
where msl_release_num=22
and name='Apple latent spherical virus'
)
*/
