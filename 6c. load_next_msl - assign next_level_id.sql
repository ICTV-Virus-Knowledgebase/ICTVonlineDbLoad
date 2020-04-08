--
-- set next_level_id
--

update load_next_msl set
--select  MSG=(case when [rank] <> [_dest_taxon_rank] then 'ERROR' else '' end), [sort], [rank], _dest_taxon_rank, lvl.name, change,  *,
	dest_level_id=lvl.id
from load_next_msl
join taxonomy_level lvl on lvl.name = _dest_taxon_rank
where isWrong is NULL AND
(
	[rank] <> lvl.name
	or 
	[rank] <> [_dest_taxon_rank]
	or 
	(dest_level_id is null or dest_level_id<>lvl.id)
)

select * from load_next_msl where dest_level_id is null