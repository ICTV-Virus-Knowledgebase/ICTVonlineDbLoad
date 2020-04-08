--
-- set next_level_id
--

update load_next_msl_33 set
--select *,
	dest_level_id=lvl.id
from load_next_msl_33
join taxonomy_level lvl on lvl.name = _dest_taxon_rank
--where dest_level_id is null or dest_level_id<>lvl.id