--USE [ICTVonline]
GO
-- 
-- instead of 
-- dropping old load tables, archive them.
--
--print '!!!!! Rename load_next_msl to load_next_msl_' + rtrim(select max(dest_msl_release_num) from load_next_msl) + '  !!!!!!!!'
exec sp_rename 'load_next_msl', 'load_next_msl_31'
exec sp_rename 'load_next_msl_taxonomy', 'load_next_msl_taxonomy_31'

-- drop table [dbo].[load_next_msl]
GO
/****** Object:  Table [dbo].[load_next_msl]    Script Date: 03/14/2014 09:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[load_next_msl](
/*A*/	[src_tree_id] [int] NULL,		
/*B*/	[src_msl_release_num] [int] NULL,		
/*C*/	[src_left_idx] [int] NULL,		
/*D*/	[src_taxnode_id] [int] NULL,		
/*E*/	[src_ictv_id] [int] NULL,		
/*F*/	[src_is_hidden] [int] NULL,		
/*G*/	[src_lineage] [nvarchar](400) NULL,		
/*H*/	[src_level] [nvarchar](50) NULL,		
/*I*/	[src_name] [nvarchar](200) NULL,		
/*J*/	[src_is_type] [int] NULL,		
/*K*/	[src_isolates] [nvarchar](max) NULL,		
/*L*/	[src_ncbi_accessions] [nvarchar](max) NULL,	
/*M*/	[src_abbrevs] [nvarchar](max) NULL,			
/*N*/	[src_molecule] [nvarchar](100) NULL,		
/*O*/	[dest_in_change] [nvarchar](50) NULL,		
/*P*/	[src_out_change] [nvarchar](50) NULL,		
/*Q*/	[dest_target] [nvarchar](400) NULL,		
/*R*/	[orig_ref_filename] [nvarchar](400) NULL,	
/*S*/	[ref_filename] [nvarchar](400) NULL,		
/*T*/	[ref_notes] [nvarchar](400) NULL,		
/*U*/	[ref_problems] [nvarchar](200) NULL,		
/*V*/	[dest_level] [nvarchar](50) NULL,		
/*W*/	[dest_is_type] [int] NULL,		
/*X*/	[dest_is_hidden] [int] NULL,		
/*Y*/	[dest_isolates] [nvarchar](500) NULL,			
/*Z*/	[dest_ncbi_accessions] [nvarchar](500) NULL,	
/*AA*/	[dest_abbrevs] [nvarchar](100) NULL,			
/*AB*/	[dest_molecule] [nvarchar](50) NULL,			
/*AC*/	[dest_msl_release_num] [int],		
/*AD*/	[dest_tree_id] [int],		
/*AE*/	[dest_taxnode_id] [int] NOT NULL,  -- MSL32 go back to assigning IDs in Excel
/*AF*/  [edit_comments] [nvarchar](500) NULL,	
		-- admin columns
        [corrected] [nvarchar](500) NULL,	
		[dest_parent_id] [int] NULL,
        -- computed columns
        -- strip right most taxon off a lineage to get parent
	    [dest_parent_lineage] AS (case when [dest_target] like '%;%' then reverse(ltrim(replace(substring(replace(reverse([dest_target]),';',space((200))),(200),(5000)),space((200)),';')))  end) PERSISTED,
        -- strip right most taxon off a lineage to get parent
	    [src_parent_lineage] AS (case when [src_lineage] like '%;%' then reverse(ltrim(replace(substring(replace(reverse([src_lineage]),';',space((200))),(200),(5000)),space((200)),';')))  end) PERSISTED,
		-- get just the name of the parent, w/o it's lineage   
	    [dest_parent_name] AS (case when [dest_target] like '%;%' then reverse(rtrim(left(replace(REVERSE(reverse(ltrim(replace(substring(replace(reverse([dest_target]),';',space((200))),(200),(5000)),space((200)),';')))),';',space(200)),200))) end) PERSISTED,
		-- get just the name of the taxa - strop off all leading lineage from dest_target   
	 	[dest_name]  AS (case when [dest_target] like '%;%' then reverse(rtrim(left(replace(reverse([dest_target]),';',space((200))),(200)))) else [dest_target] end) PERSISTED
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique name or lineage (semi-colon delimited)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl', @level2type=N'COLUMN',@level2name=N'dest_target'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of representative isolate names (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl', @level2type=N'COLUMN',@level2name=N'src_isolates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of representative isolate names (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl', @level2type=N'COLUMN',@level2name=N'dest_isolates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of NCBI accession numbers (CSV of [segment_name:]acession)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl', @level2type=N'COLUMN',@level2name=N'src_ncbi_accessions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of NCBI accession numbers (CSV of [segment_name:]acession)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl', @level2type=N'COLUMN',@level2name=N'dest_ncbi_accessions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'list of common abbreviations (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl', @level2type=N'COLUMN',@level2name=N'src_abbrevs'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'list of common abbreviations (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl', @level2type=N'COLUMN',@level2name=N'dest_abbrevs'
GO

--
-- create some indices
--

GO
CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_target] ON dbo.load_next_msl
	(
	dest_target
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_in_change] ON dbo.load_next_msl
	(
	dest_in_change
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_load_next_msl-src_out_change] ON dbo.load_next_msl
	(
	src_out_change
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.load_next_msl SET (LOCK_ESCALATION = TABLE)

CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_parent_id] ON dbo.load_next_msl
	(
	[dest_parent_id]
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
--
-- Create more recommended by tuning to get QC to run in under 3 hours!
--
CREATE STATISTICS [_dta_stat_879342197_1_17] ON [dbo].[load_next_msl]([src_tree_id], [dest_target])

CREATE NONCLUSTERED INDEX [_dta_index_load_next_msl_9_879342197__K1] ON [dbo].[load_next_msl] 
(
	[src_tree_id] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [_dta_index_load_next_msl_9_879342197__K17_31] ON [dbo].[load_next_msl] 
(
	[dest_target] ASC
)
INCLUDE ( [dest_taxnode_id]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [_dta_index_load_next_msl_9_879342197__K17_K22_1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_18_19_20_21_23_24_25_26_27_28_29_30_31] ON [dbo].[load_next_msl] 
(
	[dest_target] ASC,
	[dest_level] ASC
)
INCLUDE ( [src_tree_id],
[src_msl_release_num],
[src_left_idx],
[src_taxnode_id],
[src_ictv_id],
[src_is_hidden],
[src_lineage],
[src_level],
[src_name],
[src_is_type],
[src_isolates],
[src_ncbi_accessions],
[src_abbrevs],
[src_molecule],
[dest_in_change],
[src_out_change],
[orig_ref_filename],
[ref_filename],
[ref_notes],
[ref_problems],
[dest_is_type],
[dest_is_hidden],
[dest_isolates],
[dest_ncbi_accessions],
[dest_abbrevs],
[dest_molecule],
[dest_msl_release_num],
[dest_tree_id],
[dest_taxnode_id]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


/***********************************************************************************************************************
 * add indexs to taxonomy_node to improve LOAD QC time
 ***********************************************************************************************************************/
/*
-- RUN ONCE
CREATE STATISTICS [_dta_stat_1874821741_6_3] ON [dbo].[taxonomy_node]([name], [tree_id])

 CREATE NONCLUSTERED INDEX [_dta_index_taxonomy_node_9_1874821741__K3_K6_1_42] ON [dbo].[taxonomy_node] 
(
	[tree_id] ASC,
	[name] ASC
)
INCLUDE ( [taxnode_id],
[lineage]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
*/
