/*
 * DEMOTE
 * 
 * already added to taxonomy_change_out
 * add
 *	TABLE taxonomy_node_delta
 *  SP    update
 */

/*
 * schema changes
 */

-- create column
alter table taxonomy_node_delta add is_demoted int null;
GO
-- open MSSQL Studio and move it to the correct position by hand (no SQL for this?)

-- set default value
ALTER TABLE [dbo].[taxonomy_node_delta] ADD  CONSTRAINT [DF_taxonomy_node_delta_is_demoted]  DEFAULT ((0)) FOR [is_demoted]
GO

-- populate with default values
update taxonomy_node_delta set is_demoted=0

-- change column to be "NOT NULL"
GO
alter table taxonomy_node_delta alter column is_demoted int not null;
GO

-- check
select t='taxonomy_node_delta', is_demoted, ct=count(*) from taxonomy_node_delta group by is_demoted

-- rebuild views
exec refresh_views

-- test
select _numKids, '=93', right_idx, '=13072' from taxonomy_node_dx where msl_release_num=36 and name='Flaviviridae'
-- 
-- go update SP: rebuild_delta_nodes
--
exec rebuild_delta_nodes NULL -- defaults to latest MSL (36)

-- re-check flags
select t='taxonomy_node_delta', is_demoted, ct=count(*)
	,status=(case 
		when is_demoted=0 and count(*)=106118 then 'OK'
		when is_demoted=1 and count(*)=1		THEN 'OK'
		else 'ERROR'
		end)
from taxonomy_node_delta group by is_demoted

-- prototype new TAGS
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

-- apply new computed column
GO
DROP INDEX [_dta_index_taxonomy_node_delta_8_143339575__K2_K1_K13] ON [dbo].[taxonomy_node_delta]
GO
alter table taxonomy_node_delta drop column [tag_csv];
go
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

/****** Object:  Index [_dta_index_taxonomy_node_delta_8_143339575__K2_K1_K13]    Script Date: 5/5/2021 6:04:01 PM ******/
CREATE NONCLUSTERED INDEX [_dta_index_taxonomy_node_delta_8_143339575__K2_K1_K13] ON [dbo].[taxonomy_node_delta]
(
	[new_taxid] ASC,
	[prev_taxid] ASC,
	[tag_csv] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
-- re-check TAGS
select 
	t='taxonomy_node_delta'
	, prev_msl=min(p.msl_release_num), msl=max(n.msl_release_num)
	, d.is_demoted, d.is_promoted
	, tag_csv, ct=count(*)
	,status=(case 
		when max(n.msl_release_num)='36' and tag_csv=''				and count(*)=7586	then 'OK (MSL36)'
		when max(p.msl_release_num)='35' and tag_csv='Abolished,'	and count(*)=32		THEN 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='Merged,'		and count(*)=12		then 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='Merged,Moved,' and count(*)=1		then 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='Moved,'		and count(*)=626	then 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='New,'			and count(*)=3435	then 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='Renamed,'		and count(*)=164	then 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='Renamed,Moved,' and count(*)=58	then 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='Renamed,Promoted,' and count(*)=1	then 'OK (MSL36)'
		when max(n.msl_release_num)='36' and tag_csv='Moved,Demoted,' and count(*)=1		then 'OK (MSL36)'
		else 'ERROR'
		end)
from taxonomy_node_delta d
left outer join taxonomy_node p on 
	(p.taxnode_id = d.prev_taxid and p.msl_release_num=(select max(msl_release_num)-1 from taxonomy_toc))
left outer join taxonomy_node n on 
	(n.taxnode_id = d.new_taxid and n.msl_release_num=(select max(msl_release_num) from taxonomy_toc))
where p.taxnode_id is not null or n.taxnode_id is not null
group by d.tag_csv, d.is_demoted, d.is_promoted
order by status
