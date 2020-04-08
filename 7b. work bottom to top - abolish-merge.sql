--
-- work from top to bottom rank - abolishing things
--
-- when we created the new MSL tree, we copied everything, 
-- so we now need to PRUNE the abolished nodes. 
-- and mark their  previous-year versions with an out_change='abolish'
--
BEGIN TRANSACTION

--commit transaction
--ROLLBACK TRANSACTION
DECLARE @level_id int
DECLARE @level varchar(50)
DECLARE @ct varchar(50)

DECLARE foreach_cursor SCROLL CURSOR FOR 
	SELECT 
		id, name
	FROM taxonomy_level as src
	WHERE name in (
		select _src_taxon_rank 
		from load_next_msl as msl
		 where isWrong is NULL
		AND _action in ('abolish')
	)
	--AND id between 101 and 199 -- tree to subphylum - only NEW's
	--AND id = 200 -- order : first assign node
	--AND id between 201 and 300 --suborder and family
	--AND id > 300 -- subfamily and below. 
	--AND id > 100 -- everything
	ORDER BY id ASC

OPEN foreach_cursor
FETCH NEXT FROM foreach_cursor INTO @level_id, @level
WHILE @@FETCH_STATUS = 0 BEGIN
	-- WORK

	print '##################################################'
	print '## MERGE taxa'
	print '##################################################'
	--

	-- total taxa
	--  DECLARE @level nvarchar(50); SET @level='species'; DECLARE  @ct varchar(10) -- debug
	select @ct=rtrim(count(*)) from load_next_msl where _src_taxon_rank=@level and _action   in ('merge')
	PRINT '####### MERGE rank='+ @level + '; n='+rtrim(@ct)+' #####################################'	


	print ''
	print '##'
 	PRINT '### pre-MERGE check'
	print '##'
	--  DECLARE @level nvarchar(50); SET @level='species'; DECLARE  @ct varchar(10) -- debug
	select 
		MESG=
			(case when nNew.right_idx -nNew.left_idx > 1 then 'WARNING - might have children; ' else '' end)
			+(case when nOld.taxnode_id is NULL then 'ERROR: could not find in prev MSL; ' else '' end)
			+(case when nNew.taxnode_id is NULL then 'ERROR: could not find in current MSL; ' else '' end)
			+(case when pNew.taxnode_id is NULL then 'ERROR: could not find PARENT "'+ld._dest_parent_name+' in current MSL' else '' end)+
			+ 'OK'
		,step='pre-merge check'
		, ld._src_taxon_rank --, ld.dest_level_id, ld._dest_taxon_rank
		,ld._src_taxon_name,ld._src_lineage, ld.change
		, nOld.taxnode_id, nOld.lineage, nOld.out_change, oldRightLeftDelta=nOld.right_idx -nOld.left_idx
		, nNew.taxnode_id, nNew.lineage , newRightLeftDelta=nNew.right_idx -nNew.left_idx
		-- parent match in currrent MSL
		, newParent=pNew.lineage
	 from load_next_msl ld
	 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
	 left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
	 left outer join  taxonomy_node pNew on pNew.msl_release_num = ld.dest_msl_release_num and pNew.name = ld._dest_parent_name
	 left outer join  taxonomy_node nOld on nOld.msl_release_num = ld.dest_msl_release_num-1 and nOld.name = ld._src_taxon_name
	 where ld._action in ('merge') and  _src_taxon_rank = @level

	
	 print ''
	 print '##'
	 PRINT '## WORK: CURR MSL: delete ALL-BUT-ONE of the merged taxa from (keep one with matching/oldest ictv_id)'
	 print '##'
	 delete 
	 --  DECLARE @level nvarchar(50); SET @level='species'; DECLARE  @ct varchar(10); select *  -- debug
	 from taxonomy_node
	 where taxnode_id in (
		select 
			nNew.taxnode_id
		 from load_next_msl ld
		 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
		 left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
		 where ld._action in ('merge') and  _src_taxon_rank = @level
		 -- delete all but the one with the matching ictv_id, which will be the merge target
		 AND ld.dest_ictv_id <> nNew.ictv_id
	 )

	 print ''
	 print '##'
	 PRINT '## PREP: set DEST parent_id'
	 print '##'
	 --DECLARE @level nvarchar(50); SET @level='species';
	 update load_next_msl set 
	 --DECLARE @level nvarchar(50); SET @level='species'; select ld.dest_ictv_id, n.ictv_id, ld._dest_lineage, ld._dest_parent_name, p.lineage, -- debug
	 	dest_parent_id = p.taxnode_id
	 from load_next_msl ld
	 join taxonomy_node n on n.msl_release_num = ld.dest_msl_release_num AND n.taxnode_id = ld.dest_taxnode_id
	 join taxonomy_node p on p.msl_release_num = ld.dest_msl_release_num AND p.name = ld._dest_parent_name
	 where ld._action in ('merge') and  ld._src_taxon_rank = @level
	 and ld.dest_parent_id <> p.taxnode_id or ld.dest_parent_id is null
	
	
	 --
	 PRINT '## WORK: CURR MSL: update THERE-CAN-ONLY-BE-ONE of the merged taxa with new info'
	 --
	 --  DECLARE @level nvarchar(50); SET @level='species'; select taxonomy_node.msl_release_num, taxonomy_node.taxnode_id, taxonomy_node.lineage, ictv_id, ld._dest_parent_name,-- debug
	 update taxonomy_node set 
		name = ld._dest_taxon_name,
		parent_id = ld.dest_parent_id,
		level_id = ld.dest_level_id -- in case we merge species to make a genus!
	 from taxonomy_node
	 join   load_next_msl ld 
	 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
	 on taxonomy_node.msl_release_num = ld.dest_msl_release_num 
	 and taxonomy_node.taxnode_id = ld.dest_taxnode_id 
	 and taxonomy_node.ictv_id = ld.dest_ictv_id
	 and taxonomy_node.name = ld._src_taxon_name
	 where ld._action in ('merge') and  ld._src_taxon_rank = @level
	

	 print ''
	 print '##'
	 PRINT '## WORK: set the out_change on the PREV MSL'
	 print '##'
	 --  DECLARE @level nvarchar(50); SET @level='species';  -- debug
	 update taxonomy_node set -- comment out this line to debug/select
	 --  DECLARE @level nvarchar(50); SET @level='species'; select  taxnode_id, lineage, out_change, out_target, out_filename, out_notes, changes_to='>>>>', -- debug
		out_change='merge'
		, out_target = ld._dest_lineage
		, out_filename = ld.proposal
		, out_notes = ld.change
	 from taxonomy_node
	 join   load_next_msl ld 
	 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
	 on taxonomy_node.msl_release_num = ld.dest_msl_release_num-1 and taxonomy_node.name = ld._src_taxon_name
	 where ld._action in ('merge') and  ld._src_taxon_rank = @level


	print '##################################################'
	print ' ## ABOLISH taxa '
	print '##################################################'
	--

	-- total taxa
	--  DECLARE @level nvarchar(50); SET @level='species'; DECLARE  @ct varchar(10) -- debug
	select @ct=rtrim(count(*)) from load_next_msl where _src_taxon_rank=@level and _action   in ('abolish')
	PRINT '####### ABOLISH rank='+ @level + '; n='+rtrim(@ct)+' #####################################'	


	 print ''
	 print '##'
	print '## pre-ABOLISH check'
	 print '##'
	select 
		MESG=isnull(
			(case when nNew.right_idx -nNew.left_idx > 1 then 'WARNING - might have children; ' end)
			+(case when nOld.taxnode_id is NULL then 'ERROR: could not find in prev MSL; ' else '' end)
			+(case when nNew.taxnode_id is NULL then 'ERROR: could not find in current MSL; ' else '' end)
			, 'OK')
		,step='pre-abolish check'
		, ld._src_taxon_rank --, ld.dest_level_id, ld._dest_taxon_rank
		,ld._src_taxon_name,ld._src_lineage, ld.change
		, nOld.taxnode_id, nOld.lineage, nOld.out_change, nOld.right_idx -nOld.left_idx
		, nNew.taxnode_id, nNew.lineage , nNew.right_idx -nNew.left_idx
	 from load_next_msl ld
	 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
	 left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
	 left outer join  taxonomy_node nOld on nOld.msl_release_num = ld.dest_msl_release_num-1 and nOld.name = ld._src_taxon_name
	 where ld._action in ('abolish') and  _src_taxon_rank = @level

	 print ''
	 print '##'
	 print '##  WORK: do the actual deletion in CURR MSL'
	 print '##'
	 delete from taxonomy_node
	 where taxnode_id in (
		select 
			nNew.taxnode_id
		 from load_next_msl ld
		 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
		 left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
		 where ld._action in ('abolish') and  _src_taxon_rank = @level
	 )

	 print ''
	 print '##'
	 print '## WORK: set the out_change on the PREV MSL'
	 print '##'
	 update taxonomy_node set
	 --select taxnode_id, lineage,
		out_change='abolish'
		, out_target = ld._src_lineage
		, out_filename = ld.proposal
		, out_notes = ld.change
	 from taxonomy_node
	 join   load_next_msl ld 
	 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
	 on taxonomy_node.msl_release_num = ld.dest_msl_release_num-1 and taxonomy_node.name = ld._src_taxon_name
	 where ld._action in ('abolish') and  ld._src_taxon_rank = @level

	-- next
	FETCH NEXT FROM foreach_cursor INTO  @level_id, @level
END
CLOSE foreach_cursor; DEALLOCATE foreach_cursor


print ''
print '########################################################'
print '## QC '
print '########################################################'
--declare @ct int
select QC=isnull(
			(case when nNew.taxnode_id is not null then 'ERROR - deleted failed in new MSL; ' else '' end)
			+(case when nOld.out_change is NULL  then 'ERROR: out_change missing in PREV MSL; ' else '' end)
			+(case when nOld.out_change <> ld._action then 'ERROR: out_change wrong in PREV MSL:'+isnull(nOld.out_change,'NULL')+'; ' else '' end)
			+(case when nOld.out_target is NULL  then 'ERROR: out_target missing in PREV MSL; ' else '' end)
			+(case when nOld.out_target <> ld._src_lineage  then 'ERROR: out_target wrong in PREV MSL:'+isnull(nOld.out_target,'NULL')+'; ' else '' end)
			+(case when nOld.out_filename is NULL  then 'ERROR: out_filename missing in PREV MSL; ' else '' end)
			+(case when nOld.out_filename <> ld.proposal  then 'ERROR: out_filename wrong in PREV MSL; ' else '' end)
			, 'OK')
		,step='post-change QC'
		, ld._src_taxon_rank 
		,ld._src_taxon_name,ld._src_lineage, ld.change
		, nOld.taxnode_id, nOld.lineage, nOld.out_change, oldRightLeftDelta = nOld.right_idx -nOld.left_idx
		, newTaxnode_id =nNew.taxnode_id, newLineage=nNew.lineage , newRightLeftDelta=nNew.right_idx -nNew.left_idx
from load_next_msl ld
-- match by name, not lineage, as renames, moves, etc may have changed the lineage.
left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
left outer join  taxonomy_node nOld on nOld.msl_release_num = ld.dest_msl_release_num-1 and nOld.name = ld._src_taxon_name
where ld._action in ('abolish','merge') 
and (
	nNew.taxnode_id is not null 
	or
	(nOld.out_change is NULL or nOld.out_change <> ld._action)
	or
	(nOld.out_target is NULL or (ld._action='abolish' and nOld.out_target <> ld._src_lineage) or (ld._action='merge' and nOld.out_target <> ld._dest_lineage)  )
	or
	(nOld.out_filename is NULL or nOld.out_filename <> ld.proposal)
)
order by nOld.level_id desc
set @ct = @@ROWCOUNT
print (case when @ct > 0 then '!!!!ERRORR!!!!!: ' else 'NO ' end)+'ROWS FAILING ID=NULL QC: '+ltrim(@ct)

--commit transaction
--ROLLBACK TRANSACTION

print ''
print '##'
print '## MERGE report'
print '##'


select msl_release_num, taxnode_id, ictv_id,  lineage, in_change, out_change, out_filename, out_target
from taxonomy_node
where ictv_id in (19990647,19990648) or taxnode_id in (20180126, 20180127) or name in ( 'Sathuperi orthobunyavirus','Shamonda orthobunyavirus')
order by msl_release_num desc, left_idx

select t='load_next_msl'
	, _action,  _src_taxon_name, _dest_taxon_name prev_taxnode_id, dest_taxnode_id, dest_parent_id, * 
from load_next_msl
where _action in ('merge')
