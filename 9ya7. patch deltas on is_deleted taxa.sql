---
--- finx and fix other delta/is_deleted based problems
---
-- !!! NOT DONE !!!

begin transaction
-- ROLLBACK transaction
-- commit transaction





--
-- list ICTV_ID's with potential problems
--
select report='list ICTV_IDs with potential in_delta problems', ictv_id, msl_ct=count(msl_release_num), prev_tag_ct=count(prev_tags), next_tags_ct=count(next_tags)
from taxonomy_node_dx
where msl_release_num is not null
--and ictv_id = 19910774
group by ictv_id
having count(msl_release_num) <> count(prev_tags)

-- get details on one
select
	report='problem: fewer prev_tags than msls'
	,flag=(case when not (prev_tags='' /*and next_tags=''*/) then '>>>>>' else '' end)
	,release=(select name from taxonomy_node rt where rt.tree_id=dx.tree_id and rt.level_id=100), msl_release_num
	, prev_tags, is_hidden, taxnode_id, ictv_id, lineage, next_tags
	, out_change, out_target, out_filename,  in_change, in_target, in_filename
	, [filename]
	,*
from taxonomy_node_dx dx
where 
ictv_id in (19911849) -- Tobamovirus group;Tobacco mild green mosaic virus
order by dx.tree_id desc




-- problem deltas - no new_taxid, NOT deleted
select report='problem deltas - no new_taxid, NOT deleted',  * from taxonomy_node_delta where prev_taxid is not null and  new_taxid is null and is_deleted = 0



-- problem with  MSL29 
--Caudovirales;Podoviridae;Pseudomonas phage F116	
--Caudovirales;Podoviridae;F116likevirus;Pseudomonas phage F116	
select is_deleted, * from taxonomy_node where name ='Pseudomonas phage F116' and msl_release_num=29

select * from taxonomy_node_dx where is_deleted = 1 and (prev_tags is not null or next_tags is not null)
