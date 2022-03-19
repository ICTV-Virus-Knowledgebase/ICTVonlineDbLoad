--
-- SET load_new_msl: dest_TAXNODE_id, dest_ICTV_id and dest_PARENT_id 
--
-- scan both taxa in taxonomy_node(new MSL) and load_next_msl(new, split and renamed) things. 
--
--
-- this must happen after 
--  * prev MSL is copied to create new one
--  * load_next_msl is loaded
-- and before we start applying changes
--

BEGIN TRANSACTION
-- COMMIT TRANSACTION

-- --------------------------------
-- Data Fixes 
-- --------------------------------

-- MSL37
-- they added spceies [Doupovirus australiaense], but forgot to add genus [Doupovirus]
insert into load_next_msl (
	filename
	,sort
	,proposal_abbrev, proposal, spreadsheet
	, realm, kingdom, phylum, subphylum, class, [order], family
	, genus
	, molecule, change
	, rank
	, _action
	,dest_taxnode_id
	,dest_ictv_id
	,dest_parent_id
	,[comments]
)
select 
	filename
	, sort=sort +0.5
	,proposal_abbrev, proposal, spreadsheet
	, realm, kingdom, phylum, subphylum, class, [order], family
	, genus
	, molecule=NULL, change
	, rank='genus'
	, _action
	,dest_taxnode_id=(select max(dest_taxnode_id)+1 from load_next_msl)
	,dest_ictv_id=(select max(dest_taxnode_id)+1 from load_next_msl)
	,dest_parent_id=(select taxnode_id from taxonomy_node n where n.name='Xinmoviridae' and n.msl_release_num = load_next_msl.dest_msl_release_num)
	,[comments]='Missing from MSL summary sheet. Added by CurtisH in load_next_msl using 3.c.load_next_msl-set-dest_taxnode_id-dest_parent_id.sql'
 from load_next_msl 
 where _dest_taxon_name = 'Doupovirus australiaense'
 and not exists (select * from load_next_msl e where e.genus =load_next_msl.genus)
 -- now go re-run "set parent" update and QC
 
 select 'Check Doupovirus creation', * from load_next_msl where genus='Doupovirus'
 select 'Check Doupovirus parent', * from taxonomy_node where taxnode_id = 202106259
-- --------------------------------
-- WORK
-- --------------------------------


DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)
DECLARE @tree_id int; SET @tree_id=(select tree_id from taxonomy_toc where msl_release_num=@msl)
DECLARE @next_taxnode_id int; SET @next_taxnode_id = (select max(taxnode_id+1) from taxonomy_node where msl_release_num=@msl)

PRINT 'set tree_id '+rtrim(@tree_id)+' and msl_release_num '+rtrim(@msl)+'; next taxnode_id='+rtrim(@next_taxnode_id)

PRINT ''
PRINT 'Starting taxnode ID: '+rtrim(@next_taxnode_id)

-- cursor to assign IDs?

SET NOCOUNT ON
DECLARE @dest_taxnode_id int
DECLARE @dest_ictv_id int
DECLARE @msg nvarchar(200)

DECLARE UP_CURSOR CURSOR FOR
	SELECT @dest_taxnode_id, @dest_ictv_id 
	FROM load_next_msl 
	WHERE isWrong is null 
	AND dest_taxnode_id is null 
	AND _action in ('new', 'split') 
	-- if a split still contains it's original name, don't give that one a new taxnode/ictv
	AND not (_action = 'split' and _src_taxon_name = _dest_taxon_name)
	FOR UPDATE OF dest_taxnode_id, dest_ictv_id
OPEN UP_CURSOR
FETCH NEXT FROM UP_CURSOR INTO @dest_taxnode_id, @dest_ictv_id

WHILE(@@FETCH_STATUS=0)
BEGIN
	-- set ID
	UPDATE load_next_msl SET dest_taxnode_id = @next_taxnode_id, dest_ictv_id = @next_taxnode_id WHERE CURRENT OF UP_CURSOR

	-- report
	--SET MSG=(select '_action='+_action+'; rank='+rank+'; lineage='+dest_lineage from load_next_msl where dest_taxnode_id 
	--PRINT 
	-- NEXT
	SET @next_taxnode_id =@next_taxnode_id + 1
	FETCH NEXT FROM UP_CURSOR INTO @dest_taxnode_id, @dest_ictv_id
END

CLOSE UP_CURSOR
DEALLOCATE UP_CURSOR

SET NOCOUNT OFF

--
-- replicate that into next_ictv_id
--
update load_next_msl set
--select 
	dest_ictv_id=dest_taxnode_id
from load_next_msl
where isWrong is null 
AND _action in ('new','split')
AND not (_action = 'split' and _src_taxon_name = _dest_taxon_name)
and dest_ictv_id is NULL

-- -------------------------------------------------------------------------------------------------------------
-- assign dest_parent_id
-- -------------------------------------------------------------------------------------------------------------

--
-- things that already exist
--
UPDATE load_next_msl SET dest_parent_id=targ.taxnode_id
-- SELECT
--	load_next_msl.sort, load_next_msl._action, load_next_msl._dest_taxon_rank, load_next_msl.rank, load_next_msl._dest_lineage, load_next_msl._dest_parent_name, load_next_msl._dest_taxon_name
--	, _dest_taxon_name, dest_parent_id = targ.taxnode_id, targ.lineage, targ.level_id
FROM load_next_msl
JOIN taxonomy_node targ 
	ON targ.msl_release_num = load_next_msl.dest_msl_release_num 
	AND (
		targ.name = load_next_msl._dest_parent_name  
		OR  
		(targ.level_id=100/*root*/ and load_next_msl._dest_parent_name=''/*root*/)
	)
where isWrong is NULL
and _action in ('new', 'split', 'move','promote','rename')
and load_next_msl.dest_parent_id is null
-- END UPDATE
--order by targ.level_id

select * from taxonomy_change_in
select * from taxonomy_change_out

--
-- things that will exist
--
UPDATE load_next_msl SET dest_parent_id=targ.dest_taxnode_id
--SELECT 
--	load_next_msl.sort, load_next_msl._action, load_next_msl._dest_taxon_rank, load_next_msl.rank, load_next_msl._dest_lineage, load_next_msl._dest_parent_name, load_next_msl._dest_taxon_name
--	, targ_action=targ._action, dest_parent_id = targ.dest_taxnode_id, targ._dest_lineage, targ._dest_taxon_rank
FROM load_next_msl
JOIN load_next_msl targ 
	ON targ.dest_msl_release_num = load_next_msl.dest_msl_release_num 
	AND targ._dest_taxon_name = load_next_msl._dest_parent_name 
	AND targ.dest_taxnodE_id is not null
where load_next_msl.isWrong is NULL and targ.isWrong is NULL 
and load_next_msl._action in ('new', 'split', 'move', 'promote','rename')
and load_next_msl.dest_parent_id is null
-- END UPDATE 
-- order by targ._dest_taxon_rank

--
-- show what we did
--
SELECT report='Split actions', _action, rank, _src_lineage, prev_taxnode_id, _dest_lineage, dest_parent_id, dest_taxnode_id, dest_ictv_id FROM load_next_msl where isWrong is null and  _action in ('split')

-- --------------------------------
-- QC 
-- --------------------------------

select 
	ERROR_report='actions that should have dest_parent_id set, but do NOT'
	,load_next_msl.sort, load_next_msl._action, load_next_msl._dest_taxon_rank, load_next_msl.rank, load_next_msl._dest_lineage, load_next_msl._dest_parent_name, load_next_msl._dest_taxon_name
	, dest_taxnode_id, dest_parent_id, dest_ictv_id
from load_next_msl where isWrong is null and dest_parent_id is null and _action not in ('abolish', 'rename', 'merge','rename')

/*
 * QC
 */
select report='Non-NULL count by action class'
	, _action
	, tot_ct=count(*)
	, [0=>]=(case when _action='new' and count(prev_taxnode_id)=0 then 'ok' when count(*)<>count(prev_taxnode_id) then '!!ERROR!!' else 'ok' end)
	, prev_taxnode_id=count(prev_taxnode_id) 
	, [1=>]=(case when count(*)<>count(dest_taxnode_id) then '!!ERROR!!' else 'ok' end)
	, dest_taxnode_id=count(dest_taxnode_id) 
	, [2=>]=(case when _action='abolish' and count(dest_parent_id)=0 then 'ok' when count(*)<>count(dest_parent_id) then '!!ERROR!!' else 'ok' end)
	, dest_parent_id=count(dest_parent_id) 
from load_next_msl 
--where isWrong is null
group by _action

/* 
 --
 -- ad hoc research query - find taxon in both tables
 --

DECLARE @targ varchar(50); SET @targ='Cofodevirus'
select t='taxonomy_node', * from taxonomy_node where name like @targ order by msl_release_num desc
select t='load_next_msl', * from load_next_msl where _dest_taxon_name like @targ
*/

--ROLLBACK TRANSACTION
--COMMIT TRANSACTION

