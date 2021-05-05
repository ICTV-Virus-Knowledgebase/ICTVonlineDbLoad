--
-- add DEMOTE
--
-- update tags_csv computed column on taxonomy_node_delta
-- to add a tag for is_demoted
--
--
GO
-- prototype new TAGS formula
select tag_csv
	, [tag_csv_v2] = 
	case when d.[is_merged]=1 then 'Merged,' else '' end+
	case when d.[is_split]=1 then 'Split,' else '' end+
	case when d.[is_renamed]=1 then 'Renamed,' else '' end+
	case when d.[is_new]=1 then 'New,' else '' end+
	case when d.[is_deleted]=1 then 'Abolished,' else '' end+
	case when d.[is_moved]=1 then 'Moved,' else '' end+
	case when d.[is_promoted]=1 then 'Promoted,' else '' end+
	case when d.[is_demoted]=1 then 'Demoted,' else '' end+
	case when d.[is_now_type]=1 then 'Assigned as Type Species,' when [is_now_type]=-1 then 'Removed as Type Species,' else '' end
	,d.[is_demoted], d.[is_promoted]
from taxonomy_node_delta d
left outer join taxonomy_node p on 
	(p.taxnode_id = d.prev_taxid and p.msl_release_num=(select max(msl_release_num)-1 from taxonomy_toc))
left outer join taxonomy_node n on 
	(n.taxnode_id = d.new_taxid and n.msl_release_num=(select max(msl_release_num) from taxonomy_toc))
where p.taxnode_id is not null or n.taxnode_id is not null
group by d.tag_csv, d.[is_merged],d.[is_split],d.[is_renamed],d.[is_new],d.[is_deleted],d.[is_moved],d.[is_promoted],d.[is_demoted],d.[is_now_type]

-- delete column (must first delete index)

GO
DROP INDEX [_dta_index_taxonomy_node_delta_8_143339575__K2_K1_K13] ON [dbo].[taxonomy_node_delta]
GO
alter table taxonomy_node_delta drop column [tag_csv];
go

-- create new computed column

alter table taxonomy_node_delta add [tag_csv] as (case when [is_merged]=1 then 'Merged,' else '' end+
	case when [is_split]=1 then 'Split,' else '' end+
	case when [is_renamed]=1 then 'Renamed,' else '' end+
	case when [is_new]=1 then 'New,' else '' end+
	case when [is_deleted]=1 then 'Abolished,' else '' end+
	case when [is_moved]=1 then 'Moved,' else '' end+
	case when [is_promoted]=1 then 'Promoted,' else '' end+
	case when [is_demoted]=1 then 'Demoted,' else '' end+
	case when [is_now_type]=1 then 'Assigned as Type Species,' when [is_now_type]=-1 then 'Removed as Type Species,' else '' end)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO

-- re-create the index we had to drop 

CREATE NONCLUSTERED INDEX [_dta_index_taxonomy_node_delta_8_143339575__K2_K1_K13] ON [dbo].[taxonomy_node_delta]
(
	[new_taxid] ASC,
	[prev_taxid] ASC,
	[tag_csv] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO