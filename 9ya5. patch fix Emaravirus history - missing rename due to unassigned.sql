--
-- fix history: Emaravirus
--
-- 2016 (MSL31) MOVE was not showing up in history
-- MSL30 out_target is 'Bunyavirales;Fimoviridae;unassigned;Emaravirus'
-- MSL31 lineage    is 'Bunyavirales;Fimoviridae;Emaravirus'
-- because we eliminated the "unassigned"s


select
	flag=(case when not (prev_tags='' /*and next_tags=''*/) then '>>>>>' else '' end)
	,release=(select name from taxonomy_node rt where rt.tree_id=dx.tree_id and rt.level_id=100), msl_release_num
	, prev_tags, is_hidden, taxnode_id, ictv_id, lineage, next_tags
	, out_change, out_target, out_filename,  in_change, in_target, in_filename
	, [filename]
	,*
from taxonomy_node_dx dx
where name ='Emaravirus'
--and not (prev_tags='' and next_tags='')
order by dx.tree_id desc

select * from taxonomy_node where ictv_id = 20091355
order by tree_id desc



select * 
from taxonomy_node_delta d
where 20170008 in (prev_taxid, new_taxid)
 or 20164482 in (prev_taxid, new_taxid)
  or 20154495 in (prev_taxid, new_taxid)
  order by isnull(prev_taxid, new_taxid) desc

 /**********************
  * actual fixes
  **********************
 delete from taxonomy_node_delta where prev_taxid = 20154495
 
  insert into taxonomy_node_delta (prev_taxid, new_taxid, proposal, notes, is_moved) 
  values (20154495,20164482,'2016.030a-vM.A.v6.Bunyavirales.pdf','ROWS:714-932',1)


 */

 select 'problem: no new_taxid, but not "deleted" expressly', * from taxonomy_node_delta where new_taxid is null and is_deleted = 0

 select msl_release_num,  taxnode_id, in_target,in_change, prev_id, is_hidden, lineage, leftRight=(right_idx-left_idx-1), next_id, out_change,  out_target
	, delta_ct=(select count(*) from taxonomy_node_delta d where dx.taxnode_id in (d.prev_taxid, d.new_taxid))
 from taxonomy_node_dx dx

 where msl_release_num is not null
 and (
	lineage like '%unassigned%' 
	--or in_target like '%unassigned%' 
	--or out_target like '%unassigned%' 
	)
	order by msl_release_num desc
