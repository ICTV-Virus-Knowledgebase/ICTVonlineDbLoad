/*
 *
 * QC - check all actions are implemented
 *
 */
DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)



-- 
-- summary counts by [ACTION]
select 
	report='counts by [ACTION]'
	,action=act.change, prevMSL=prev.ct, load_next_msl=new.ct, nextMSL=dest.ct
	, (case when  isnull(prev.ct,0)+isnull(dest.ct,0) = isnull(new.ct,0) then 'OK' else 'ERROR' end )
from (select change from taxonomy_change_in union select change from taxonomy_change_out) as act
left outer join (
	-- load_next_msl
	select change=_action, ct=count(*), title='load_next_msl', col='_action',  msl=dest_msl_release_num
	from load_next_msl 
	where isWrong is null
	group by dest_msl_release_num, _action 
) as new on new.change = act.change
left outer join (
	-- prev-MSL: out_change
	select  change=out_change, ct=count(*),title='prevMSL.out_action', col='out_change', msl_release_num
	from taxonomy_node_names where msl_release_num=34/*(@msl-1)*/ and out_change is not null
	group by msl_release_num, out_change
) as prev on prev.change = act.change
left outer join (
	-- MSL: in_change DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)
	select change=in_change, ct=count(*), title='currMSL.in_action ', col='in_change=',  msl_release_num
	from taxonomy_node_names where msl_release_num=@msl and in_change is not null
	group by msl_release_num, in_change
) as dest on dest.change = act.change
order by action

--
-- summary counts by [ACTION, RANK]
--
select 
	report='counts by [ACTION, RANK]'
	, action=act.change, rank.name, prevMSL=prev.ct, load_next_msl=new.ct, nextMSL=dest.ct
	, (case when  isnull(prev.ct,0)+isnull(dest.ct,0) = isnull(new.ct,0) then 'OK' else 'ERROR' end )
from (select change from taxonomy_change_in union select change from taxonomy_change_out) as act
join taxonomy_level as rank on 1=1
left outer join (
	-- load_next_msl
	select change=_action, rank, ct=count(*), title='load_next_msl', col='_action',  msl=dest_msl_release_num
	from load_next_msl
	where isWrong is null
	group by dest_msl_release_num, _action, rank
) as new on new.change = act.change and new.rank = rank.name
left outer join (
	-- prev-MSL: out_change
	select  change=out_change, rank, ct=count(*),title='prevMSL.out_action', col='out_change', msl_release_num
	from taxonomy_node_names where msl_release_num=34/*(@msl-1)*/ and out_change is not null
	group by msl_release_num, out_change, rank
) as prev on prev.change = act.change and prev.rank = rank.name
left outer join (
	-- MSL: in_change DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)
	select change=in_change, rank, ct=count(*), title='currMSL.in_action ', col='in_change=',  msl_release_num
	from taxonomy_node_names where msl_release_num=@msl and in_change is not null
	group by msl_release_num, in_change, rank
) as dest on dest.change = act.change and dest.rank = rank.name
where isnull(isnull(prev.ct, new.ct),dest.ct) is not null
order by action, rank.id

--
-- move qc with name check
--
select 
	report='move QC with name check'
	, ERRORS=
		(case when delta._src_taxon_name <> prev.name then 'prev_taxon_name mismatch; ' else '' end )
		+(case when delta._dest_taxon_name <> dest.name then 'dest_taxon_name mismatch; ' else '' end )
		+(case when delta._dest_parent_name <> pdest.name and pdest.level_id <> 100 then 'dest_parent_name mismatch; ' else '' end )
	,prev.taxnode_id, prev.lineage,prev.out_filename, pprev.name, prev.name, prev.out_change
	, '>>'
	, _src_taxon_name, sort, _action
	, x=(case when _src_taxon_name <> _dest_taxon_name then '[rename]' else '' end)
	, delta.rank, isDone, _dest_parent_name, _dest_taxon_name
	, '>>'
	, dest.taxnode_id, dest.in_change, pdest.name, dest.name, dest.lineage
from load_next_msl delta
left outer join taxonomy_node_names prev on prev.taxnode_id = delta.prev_taxnode_id
left outer join taxonomy_node pprev on pprev.taxnode_id = prev.parent_id
left outer join taxonomy_node_names dest on dest.taxnode_id = delta.dest_taxnode_id
left outer join taxonomy_node pdest on pdest.taxnode_id = dest.parent_id
where isWrong is null
AND _action in ('move') --and rank in ('genus')
order by ERRORS desc, rank, prev.left_idx

--
-- details!
-- 
select 
	report='DETAILS per-taxon'
	, prev.taxnode_id, prev.lineage,prev.out_filename, prev.out_change
	, prevMSL='<<'
	, sort, _action, rank, _src_taxon_rank, _dest_taxon_rank, isWrong=isnull(isWrong,'')
	, nextMSL='>>', dest.taxnode_id, dest.in_change, dest.lineage
from load_next_msl
left outer join taxonomy_node prev on prev.taxnode_id = load_nexT_msl.prev_taxnode_id
left outer join taxonomy_node dest on dest.taxnode_id = load_nexT_msl.dest_taxnode_id
where isWrong is null
AND _action in ('move') and rank in ('family')
order by _action, rank, prev.lineage, dest.lineage

select 
	report='TAXONOMY_NODE detals'
	, taxnode_id, level_id, lineage, out_change 
from taxonomy_node where 
--rank='subgenus'and 
msl_release_num=34 and out_change='move'
order by level_id 


--
-- data fixes
--

--
-- ICTV35: double entry: Banyangvirus >> rename>> Bandavirus 
-- This genus gets renamed twice, to the same thing (could be worse – at least the result is consistent).
-- I’ve marked the 2nd rename “isWrong”, so the associated proposal will be “2019.015M.zip” aka “2019.015M.Bandavirus.xlsx”
-- sort=[506,759]
--
update load_next_msl 
set isWrong='Same change already made in sort=506, proposal=2019.015M.Bandavirus.xlsx' 
where sort = 759 and _dest_taxon_name = 'Bandavirus' 
and isWrong is null


update load_next_msl 
set isWrong='Same change already made in sort=165, proposal=2019.005G.Monodnaviria.xlsx' 
where sort = 1016 and _dest_parent_name='Tubulavirales' and _dest_taxon_name = 'Inoviridae' 
and isWrong is null

