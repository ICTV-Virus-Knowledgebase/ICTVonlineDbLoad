USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[rebuild_delta_nodes_20181022_no_is_type]
	@msl int = NULL-- delete related deltas first?
AS
	-- -----------------------------------------------------------------------------
	--
	-- build deltas from in_out changes
	--
	-- RUN TIME: 7 seconds
	-- -----------------------------------------------------------------------------

	set @msl=(select isnull(@msl,MAX(msl_release_num)) from taxonomy_node)
	select 'TARGET MSL: ',@msl

	-- ******************************************************************************************************
	--
	-- clean out deltas for this MSL
	--
	-- ******************************************************************************************************
	delete 
	-- select * 
	from taxonomy_node_delta
	where (new_taxid in (select taxnode_id from taxonomy_node where msl_release_num=@msl) or new_taxid is null)
	and   (prev_taxid in (select taxnode_id from taxonomy_node where msl_release_num=@msl-1) or prev_taxid is null)


	-- ******************************************************************************************************
	--
	-- IN_CHANGE: NEW / SPLIT
	--
	-- ******************************************************************************************************

	insert into taxonomy_node_delta (prev_taxid, new_taxid, proposal, notes, is_new, is_split)
	select 
		p.taxnode_id, n.taxnode_id
		,proposal=n.in_filename
		,notes   =n.in_notes
		,is_new=(case when n.in_change='new' then 1 else 0 end)
		,is_split=(case when n.in_change='split' then 1 else 0 end)
		-- debug
		--, t2='prev', p.taxnode_id, p.out_change, p.lineage
		--, t3='delta', d.*
	from taxonomy_node n
	left outer join taxonomy_node p on 
		p.msl_release_num = n.msl_release_num-1
		and 
		n.in_target in (p.lineage, p.name)
	left outer join taxonomy_node_delta d on d.new_taxid=n.taxnode_id
	where 
		n.in_change in ('new', 'split')
	and d.new_taxid is null
	and n.msl_release_num=@msl
	and n.is_deleted = 0
	--and n.taxnode_id=20132530 -- debug
	--group by p.lineage, n.in_target, p.msl_release_num, n.in_change, n.msl_release_num, n.lineage, n.taxnode_id, n.in_filename, cast(n.in_notes as varchar(max))
	order by n.taxnode_id, n.msl_release_num, n.lineage


	-- ******************************************************************************************************
	--
	-- OUT_CHANGE: rename, merge, promote, move, abolish
	--
	-- ******************************************************************************************************


	insert into taxonomy_node_delta (prev_taxid, new_taxid, proposal, notes, is_renamed, is_merged, is_promoted, is_moved, is_deleted)
	--select prev_taxid, new_taxid, count(*) from (
	-- add rename/moved empirally
	select 
		src.prev_taxid, src.new_taxid, src.proposal, src.notes
		, is_renamed =case when prev_msl.name <> next_msl.name and is_merged = 0 then 1 else 0 end
		, src.is_merged
		, src.is_promoted
		, is_moved = case when prev_pmsl.lineage <> next_pmsl.lineage AND prev_pmsl.level_id<>100/*root*/ then 1 else 0 end
		, src.is_abolish
	from (
		select distinct
			prev_taxid=p.taxnode_id
			,new_taxid=case
				-- handle SPECIES(Unassigned;Unassigned;Unassigned;Geminivirus group;Bean golden mosaic virus) BUT (target=new GENUS name)
				when p.out_change <> 'promote' AND p.level_id > targ.level_id AND targ_child.taxnode_id IS NOT NULL then targ_child.taxnode_id -- allow match to child of target of same name
				-- handle GENUS(Unassigned;Iridoviridae;Unassigned;African swine fever virus group) BUT (target=SPECIES, but genus is moved)
				when p.level_id=500/*genus*/ AND targ.level_id=600/*species*/ and p.name <> 'Unassigned' then targ.parent_id
				-- normal case - correct target
				else targ.taxnode_id
				end	
			/*,new_taxid_src=case
				-- handle SPECIES(Unassigned;Unassigned;Unassigned;Geminivirus group;Bean golden mosaic virus) BUT (target=new GENUS name)
				when p.out_change <> 'promote' AND p.level_id > targ.level_id AND targ_child.taxnode_id IS NOT NULL then 'targ_child.taxnode_id' -- allow match to child of target of same name
				-- handle GENUS(Unassigned;Iridoviridae;Unassigned;African swine fever virus group) BUT (target=SPECIES, but genus is moved)
				when p.level_id=500/*genus*/ AND targ.level_id=600/*species*/ and p.name <> 'Unassigned' then 'targ.parent_id'
				-- normal case - correct target
				else 'targ.taxnode_id'
				end
			*/
			,proposal=p.out_filename
			,notes   =cast(p.out_notes as varchar(max))
			,is_merged=(case when p.out_change='merge' then 1 else 0 end)
			,is_promoted=(case when p.out_change='promote' then 1 else 0 end)
			,is_abolish=(case when p.out_change='abolish' then 1 else 0 end)
			--,is_renamed=(case when p.out_change='rename' then 1 else 0 end)
			--,is_move=(case when p.out_change='move' then 1 else 0 end)
			-- debugging
			--, p.out_change,p.lineage,p.out_target,targ.lineage,old_link=d.prev_taxid,targ_id=targ.taxnode_id, targ_child_id=targ_child.taxnode_id
		from taxonomy_node p
		left outer join taxonomy_node targ on 
			p.msl_release_num = targ.msl_release_num-1
			and 
			p.out_target in (targ.lineage, targ.name)
			and 
			p.is_deleted = 0
		-- allow match to child of target (ie, target is new genus for a species)
		left outer join taxonomy_node targ_child on 
			targ_child.parent_id = targ.taxnode_id
			and (targ_child.name = p.name or targ_child.name = p.out_target)
			and targ_child.level_id = p.level_id
			and p.out_change <> 'promote'
			and targ_child.name <> 'Unassigned'
			and targ_child.name is not null
			and targ_child.is_hidden = 0
			--and targ_child.name <> targ.name
		left outer join taxonomy_node_delta d on d.prev_taxid=p.taxnode_id
		where p.out_change is not null --in ('new', 'split')
		and p.msl_release_num = (@msl-1)
		and d.prev_taxid is null -- no double inserts!!!
		-- TESTING
		--and p.taxnode_id=19841242 -- TEST: Unassigned;Unassigned;Unassigned;Geminivirus group;Bean golden mosaic virus (target=genus name)
		--and p.taxnode_id=19820086 -- TEST: 'Unassigned;Iridoviridae;Unassigned;African swine fever virus group (target=species, but genus is moved)
		--and p.msl_release_num=11	and p.name like 'Influenza type C virus%'
		--and p.taxnode_id in (19900137, 19900770) -- 'Influenza C virus' genus/species ambiguity heuristic resolution (msl 11-12)
	) as src
	join taxonomy_node prev_msl on prev_msl.taxnode_id = src.prev_taxid
	join taxonomy_node prev_pmsl on prev_pmsl.taxnode_id = prev_msl.parent_id
	left outer join taxonomy_node next_msl on next_msl.taxnode_id = src.new_taxid
	left outer join taxonomy_node next_pmsl on next_pmsl.taxnode_id = next_msl.parent_id

	--select * from taxonomy_node where taxnode_id in (19900137	,19910141, 19900770	,19910993)

	--) as src 
	--group by prev_taxid, new_taxid
	--having count(distinct(rtrim(prev_taxid)+','+rtrim(new_taxid))) > 1

	-- ******************************************************************************************************
	--
	-- NO CHANGE - deltas between nodes with same lineage
	--
	-- ******************************************************************************************************
	insert into taxonomy_node_delta (prev_taxid, new_taxid, is_moved, is_now_type)
	select 
		--p.msl_release_num, p_lin=p.lineage, p_name=p.name, -- debug
		p.taxnode_id, n.taxnode_id
		,is_moved = (case when pp.lineage <> pn.lineage AND pp.level_id<>100/*root*/ then 1 else 0 end)
		,is_now_type = (case
			when p.is_ref = 1 and n.is_ref = 0 then -1
			when p.is_ref = 0 and n.is_ref = 1 then 1
			else 0 end)
		--,n_lin=n.lineage -- debug
		--,pd.tag_csv, nd.tag_csv, nd.prev_taxid -- debug
	from taxonomy_node p
	join taxonomy_node n 
			-- SAME NAME constraints v7 (link root nodes)
			on n.msl_release_num = (p.msl_release_num+1)
			and (
				-- same LINEAGE
				(n.lineage = p.lineage)
				or
				-- same non-NULL, non-Unassigned names, same level (species, genus, etc)
				(n.name = p.name AND n.name<>'Unassigned' AND n.level_id=p.level_id)
				or 
				-- root of tree (special case)
				(n.level_id = 100 AND p.level_id = 100)
			) and (
				-- no relationships between hidden nodes
				(p.is_hidden=0 and n.is_hidden=0)
				or
				-- root of tree (special case)
				(n.level_id = 100 AND p.level_id = 100)		
			)
		left outer join taxonomy_node_delta pd 
			on pd.prev_taxid = p.taxnode_id
			and p.taxnode_id is not null
			and pd.is_split = 0
		left outer join taxonomy_node_delta nd
			on nd.new_taxid = n.taxnode_id
			and n.taxnode_id is not null
			and nd.is_merged = 0 -- merge target often exists in prev MSL and continues with same name
		-- get parents
		join taxonomy_node pp on pp.taxnode_id = p.parent_id
		join taxonomy_node pn on pn.taxnode_id = n.parent_id
	where
	n.msl_release_num=@msl
	and 
	pd.prev_taxid is null and nd.new_taxid is null
	and 
	p.is_deleted = 0 and n.is_deleted = 0
	-- and p.level_id<=300 -- debug
	-- and p.name ='bushbush virus' -- debug
	-- and select msl_release_num, in_change, out_change, name, lineage from taxonomy_node p where p.name in ('Bovine enterovirus', 'Bovine enterovirus 1', 'Bovine enterovirus 2') -- debug
	order by p.name, p.msl_release_num


	-- stats
	-- declare @msl int; set @msl=(select MAX(msl_release_num) from taxonomy_node)
	select 
		@msl as msl
		,case when tag_csv='' then 'UNCHANGED' else tag_csv end as [change_type]
		, COUNT(*) as [counts]
	from taxonomy_node_delta
	where (new_taxid in (select taxnode_id from taxonomy_node where msl_release_num=@msl) or new_taxid is null)
	and   (prev_taxid in (select taxnode_id from taxonomy_node where msl_release_num=@msl-1) or prev_taxid is null)
	group by tag_csv
	order by tag_csv

GO
