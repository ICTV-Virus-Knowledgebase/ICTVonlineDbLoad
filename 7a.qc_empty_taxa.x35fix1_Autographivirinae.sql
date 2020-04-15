-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Caudovirales;Podoviridae;Autographivirinae
--
-- subtaxa all moved, forgot to abolish.
--
-- Correction: code this as promotion of Autographivirinae to Autographiviridae
--
-- --------------------------------------------------------------------------------------------------

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

-- --------------------------------------------------------------------------------------------------
--
-- Correction: re-code this as promotion of Autographivirinae to Autographiviridae
--
-- --------------------------------------------------------------------------------------------------

BEGIN TRANSACTION

--
-- redo as PROMOTION
--

-- list new=1423/abolish=1849.5 pair
--
select 
	report='sort list' 
	, prev.taxnode_id, prev.rank, prev.name, prev.lineage, prev.out_change
	, prevMSL='<<<<'
	, ld.prev_taxnode_id, ld._src_taxon_name, ld.sort, ld._action, ld.rank, ld._dest_parent_name, ld._dest_taxon_name, ld.dest_taxnode_id
	, destMSL='<<<<'
	, dest.in_change	,dest.taxnode_id, dest.rank, dest.name, dest.lineage
from load_next_msl ld
left outer join taxonomy_node_names prev on prev.taxnode_id = ld.prev_taxnode_id
left outer join taxonomy_node_names dest on dest.taxnode_id = ld.dest_taxnode_id
where ld._src_taxon_name = 'Autographivirinae' or ld._dest_taxon_name='Autographiviridae' --ld.sort between 173 and 186
order by ld.sort, isnull(prev.left_idx, dest.left_idx)

select report='ancestors', n.parent_id, n.taxnode_id, n.rank, n.name, n.lineage, n.in_change, n.in_filename
from taxonomy_node t
join taxonomy_node_names n on t.left_idx between n.left_idx and n.right_idx and n.tree_id = t.tree_id
where t.name = 'Autographivirinae' and t.msl_release_num=34
order by n.level_id 

-- update the new into an promote
select promote.sort, promote._src_taxon_rank, promote._src_lineage, promote._action, promote._dest_taxon_rank, promote._dest_lineage, upd='>>>', 
--RUN-- update promote set
	
	change='promote subfamily to family'
	, _action='promote'
	, prev_taxnode_id = abolish.prev_taxnode_id
	, srcOrder=abolish.srcOrder
	, srcFamily=abolish.srcFamily

from load_next_msl as promote
join load_nexT_msl as abolish on abolish.sort=1849.5
where promote.sort=1423
and _action <> 'promote'

-- isWrong the abolish
select abolish.sort, abolish._src_taxon_rank, abolish._src_lineage, abolish._action, abolish._dest_taxon_rank, abolish._dest_lineage, upd='>>>', 
--RUN-- update abolish set
	isWrong = 'per Elliot, recode abolish/new as promote subfamily Autographivirinae in 2019.103B as a ‘promote’ to the new family, Autographiviridae'
from load_nexT_msl as abolish 
where abolish.sort=1849.5
and isWrong is null

-- update prevMSL out_changes
select prev.msl_release_num, prev.taxnode_id, prev.lineage, prev.out_change, prev.out_filename, prev.out_notes,prev.out_target, sep='>>>',
--RUN-- update prev set
	out_change='promote'
	, out_filename=load_next_msl.proposal
	, out_notes=load_next_msl.spreadsheet
	, out_target=dest.lineage
from taxonomy_node prev
join load_next_msl on prev.taxnode_id = prev_taxnode_id 
join taxonomy_node dest on dest.taxnode_id = desT_taxnode_id
where sort=1423
and (prev.out_change is null or prev.out_change <> 'promote')


-- update nextMSL in_changes
select msl_release_num, taxnode_id, lineage, in_change, in_filename, in_notes, in_target, sep='>>>',
--RUN-- update taxonomy_node set
	in_change=NULL
	, in_filename=NULL
	, in_notes=NULL
	, in_target=NULL
from taxonomy_node where taxnode_id in (
	select dest_taxnode_id 
	from load_next_msl
	where sort=1423
)
and in_change ='new'

--COMMIT TRANSACTION
--ROLLBACK TRANSACTION

