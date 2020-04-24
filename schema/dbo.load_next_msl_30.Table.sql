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
