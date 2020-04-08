--
-- historic lineage=%Unassigned% nodes which were locked in as ictv_id "founders" 
-- 

select report='problem: no new_taxid, but not "deleted" expressly', * 
from taxonomy_node_delta 
where new_taxid is null and is_deleted = 0


select report='problem: unassinged nodes'
	, msl_release_num,  taxnode_id, ictv_id, in_target,in_change, prev_id, is_hidden, lineage, leftRight=(right_idx-left_idx-1), next_id, out_change,  out_target
	, delta_ct=(select count(*) from taxonomy_node_delta d where dx.taxnode_id in (d.prev_taxid, d.new_taxid))
from taxonomy_node_dx dx
where msl_release_num is not null and (
	lineage like '%unassigned%'
--	or lineage like '%unnamed genus' 
	--or in_target like '%unassigned%' 
	--or out_target like '%unassigned%' 
)
order by msl_release_num desc


select ictv=ictv_id, lineage, right_idx-left_idx-1, msl_release_num, * from taxonomy_node_dx where ictv_id in (
	select -- report='problem: unassinged, no kids, no link nodes'
		dx.ictv_id
	from taxonomy_node_dx dx
	where msl_release_num is not null 
	and lineage like '%unassigned%' 
	and (right_idx-left_idx-1) = 0 -- no kids
	and (select count(*) from taxonomy_node_delta d where dx.taxnode_id in (d.prev_taxid, d.new_taxid)) = 0 -- no delta links
	)
order by ictv_id, tree_id desc

begin transaction
--delete from taxonomy_node where taxnode_id=20081061 -- ok if no non-MSL releases use ICTV_ID
-- rollback transaction

select change='push ictv_id back to smallest taxnode_id so we can delete MSL Unassigned nodes', tn.msl_release_num, tn.lineage, tn.ictv_id,
--update taxonomy_node set 
	ictv_id=src.min_ictv_id
from taxonomy_node tn 
join (
	select ictv_id, min_ictv_id=min(taxnode_id)
	from taxonomy_node 
	where name <> 'Unassigned'
	group by ictv_id
	having ictv_id <> min(taxnode_id) and  ictv_id in (
		select -- report='problem: unassinged, no kids, no link nodes'
			dx.ictv_id
		from taxonomy_node_dx dx
		where msl_release_num is not null 
		and lineage like '%unassigned%' 
		and (right_idx-left_idx-1) = 0 -- no kids
		and (select count(*) from taxonomy_node_delta d where dx.taxnode_id in (d.prev_taxid, d.new_taxid)) = 0 -- no delta links
	)
)  src on tn.ictv_id = src.ictv_id

-- disconnect Potyviridae;Unassigned - two MSL's use it, but not linkd anywhere else
select * from taxonomy_node where ictv_id= 20071138 
order by tree_id desc

select * ,
--update taxonomy_node set 
ictv_id = taxnode_id from taxonomy_node where lineage in (
 'Potyviridae;Unassigned', 'Luteoviridae;Unassigned','Dicistroviridae;Unassigned'
,'- unnamed -;Dicistroviridae;- unnamed -;- unnamed -','- unnamed -;Luteoviridae;- unnamed -;- unnamed -' )

print '-- delete remaining UNASSIGNED, no kids, no link nodes'
delete from taxonomy_node
where taxnode_id in (
	select top 1  -- select report='problem: unassinged, no kids, no link nodes', ictv_id,
		dx.taxnode_id
	from taxonomy_node_dx dx
	where msl_release_num is not null 
	and lineage like '%unassigned%' 
	and (right_idx-left_idx-1) = 0 -- no kids
	and (select count(*) from taxonomy_node_delta d where dx.taxnode_id in (d.prev_taxid, d.new_taxid)) = 0 -- no delta links
)




-- commit transaction


--
-- do we have any duplicate names w/in MSLs, now? 
--
select msl_release_num, name, count(*), min(lineage), max(lineage)
from taxonomy_node
where msl_release_num is not null and is_deleted = 0
group by msl_release_num, name
having count(*) > 1
--
-- nope - still 11 problems
--
/*
MSL	taxon.name	count
--- ----------- -----
5	Cardiovirus	2
22	Chayote mosaic virus	2
12	Influenza virus C	2
13	Influenza virus C	2
1	Lipid phage PM2	2
2	Lipid phage PM2	2
3	Lipid phage PM2	2
1	Polyomavirus	2
2	Polyomavirus	2
3	Polyomavirus	2
15	Unnamed genus	4

*/