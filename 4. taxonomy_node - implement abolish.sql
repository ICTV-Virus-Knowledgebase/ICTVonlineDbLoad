--
-- Apply actions from load_new_msl to edit axonomy_node
--

-- 
-- must abolish AFTER moving, or some taxa may not be empty (and thus removable)
--

-- 
-- NTH: abolish
--


--
-- pre-flight check/report
---
begin transaction

select 
	pre_flight='applying '+rtrim(count(*)-count(isWrong))+' abolish actions'
	, isWrong='('+rtrim(count(isWrong))+' other was/were surpressed)'
	, done=rtrim(count(isDone))+' already applied'
	, msg=(case 
		when count(isnull(prev_taxnode_id, isWrong)) <> count(*) then 'ERROR: not all actions have prev_taxnode_id set!!!' 
		else 'ok' 
		end)
from load_next_msl as src 
left outer join taxonomy_node n on n.msl_release_num = src.dest_msl_releasE_num and n.taxnode_id = src.prev_taxnode_id
where 
	(_action = 'abolish')

	update load_next_msl set isdone=null 

--
-- set the proposal and abolish flags on PREV MSL in taxonomy_node
--
update taxonomy_node set
--
-- DEBUG RUN HERE:  select lineage, src.change, 
--
	out_change='abolish'
	,out_filename=src.proposal
	,out_notes = src.change
from taxonomy_node
join load_next_msl src
on  src.prev_taxnode_id = taxonomy_node.taxnode_id
and src._action like 'abolish%'
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
	join load_next_msl src on src.dest_msl_release_num = n.msl_release_num and src._src_taxon_name = n.name 
	where src._action = 'abolish'
	and src.isWrong is null
	order by n.level_id desc , left_idx

	-- describte target
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


-- rollback transaction
-- commit transaction 

select * from load_next_msl where _action='abolish' and  dest_taxnode_id=201901629
