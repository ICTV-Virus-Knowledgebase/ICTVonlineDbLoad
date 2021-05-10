USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[load_next_msl_30](
	[src_tree_id] [int] NULL,
	[src_msl_release_num] [int] NULL,
	[src_left_idx] [int] NULL,
	[src_taxnode_id] [int] NULL,
	[src_ictv_id] [int] NULL,
	[src_is_hidden] [int] NULL,
	[src_lineage] [nvarchar](400) NULL,
	[src_level] [nvarchar](50) NULL,
	[src_name] [nvarchar](200) NULL,
	[src_is_type] [int] NULL,
	[src_isolates] [nvarchar](400) NULL,
	[src_ncbi_accessions] [nvarchar](400) NULL,
	[src_abbrevs] [nvarchar](100) NULL,
	[src_molecule] [nvarchar](50) NULL,
	[dest_in_change] [nvarchar](50) NULL,
	[src_out_change] [nvarchar](50) NULL,
	[dest_target] [nvarchar](400) NULL,
	[orig_ref_filename] [nvarchar](400) NULL,
	[ref_filename] [nvarchar](400) NULL,
	[ref_notes] [nvarchar](400) NULL,
	[ref_problems] [nvarchar](200) NULL,
	[dest_level] [nvarchar](50) NULL,
	[dest_is_type] [int] NULL,
	[dest_is_hidden] [int] NULL,
	[dest_isolates] [nvarchar](500) NULL,
	[dest_ncbi_accessions] [nvarchar](500) NULL,
	[dest_abbrevs] [nvarchar](100) NULL,
	[dest_molecule] [nvarchar](50) NULL,
	[dest_msl_release_num] [int] NULL,
	[dest_tree_id] [int] NULL,
	[dest_taxnode_id] [int] NULL,
	[edit_comments] [nvarchar](500) NULL,
	[dest_parent_lineage]  AS (case when [dest_target] like '%;%' then reverse(ltrim(replace(substring(replace(reverse([dest_target]),';',space((200))),(200),(5000)),space((200)),';')))  end) PERSISTED,
	[dest_parent_name]  AS (case when [dest_target] like '%;%' then reverse(rtrim(left(replace(reverse(reverse(ltrim(replace(substring(replace(reverse([dest_target]),';',space((200))),(200),(5000)),space((200)),';')))),';',space((200))),(200))))  end) PERSISTED,
	[dest_name]  AS (case when [dest_target] like '%;%' then reverse(rtrim(left(replace(reverse([dest_target]),';',space((200))),(200)))) else [dest_target] end) PERSISTED,
 CONSTRAINT [IX_load_next_msl-dest_taxnode_id] UNIQUE NONCLUSTERED 
(
	[dest_taxnode_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_load_next_msl_9_879342197__K1] ON [dbo].[load_next_msl_30]
(
	[src_tree_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [_dta_index_load_next_msl_9_879342197__K17_31] ON [dbo].[load_next_msl_30]
(
	[dest_target] ASC
)
INCLUDE([dest_taxnode_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [_dta_index_load_next_msl_9_879342197__K17_K22_1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_18_19_20_21_23_24_25_26_27_28_29_30_31] ON [dbo].[load_next_msl_30]
(
	[dest_target] ASC,
	[dest_level] ASC
)
INCLUDE([src_tree_id],[src_msl_release_num],[src_left_idx],[src_taxnode_id],[src_ictv_id],[src_is_hidden],[src_lineage],[src_level],[src_name],[src_is_type],[src_isolates],[src_ncbi_accessions],[src_abbrevs],[src_molecule],[dest_in_change],[src_out_change],[orig_ref_filename],[ref_filename],[ref_notes],[ref_problems],[dest_is_type],[dest_is_hidden],[dest_isolates],[dest_ncbi_accessions],[dest_abbrevs],[dest_molecule],[dest_msl_release_num],[dest_tree_id],[dest_taxnode_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_in_change] ON [dbo].[load_next_msl_30]
(
	[dest_in_change] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_target] ON [dbo].[load_next_msl_30]
(
	[dest_target] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_load_next_msl-src_out_change] ON [dbo].[load_next_msl_30]
(
	[src_out_change] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of representative isolate names (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_30', @level2type=N'COLUMN',@level2name=N'src_isolates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of NCBI accession numbers (CSV of [segment_name:]acession)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_30', @level2type=N'COLUMN',@level2name=N'src_ncbi_accessions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'list of common abbreviations (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_30', @level2type=N'COLUMN',@level2name=N'src_abbrevs'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique name or lineage (semi-colon delimited)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_30', @level2type=N'COLUMN',@level2name=N'dest_target'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of representative isolate names (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_30', @level2type=N'COLUMN',@level2name=N'dest_isolates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of NCBI accession numbers (CSV of [segment_name:]acession)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_30', @level2type=N'COLUMN',@level2name=N'dest_ncbi_accessions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'list of common abbreviations (CSV)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_30', @level2type=N'COLUMN',@level2name=N'dest_abbrevs'
GO
