--
-- summarize status by rank and action
--

-- summarize change types by rank
select _action, _dest_taxon_rank, count(*)  as tot, count(prev_tax_id) as prev_tax_id, count(isDone) as done
from  load_next_msl_33 msl
left outer join taxonomy_level lvl on lvl.name =msl._dest_taxon_rank
group by _action, _dest_taxon_rank, lvl.id
order by lvl.id , _action 