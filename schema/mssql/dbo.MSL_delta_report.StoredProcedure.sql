
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[MSL_delta_report]
	 @msl int = NULL,
	 @server varchar(200) = 'ictv.global'
AS
--
-- brief delta list between an MSL and the previous one.
--
-- TEST
--    exec [MSL_delta_report]
--
--	  exec [MSL_delta_report] 38 'test.ictv.global'

select @msl = isnull(@msl, max(msl_release_num)) from taxonomy_node
declare  @prev_msl int; SET @prev_msl = @msl-1

select 'TARGET MSLs', [current]=@msl, [prev]=@prev_msl, [excel_tab_name]='Deltas MSL'+rtrim(@prev_msl)+' v '+rtrim(@msl)

select 
	report='all_changes',
	isnull(rtrim(prev.left_idx),'') as sort_old
	,isnull(plevel.name,'') as old_rank
	,isnull(plevel.id,'') as old_level
	,isnull(prev.lineage,'') as old_lineage
	, delta.tag_csv as change
	, isnull(delta.proposal,'') as proposal
	, proposal_url = (case
			when delta.proposal is null then ''
			when delta.proposal not like '%;%' then '=HYPERLINK("https://ictv.global/ictv/proposals/'+delta.proposal+'","'+delta.proposal+'")'
			-- if multiple proposals in a ;-sep list, link them all to the first one (Excel only allows one link per cell)
			when delta.proposal     like '%;%' then '=HYPERLINK("https://ictv.global/ictv/proposals/'+left(delta.proposal,charindex(';',delta.proposal)-1)+'","'+delta.proposal+'")'
			end)
	, isnull(dlevel.name,'') as new_rank
	, isnull(dlevel.id,'') as new_level
	, isnull(dx.lineage,'') as new_lineage
	, isnull(dx.left_idx,'') as sort_new
from taxonomy_node_delta delta 
left outer join taxonomy_node dx on delta.new_taxid = dx.taxnode_id
left outer join taxonomy_level dlevel on dlevel.id = dx.level_id
left outer join taxonomy_node prev on prev.taxnode_id = delta.prev_taxid
left outer join taxonomy_level plevel on plevel.id = prev.level_id
where (dx.msl_release_num = @msl and delta.tag_csv <> '')
or (prev.msl_release_num = (@prev_msl) and delta.is_deleted =1)
order by isnull(dlevel.id,plevel.id), dx.left_idx, prev.left_idx



--  DECLARE @server varchar(200); DECLARE @msl int; SET @server = 'ictv.global'; SET @msl=40
select 
	_level_id = level_id, _left_idx = left_idx,
	_report='renames_only; by rank, then left_idx'
	, ictv_id_url = '=HYPERLINK("https://'+@server+'/taxonomy/taxondetails?taxnode_id='+rtrim(dx.prev_id)+'&ictv_id=ICTV'+rtrim(dx.prev_ictv_id)+'","ICTV'+rtrim(dx.prev_ictv_id)+'")'
	, rank= (case when tl.name=ptl.name then tl.name else ptl.name+'>'+tl.name end) 
	, action=left(dx.prev_tags,len(dx.prev_tags)-1)
	, old_lineage  =dx.prev_lineage
	, new_lineage=  dx.lineage
	, proposal_url = (case
			when dx.prev_proposal is null then ''
			when dx.prev_proposal not like '%;%' then '=HYPERLINK("https://'+@server+'/ictv/proposals/'+dx.prev_proposal+'","'+dx.prev_proposal+'")'
			-- if multiple proposals in a ;-sep list, link them all to the first one (Excel only allows one link per cell)
			when dx.prev_proposal     like '%;%' then '=HYPERLINK("https://'+@server+'/ictv/proposals/'+left(dx.prev_proposal,charindex(';',dx.prev_proposal)-1)+'","'+dx.prev_proposal+'")'
			end)
from  taxonomy_node_dx dx
join taxonomy_level tl on tl.id = dx.level_id
join taxonomy_level ptl on ptl.id = dx.prev_level
where ( dx.prev_tags like '%rename%'  AND dx.msl_release_num = @msl)

UNION ALL
	
--  DECLARE @server varchar(200); DECLARE @msl int; SET @server = 'ictv.global'; SET @msl=40
select 
	prev_level, left_idx,
	report='abolish_only; by rank, then left_idx'
	, ictv_id_url = '=HYPERLINK("https://'+@server+'/taxonomy/taxondetails?taxnode_id='+rtrim(dx.taxnode_id)+'&ictv_id=ICTV'+rtrim(dx.ictv_id)+'","ICTV'+rtrim(dx.ictv_id)+'")'
	, rank= tl.name 
	, action=left(dx.next_tags,len(dx.next_tags)-1)
	, old_lineage  =dx.lineage
	, new_lineage=  ISNULL(dx.next_lineage,'')
	, proposal_url = (case
			when dx.next_proposal is null then ''
			when dx.next_proposal not like '%;%' then '=HYPERLINK("https://'+@server+'/ictv/proposals/'+dx.next_proposal+'","'+dx.next_proposal+'")'
			-- if multiple proposals in a ;-sep list, link them all to the first one (Excel only allows one link per cell)
			when dx.next_proposal     like '%;%' then '=HYPERLINK("https://'+@server+'/ictv/proposals/'+left(dx.next_proposal,charindex(';',dx.next_proposal)-1)+'","'+dx.prev_proposal+'")'
			end)
from  taxonomy_node_dx dx
join taxonomy_level tl on tl.id = dx.level_id
where dx.next_tags like '%abolish%'  
AND dx.msl_release_num = (@msl-1)

order by level_id, old_lineage


/* test

exec [MSL_delta_report]

*/
GO

