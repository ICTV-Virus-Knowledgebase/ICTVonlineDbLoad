--
-- summarize status by rank and action
--

-- ===============================================================================
-- MSL36 data fixes
-- ===============================================================================

-- sort=66777; blank entry with dest_taxnode_id (verified node doesn't exist in taxonomy_node)
select * from load_next_msl where _action='new' and _dest_taxon_rank is nULL
select* from taxonomy_node where taxnode_id=202009901
update load_next_msl set dest_taxnode_id=NULL, dest_parent_id=NULL, dest_ictv_id=NULL 
where _action='new' and _dest_taxon_rank is nULL 
and isWrong is NOT null 
and dest_taxnode_id is not null -- don't redo

select sort, isWRong from load_next_msl where isWrong like '%blank%'
-- missing dest_ictv_ids : NOT a problem - only reportable if _action="new","split" 
-- MSL36: updated warning code.
select 
	msl._action, msl.prev_taxnode_id, msl.dest_taxnode_id, msl.dest_ictv_id, msl.dest_parent_id, msl.isDone
	,n.taxnode_id, n.ictv_id, n.in_change
from load_next_msl_isok msl
join taxonomy_node n on n.taxnode_id = msl.dest_taxnode_id
where dest_taxnode_id is not null --and dest_ictv_id is null
order by msl._action 


-- ===============================================================================
-- main QC/Summary code
-- ===============================================================================

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
	, status=
		(case when count(*) <> count(isDone) + count(isWrong) then 'tot <> isDone+isWrong; ' else '' end)+
		(case when _action not in ('new') and count(*) <> count(prev_taxnode_id) + count(isWrong) then 'tot <> prev_tax_id+isWrong; ' else '' end)+
		(case when count(*) <> count(dest_taxnode_id) + count(isWrong) then 'tot <> dest_tax_id+isWrong; ' else '' end)
from  load_next_msl msl
group by dest_msl_release_num, _action
order by _action 


-- summarize change types by RANK
select
	report='summarize change types by RANK'
	,msl=dest_msl_release_num
	, rank=isnull(_src_taxon_rank, _dest_taxon_rank)
	,  _action
	, count(isWrong) as isWrong
	, count(*)  as tot
	, count(prev_taxnode_id) as prev_tax_id
	, count(dest_taxnode_id) as dest_taxnode_id
	, count(dest_ictv_id) as dest_ictv_id
	, count(isDone) as done
	, status=
		(case when count(*) <> count(isDone) + count(isWrong) then 'DONE: tot <> isDone+isWrong; ' else '' end)+
		(case when _action not in ('new') and count(*) <> count(prev_taxnode_id) + count(isWrong) then 'PREV: tot <> dest_tax_id+isWrong; ' else '' end)+
		(case when count(*) <> count(dest_taxnode_id) + count(isWrong) then 'DEST: tot <> dest_tax_id+isWrong; ' else '' end)+
		(case when _action  in ('new') and count(*) <> count(dest_ictv_id) + count(isWrong) then 'ICTV_ID: tot <> dest_ictv_id+isWrong; ' else '' end)
from  load_next_msl msl
left outer join taxonomy_level lvl on lvl.name= isnull(_src_taxon_rank, _dest_taxon_rank)
--where msl.isWrong is NULL
group by dest_msl_release_num,_action, isnull(_src_taxon_rank, _dest_taxon_rank), lvl.id
order by lvl.id , _action 

-- x