/*
 *
 * QC - check all actions are implemented
 *
 */
DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)

--
-- summary counts
--
-- MSL-1: out_change
select action=act.change, prevMSL=prev.ct, load_next_msl=new.ct, nextMSL=dest.ct
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
	from taxonomy_node where msl_release_num=(@msl-1) and out_change is not null
	group by msl_release_num, out_change
) as prev on prev.change = act.change
left outer join (
	-- MSL: in_change DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)
	select change=in_change, ct=count(*), title='currMSL.in_action ', col='in_change=',  msl_release_num
	from taxonomy_node where msl_release_num=@msl and in_change is not null
	group by msl_release_num, in_change
) as dest on dest.change = act.change
order by action



--
--

select prev.taxnode_id, prev.lineage,prev.out_change, '>>', sort, _action, rank, '>>', dest.taxnode_id, dest.in_change, dest.lineage
from load_next_msl
left outer join taxonomy_node prev on prev.taxnode_id = load_nexT_msl.prev_taxnode_id
left outer join taxonomy_node dest on dest.taxnode_id = load_nexT_msl.dest_taxnode_id
where isWrong is null
AND _action in ('move')
order by _action
