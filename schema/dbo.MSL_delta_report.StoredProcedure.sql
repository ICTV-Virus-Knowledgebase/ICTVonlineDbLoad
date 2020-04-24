USE [ICTVonlnie34]
GO
/****** Object:  StoredProcedure [dbo].[MSL_delta_report]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[MSL_delta_report]
	 @msl int = NULL
AS

-- brief delta list between an MSL and the previous one.
select @msl = isnull(@msl, max(msl_release_num)) from taxonomy_node
declare  @prev_msl int; SET @prev_msl = @msl-1

select 'TARGET MSLs', [current]=@msl, [prev]=@prev_msl, [excel_tab_name]='Deltas MSL'+rtrim(@prev_msl)+' v '+rtrim(@msl)

select 
	isnull(rtrim(prev.left_idx),'') as sort_old
	,isnull(plevel.name,'') as old_level
	,isnull(prev.lineage,'') as old_lineage
	, delta.tag_csv as change
	, isnull(delta.proposal,'') as proposal
	, isnull(dlevel.name,'') as new_level, isnull(dx.lineage,'') as new_lineage, isnull(dx.left_idx,'') as sort_new
from taxonomy_node_delta delta 
left outer join taxonomy_node dx on delta.new_taxid = dx.taxnode_id
left outer join taxonomy_level dlevel on dlevel.id = dx.level_id
left outer join taxonomy_node prev on prev.taxnode_id = delta.prev_taxid
left outer join taxonomy_level plevel on plevel.id = prev.level_id
where (dx.msl_release_num = @msl and delta.tag_csv <> '')
or (prev.msl_release_num = (@prev_msl) and delta.is_deleted =1)
order by dx.left_idx, prev.left_idx


GO
