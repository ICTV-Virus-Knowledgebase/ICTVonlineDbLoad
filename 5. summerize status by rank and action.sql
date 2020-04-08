--
-- summarize status by rank and action
--

-- summarize change types by action
select _action
	, count(*)  as tot
	, count(prev_taxnode_id) as prev_tax_id
	, count(dest_taxnode_id) as next_tax_id
	, count(isDone) as done
from  load_next_msl_33 msl
group by _action
order by _action 


-- summarize change types by rank
select _action, lvl.id, _dest_taxon_rank
	, count(*)  as tot
	, count(prev_taxnode_id) as prev_tax_id
	, count(dest_taxnode_id) as dest_taxnode_id
	, count(dest_ictv_id) as dest_ictv_id
	, count(isDone) as done
from  load_next_msl_33 msl
left outer join taxonomy_level lvl on lvl.name =msl._dest_taxon_rank
group by _action, _dest_taxon_rank, lvl.id
order by lvl.id , _action 
