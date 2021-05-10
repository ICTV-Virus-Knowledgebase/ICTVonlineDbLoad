USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[load_next_msl_28](
	[src_tree_id] [int] NULL,
	[src_msl_release_num] [int] NULL,
	[src_left_idx] [int] NULL,
	[src_taxnode_id] [int] NULL,
	[src_ictv_id] [int] NULL,
	[src_is_hidden] [int] NULL,
	[src_lineage] [varchar](500) NULL,
	[src_level] [varchar](50) NULL,
	[src_name] [varchar](200) NULL,
	[src_is_type] [int] NULL,
	[dest_molecule] [varchar](50) NULL,
	[dest_in_change] [varchar](50) NULL,
	[src_out_change] [varchar](50) NULL,
	[dest_target] [varchar](500) NULL,
	[ref_filename] [varchar](500) NULL,
	[ref_notes] [varchar](500) NULL,
	[ref_problems] [varchar](200) NULL,
	[dest_level] [varchar](50) NULL,
	[dest_is_type] [int] NULL,
	[dest_is_hidden] [int] NULL,
	[dest_msl_release_num] [int] NULL,
	[dest_tree_id] [int] NULL,
	[dest_taxnode_id] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_load_next_msl_28-dest_in_change] ON [dbo].[load_next_msl_28]
(
	[dest_in_change] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_load_next_msl_28-dest_target] ON [dbo].[load_next_msl_28]
(
	[dest_target] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_load_next_msl_28-src_out_change] ON [dbo].[load_next_msl_28]
(
	[src_out_change] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique name or lineage (semi-colon delimited)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'load_next_msl_28', @level2type=N'COLUMN',@level2name=N'dest_target'
GO
