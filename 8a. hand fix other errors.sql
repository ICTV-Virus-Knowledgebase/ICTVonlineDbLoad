--
-- the history for 'Apple latent spherical virus' 
-- had no 'new' link. 
--
-- Node was missing in_change, in_filename. 
-- add the in_* and create a delta node. 
--

update taxonomy_node set
--select *, 
	in_change='new'
	, in_filename='2003.P200-204.Cheravirus.pdf'
	, in_target=lineage
from taxonomy_node
where msl_release_num=22
and name='Apple latent spherical virus'
and (in_change is null or in_change <> 'new')

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
