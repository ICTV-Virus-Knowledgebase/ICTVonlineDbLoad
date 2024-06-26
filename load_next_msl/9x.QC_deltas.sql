--
-- check that node counts line up with delta counts
--
declare @msl int; set @msl=(select MAX(msl_release_num) from taxonomy_node)
select 'TARGET MSL: ',@msl



-- ***************************************************************************
-- stats on MSL and MSL-1
-- ***************************************************************************
select report='stats on MSL and MSL-1',
	--p.msl_release_num, dx.prev_id, dx.msl_release_num, dx.taxnode_id, dx.next_id, n.msl_release_num,
	p.msl_release_num as prev_msl, dx.prev_tags, dx.msl_release_num as msl, dx.next_tags, n.msl_release_num as next_msl
	, COUNT(case when dx.is_hidden=0 then 1 end) as [viz_count]
	, COUNT(case when dx.is_hidden=1 then 1 end) as [hidden_count]
	, COUNT(dx.is_hidden) as [total_count]
	, [notes and errors]= case	
		when prev_tags='Renamed,' then case	
			when COUNT(case when dx.is_hidden=1 then 1 end)=1 then 'OK: Tree root node is hidden and renamed'
			else 'ERROR: Only the tree root node can be hidden and renamed'
			end
		when prev_tags in ('Merged,', 'Moved,','Renamed,Moved,') and COUNT(case when dx.is_hidden=1 then 1 end)>0 then 'ERROR: only visible nodes '+prev_tags
		when prev_tags IS NULL and next_tags IS NULL and COUNT(case when dx.is_hidden=0 then 1 end)>0 then 'ERROR: only hidden nodes can disapear/appear w/o delta links'
		else ''
	end
from taxonomy_node_dx dx
left outer join taxonomy_node p on p.taxnode_id=dx.prev_id
left outer join taxonomy_node n on n.taxnode_id=dx.next_id
where (dx.msl_release_num = @msl or p.msl_release_num=(@msl-1)) and dx.is_deleted=0
--and dx.is_hidden=0 -- no deltas between hidden nodes
group by p.msl_release_num, dx.prev_tags, dx.msl_release_num, dx.next_tags, n.msl_release_num 
order by p.msl_release_num, dx.prev_tags, dx.msl_release_num, dx.next_tags, n.msl_release_num 

select  report='stats on MSL-1 and MSL-2',
	--p.msl_release_num, dx.prev_id, dx.msl_release_num, dx.taxnode_id, dx.next_id, n.msl_release_num 
	p.msl_release_num as prev_msl, dx.prev_tags, dx.msl_release_num as msl, dx.next_tags, n.msl_release_num as next_msl
	, COUNT(case when dx.is_hidden=0 then 1 end) as [viz_count]
	, COUNT(case when dx.is_hidden=1 then 1 end) as [hidden_count]
	, COUNT(dx.is_hidden) as [total_count]
	, [notes and errors]= case	
		when prev_tags='Renamed,' then case	
			when next_tags='Renamed,' AND COUNT(case when dx.is_hidden=1 then 1 end)=1 then 'OK: Tree root node is hidden and renamed'
			when COUNT(case when dx.is_hidden=1 then 1 end)>0 then 'ERROR: Only the tree root node can be hidden and renamed'
			else ''
			end
		when prev_tags in ('Merged,', 'Moved,','Renamed,Moved,') and COUNT(case when dx.is_hidden=1 then 1 end)>0 then 'ERROR: only visible nodes '+prev_tags
		when prev_tags IS NULL and next_tags IS NULL and COUNT(case when dx.is_hidden=0 then 1 end)>0 then 'ERROR: only hidden nodes can disapear/appear w/o delta links'
		else ''
	end
from taxonomy_node_dx dx
left outer join taxonomy_node p on p.taxnode_id=dx.prev_id
left outer join taxonomy_node n on n.taxnode_id=dx.next_id
where dx.msl_release_num = (@msl-1) and dx.is_deleted=0
--and dx.is_hidden=0 -- no deltas between hidden nodes
group by p.msl_release_num, dx.prev_tags, dx.msl_release_num, dx.next_tags, n.msl_release_num 

-- ***************************************************************************
-- report problem taxa - summary
-- ***************************************************************************


-- disappear w/o delta node
select --p.msl_release_num, dx.prev_id, dx.msl_release_num, dx.taxnode_id, dx.next_id, n.msl_release_num 
	'ERROR: MSL'+rtrim(dx.msl_release_num)+' tax DISappears with out a delta record' as [error_summary: DISappear w/o delta]
	, p.msl_release_num, dx.prev_tags, dx.msl_release_num, dx.next_tags, n.msl_release_num 
	, COUNT(*) as [count]
from taxonomy_node_dx dx
left outer join taxonomy_node p on p.taxnode_id=dx.prev_id and p.is_deleted=0
left outer join taxonomy_node n on n.taxnode_id=dx.next_id and n.is_deleted=0
where dx.msl_release_num = (select max(msl_release_num)-1 from taxonomy_toc) and dx.is_deleted=0
and dx.is_hidden=0 -- no deltas between hidden nodes
and n.msl_release_num is null and dx.next_tags is null
group by p.msl_release_num, dx.prev_tags, dx.msl_release_num, dx.next_tags, n.msl_release_num 
order by dx.msl_release_num desc--, dx.ictv_id desc

-- appear w/o delta node
select --p.msl_release_num, dx.prev_id, dx.msl_release_num, dx.taxnode_id, dx.next_id, n.msl_release_num 
	'ERROR: MSL'+rtrim( dx.msl_release_num)+' tax APPEARS with out a delta record' as [error_summary: APPEAR w/o delta]
	, p.msl_release_num, dx.prev_tags, dx.msl_release_num, dx.next_tags, n.msl_release_num 
	, COUNT(*) as [count]
from taxonomy_node_dx dx 
left outer join taxonomy_node p on p.taxnode_id=dx.prev_id and p.is_deleted=0
left outer join taxonomy_node n on n.taxnode_id=dx.next_id and n.is_deleted=0
where dx.msl_release_num = (select max(msl_release_num) from taxonomy_toc) and dx.is_deleted=0
and dx.is_hidden=0 -- no deltas between hidden nodes
and p.msl_release_num is null and dx.prev_tags is null
group by p.msl_release_num, dx.prev_tags, dx.msl_release_num, dx.next_tags, n.msl_release_num 
order by dx.msl_release_num desc--, dx.ictv_id desc

-- ***************************************************************************
-- report problem taxa - details
-- ***************************************************************************

select --p.msl_release_num, dx.prev_id, dx.msl_release_num, dx.taxnode_id, dx.next_id, n.msl_release_num 
	'ERROR DETAIL: MSL'+rtrim(dx.msl_release_num)+' tax DISappears with out a delta record' as [error_detail]
	, prev_msl=p.msl_release_num, dx.prev_tags, cur_msl=dx.msl_release_num, dx.next_tags, nexT_msl=n.msl_release_num 
	, dx.taxnode_id, dx.ictv_id, rank=lvl.name, taxon=dx.name,  dx.lineage
from taxonomy_node_dx dx
left outer join taxonomy_node p on p.taxnode_id=dx.prev_id and p.is_deleted=0
left outer join taxonomy_node n on n.taxnode_id=dx.next_id and n.is_deleted=0
left outer join taxonomy_level lvl on lvl.id = dx.level_id
where dx.msl_release_num = dbo.udf_getMSL(NULL)-1 and dx.is_deleted=0 
and dx.is_hidden=0 -- no deltas between hidden nodes
and n.msl_release_num is null and dx.next_tags is null
--order by dx.left_idx

UNION 

select --p.msl_release_num, dx.prev_id, dx.msl_release_num, dx.taxnode_id, dx.next_id, n.msl_release_num 
	'ERROR DETAIL: MSL'+rtrim(dx.msl_release_num)+' tax APPEARS with out a delta record' as [error_detail]
	, prev_mx=p.msl_release_num, dx.prev_tags, cur_msl=dx.msl_release_num, dx.next_tags, next_msl=n.msl_release_num 
	, dx.taxnode_id, dx.ictv_id,  rank=lvl.name, taxon=dx.name,  dx.lineage
from taxonomy_node_dx dx
left outer join taxonomy_node p on p.taxnode_id=dx.prev_id and p.is_deleted=0
left outer join taxonomy_node n on n.taxnode_id=dx.next_id and n.is_deleted=0
left outer join taxonomy_level lvl on lvl.id = dx.level_id
where dx.msl_release_num = (select max(msl_release_num) from taxonomy_toc) and dx.is_deleted=0
and dx.is_hidden=0 -- no deltas between hidden nodes
and p.msl_release_num is null and dx.prev_tags is null

union

select --p.msl_release_num, dx.prev_id, dx.msl_release_num, dx.taxnode_id, dx.next_id, n.msl_release_num 
	'ERROR DETAIL: MSL'+rtrim(dx.msl_release_num)+' taxa HIDDEN and RENAMED' as [error_details: HIDDEN and RENAMED]
	, prev_msl=p.msl_release_num, dx.prev_tags, cur_msl=dx.msl_release_num, dx.next_tags, next_msl=n.msl_release_num 
	, dx.taxnode_id, dx.ictv_id,  rank=lvl.name, taxon=dx.name,  dx.lineage
from taxonomy_node_dx dx
left outer join taxonomy_node p on p.taxnode_id=dx.prev_id and p.is_deleted=0
left outer join taxonomy_node n on n.taxnode_id=dx.next_id and n.is_deleted=0
left outer join taxonomy_level lvl on lvl.id = dx.level_id
where dx.msl_release_num =  dbo.udf_getMSL(NULL) and dx.is_deleted=0
and dx.is_hidden=1 and (prev_tags like '%Renamed%' or next_tags like '%Renamed%') -- no deltas between hidden nodes
and dx.tree_id <> dx.taxnode_id -- trees are hidden, but DO have deltas
--order by dx.left_idx

order by cur_msl desc, lineage --desc

