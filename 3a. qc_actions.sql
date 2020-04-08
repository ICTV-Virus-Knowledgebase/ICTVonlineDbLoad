--
-- set load_new_msl.prev_taxnode_id and dest_taxnode_id, dest_ictv_id
--

-- QC
select 
	report='QC change vocabulary'
	, filename
	,src.dest_msl_release_num, src.change
	,_action
	, _action_legal = -- check against official vocab 
	(case when (
		select change from taxonomy_change_in where change=src._action
		union all
		select change from taxonomy_change_out where change=src._action
		) is not null then 'yes' else '!!NO!!' end) 
	-- fix up _action
	,_action_new = (case 
	when [change] like '%merge%' then 'merge' 
	when [change] like 'new%' then 'new' 
	when [change] like 'family%assigned%' then 'move'
	when [change] like '%move%rename%' then 'move'
	when [change] like '%move%' then 'move' 
	when [change] like 'species assign%' then 'move' 
	when [change] like 'assign%' then 'move'
	when [change] like '%rename%' then 'rename'
	when [change] like 'abolish%' then 'abolish'
	else [change] 
    end)
	-- counts
	,row_ct=count(*) 
from load_next_msl src
group by filename, dest_msl_release_num, change, _action


-- summarize after cleanup
select report='action summary', filename, dest_msl_release_num, _action, row_ct=count(*), max_taxid=max(dest_taxnode_id) 
from load_next_msl 
group by filename, dest_msl_release_num, _action
order by filename, dest_msl_release_num, _action

