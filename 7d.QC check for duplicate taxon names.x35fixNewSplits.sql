--
-- FIX duplicate taxa created by a new + split
--
-- new generally has better info (correct parent, molecule)
-- but we want to keep the split - it's more accurate 
-- so, xfer metadata to split and kill the new

--
-- Betanucleorhabdovirus','Alphanucleorhabdovirus','Hamaparvovirinae
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
where _dest_taxon_name in('Betanucleorhabdovirus','Alphanucleorhabdovirus','Hamaparvovirinae')
-- 'Betanucleorhabdovirus' in (_src_taxon_name, _dest_taxon_name)
order by dest_taxon_name, action


--
-- mark new's as isWrong
--
update load_next_msl set
	isWrong='split (814.1) and new(825). Use split, fix parent, molecule, etc.'
from load_next_msl
where sort in (825) and isWrong is null

update load_next_msl set
	isWrong='split (814) and new(815). Use split, fix parent, molecule, etc.'
from load_next_msl
where sort in (815) and isWrong is null

update load_next_msl set
	isWrong='split (373.1) and new(394). Use split, fix parent, molecule, etc.'
from load_next_msl
where sort in (394) and isWrong is null

--
-- taxonomy_node: move kids from split to new
--

-- Alphanucleorhabdovirus
update taxonomy_node set parent_id=201907681 where parent_id=201907678
-- Betanucleorhabdovirus
update taxonomy_node set parent_id=201907685 where parent_id=201907679
-- Hamaparvovirinae
update taxonomy_node set parent_id=201907324 where parent_id=201907310

--
-- taxonomy_node: delete split nodes
--
delete from taxonomy_node where taxnode_id in (201907678, 201907679, 201907310)

update load_nexT_msl set dest_taxnode_id=201907681 where dest_taxnode_id = 201907678
update load_nexT_msl set dest_taxnode_id=201907685 where dest_taxnode_id = 201907679
update load_nexT_msl set dest_taxnode_id=201907324 where dest_taxnode_id = 201907310
update load_next_msl set dest_taxnode_id=NULL where sort in (815,825, 394)

--
-- update in_change on taxonomy_node
--
select taxnode_id, level_id, lineage, in_change, in_filename, in_notes, in_target,
--RUN-- update  dest set 
	in_change=_action
	,in_filename = proposal
	, in_notes=spreadsheet
	, in_target=src._src_taxon_name
from taxonomy_node dest
join load_next_msl src on src.dest_taxnode_id = dest.taxnode_id
where src.sort in (814,814.1,373.1)


--commit transaction 
-- rollback transaction
