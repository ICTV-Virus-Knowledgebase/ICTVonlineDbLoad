--
-- summarize status by rank and action
--

-- summarize change types by ACTION
select
	report='summarize change types by ACTION'
	,msl=dest_msl_release_num
	, _action
	, count(*)  as tot
	, count(prev_taxnode_id) as prev_tax_id
	, count(dest_taxnode_id) as next_tax_id
	, count(isDone) as done
	, count(isWrong) as isWrong
from  load_next_msl msl
group by dest_msl_release_num, _action
order by _action 


-- summarize change types by RANK
select
	report='summarize change types by RANK'
	,msl=dest_msl_release_num
	,  _action, lvl.id, _dest_taxon_rank
	, count(*)  as tot
	, count(prev_taxnode_id) as prev_tax_id
	, count(dest_taxnode_id) as dest_taxnode_id
	, count(dest_ictv_id) as dest_ictv_id
	, count(isDone) as done
	, count(isWrong) as isWrong
from  load_next_msl msl
left outer join taxonomy_level lvl on lvl.name =msl._dest_taxon_rank
group by dest_msl_release_num,_action, _dest_taxon_rank, lvl.id
order by lvl.id , _action 
