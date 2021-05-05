/*
 * remove type species
 *
 * https://github.com/rusalkaguy/ICTVonlineDbLoad/issues/5
 */
--
-- assess the state of affairs
--

-- LOAD: OK (all NULL)
select 
	t='check load_next_msl.isType', dest_msl_release_num, istype, ct=count(*) 
	, status=(case when istype is null then 'OK - not set' when dest_msl_release_num < 36 then 'OK - pre-MSL36' else '===> ERROR <===' end)
from load_nexT_msl 
group by dest_msl_release_num, istype

-- NODE: OK - fixed 
select top 10
	t='check taxonomy_node.is_ref',
	msl_release_num, is_ref, count(*)
	, status=(case when is_ref=0 then 'OK - not set' when msl_release_num < 36 then 'OK - pre-MSL36' else '===> ERROR <===' end)
from taxonomy_node
--where msl_release_num in (35,36)
group by msl_release_num, is_ref
order by msl_release_num desc, is_ref desc

-- DELTA: needs work (2 non-zero values)
DECLARE @msl int; SET @msl =(select max(msl_release_num) from taxonomy_toc)
select t='taxonomy_node_delta',
	d.is_now_type, ct=count(*)
	,status=(case when is_now_type=0 then 'OK - not set' when n.msl_release_num < 36 then 'OK - pre-MSL36' else '===> ERROR <===' end)
-- select p.taxnode_id, p.is_ref, p.out_change, p.out_notes, '<<PREV', d.*, 'NEXT>>', n.taxnode_id, n.is_ref, n.in_change, n.in_notes
from taxonomy_node_delta  d
join taxonomy_node p  on 
	(p.taxnode_id = d.prev_taxid and p.msl_release_num = @msl-1)
join taxonomy_node n on 
	(n.taxnode_id = d.new_taxid and n.msl_release_num = @msl)
where (n.taxnode_id is not null or p.taxnode_id is not null)
-- for details, use this WHERE-AND with the commented SELECT above
--and (d.is_now_type <> 0 or d.is_now_type is null)
group by d.is_now_type, n.msl_release_num
order by n.msl_release_num desc, abs(d.is_now_type) desc

-- ======================================================================================
--
-- DATA FIXES
--
-- ======================================================================================

update taxonomy_node set
	is_ref = 0
	-- select 'to set to 0: ', ct=count(*), msl_release_num, is_ref
from taxonomy_node
where msl_release_num > 35 
and (is_ref <> 0 or is_ref is null)
group by msl_release_num, is_ref

--
-- rebuild deltas after data fixes
--
-- (also after coding new SP rebuild_delta_nodes)

-- MSL36 1m47s (genome-ws-02)
EXEC [dbo].[rebuild_delta_nodes] NULL -- hits latest MSL automatically.
EXEC [dbo].[rebuild_delta_nodes] 35 -- validate it still works for N-1, where we still honor is_ref/is_type