-- 
-- QC of merge split
--
-- as of MSL34 237 ICTV_IDs not in merge/split table - all hidden
-- normally a taxon should at least be in there as a dist=0 self/self
select [visble taxa missing from merge split]='MISSING', ictv_id, ct=count(*), hid=sum(is_hidden), min(lineage), max(lineage), max(in_change)
from taxonomy_node
where msl_release_num is not null and is_hidden=0
group by ictv_id
having 
	ictv_id NOT in (select NEXT_ictv_id from taxonomy_node_merge_split)
and 
	ictv_id NOT in (select PREV_ictv_id from taxonomy_node_merge_split)
order by ictv_id desc

/* -- RESEARCH

-- 
-- details on a specific taxon
--
select msl_release_num, taxnode_id, ictv_id, is_hidden, lineage, t='>>splitmerge', tms.*
from taxonomy_node tn
left outer  join taxonomy_node_merge_split tms on tms.next_ictv_id = tn.ictv_id
where 
--msl_release_num = 34
tn.taxnode_id =201853960
-- ICTV_id = 19870699
-- ( tms.prev_ictv_id is null or tms.nexT_ictv_id is null) -- missing merge-split - should at least be in there as a dist=0 self/self
order by tn.msl_release_num desc

*/