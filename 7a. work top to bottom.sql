--
-- work from top to bottom rank
--
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
	ORDER BY id

OPEN foreach_cursor
FETCH NEXT FROM foreach_cursor INTO @level_id, @level
WHILE @@FETCH_STATUS = 0 BEGIN
	-- WORK

	-- total taxa
	select @ct=rtrim(count(*)) from load_next_msl_33 where _dest_taxon_rank=@level and _action not  in ('abolish')
	PRINT '####### rank '+ rtrim(@level_id)+ '='+ @level + '; n='+@ct+' #####################################'	

	-- ##################################################
	-- ## NEW taxa
	-- ##################################################
	select @ct=count(*) from load_next_msl_33 where _dest_taxon_rank=@level and _action in ('new')
	PRINT 'insert '+@ct+' NEW '+@level

		-- find parent
	update load_next_msl_33 set
	--select _dest_lineage, _dest_parent_name, 
		dest_parent_id =  (
			-- VERSION 2 - faster?
			select x.taxnode_id 
			from taxonomy_node x 
			where (
				x.name=_dest_parent_name 
				or 
				-- empty parent = root of tree
				(_dest_parent_name='' and x.level_id=100)
			)
			and x.msl_release_num = dest_msl_release_num
		)
	from load_next_msl_33
	where _dest_taxon_rank = @level and _action in ('new')

	-- DEBUG output
	select  
		'new' -- debug
		, [rank]=@level
		, msg = (case when dest_parent_id is null then 'ERROR: dest_parent_id=NULL' else '' end)
		,src._src_lineage
		,src._action
		,src.change
		,src._dest_lineage
		,src._dest_parent_name
		,src._dest_taxon_rank
		,is_ref = isnull(isnull(src.isType, src.srcIsType),0)
		,src.dest_taxnode_id
		,in_change = src._action
		,in_filename = src.proposal
--		,in_notes = src.ref_notes
		,in_target = src._dest_lineage
		,notes = src.change
	from load_next_msl_33 as src
	where _dest_taxon_rank = @level and _action in ('new')
	-- don't redo it if it already exists
	and not exists (select * from taxonomy_node exist where exist.taxnode_id = src.dest_taxnode_id)

	-- actual work
	insert into taxonomy_node (
		taxnode_id
		,parent_id
		,tree_id
		,msl_release_num
		,name
		,level_id
		,is_ref
--		,is_hidden
		,ictv_id
		,in_change
		,in_filename
--		,in_notes
		,in_target
--		,out_change
--		,out_filename
--		,out_notes
		,notes
	) 
	select  
		--'new', -- debug
		taxnode_id = src.dest_taxnode_id
		-- figure out new taxid of parent (assume target is a lineage with semi-colons)
		, parent_id = src.dest_parent_id
		,tree_id = src.dest_tree_id
		,msl_release_num = src.dest_msl_release_num
		-- assume it's a lineage, and get what's after the last semi-colon
		,name = _dest_taxon_name
		,level_id = (select id from taxonomy_level where name=src._dest_taxon_rank)
		,is_ref = isnull(isnull(src.isType, src.srcIsType),0)
--		,is_hidden = 0
		,ictv_id = src.dest_taxnode_id
		,in_change = src._action
		,in_filename = src.proposal
--		,in_notes = src.ref_notes
		,in_target = src._dest_lineage
		,notes = src.change
	from load_next_msl_33 as src
	where _dest_taxon_rank = @level and _action in ('new')
	-- don't redo it if it already exists
	and not exists (select * from taxonomy_node exist where exist.taxnode_id = src.dest_taxnode_id)

	-- ##################################################
	-- ## RENAME/MOVE/ASSIGN taxa
	-- ##################################################
/*BEGIN TRANSACTION
DECLARE @ct varchar(20);
DECLARE @level_id int; SET @level_id = 200
DECLARE @level varchar(50); SET @level ='order'
*/
	-- edit new taxon to reparent
	-- put out_change info on MSL-1 taxon
	select @ct=count(*) from load_next_msl_33 where _dest_taxon_rank=@level and _action in ('assign','move','rename')
	PRINT 'insert '+@ct+' MOVE/RENAME '+@level

	-- find parent
	update load_next_msl_33 set
	--select _dest_lineage, _dest_parent_name, 
		dest_parent_id =  (
			-- VERSION 2 - faster?
			select x.taxnode_id 
			from taxonomy_node x 
			where (
				x.name=_dest_parent_name 
				or 
				-- empty parent = root of tree
				(_dest_parent_name='' and x.level_id=100)
			)
			and x.msl_release_num = dest_msl_release_num
		)
	from load_next_msl_33
	where _dest_taxon_rank = @level and _action in ('assign','move','rename')

	-- DEBUG output
	select  
		'assign/move/rename' 
		, [rank]=@level
		, msg = (case when dest_parent_id is null then 'ERROR: dest_parent_id=NULL' else '' end)
		 ,src._src_lineage
		, src._action
		, src.change
		, src._dest_lineage
		, src._dest_parent_name
		, dest_parent_id
		, dest_ictv_id
		, src._dest_taxon_rank
		,is_ref = isnull(isnull(src.isType, src.srcIsType),0)
		,src.dest_taxnode_id
		,out_change = src._action
		,out_filename = src.proposal
--		,out_notes = src.ref_notes
		,out_target = src._dest_lineage
		,notes = src.change
	from load_next_msl_33 as src
	where _dest_taxon_rank = @level and _action in ('assign','move','rename')
	-- don't redo it if it already exists
	--and not exists (select * from taxonomy_node exist where exist.taxnode_id = src.dest_taxnode_id)

	-- actual work
	update taxonomy_node set
	--select  'real assign/move/rename', taxonomy_node.parent_id, taxonomy_node.name, taxonomy_node.level_id, src._src_lineage, src.change, src._dest_lineage, -- debug
		parent_id = dest_parent_id
		,name = src._dest_taxon_name
		,level_id = (select id from taxonomy_level where name=src._dest_taxon_rank)
		,is_ref = isnull(isnull(src.isType, src.srcIsType),0)
		--,ictv_id = src.dest_taxnode_id
		,notes = src.change
	from taxonomy_node
	join load_next_msl_33 as src on taxonomy_node.taxnode_id = src.dest_taxnode_id
	where src._dest_taxon_rank = @level and src._action in ('assign','move','rename')
	and (
	-- don't do it if it's already done
		 taxonomy_node.parent_id <> src.dest_parent_id
		or taxonomy_node.name <> src._dest_taxon_name
		or taxonomy_node.level_id <> (select id from taxonomy_level where name=src._dest_taxon_rank)
	)

	-- set OUT_CHANGE on src_taxnode_id
	update taxonomy_node set
	--select  'real assign/move/rename; set out_change', taxonomy_node.parent_id, taxonomy_node.name, taxonomy_node.level_id, src._src_lineage, src.change, src._dest_lineage, -- debug
		out_change = src._action 
		,out_filename= src.proposal
		,out_target = src._dest_lineage
		,out_notes = src.change
	from taxonomy_node
	join load_next_msl_33 as src on taxonomy_node.taxnode_id = src.prev_taxnode_id
	where src._dest_taxon_rank = @level and src._action in ('assign','move','rename')
	and (
	-- don't do it if it's already done
		out_change <> src._action or out_change is null
		or out_filename <> src.proposal or out_filename is null
		or out_target <> src._dest_lineage or out_target is null
	)

   -- debug queries
	--select lineage, out_change, out_target, out_filename, * from taxonomy_node where taxnode_id in (20170001, 20171548,20180001, 20181548)  or name in ('Mononegavirales','Bunyavirales') 
	--order by name, tree_id

	--select _dest_taxon_name, dest_ictv_id , dest_taxnode_id, prev_taxnode_id from load_next_msl_33 where _dest_taxon_name in ('Mononegavirales','Bunyavirales')
	-- next
	FETCH NEXT FROM foreach_cursor INTO  @level_id, @level
END
CLOSE foreach_cursor; DEALLOCATE foreach_cursor


-- debug
 select *, (case when change like '"%"' then 'ACK!' else 'ok' end) from load_next_msl_33 where _dest_lineage like '%Torovirinae%' or _dest_lineage like '%Torovirus%'

declare @ct int
select QC='MISSING(NULL): '
	+ (case when dest_taxnode_id is null AND _action not in ('abolish') then 'dest_taxnode_id ' else '' end)
	+ (case when dest_parent_id is null AND _action not in ('abolish') then 'dest_parent_id ' else '' end)
	+ (case when dest_ictv_id is null AND _action not in ('abolish')  then 'dest_ictv_id ' else '' end)
	+ (case when prev_taxnode_id is null AND _action not in ('new') then 'prev_taxnode_id ' else '' end)
	, _action, *
from load_next_msl_33
where (
	(dest_taxnode_id is null or dest_parent_id is null or dest_ictv_id is null) and _action not in ('abolish')
) or  (
	(prev_taxnode_id is null) AND _action not in ('new') 
)
set @ct = @@ROWCOUNT
print (case when @ct > 0 then '!!!!ERRORR!!!!!: ' else 'NO ' end)+'ROWS FAILING ID=NULL QC: '+ltrim(@ct)

--commit transaction
--ROLLBACK TRANSACTION