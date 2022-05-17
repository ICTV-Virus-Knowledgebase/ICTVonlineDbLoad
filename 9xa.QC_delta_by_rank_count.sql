--
-- compute counts of changes by rank from taxonomy_node_delta
--
-- something that is moved AND renamed will be counted for each.
--

/*select 
	src_taxid = count(distinct prev_taxid)
	,is_merged=count(case when is_merged=1 then 1 end)
	,is_split=count(case when is_split=1 then 1 end)
	,is_moved=count(case when is_moved=1 then 1 end)
	,is_promoted=count(case when is_promoted=1 then 1 end)
	,is_demoted=count(case when is_demoted=1 then 1 end)
	,is_renamed=count(case when is_renamed=1 then 1 end)
	,is_new=count(case when is_new=1 then 1 end)
	,is_deleted=count(case when is_deleted=1 then 1 end)
	,new_taxid=count(distinct new_taxid)
from taxonomy_node_delta
where prev_taxid in (select taxnode_id from taxonomy_node where msl_release_num=37)
or 
	new_taxid in (select taxnode_id from taxonomy_node where msl_release_num=37)
*/
select 
		ranks
		,src_taxids = count(distinct src_taxid)
		,is_merged=  count(case when is_merged=1 then 1 end)
		,is_split=   count(case when is_split=1 then 1 end)
		,is_moved=   count(case when is_moved=1 then 1 end)
		,is_promoted=count(case when is_promoted=1 then 1 end)
		,is_demoted= count(case when is_demoted=1 then 1 end)
		,is_renamed= count(case when is_renamed=1 then 1 end)
		,is_new=     count(case when is_new=1 then 1 end)
		,is_deleted= count(case when is_deleted=1 then 1 end)
		,new_taxid=  count(distinct new_taxid)
from (
	select 
		ranks = (case when src.rank = dest.rank then src.rank 
				 when src.rank is null then dest.rank
				 when dest.rank is null then src.rank
				 else src.rank+'>>>'+dest.rank
				 end)
		,level_id = (case when src.rank = dest.rank then str(src.level_id)
				 when src.rank is null then str(dest.level_id)
				 when dest.rank is null then str(src.level_id)
				 else str(src.level_id)+'.'+str(dest.level_id)
				 end)
		,src_taxid = src.taxnode_id
		,is_merged=  delta.is_merged
		,is_split=   delta.is_split
		,is_moved=   delta.is_moved
		,is_promoted=delta.is_promoted
		,is_demoted= delta.is_demoted
		,is_renamed= delta.is_renamed
		,is_new=     delta.is_new
		,is_deleted= delta.is_deleted
		,new_taxid=  dest.taxnode_id

	from taxonomy_node_delta delta
	left outer join taxonomy_node_names src  on src.msl_release_num=36 and src.taxnode_id = delta.prev_taxid
	left outer join taxonomy_node_names dest on dest.msl_release_num=37 and dest.taxnode_id = delta.new_taxid
	where 
		delta.prev_taxid in (select taxnode_id from taxonomy_node where msl_release_num=36 and level_id > 100)
	or 
		delta.new_taxid in (select taxnode_id from taxonomy_node where msl_release_num=37 and level_id > 100)
) as counts
group by ranks, level_id
order by level_id