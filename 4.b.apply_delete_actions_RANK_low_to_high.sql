--
-- Apply actions from load_new_msl to edit axonomy_node
--
begin transaction
-- 
-- must abolish AFTER moving, or some taxa may not be empty (and thus removable)
--

-- 
--  (merge deletions already handled with create actions)
--


--
-- pre-flight check/report
---
select 
	pre_flight='applying '+rtrim(count(*)-count(isWrong))+' abolish actions'
	, isWrong='('+rtrim(count(isWrong))+' other was/were surpressed)'
	, done=rtrim(count(isDone))+' already applied'
	, msg=(case 
		when count(isnull(rtrim(prev_taxnode_id), isWrong)) <> count(*) then 'ERROR: not all actions have prev_taxnode_id set!!!' 
		else 'ok' 
		end)
from load_next_msl as src 
left outer join taxonomy_node n on n.msl_release_num = src.dest_msl_releasE_num and n.taxnode_id = src.prev_taxnode_id
where 
	(_action = 'abolish')

select status_report='in-flight check: abolish order and status '
	, 'load_nexT_msl>>>', sort, _src_taxon_rank,lvl.id,  _src_lineage, prev_taxnode_id, dest_taxnode_id, isDone
	, 'taxonomy_node>>>', dest.taxnode_id, dest.rank, dest.lineage, dest._numKids
from load_next_msl 
left outer join taxonomy_node_names dest on dest.taxnode_id = dest_taxnode_id 
left outer join taxonomy_level lvl on lvl.name = load_next_msl._src_taxon_rank
where isWrong is null and _action='abolish' 
order by lvl.id desc

select qc_report='post-flight check: check that taxa have been removed'
	, 'load_nexT_msl>>>', sort, _src_lineage, prev_taxnode_id, dest_taxnode_id
	, 'taxonomy_node>>>', dest.taxnode_id, dest.rank, dest.lineage, dest._numKids
from load_next_msl 
left outer join taxonomy_node_names dest on dest.taxnode_id = dest_taxnode_id 
where isWrong is null and _action='abolish' 
order by dest.left_idx

select taxnode_id, left_idx, rank, name, lineage
from taxonomy_node_names
where parent_id in (202103641,202108168,202100713,202100540,202107994,202111560,202112877,202112880)
or taxnode_id in   (202103641,202108168,202100713,202100540,202107994,202111560,202112877,202112880)
order by left_idx

select report='why was "droplet-shaed virus" not abolished in Alphaguttavirus genus', * from load_next_msl where _src_taxon_name like '%drop%' or proposal_abbrev like '2021.004A%'

select report='should have been moved', _action, _src_taxon_rank, _src_taxon_name, isDone, proposal, * from load_next_msl where srcgenus in( 'Nevevirus')--,'Pharaohvirus','Refugevirus') order by _src_lineage
--
-- set the proposal and abolish flags on PREV MSL in taxonomy_node
--
update taxonomy_node set
--
-- DEBUG RUN HERE:  select lineage, src.change, '|',out_change, out_filename, out_notes,'>>>',
--
	out_change='abolish'
	,out_filename=src.proposal
	,out_notes = src.change
from taxonomy_node
join load_next_msl src
on  src.prev_taxnode_id = taxonomy_node.taxnode_id
and src._action like 'abolish'
WHERE isWrong is NULL
and out_change is null


--
-- remove nodes from currrent taxonomy from low rank to high rank
--
-- and mark load_next_msl.isDONE=1
DECLARE @rows INT; SET @rows=1
DECLARE @target INT
DECLARE @prev_id INT
DECLARE @msg nvarchar(500)
WHILE(@rows > 0) BEGIN
	-- get next to delete
	-- DEBUG:  DECLARE @target INT; DECLARE @prev_id INT; DECLARE @msg nvarchar(500)
	SELECT TOP 1
		@TARGET=n.taxnode_id, @PREV_ID=src.prev_taxnode_id
	-- DEBUG:   SELECT n.level_id, src._src_taxon_name, src._src_lineage, src.isWrong, in_CURRENT_msl=n.lineage,msl=n.msl_release_num, _numKids, TARGET=n.taxnode_id, PREV_ID=src.prev_taxnode_id
	from taxonomy_node n
	join load_next_msl src 
		on src.dest_msl_release_num = n.msl_release_num 
		and src._src_taxon_name = n.name 
	where src._action = 'abolish'
	and src.isWrong is null
	order by n.level_id desc , left_idx

	-- describe target
	SET @MSG=(select 
		'level='+rtrim(level_id)
		+'; numKids='+rtrim(_numKids)+		(case when _numKids > 0 then ' !!!ERROR:subtaxa!!! ' else '' end)
		+'; lineage='+lineage 
	from taxonomy_node 
	where taxnode_id=@TARGET)
	PRINT 'ABOLISH taxnode_id='+rtrim(@TARGET)+'; '+@MSG
	-- actually delete target
	DELETE from taxonomy_node 
	WHERE taxnode_id = @TARGET
	SET @rows=@@ROWCOUNT -- save this to decide if we're done
	-- mark it as done
	PRINT 'marking done in load_next_msl'
	UPDATE load_next_msl SET dest_taxnode_id=@TARGET, isDone='step 4.b: abolished'
	WHERE prev_taxnode_id=@PREV_ID
END

--
-- post flight QC
--
select 'post-flight check: check that taxa have been removed'
	, 'load_nexT_msl>>>', sort, _src_lineage, prev_taxnode_id, dest_taxnode_id, _src_taxon_rank, _action
	, 'taxonomy_node>>>', dest.taxnode_id, proposal, dest.lineage, dest._numKids
	, 'node_child>>>', c.rank, c.name,c._numKids
from load_next_msl 
left outer join taxonomy_node dest on dest.taxnode_id = dest_taxnode_id or (dest.name = _src_taxon_name and dest.msl_release_num = dest_msl_release_num)
left outer join taxonomy_node_names c on c.msl_release_num = dest.msl_release_num and c.left_idx between dest.left_idx and dest.right_idx
where isWrong is null AND _action='abolish' 
and dest._numKids > 0
order by dest.left_idx
, c.left_idx

select * from taxonomy_node where  parent_id in (202100540,202111560, 202100713, 202100713)  or taxnode_id in (202100540,202100713) order by left_idx
select rank, name, * from taxonomy_node_names  where msl_release_num = 37 and left_idx between 442 and	445 -- Giessenvirus
select * from load_next_msl where species ='Hungariovirus C1302' or srcGenus = 'Giessenvirus'

print '-- REMEMBER TO COMMIT'
select '****** LAST STEP ********'='COMMIT after checking post-flight results'
select 
	report='applying '+rtrim(count(*)-count(isWrong))+' abolish actions'
	, isWrong='('+rtrim(count(isWrong))+' other was/were surpressed)'
	, done=rtrim(count(isDone))+' already applied'
	, msg=(case 
		when count(isnull(rtrim(prev_taxnode_id), isWrong)) <> count(*) then 'ERROR: not all actions have prev_taxnode_id set!!!' 
		else 'ok' 
		end)
from load_next_msl as src 
left outer join taxonomy_node n on n.msl_release_num = src.dest_msl_releasE_num and n.taxnode_id = src.prev_taxnode_id
where 
	(_action = 'abolish')

-- rollback transaction
-- commit transaction 

select [rank], lineage, * from taxonomy_node_names where msl_release_num=37 and lineage like 'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Drexlerviridae;Gyeonggidovirus%'
order by left_idx

select * from load_next_msl where _src_lineage like '%Gyeonggidovirus%'

