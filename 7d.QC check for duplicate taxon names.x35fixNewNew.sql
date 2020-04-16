--
-- FIX duplicate taxa created by a new + a 2nd New
--
-- one new generally has better info (correct parent, molecule)
-- but we want to keep the split - it's more accurate 
-- so, xfer metadata to split and kill the new

--
-- Tubulavirales, Cressdnaviricota, Plectroviridae
--
BEGIN TRANSACTION 

--
-- details on LOAD_NEXT_MSL w/ prev, dest, and destParent
--
select 
	sort, spreadsheet, _src_taxon_name, isWrong=left(isWRong,20), action=_action, _dest_parent_name, dest_taxon_name=_dest_taxon_name, dest_taxnode_id, dest_parent_id, _dest_parent_name, src.molecule
	, prev='>>>', prev.taxnode_id, prev.out_change, prev.out_filename
	, dest='>>>', dest.taxnode_id, dest.in_change, dest.in_filename, dest.lineage, dest._numKids
	, destParent='byNameOrId>>>', destp.taxnode_id, destp.lineage
from load_next_msl src
left outer join taxonomy_node_names prev on prev.taxnode_id = src.prev_taxnode_id
left outer join taxonomy_node_names dest on dest.taxnode_id = src.dest_taxnode_id
left outer join taxonomy_node_names destp on destp.taxnode_id = src.dest_parent_id or (destp.msl_release_num=src.dest_msl_release_num and destp.name=src._dest_parent_name)
where _dest_taxon_name in('Tubulavirales','Cressdnaviricota','Plectroviridae')
-- 'Betanucleorhabdovirus' in (_src_taxon_name, _dest_taxon_name)
order by dest_taxon_name, action

-- more details: DESCENDANTS
select report='descendants', n.in_change, n.taxnode_id,n.ictv_id, n.molecule ,n.rank,n.lineage
from taxonomy_node t
join taxonomy_node_names n on n.left_idx between t.left_idx and t.right_idx and n.tree_id = t.tree_id
where t.name in ('Plectroviridae') and t.msl_release_num=35
order by n.left_idx

--
-- mark new's as isWrong
--
update load_next_msl set
	isWrong='new(450) and new(449) with diff parents. Use 449 (Shotokuvirae)'
from load_next_msl
where sort in (450) and isWrong is null

update load_next_msl set
	isWrong='new(1015) and new(1014) with diff parents. Use 1014 (Faserviricetes)'
from load_next_msl
where sort in (1015) and isWrong is null

update load_next_msl set
	isWrong='new(166) and new(1018). Both correct, though differ on molecule (ssDNA vs ssDNA(+)). Keep 1018 '
from load_next_msl
where sort in (166) and isWrong is null

--
-- taxonomy_node: move kids from bad new to good new
--

-- 201907373 Cressdnaviricota >> 201907372 Monodnaviria;Shotokuvirae;Cressdnaviricota
update  taxonomy_node set parent_id=201907372 where parent_id=201907373
-- 201907855 Tubulavirales >> 201907854 Monodnaviria;Loebvirae;Hofneiviricota;Faserviricetes;Tubulavirales 
update taxonomy_node set parent_id=201907854 where parent_id=201907855
-- 201907165 Monodnaviria;Loebvirae;Hofneiviricota;Faserviricetes;Tubulavirales;Plectroviridae => 201907857 Monodnaviria;Loebvirae;Hofneiviricota;Faserviricetes;Tubulavirales;Plectroviridae
update taxonomy_node set parent_id=201907857 where parent_id=201907165

--
-- taxonomy_node: delete split nodes
--
select taxnode_id, level_id, lineage, _numKids
--RUN-- delete 
from taxonomy_node where taxnode_id in (201907373, 201907855, 201907165)



--
-- double check the fix is in
--
select 'just this MSL' as scope, msl_release_num, name, count=COUNT(name)
	, [duplicate taxon names] = (case when name = 'unassigned' and min(level_id)=500 and max(level_id)=500 then 'OK - Unassigned genera permitted' else 'PROBLEM!' end)
	, MIN(lineage) as min_lineage, MAX(lineage) as max_lineage
from taxonomy_node
where msl_release_num = (select MAX(msl_release_num) from taxonomy_node_toc)
group by msl_release_num, name
having COUNT(name) > 1


--commit transaction 
-- rollback transaction
