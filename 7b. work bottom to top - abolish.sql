--
-- work from top to bottom rank - abolishing things
--
-- when we created the new MSL tree, we copied everything, 
-- so we now need to PRUNE the abolished nodes. 
-- and mark their  previous-year versions with an out_change='abolish'
--
BEGIN TRANSACTION

DECLARE @level_id int
DECLARE @level varchar(50)
DECLARE @ct varchar(50)

DECLARE foreach_cursor SCROLL CURSOR FOR 
	SELECT 
		id, name
	FROM taxonomy_level as src
	--WHERE id between 101 and 199 -- tree to subphylum - only NEW's
	--WHERE id = 200 -- order : first assign node
	--WHERE id between 201 and 300 --suborder and family
	--WHERE id > 300 -- subfamily and below. 
	WHERE id > 100 -- everything
	ORDER BY id DESC

OPEN foreach_cursor
FETCH NEXT FROM foreach_cursor INTO @level_id, @level
WHILE @@FETCH_STATUS = 0 BEGIN
	-- WORK

	-- total taxa
	select @ct=rtrim(count(*)) from load_next_msl_33 where _dest_taxon_rank=@level and _action not  in ('abolish')
	PRINT '####### rank '+ rtrim(@level_id)+ '='+ @level + '; n='+@ct+' #####################################'	

	-- ##################################################
	-- ## ABOLISH taxa
	-- ##################################################
	select @ct=count(*) from load_next_msl_33 where _dest_taxon_rank=@level and _action in ('abolish')
	PRINT 'delete  '+@ct+' abolish '+@level

	--
	-- pre-flight check
	--
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
	 from load_next_msl_33 ld
	 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
	 left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
	 left outer join  taxonomy_node nOld on nOld.msl_release_num = ld.dest_msl_release_num-1 and nOld.name = ld._src_taxon_name
	 where ld._action in ('abolish') and  _src_taxon_rank = @level

	 --
	 -- WORK: do the actual deletion in CURR MSL
	 --
	 delete from taxonomy_node
	 where taxnode_id in (
		select 
			nNew.taxnode_id
		 from load_next_msl_33 ld
		 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
		 left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
		 where ld._action in ('abolish') and  _src_taxon_rank = @level
	 )

	 --
	 -- WORK: set the out_change on the PREV MSL
	 --
	 update taxonomy_node set
	 --select taxnode_id, lineage,
		out_change='abolish'
		, out_target = ld._src_lineage
		, out_filename = ld.proposal
		, out_notes = ld.change
	 from taxonomy_node
	 join   load_next_msl_33 ld 
	 -- match by name, not lineage, as renames, moves, etc may have changed the lineage.
	 on taxonomy_node.msl_release_num = ld.dest_msl_release_num-1 and taxonomy_node.name = ld._src_taxon_name
	 where ld._action in ('abolish') and  ld._src_taxon_rank = @level

	-- next
	FETCH NEXT FROM foreach_cursor INTO  @level_id, @level
END
CLOSE foreach_cursor; DEALLOCATE foreach_cursor


-- QC
--declare @ct int
select QC=isnull(
			(case when nNew.taxnode_id is not null then 'ERROR - deleted failed in new MSL; ' else '' end)
			+(case when nOld.out_change is NULL or nOld.out_change <> 'abolish'  then 'ERROR: out_change missing in PREV MSL; ' else '' end)
			+(case when nOld.out_target is NULL or nOld.out_target <> ld._src_lineage  then 'ERROR: out_target missing/wrong in PREV MSL; ' else '' end)
			+(case when nOld.out_filename is NULL or nOld.out_filename <> ld.proposal  then 'ERROR: out_filename missing/wrong in PREV MSL; ' else '' end)
			, 'OK')
		,step='post-change QC'
		, ld._src_taxon_rank 
		,ld._src_taxon_name,ld._src_lineage, ld.change
		, nOld.taxnode_id, nOld.lineage, nOld.out_change, nOld.right_idx -nOld.left_idx
		, newTaxnode_id =nNew.taxnode_id, newLineage=nNew.lineage , newRightLeftIdx=nNew.right_idx -nNew.left_idx
from load_next_msl_33 ld
-- match by name, not lineage, as renames, moves, etc may have changed the lineage.
left outer join  taxonomy_node nNew on nNew.msl_release_num = ld.dest_msl_release_num and nNew.name = ld._src_taxon_name
left outer join  taxonomy_node nOld on nOld.msl_release_num = ld.dest_msl_release_num-1 and nOld.name = ld._src_taxon_name
where ld._action in ('abolish') 
and (
	nNew.taxnode_id is not null 
	or
	(nOld.out_change is NULL or nOld.out_change <> 'abolish')
	or
	(nOld.out_target is NULL or nOld.out_target <> ld._src_lineage  )
	or
	(nOld.out_filename is NULL or nOld.out_filename <> ld.proposal)
)
order by nOld.level_id desc
set @ct = @@ROWCOUNT
print (case when @ct > 0 then '!!!!ERRORR!!!!!: ' else 'NO ' end)+'ROWS FAILING ID=NULL QC: '+ltrim(@ct)

--commit transaction
--ROLLBACK TRANSACTION