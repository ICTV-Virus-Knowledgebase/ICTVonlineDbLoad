--
-- Tranfer data from load_new_msl =>taxonomy_node
--

-- 
-- THIRD: xfer new and split
--
-- report on taxa count
--
select 
	message='transfering '+rtrim(count(*))+' dest_in_change='+src.dest_in_change
	-- fixed in MSL32/2017, errors=case when dest_in_change='split' then 'ERROR: split not fully implemented - go fix it! (MSL2014 had no splits)' else '' end
-- select * 
from load_next_msl as src
where 
	(src.dest_in_change in ('new', 'new_type', 'split') and src.src_out_change is null)
group by src.dest_in_change


-- rewind!
/*
delete -- select * 
	from taxonomy_node where taxnode_id in (	 
	SELECT dest_taxnode_id
	FROM load_next_msl as src
	WHERE
		(src.dest_in_change in ('new', 'split') and src.src_out_change is null)
)
*/

/* FIXES 
select * from taxonomy_node where tree_id=20160000
select src_parent_lineage, dest_parent_id, * from load_next_msl
alter table load_next_msl add [src_parent_lineage]  AS (case when [src_lineage] like '%;%' then reverse(ltrim(replace(substring(replace(reverse([src_lineage]),';',space((200))),(200),(5000)),space((200)),';')))  end) PERSISTED
go
alter table load_next_msl add [dest_parent_id] int null
go
-- fix unexplained duplicates
select * from load_next_msl where 'Tymovirales;Tymoviridae;Unassigned'	 in ( dest_target, src_lineage)
select * from load_next_msl where  'unassigned;Tristromaviridae;unassigned' in (dest_target, src_lineage)		
---delete from load_next_msl where dest_taxnode_id = 20161657 -- 2 copies of Tymovirales;Tymoviridae;Unassigned, with different ICTV_ids
--delete from load_next_msl where dest_taxnode_id = 20164633 -- 2 copies of unassigned;Tristromaviridae;unassigned, with different ICTV_ids
*/

-- -----------------------------------------------------------------------------------------
--
-- INSERT new taxa
---
-- 
-- -----------------------------------------------------------------------------------------
-- delete from taxonomy_node where tree_id=20160000 and level_id is null
insert into taxonomy_node (
		taxnode_id,
		tree_id,
		parent_id,
		name,
		level_id,
		is_ref,
		is_hidden,
		ictv_id,
		msl_release_num,
		in_change, in_filename, in_notes, in_target,
		--out_change, out_filename, out_notes
		notes
	)
select 
		taxnode_id = src.dest_taxnode_id
		, tree_id = src.dest_tree_id
		-- figure out new taxid of parent (assume target is a lineage with semi-colons)
		, parent_id = src.dest_parent_id /*
			(
				-- ** Find parents already inserted for current year
				--select count(n.taxnode_id) -- debug
				select taxnode_id=n.taxnode_id -- production
				from taxonomy_node n 
				where n.lineage=src.dest_parent_lineage
				and n.tree_id = src.dest_tree_id
			--),( -- ISNULL(A,B)
			union --prod
			--), parent_id2 = ( -- debug
				-- ** Find parents yet to be inserted, for current year
				--select count(x.dest_taxnode_id) -- debug
				--select ltrim(rtrim(left(src.dest_target, dbo.vgd_strrchr(';', src.dest_target)-1))) -- debug
				select taxnode_id=x.dest_taxnode_id -- production
				from load_next_msl as x
				where dest_target=src.dest_parent_lineage
				and (dest_in_change in ('new','split') or src_out_change like 'move%' or src_out_change in ('rename','promote'))
			)
		--) -- end ISNULL()
		*/
		-- assume it's a lineage, and get what's after the last semi-colon
		,name = (case 
			when dest_level='subfamily' and src.dest_target like '%;Unassigned' then NULL	
			else  src.dest_name
			end)
		,level_id = (select id from taxonomy_level where name=src.dest_level or id=dest_level)
		,is_ref = isnull(isnull(src.dest_is_type, src.src_is_type),0)
		,is_hidden = (case 
			when dest_level='subfamily' and src.dest_target like '%;Unassigned' then 1	
			else isnull(src.dest_is_hidden, 0)
			end)
		,ictv_id = src.dest_taxnode_id
		,msl_release_num = src.dest_msl_release_num
		,in_change = src.dest_in_change
		,in_filename = src.ref_filename
		,in_notes = src.ref_notes
		-- for a NEW node, the target is the new taxon
		-- for a SPLIT node, the target is the old taxon that was split, so we can build the deltas
		,in_target = (case src.dest_in_change when 'split' then src.src_lineage else src.dest_target end)
		,notes = src.ref_problems
	-- debug select src.dest_taxnode_id, src.dest_tree_id, src.dest_target, src.dest_level,src.ref_filename
	-- debug select src.dest_target, count(*)
	from (select * 
		from load_next_msl as src
		WHERE
			-- insert only NEW/SPLIT
			(src.dest_in_change in ('new', 'new_type', 'split') and src.src_out_change is null)
		AND
			-- skip records already inserted
			(src.dest_taxnode_id NOT in (select n.taxnode_id from taxonomy_node as n where n.tree_id=src.dest_tree_id))
	) as src
	--group by src.dest_tree_id, src.dest_target
	--having src.dest_target in (select lineage from taxonomy_node as n where n.tree_id = src.dest_tree_id)
	ORDER BY src.dest_taxnode_id


/*
 *******************************************************************************
 -- cursor version - very slow	 
 *******************************************************************************
-- instead of a cursor, might be a LOT faster as a 
-- batch insert, but only considering "new" rows in load_next_msl
DECLARE @dest_taxnode_id int
DECLARE foreach_cursor SCROLL CURSOR FOR 
	SELECT dest_taxnode_id
	FROM load_next_msl as src
	WHERE
		(src.dest_in_change in ('new', 'split') and src.src_out_change is null)
	AND
		(src.dest_taxnode_id NOT in (select n.taxnode_id from n.taxonomy_node where n.tree_id=src.dest_tree_id))
	ORDER BY dest_target

OPEN foreach_cursor
FETCH NEXT FROM foreach_cursor INTO @dest_taxnode_id
WHILE @@FETCH_STATUS = 0 BEGIN
	-- WORK
	insert into taxonomy_node (
		taxnode_id,
		tree_id,
		parent_id,
		name,
		level_id,
		is_ref,
		is_hidden,
		ictv_id,
		msl_release_num,
		in_change, in_filename, in_notes, in_target,
		--out_change, out_filename, out_notes
		notes
	) 
	select 
		taxnode_id = src.dest_taxnode_id
		, tree_id = src.dest_tree_id
		-- figure out new taxid of parent (assume target is a lineage with semi-colons)
		, parent_id = (
			select n.taxnode_id 
			from taxonomy_node n 
			where n.lineage=ltrim(rtrim(left(src.dest_target, dbo.vgd_strrchr(';', src.dest_target)-1)))
			and n.tree_id = src.dest_tree_id
		)
		-- assume it's a lineage, and get what's after the last semi-colon
		,name = ltrim(rtrim(substring(src.dest_target, dbo.vgd_strrchr(';', src.dest_target)+1,200)))
		,level_id = (select id from taxonomy_level where name=src.dest_level)
		,is_ref = isnull(isnull(src.dest_is_type, src.src_is_type),0)
		,is_hidden = isnull(src.dest_is_hidden, 0)
		,ictv_id = src.dest_taxnode_id
		,msl_release_num = src.dest_msl_release_num
		,in_change = src.dest_in_change
		,in_filename = src.ref_filename
		,in_notes = src.ref_notes
		,in_target = src.dest_target
		,notes = src.ref_problems
	from load_next_msl as src
	where dest_taxnode_id = @dest_taxnode_id
	
	-- next
	FETCH NEXT FROM foreach_cursor INTO @dest_taxnode_id
END
CLOSE foreach_cursor; DEALLOCATE foreach_cursor
*/

/*
--
-- update out_change in taxonomy_node of prev MSL
--
update taxonomy_node set
-- select
	out_change = 'rename'
	, out_target = src.dest_target
	, out_filename = ref_filename
	, out_notes = ref_notes
from taxonomy_node 
join load_next_msl as src on src.src_taxnode_id = taxonomy_node.taxnode_id
and src.src_out_change = 'rename'
*/

/*******************************************************************************
 * moved delta node creation to a single script
 * 9a. rebuild delta nodes
 *******************************************************************************
--
-- create delta nodes
--
insert into taxonomy_node_delta (
	prev_taxid, new_taxid
	, proposal, notes
	, is_new
	, is_split
	, is_now_type
) 
select 	
	prev_taxid=src.src_taxnode_id, new_taxid=src.dest_taxnode_id
	, proposal=src.ref_filename, notes=src.ref_notes
	, is_new=case when src.dest_in_change = 'new' then 1 else 0 end
	, is_split=case when src.dest_in_change = 'split' then 1 else 0 end
	, is_now_type=msl2.is_ref-- - msl1.is_ref
from load_next_msl as src
--join taxonomy_node msl1 on msl1.taxnode_id=src.src_taxnode_id
join taxonomy_node msl2 on msl2.taxnode_id=src.dest_taxnode_id
where 
	(src.dest_in_change in ('new', 'split') and src.src_out_change is null)
order by src_left_idx
*/