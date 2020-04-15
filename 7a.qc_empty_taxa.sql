--
-- manual fixups
--


-- ***** MSL 32 ******************************************************************************************************************************************

-- --------------------------------------------------------------------------------------
-- 
-- SCAN for orphan 'Unassigned' - NOT WORKING
-- Ex: MSL30, Tymovirales > Betaflexiviridae > [Unassigned] > Unassigned : has no kids
--
-- --------------------------------------------------------------------------------------
select
	report='scan for non-species nodes with no children'
	, p.msl_release_num, p.taxnode_id, p.ictv_id, p.rank, p.is_hidden, p.lineage,p.notes, _numKids
from taxonomy_node_names as p
where p.msl_release_num is not null
and p.level_id < 600
and p.is_deleted = 0
and not (
	-- Elliot: prior to 1999, species were not recognized. So higher-level taxa were established that did not formally contain species. 
	-- Many times they were populated with "viruses" and that is what was listed in the database. 
	-- But occasionally, no virus was designated that would have been assigned to the higher-level taxon. Hence these two taxa with no species/virus
	--p.lineage in ('')--('Unassigned;Poxviridae;Unassigned;Entomopoxvirus','Unassigned;Hepadnaviridae')
	p.notes like '%known empty taxon!%' and p.notes is not null
)
and _numKids = 0 
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7; empty taxa found', 18, 1) else print('PASS - no empty taxa')



--
-- AD HOC QUERIES
--
select 'load_next_msl', * from load_next_msl where 'Redondoviridae' in (_src_taxon_name, _dest_taxon_name)

select 'nextMSL', * from taxonomy_node where name = '%NBD2%' order by msl_release_num desc

select report='descendants', n.taxnode_id, n.rank,n.lineage
from taxonomy_node t
join taxonomy_node_names n on n.left_idx between t.left_idx and t.right_idx and n.tree_id = t.tree_id
where t.name in ('Scindoambidensovirus') and t.msl_release_num=35
order by n.left_idx

select report='ancestors', n.parent_id, n.taxnode_id, n.rank, n.name, n.lineage, n.in_change, n.in_filename
from taxonomy_node t
join taxonomy_node_names n on t.left_idx between n.left_idx and n.right_idx and n.tree_id = t.tree_id
where t.name = 'Vilniusvirus'
order by n.level_id 

select 
	report='duplicate dest_taxon_names in load_next_msl'
	, count=src.ct
	, ld.sort, ld._src_taxon_name, ld._action, ld.rank, ld._dest_parent_name, ld._dest_taxon_name, ld._dest_lineage, ld.isWrong
from load_nexT_msl ld
join (
	select _dest_taxon_name, ct= count(*)
	from load_next_msl
	where _action <> 'abolish'
	--and isWrong is null
	group by _dest_taxon_name
	having count(*) > 1
) src on src._dest_taxon_name=ld._dest_taxon_name
--where ld.isWrong is null
order by ld._dest_taxon_name, ld.sort

select 
	report='sort list' 
	, prev.taxnode_id, prev.rank, prev.name
	, prevMSL='<<<<'
	, ld.prev_taxnode_id, ld._src_taxon_name, ld.sort, ld._action, ld.rank, ld._dest_parent_name, ld._dest_taxon_name, ld.dest_taxnode_id
	, destMSL='<<<<'
	,dest.taxnode_id, dest.rank, dest.name, dest.lineage
from load_next_msl ld
left outer join taxonomy_node_names prev on prev.taxnode_id = ld.prev_taxnode_id
left outer join taxonomy_node_names dest on dest.taxnode_id = ld.dest_taxnode_id
where ld.sort between 173 and 186
order by ld.sort, isnull(prev.left_idx, dest.left_idx)


--
-- DATA CORRECTIONS
--

--
-- NO KIDS: Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Caudovirales;Podoviridae;Autographivirinae
--
-- subtaxa all moved, forgot to abolish.
--

-- add action to load_next_msl, for the record
--DEBUG-- DELETE FROM LOAD_NEXT_MSL WHERE SORT=1849.5
insert into load_next_msl (filename, sort, proposal_abbrev, proposal, spreadsheet, srcOrder, SrcFamily, srcSubFamily, change,  _action, rank, prev_taxnode_id, dest_taxnode_id)
select src.filename, sort+0.5, proposal_abbrev, proposal, spreadsheet, srcOrder, SrcFamily, srcSubFamily, change='abolish',  _action='abolish', rank='subfamily', prev_taxnode_id=prev.taxnode_id, dest_taxnode_id=dest.taxnode_id
from load_next_msl src
left outer join taxonomy_node prev on prev.name = srcSubFamily and prev.msl_release_num=dest_msl_release_num-1
left outer join taxonomy_node dest on dest.name = srcSubFamily and dest.msl_release_num=dest_msl_release_num
where sort=1849
and not exists (select * from load_next_msl tst where tst.sort=src.sort+0.5)

-- set out_change on prevMSL
update taxonomy_node set -- SELECT taxnode_id, level_id, lineage, 
	out_change=src._action
	,out_filename=src.proposal
from taxonomy_node
join load_next_msl src on taxnode_id=src.prev_taxnode_id
where sort=1849.5

-- remove row from nextMSL
delete from taxonomy_node -- SELECT taxnode_id, level_id, lineage, _numKids FROM taxonomy_node
where taxnode_id in (select dest_taxnode_id from load_next_msl where sort=1849.5)
and _numKids=0
--

--
-- NO KIDS: Riboviria;Orthornavirae;Negarnaviricota;Haploviricotina;Monjiviricetes;Mononegavirales;Rhabdoviridae;Nucleorhabdovirus
--
-- split, code didn't remove orignal name
--

--select sort, * from load_next_msl where dest_taxnode_id = 201901741 or _src_taxon_name = 'Nucleorhabdovirus'
delete from taxonomy_node
-- select _numKids, * from taxonomy_node 
where msl_release_num=35 and name='Nucleorhabdovirus'  and _numKids=0

--
-- NO KIDS: Monodnaviria;Shotokuvirae;Cossaviricota;Quintoviricetes;Piccovirales;Parvoviridae;Densovirinae;Ambidensovirus
--
-- split, code didn't remove orignal name
--
-- select sort, _src_taxon_name, isWRong, _action, _dest_parent_name, _dest_taxon_name, * from load_next_msl where dest_taxnode_id = 201901741 or _src_taxon_name = 'Ambidensovirus'
delete from taxonomy_node
-- select _numKids, * from taxonomy_node 
where msl_release_num=35 and name='Ambidensovirus' and _numKids=0

--
-- NO KIDS: Monodnaviria;Shotokuvirae;Cossaviricota;Quintoviricetes;Piccovirales;Parvoviridae;Pefuambidensovirus
-- NO KIDS: Monodnaviria;Shotokuvirae;Cossaviricota;Quintoviricetes;Piccovirales;Parvoviridae;Densovirinae;Blattambidensovirus
--
-- split (sort=374-374.9) put new genera directly in Parvoviridae, 
-- while new genus (same genera as split;sort=375,378,382, 385,388,390) 
-- put them under Densovirinae sub family. 
-- Removing the "new genus" and fixing the "splits"
--
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

select sort, _action, _dest_lineage,  sep='||', dest.taxnode_id, dest.lineage, dest.in_change, dest.in_filename, dest.in_target, dest.in_notes, _numKids
from load_next_msl aSplit
join taxonomy_node dest on dest.taxnode_id = aSplit.dest_taxnode_id
where aSplit.sort between 374 and 374.9 



-- ===================================================================================================================================
-- === MORE QC
-- ===================================================================================================================================

select 
	_src_taxon_rank, _action, _dest_taxon_rank
	,  * 
from load_next_msl 
where _src_taxon_rank <> _dest_taxon_rank
and (_action not in ('new') or _action is null) and (_action not in ('abolish') or _action is null)
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7; taxa change level badly', 18, 1) else print('PASS - no bad level changes')

--
-- DELETE 'Unassigned' subfamilies/genera with prejudice
--
-- RUN until 0 rows deleted (2x) - deleting an unassigned genus and leave an unassigned subfamily empty!
--
delete from taxonomy_node where taxnode_id in 
(
	select p.taxnode_id
	--select p.msl_release_num, p.taxnode_id, p.level_id, p.is_hidden, p.lineage
	from taxonomy_node as p
	left outer join taxonomy_node as c on c.parent_id = p.taxnode_id
	where p.msl_release_num is not null
	and (
		(p.level_id = 400 and p.is_hidden = 1) -- subfamily
		or
		(p.name = 'Unassigned')
	)
	group by p.msl_release_num, p.taxnode_id, p.level_id, p.is_hidden,  p.lineage
	having count(c.taxnode_id) = 0 
)

/*
-- query detail on children for a taxon across the years.
select tree=msl_release_num, lineage, * from taxonomy_node
where lineage like 'Unassigned;Hepadnaviridae%' 
order by tree_id, left_idx

-- query for details on a particular taxon's children
select t.lineage as 'target', tn.lineage as 'hit', tn.*
from taxonomy_node t
left outer join taxonomy_node as tn on tn.left_idx between t.left_idx and t.right_idx and tn.tree_id = t.tree_id
where t.taxnode_id =20162972
order by tn.left_idx

*/


-- -------------------------------------------------------------------
-- lowercase 'unassigned'
-- -------------------------------------------------------------------
update taxonomy_node set 
	--select ascii(name), name, 
	name = 'Unassigned' 
from taxonomy_node
where name = 'unassigned' and ascii(name)=117 -- lowercase U

-- -------------------------------------------------------------------
-- 3.	The ‘Unassigned’ designation when used for genera is sometimes upper, sometimes lower case
-- -------------------------------------------------------------------
update taxonomy_node set
	name = NULL
where taxnode_id in (
	select	-- select *,
		taxnode_id
	from taxonomy_node 
	where level_id=400 -- subfamily
	and is_hidden = 1 and name = 'unassigned'
)
-- -------------------------------------------------------------------
-- 1.	See extra line 2974 of your spreadsheet. 
-- CTRL-ENTER introduced in MSL30. Fixes 2 rows.
-- -------------------------------------------------------------------
update taxonomy_node set 
	-- select genbank_accession_csv, replace(genbank_accession_csv, char(10), ' '),
	genbank_accession_csv=replace(genbank_accession_csv, char(10), ', ')
from taxonomy_node 
where genbank_accession_csv like '%'+char(10)+'%' 





--
-- clean up quoted proposal filenames! ARG - shoudln't get this far!!!!
--
select 'quoted proposal name' as problem 
	, msl_release_num, lineage, in_filename, in_change, out_filename, out_change
from taxonomy_node n
where in_filename like '"%"'
or out_filename like '"%"'
	
update taxonomy_node set
	in_filename = REPLACE(in_filename,'"','')
where in_filename like '"%"'

update taxonomy_node set
	out_filename = REPLACE(out_filename,'"','')
where out_filename like '"%"'

update taxonomy_node_delta set
	proposal = REPLACE(proposal,'"','')
where proposal like '"%"'


--
-- add .pdf to existing filenames that lack an extension of .pdf or .zip
-- 
update taxonomy_node set 
--select *,
	in_filename = in_filename + '.pdf'
from taxonomy_node 
where in_filename is not null and in_filename not like '%.pdf'  and in_filename not like '%.zip'

update taxonomy_node set 
--select *,
	out_filename = out_filename + '.pdf'
from taxonomy_node 
where out_filename is not null and out_filename not like '%.pdf'  and out_filename not like '%.zip'

update taxonomy_node_delta set
-- select *,
	proposal = proposal + '.pdf'
from taxonomy_node_delta
where proposal is not null and proposal not like '%.pdf'  and proposal not like '%.zip'

