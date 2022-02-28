/*
 * add DEMOTE as an acton
 *
 * demote and promote are just MOVE where a change of rank is allowed. 
 */

select 'before', * from taxonomy_change_out
insert into taxonomy_change_out (change) values ('demote')
select 'after adding demote', * from taxonomy_change_out

select 'before', sort, change, _src_taxon_rank, _dest_taxon_rank, _action from  load_next_msl where change like '%demote%'
update load_next_msl set 
	--select sort, change, _src_taxon_rank, _dest_taxon_rank, _action,
	_action = 'demote'
from  load_next_msl
where change like '%demote%' and _action <> 'demote'
select 'after', sort, change, _src_taxon_rank, _dest_taxon_rank, _action from  load_next_msl where change like '%demote%'
