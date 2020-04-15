-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Monodnaviria;Shotokuvirae;Cossaviricota;Quintoviricetes;Piccovirales;Parvoviridae;Pefuambidensovirus
-- NO KIDS: Monodnaviria;Shotokuvirae;Cossaviricota;Quintoviricetes;Piccovirales;Parvoviridae;Densovirinae;Blattambidensovirus
--
-- split (sort=374-374.9) put new genera directly in Parvoviridae, 
-- while new genus (same genera as split;sort=375,378,382, 385,388,390) 
-- put them under Densovirinae sub family. 
-- Removing the "new genus" and fixing the "splits"
--
-- --------------------------------------------------------------------------------------------------
BEGIN TRANSACTION 

select 
	sort, _src_taxon_name, isWrong=left(isWRong,20), action=_action, _dest_parent_name, dest_taxon_name=_dest_taxon_name, * 
from load_next_msl
where sort between 374 and 374.9 
or sort in (375,378,382, 385,388,390) 
order by dest_taxon_name, action

update load_next_msl set
	isWrong='split (sort=374-374.9) put new genera directly in Parvoviridae, '
	+  'while new genus (same genera as split;sort=375,378,382, 385,388,390) '
	+  'put them under Densovirinae sub family. '
	+  'Removing the "new genus" and fixing the "splits"'
from load_next_msl
where sort in (375,378,382, 385,388,390) 

-- move kids of (soon to be deleted) "split" nodes (which are under the wrong taxa) to the matching "new" node

select 
	report='link taxa produced by matching new/split actions'
	-- aNew
	,aNew.sort, aNew._action, aNew._dest_lineage
	,  sep='||', newDest.taxnode_id, newDest.lineage, newDest.in_change, newDest.in_filename, newDest.in_target, newDest.in_notes,newDest._numKids
	-- aSplit
	,  sep='||', aSplit.sort, aSplit._action, aSplit._dest_lineage
	,  sep='||', splitDest.taxnode_id, splitDest.lineage, splitDest.in_change, splitDest.in_filename, splitDest.in_target, splitDest.in_notes, splitDest._numKids

from load_next_msl aNew
join load_nexT_msl aSplit on aSplit._dest_taxon_name = aNew._dest_taxon_name and aSplit._action='split' and  aSplit.sort between 374 and 374.9 
join taxonomy_node newDest on newDest.taxnode_id = aNew.dest_taxnode_id
join taxonomy_node splitDest on splitDest.taxnode_id = aSplit.dest_taxnode_id
where aNew.sort in (375,378,382, 385,388,390) 

-- change parantage

	--parent_id=201907317 where taxnode_id=201907311
select taxnode_id, parent_id, level_id, lineage, in_target, ssep='>>',
--RUN-- update taxonomy_node set 	
	parent_id = newSplit.new_dest_taxnode_id
	,in_target = newSplit.split_dest_in_target
from taxonomy_node
join (
	-- DEBUG - full report here
	select 
		report='link taxa produced by matching new/split actions'
		-- aNew
		, new_sort=aNew.sort, new_action=aNew._action, new_lineage=aNew._dest_lineage
		,  sep1='||', new_dest_taxnode_id=newDest.taxnode_id, new_dest_lineage=newDest.lineage, new_dest_in_change=newDest.in_change, new_deat_in_filename=newDest.in_filename, new_dest_in_target=newDest.in_target, new_dest_in_notes=newDest.in_notes,new_dest_numKids=newDest._numKids
		-- aSplit
		,  sep2='||', split_sort=aSplit.sort, split_action=aSplit._action, split_lineage=aSplit._dest_lineage
		,  sep3='||', split_dest_taxnode_id=splitDest.taxnode_id, split_dest_lineage=splitDest.lineage, split_dest_in_change=splitDest.in_change, split_dest_in_filename=splitDest.in_filename, split_dest_in_target=splitDest.in_target, split_date_in_notes=splitDest.in_notes, split_dest_numKides=splitDest._numKids
			from load_next_msl aNew
	join load_nexT_msl aSplit on aSplit._dest_taxon_name = aNew._dest_taxon_name and aSplit._action='split' and  aSplit.sort between 374 and 374.9 
	left outer join taxonomy_node newDest on newDest.taxnode_id = aNew.dest_taxnode_id
	left outer join taxonomy_node splitDest on splitDest.taxnode_id = aSplit.dest_taxnode_id
	where aNew.sort in (375,378,382, 385,388,390) 
) as newSplit on newSplit.split_dest_taxnode_id = taxonomy_node.parent_id

-- remove the incorrect taxa that were created by the split
delete from taxonomy_node
where taxnode_id in (
	select dest_taxnode_id	
	from load_next_msl aSplit
	where aSplit._action='split' and  aSplit.sort between 374 and 374.9 
)
--

-- update load_next_msl
--  * fix split to have subfamily=Densovirinae
--  * set split.dest_taxnode_id to the ones created by "new"
--
select aSplit.sort, aSplit._action, aSplit._dest_lineage, aSplit.dest_taxnode_id, '>>',
--RUN-- update aSplit set
	subfamily=aNew.subfamily
	,dest_taxnode_id = aNew.dest_taxnode_id
from load_nexT_msl aSplit 
join load_next_msl aNew on aSplit._dest_taxon_name = aNew._dest_taxon_name and aSplit._action='split' and  aSplit.sort between 374 and 374.9 
where aNew.sort in (375,378,382, 385,388,390) 

--
-- NULL the dest_taxnode_id for "new"s
--
select sort, _action, _dest_lineage
--RUN-- update aNew set dest_taxnode_id=NULL
from load_next_msl aNew
where aNew.sort in (375,378,382, 385,388,390) 

commit transaction