--
-- test for history problem
-- SQL captured from 
--  http://denguedev.genome.uab.edu/dev/ddempsey/ICTVonline/taxonomyHistory.asp?taxnode_id=20142539
--
-- after adding zero-length enteries, things are better, but merges still don't show correctly
--
select 
	taxnode_id = node.taxnode_id
	, tree_id = node.tree_id
	, ictv_id = node.ictv_id
	, msl_id = msl.msl_release_num
	, year = msl.name, release_title = substring(msl.notes,1,255)
	, prev_tag_csv = (   
		case when max(prev_delta.is_merged)=1    then 'Merged,' else '' end    +case when max(prev_delta.is_renamed)=1  then 'Renamed,' else '' end    +case when max(prev_delta.is_promoted)=1  then 'Promoted,' else '' end    +case when max(prev_delta.is_split)=1  then 'Split,' else '' end    +case when max(prev_delta.is_new)=1      then 'New,' else '' end    +case when max(prev_delta.is_deleted)=1  then 'Abolished,' else '' end    +case when max(prev_delta.is_moved)=1    then 'Moved,' else '' end    +case when min(prev_delta.is_now_type)=1 then 'Assigned as Type Species,'    when min(prev_delta.is_now_type)=-1      then 'Removed as Type Species,' else '' end  )
		,  prev_notes= max(prev_delta.notes)
		, prev_proposal = isnull(min(prev_delta.proposal),'')
		, prev_proposal2 = case when min(prev_delta.proposal)<>max(prev_delta.proposal) then max(prev_delta.proposal) else '' end
		, current_lineage = node.lineage
		, current_is_type = node.is_ref
		, next_tag_csv = (   case when max(next_delta.is_merged)=1    then 'Merged,' else '' end    +case when max(next_delta.is_renamed)=1  then 'Renamed,' else '' end    +case when max(next_delta.is_promoted)=1  then 'Promoted,' else '' end    +case when max(next_delta.is_split)=1  then 'Split,' else '' end    +case when max(next_delta.is_new)=1      then 'New,' else '' end    +case when max(next_delta.is_deleted)=1  then 'Abolished,' else '' end    +case when max(next_delta.is_moved)=1    then 'Moved,' else '' end    +case when min(next_delta.is_now_type)=1 then 'Assigned as Type Species,'    when min(next_delta.is_now_type)=-1      then 'Removed as Type Species,' else '' end )
	, next_notes = max(next_delta.notes)
	, next_proposal =  isnull(min(next_delta.proposal),'')
	, next_proposal2 = case when min(next_delta.proposal)<>max(next_delta.proposal) then max(next_delta.proposal) else '' end  
from taxonomy_node_x as node 
join taxonomy_node as msl on msl.taxnode_id = node.tree_id 
left outer join taxonomy_node_delta as prev_delta on prev_delta.new_taxid = node.taxnode_id 
left outer join taxonomy_node_delta as next_delta on next_delta.prev_taxid = node.taxnode_id 
where node.target_taxnode_id = 20130392 
and node.tree_id >= 19000000 
and node.is_deleted = 0 
and node.is_hidden=0 
group by    node.taxnode_id, node.tree_id, node.ictv_id, msl.msl_release_num, msl.name,    substring(msl.notes,1,255), node.lineage, node.is_ref, node.left_idx,    next_delta.proposal, next_delta.is_merged, next_delta.is_renamed, next_delta.is_new,    next_delta.is_deleted, next_delta.is_moved, next_delta.is_now_type, next_delta.tag_csv,    next_delta.notes, prev_delta.notes 
order by msl.msl_release_num, node.left_idx 

select node.* 
from taxonomy_node as node
where node.taxnode_id = 20130392

select * 
from taxonomy_node_delta 
where new_taxid = 20130392 or prev_taxid is null

select node.* 
from taxonomy_node_x as node
where node.target_taxnode_id in (19991442,20140392)

select * from taxonomy_node_merge_split
where 19991442 in (prev_ictv_id, next_ictv_id)

-- find a historical merge
select * 
from taxonomy_node
where out_change='merge'
order by tree_id, left_idx

-- merge of two taxa
select taxnode_id,ictv_id,name, in_change, out_change
from taxonomy_node 
where taxnode_id in (20094569, 20084520, 20084582)

select * from taxonomy_node_merge_split
where prev_ictv_id in (19982263,20084582,20094569)
and next_ictv_id in (19982263,20084582,20094569)

-- check for species in moved genus flagged as moved
select * 
from taxonomy_node_dx
where tree_id=20130000 
and (
	name = 'Beet necrotic yellow vein virus'
	or
	name = 'Tomato mild mottle virus'
	or
	name = 'Hepandensovirus'
	)
	