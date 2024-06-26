--use ictvonline

-- ================================
-- !!! not currently functional !!!
-- ================================

-- from C:\Users\curtish\Dropbox\_1_Projects_UAB\ICTV_update\_rch_development\diff\query_diff_v2.sql
declare @msl int; set @msl = (select max(msl_release_num) from taxonomy_node)
declare @prev_msl int; set @prev_msl = (@msl-1)
select 'TARGET MSLs', [current]=@msl, prev=@prev_msl


select * 
from (
select 
	-- reference list of all taxa
	ref.current_ictv_id
	-- orderings
	,isnull(t1.left_idx,-1) as t1_idx 
	,isnull(t2.left_idx,-1) as t2_idx
	-- node_ids
	,isnull(t1.taxnode_id,-1) as t1_id 
	,isnull(t2.taxnode_id,-1) as t2_id
	-- t1
	,isnull(l1.name,l2.name) as lvl
	,isnull(t1.lineage,'') as t1_lineage
	,isnull(t1.name,'') as t1_name
	,case 
		when (t1.lineage=t2.lineage AND (t1.name=t2.name OR (t1.name is null AND t2.name is null)) and t2.is_deleted = 0)
														 then '========'
		when (t1.lineage<>t2.lineage AND (t1.name=t2.name) and t2.is_deleted = 0)
														 then '==MOVED='
		when (t1.is_renamed_next_year = 1 and t2.is_deleted = 0)
														 then '=RENAME='
		when (t1.taxnode_id is null and t2.taxnode_id is not null and t2.is_deleted = 0)
														 then '   NEW=='
		when (t2.is_deleted = 1)						 then '===DEL  '
		when (m1.merged_id is not null)					 then '=MERGED '
														 else '!?!?!?!?'
		end as diff
	,case when t2.is_deleted = 1 then 'DELETED' else t2.lineage end as t2_lineage
	,case when t2.is_deleted = 1 then 'DELETED' else t2.name end as t2_name
	,case when t2.filename like 'copied from%' then '' else t2.filename end as proposal
	,isnull(t2.notes,'') as notes
from (
/*	declare @tree_id1 int; set @tree_id1 = 20090000
	declare @tree_id2 int; set @tree_id2 = 20110000
*/	-- ref
	select ref.current_ictv_id, t1.taxnode_id as t1_id, max(t2.taxnode_id) as t2_id
	from taxonomy_node_x ref
	left outer join  taxonomy_node_x t1
		on t1.current_ictv_id = ref.current_ictv_id
		and t1.msl_release_num = @prev_msl --tree_id = @tree_id1
		and t1.is_deleted = 0
	left outer join  taxonomy_node_x t2
		on t2.current_ictv_id = ref.current_ictv_id
		and t2.msl_release_num = @msl --tree_id = @tree_id2
--	where ref.current_ictv_id in (20074054, 20074053, 20073843/*moved*/, 20071300/*deleted*/	)
	group by ref.current_ictv_id, t1.taxnode_id 
	having not (t1.taxnode_id is null and max(t2.taxnode_id) is null)
) as ref
left outer join taxonomy_node t1 
ON t1.taxnode_id = ref.t1_id
	left outer join taxonomy_level l1 
	on l1.id = t1.level_id
	left outer join taxonomy_node_merge m1
	on m1.merged_id = t1.ictv_id
left outer join taxonomy_node t2
ON t2.taxnode_id= ref.t2_id
	left outer join taxonomy_level l2
	on l2.id = t2.level_id
	left outer join taxonomy_node_merge m2
	on m2.merged_id = t2.ictv_id
--order by t2.left_idx, t1.left_idx

) as src
--where src.diff = '!?!?!?!?'
--where current_ictv_id in (20074054, 20074053	)
order by 
t2_idx, t1_idx

/*
select * from taxonomy_node_merge
where 20073843 in (final_id, merged_id)

select ictv_id, current_ictv_id, tree_id, name, is_deleted, notes, filename  
from taxonomy_node_x
where name in ('Human herpesvirus 6')
and tree_id in (20110000 , 20090000)
order by ictv_id, tree_id, left_idx

selec
*/