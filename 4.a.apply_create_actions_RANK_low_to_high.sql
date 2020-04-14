/* --------------------------------------------------
 *
 * apply changes [load_next_msl] => [taxonomy_node]
 * ACTIONS: NEW, SPLIT, MOVE, RENAME 
 * ORDER: high to low rank
 *
 * ---------------------------------------------------*/
 /* to fix
  -- MOVE (+rename+isType) @ order  (niether skipped nor rows changed)
  -- MOVE (+rename+isType) @ family
  -- MOVE (+rename+isType) @ genus
  -- MOVE (+rename+isType) @ subgenus
  -- MOVE (+rename+isType) @ species
  */
 select 'todo', _action, count(*)
 from load_next_msl 
 group by _action 


BEGIN TRANSACTION
-- COMMIT TRANSACTION


 -- 
 -- data fixes (splits with same name were not exempted from getting new taxnode/ictv ids)
 --
 update load_next_msl set dest_taxnode_id=dest.taxnode_id, dest_ictv_id=dest.ictv_id
 -- select sort,_src_lineage, rank, _action, _dest_lineage, dest_taxnode_id, dest_ictv_id, taxnode_id, ictv_id, lineage
 from load_next_msl
 join taxonomy_node dest on dest.msl_release_num=dest_msl_release_num and dest.name = _dest_taxon_name 
 where isWrong is null 
 and _action='split' and _src_taxon_name = _dest_taxon_name
 and (dest_taxnode_id<>dest.taxnode_id OR  dest_ictv_id<>dest.ictv_id)


-- =======================================================================================
-- ITERATE over RANKS (top to bottom
-- =======================================================================================


DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)
DECLARE @tree_id int; SET @tree_id=(select tree_id from taxonomy_toc where msl_release_num=@msl)


PRINT 'set tree_id '+rtrim(@tree_id)+' and msl_release_num '+rtrim(@msl)

-- cursor to assign IDs?

SET NOCOUNT ON
DECLARE @level_id int; 
DECLARE @rank varchar(50); 
DECLARE @msg nvarchar(200)
DECLARE @count int

DECLARE UP_CURSOR CURSOR FOR
SELECT id, name FROM taxonomy_level WHERE id>100/*tree*/ ORDER BY id -- FOR UPDATE OF dest_taxnode_id, dest_ictv_id
OPEN UP_CURSOR
FETCH NEXT FROM UP_CURSOR INTO @level_id, @rank

WHILE(@@FETCH_STATUS=0)
BEGIN
	-- do update 
	--UPDATE load_next_msl SET dest_taxnode_id = @next_taxnode_id, dest_ictv_id = @next_taxnode_id WHERE CURRENT OF UP_CURSOR

	PRINT '-- ##############################################################################'
	PRINT '-- ## '+@rank+' ('+rtrim(@level_id)+')'
	PRINT '-- ##############################################################################'
	-- DEBUG:
	-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='species';
	print '-- -----------------------------------------------------------------------------'
	PRINT '-- RENAME @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*) 
	FROM load_next_msl where isWrong is null AND _action='rename' AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No actions for rank '+@rank
	END ELSE BEGIN

		-- change current name
		UPDATE taxonomy_node SET 
			name=src._dest_taxon_name
			,is_ref = isnull(src.isType,taxonomy_node.is_ref)
			-- metadata 
			,genbank_accession_csv	= isnull(src.exemplarAccessions,genbank_accession_csv)
			,abbrev_csv				= isnull(src.abbrev, abbrev_csv)
			,isolate_csv			= isnull(src.exemplarIsolate, isolate_csv)
			,molecule_id			= isnull(destMol.id, molecule_id)
		--SELECT taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name
		FROM taxonomy_node 
		JOIN load_next_msl src on isWrong is null AND src.dest_taxnode_id = taxonomy_node.taxnode_id
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE src._action='rename'	
		and level_id = @level_id


		-- update prev msl
		UPDATE taxonomy_node SET 
		--SELECT taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name,
			out_change = _action
			, out_target = src._dest_taxon_name
			, out_filename = proposal
			, out_notes = spreadsheet
		FROM taxonomy_node 
		JOIN load_next_msl src on isWrong is null AND src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src._action='rename'	
		and level_id = @level_id

		-- record completion
		UPDATE load_next_msl SET isDONE='4.a.apply_create_actions'
		FROM load_next_msl src 
		JOIN taxonomy_node on src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src.isWrong is null AND src._action='rename'	
		and level_id = @level_id
	END 

	-- DEBUG:
	-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='subfamily';
	print '-- -----------------------------------------------------------------------------'
	PRINT '-- NEW/SPLIT @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*) 
	FROM load_next_msl where isWrong is null AND _action in ('new') AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No actions for rank '+@rank
	END ELSE BEGIN

		-- insert new row
		INSERT INTO taxonomy_node (
			taxnode_id
			,tree_id
			,parent_id
			,name
			,level_id
			,is_ref
			,ictv_id
			,msl_release_num
			, in_change, in_filename, in_notes, in_target
			--out_change, out_filename, out_notes
			,genbank_accession_csv 
			,abbrev_csv
			,isolate_csv
			,molecule_id
		) 
		select 
			--src.src_out_change, -- debug
			taxnode_id = src.dest_taxnode_id
			, tree_id = (select tree_id from taxonomy_toc where msl_release_num = src.dest_msl_release_num)
			-- parent nodes already inserted into taxonomy_node
			, parent_id = src.dest_parent_id
			-- assume it's a lineage, and get what's after the last semi-colon
			, name = _dest_taxon_name
			,level_id = rank.id
			,is_ref = isnull(src.isType,0)
			,ictv_id = src.dest_ictv_id
			,msl_release_num = src.dest_msl_release_num
			-- change linker
			,in_change = src._action
			,in_filename = src.proposal
			,in_notes = src.spreadsheet
			,in_target = src._src_taxon_name
			-- metadata 
			,genbank_accession_csv = src.exemplarAccessions
			,abbrev_csv=src.abbrev
			,isolate_csv=src.exemplarIsolate
			,molecule_id=destMol.id
		from load_next_msl as src
		-- parent
		left outer join taxonomy_level rank on rank.name = src._dest_taxon_rank
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE (
			(_action like 'new')-- or src.src_out_change in ('promote')) )
			or
			(_action like 'split' AND _src_taxon_name <> _dest_taxon_name)
		) 
		AND _dest_taxon_rank = @rank
		AND
			-- reentrant: skip ones already inserted
			(src.dest_taxnode_id NOT in (select n.taxnode_id from taxonomy_node as n where n.msl_release_num = src.dest_msl_release_num))
		ORDER BY level_id, _dest_taxon_name

		-- split where name is same - just set in_*
		update taxonomy_node set
			-- change linker
			in_change = src._action
			,in_filename = src.proposal
			,in_notes = src.spreadsheet
			,in_target = src._src_taxon_name
			-- metadata 
			,genbank_accession_csv = src.exemplarAccessions
			,abbrev_csv=src.abbrev
			,isolate_csv=src.exemplarIsolate
			,molecule_id=destMol.id			
		from taxonomy_node 
		join load_next_msl as src on taxonomy_node.taxnode_id = src.dest_taxnode_id
		left outer join taxonomy_level rank on rank.name = src._dest_taxon_rank
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE (
			(_action like 'split' AND _src_taxon_name = _dest_taxon_name)
		) 
		AND _dest_taxon_rank = @rank
		AND
			-- reentrant: skip ones already inserted
			(src.dest_taxnode_id NOT in (select n.taxnode_id from taxonomy_node as n where n.msl_release_num = src.dest_msl_release_num))


		print '-- record completion'
		UPDATE load_next_msl SET isDONE='4.a.apply_create_actions'
		-- select src.*
		FROM load_next_msl src 
		JOIN taxonomy_node on src.dest_taxnode_id = taxonomy_node.taxnode_id
		WHERE src.isWrong is null AND src._action in ('new', 'split')	
		AND _dest_taxon_rank = @rank
		AND
			-- check inserted
			(src.dest_taxnode_id in (select n.taxnode_id from taxonomy_node as n where n.msl_release_num = src.dest_msl_release_num))
	END
	
	-- DEBUG:
	-- DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='genus';
	print '-- -----------------------------------------------------------------------------'
	PRINT '-- MOVE (+rename+isType) @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*) 
	FROM load_next_msl where isWrong is null AND _action='move' AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No actions for rank '+@rank
	END ELSE BEGIN

		-- change current name and parent 
		UPDATE taxonomy_node SET 
		--SELECT 'cur_msl',taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name,
			parent_id=src.dest_parent_id
			, name=src._dest_taxon_name
			,is_ref = isnull(src.isType,taxonomy_node.is_ref)
			-- metadata 
			,genbank_accession_csv = src.exemplarAccessions
			,abbrev_csv=src.abbrev
			,isolate_csv=src.exemplarIsolate
			,molecule_id=destMol.id
		FROM taxonomy_node 
		JOIN load_next_msl src on isWrong is null AND src.dest_taxnode_id = taxonomy_node.taxnode_id
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE src._action='move'	
		and level_id = @level_id


		-- update prev msl
		-- SELECT 'prev_msl',-- 
		UPDATE taxonomy_node SET 
		--SELECT 'prev_msl',sort, taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name,
			out_change = _action
			, out_target = dest.lineage
			, out_filename = proposal
			, out_notes = spreadsheet
		FROM taxonomy_node 
		JOIN load_next_msl src on isWrong is null AND src.prev_taxnode_id = taxonomy_node.taxnode_id
		JOIN taxonomy_node dest on dest.taxnode_id = src.dest_taxnodE_id
		WHERE src._action='move'	
		and src.sort=13
		and taxonomy_node.level_id = @level_id

		-- record completion
		UPDATE load_next_msl SET isDONE='4.a.apply_create_actions'
		FROM load_next_msl src 
		JOIN taxonomy_node on src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src.isWrong is null AND src._action='rename'	
		and level_id = @level_id

	ENd
	
	-- DEBUG:
	-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='species';
	print '-- -----------------------------------------------------------------------------'
	PRINT '-- MERGE @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*) 
	FROM load_next_msl where isWrong is null AND _action='merge' AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No actions for rank '+@rank
	END ELSE BEGIN

		-- when MSL created, included this taxon, so remove the copy in the current MSL
		-- *since it will be merged and no longer exist)
		DELETE FROM taxonomy_node 
		--SELECT a='DELETE',_action, taxonomy_node.taxnode_id, taxonomy_node.lineage, src._src_taxon_name, new_name=src._dest_taxon_name, prev_taxnode_id=src.prev_taxnode_id, isWrong
		FROM taxonomy_node 
		JOIN load_next_msl src on isWrong is null AND msl_releasE_num = src.dest_msl_releasE_num AND src._src_taxon_name = taxonomy_node.name 
		WHERE src._action='merge'	
		and level_id = @level_id


		-- update prev msl
		UPDATE taxonomy_node SET 
		--SELECT taxonomy_node.taxnode_id, taxonomy_node.lineage, '|'+_action+'|', _dest_taxon_rank, new_name=src._dest_taxon_name,
			out_change = _action
			, out_target = src._dest_taxon_name
			, out_filename = proposal
			, out_notes = spreadsheet
		FROM taxonomy_node 
		JOIN load_next_msl src on src.isWrong is null AND src.prev_taxnode_id = taxonomy_node.taxnode_id
		where src._action='merge'	
		and level_id = @level_id
		AND (
			out_target is null or out_target <> src._dest_taxon_name
		)

		-- record completion
		UPDATE load_next_msl SET 
		--SELECT _action, _src_lineage, rank, _dest_lineage, 	
			isDONE='4.a.apply_create_actions'
		FROM load_next_msl src 
		JOIN taxonomy_node on src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src.isWrong is null AND src._action='merge'	
		and level_id = @level_id
		and isDONE is null
	END 


	FETCH NEXT FROM UP_CURSOR INTO @level_id, @rank
END

CLOSE UP_CURSOR
DEALLOCATE UP_CURSOR

SET NOCOUNT OFF

--
-- report on changes implemented
--

-- DEBUG DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)
select title='prevMSL.out_action', msl_release_num, out_change, ct=count(*)
from taxonomy_node where msl_release_num=(@msl-1) and out_change is not null
group by msl_release_num, out_change
union 
select title='currMSL.in_action ', msl_release_num, in_change, ct=count(*)
from taxonomy_node where msl_release_num=@msl and in_change is not null
group by msl_release_num, in_change



--rollback transaction


