9---
--- fix HCV stops at MSL15? more generally?
---

begin transaction
-- rollback transaction

--
-- clean "Unassigned;" out of targets
--
update taxonomy_node set -- select out_target, 
	out_target = replace(out_target,'Unassigned;', '')
from taxonomy_node
where out_target like '%Unassigned%'

update taxonomy_node set -- select in_target, 
	in_target = replace(in_target,'Unassigned;', '')
from taxonomy_node
where in_target like '%Unassigned;%'

--what about "Tectiviridae;Unassigned"? CAse of targetting the genus that will contain the species
-- so add the species name back on. 
update taxonomy_node set -- select out_target, 
	out_target = replace(out_target,';Unassigned', '')+';'+name
from taxonomy_node
where out_target like '%;Unassigned'




select
	report='problem: HCV starts at MLS15 - detail HCV'
	,flag=(case when not (prev_tags='' /*and next_tags=''*/) then '>>>>>' else '' end)
	,release=(select name from taxonomy_node rt where rt.tree_id=dx.tree_id and rt.level_id=100), msl_release_num
	, prev_tags, is_hidden, taxnode_id, ictv_id, lineage, next_tags
	, out_change, out_target, out_filename,  in_change, in_target, in_filename
	, [filename]
	,*
from taxonomy_node_dx dx
where 
-- ictv_id in (20115486)
name like '%Hepacivirus C%' or ictv_id in (19910774)
--and not (prev_tags='' and next_tags='')
order by dx.tree_id desc



--
-- list ICTV_ID's with potential problems
--
select report='list ICTV_IDs with potential in_delta problems', ictv_id, msl_ct=count(msl_release_num), prev_tag_ct=count(prev_tags), next_tags_ct=count(next_tags)
from taxonomy_node_dx
where msl_release_num is not null
--and ictv_id = 19910774
group by ictv_id
having count(msl_release_num) <> count(prev_tags)


--
-- ok - more general fix to the problem?
-- fix-up the delta's for things we can connect that hav delta.new_taxid=NULL 
--
select
	report='problem: no prev_tags (entering delta) but not ictv_founder'
	,flag=(case when not (prev_tags='' /*and next_tags=''*/) then '>>>>>' else '' end)
	,release=(select name from taxonomy_node rt where rt.tree_id=dx.tree_id and rt.level_id=100), msl_release_num
	, prev_tags, is_hidden, taxnode_id, ictv_id, lineage, next_tags
	, out_change, out_target, out_filename,  in_change, in_target, in_filename
	,*
from taxonomy_node_dx dx
where 
prev_tags is null
AND ictv_id < taxnode_id
-- AND ictv_id in (20115486)
AND (name like '%Hepacivirus C%' or ictv_id in (19910774))
--and not (prev_tags='' and next_tags='')
order by dx.tree_id desc




-- problem deltas - no new_taxid, NOT deleted
select report='problem deltas - no new_taxid, NOT deleted',  * from taxonomy_node_delta where prev_taxid is not null and  new_taxid is null and is_deleted = 0


--
-- find deltas missing the new_taxid, where we can use out_target to find it in msl+1.
--
select proposed_change='find deltas missing the new_taxid, where we can use out_target to find it in msl+1'
	, d.*
	, tn.msl_release_num, tn.out_change
	, tn.level_id, nw.level_id
	, renam = (case when tn.name <> nw.name then '1' else '0' end)
	, tn.out_target
	, out_target_taxon = (rtrim(ltrim(reverse(left(replace(reverse(tn.out_target),';',replicate(' ',1000)),500)))))
	, nw.lineage, nw.msl_release_num
	,'|||',tn.name, renam2 = (case when tn.name <> nw.name then 1 else 0 end), nw.name
	,'>>>',
	--update taxonomy_node_delta set
	new_taxid=nw.taxnode_id
	, is_renamed =  (case when tn.name <> nw.name then 1 else 0 end)
	, is_moved =    (case when tnp.lineage <> nwp.lineage then 1 else 0 end)
	, is_now_type = (case when nw.is_ref is null or tn.is_ref is null then 0 else nw.is_ref - tn.is_ref end)
from taxonomy_node_delta d
join  taxonomy_node tn on  tn.is_deleted=0 and tn.taxnode_id = d.prev_taxid 
left outer join taxonomy_node nw on nw.is_deleted=0 and nw.msl_release_num=tn.msl_release_num+1 and (
	-- exact lineage match
	nw.lineage = tn.out_target
	or 
	-- name match on lineage terminator? 
	(rtrim(ltrim(reverse(left(replace(reverse(tn.out_target),';',replicate(' ',1000)),500))))) =nw.name
)
join taxonomy_node tnp on tnp.taxnode_id = tn.parent_id
join taxonomy_node nwp on nwp.taxnode_id = nw.parent_id
where d.prev_taxid is not null 
and  d.new_taxid is null 
and d.is_deleted = 0
and nw.taxnode_id is not null  -- only ones where we made a match
--and prev_taxid in (20151200,20140183,20151192,20164268,20163059)
--order by d.prev_taxid


-- problem with  MSL29 
--Caudovirales;Podoviridae;Pseudomonas phage F116	
--Caudovirales;Podoviridae;F116likevirus;Pseudomonas phage F116	
select is_deleted, * from taxonomy_node where name ='Pseudomonas phage F116' and msl_release_num=29

select * from taxonomy_node_dx where is_deleted = 1 and (prev_tags is not null or next_tags is not null)
