USE [ICTVonline39]
GO
/****** Object:  View [dbo].[taxonomy_node_dx]    Script Date: 10/8/2024 4:19:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[taxonomy_node_dx] as
select 
	  prev_level = pt.level_id, prev_id = pd.prev_taxid, prev_ictv_id=pt.ictv_id, prev_tags = pd.tag_csv, prev_name=pt.name, prev_lineage=pt.lineage, prev_proposal=pd.proposal
	, next_level = nt.level_id, next_id = nd.new_taxid,  next_ictv_id=nt.ictv_id, next_tags = nd.tag_csv, next_name=nt.name, next_lineage=nt.lineage, next_proposal=nd.proposal
	, t.*
from taxonomy_node t
left outer join taxonomy_node_delta pd on pd.new_taxid = t.taxnode_id
left outer join taxonomy_node       pt on pt.taxnode_id = pd.prev_taxid
left outer join taxonomy_node_delta nd on nd.prev_taxid = t.taxnode_id
left outer join taxonomy_node       nt on nt.taxnode_id = nd.new_taxid
GO
