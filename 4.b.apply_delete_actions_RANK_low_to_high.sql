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

select 'post-flight check: check that taxa have been removed'
	, 'load_nexT_msl>>>', sort, _src_lineage, prev_taxnode_id, dest_taxnode_id
	, 'taxonomy_node>>>', taxnode_id, lineage
from load_next_msl 
left outer join taxonomy_node dest on dest.taxnode_id = dest_taxnode_id 
where isWrong is null and _action='abolish' 

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
	UPDATE load_next_msl SET dest_taxnode_id=@TARGET, isDone='abolished'
	WHERE prev_taxnode_id=@PREV_ID
END

--
-- post flight QC
--
select 'post-flight check: check that taxa have been removed'
	, 'load_nexT_msl>>>', sort, _src_lineage, prev_taxnode_id, dest_taxnode_id
	, 'taxonomy_node>>>', taxnode_id, lineage
from load_next_msl 
left outer join taxonomy_node dest on dest.taxnode_id = dest_taxnode_id or (dest.name = _src_taxon_name and dest.msl_release_num = dest_msl_release_num)
where isWrong is null AND _action='abolish' 

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


