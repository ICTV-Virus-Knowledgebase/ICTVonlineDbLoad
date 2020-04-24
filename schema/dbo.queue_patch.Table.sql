USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[queue_patch](
	[taxnode_id] [int] NULL,
	[tree_id] [int] NOT NULL,
	[parent_id] [int] NULL,
	[name] [varchar](100) NULL,
	[abbrev] [varchar](25) NULL,
	[level_id] [int] NULL,
	[notes] [text] NULL,
	[is_ref] [int] NOT NULL,
	[is_official] [int] NOT NULL,
	[is_hidden] [int] NOT NULL,
	[is_deleted] [int] NOT NULL,
	[is_deleted_next_year] [int] NOT NULL,
	[is_typo] [int] NOT NULL,
	[is_renamed_next_year] [int] NOT NULL,
	[ictv_id] [int] NULL,
	[msl_release_num] [int] NULL,
	[in_change] [varchar](10) NULL,
	[in_target] [varchar](255) NULL,
	[in_filename] [varchar](255) NULL,
	[in_notes] [text] NULL,
	[out_change] [varchar](10) NULL,
	[out_target] [varchar](255) NULL,
	[out_filename] [varchar](255) NULL,
	[out_notes] [text] NULL,
	[start_num_sort] [int] NULL,
	[row_num] [varchar](25) NULL,
	[filename] [varchar](255) NULL,
	[xref] [varchar](255) NULL,
	[order_id] [int] NULL,
	[family_id] [int] NULL,
	[subfamily_id] [int] NULL,
	[genus_id] [int] NULL,
	[species_id] [int] NULL,
	[left_idx] [int] NULL,
	[right_idx] [int] NULL,
	[node_depth] [int] NULL,
	[lineage] [varchar](500) NULL,
	[cleaned_name] [varchar](8000) NULL,
	[cleaned_problem] [varchar](38) NULL,
	[is_obsolete] [int] NOT NULL,
	[flags] [varchar](70) NOT NULL,
	[action] [varchar](25) NULL,
	[old_taxnode_id] [int] NULL,
	[is_new] [int] NOT NULL,
	[new_ictv_id] [int] NULL,
	[is_executed] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[queue_patch] ADD  CONSTRAINT [DF_queue_patch_is_new]  DEFAULT ((1)) FOR [is_new]
GO
ALTER TABLE [dbo].[queue_patch] ADD  CONSTRAINT [DF_queue_patch_is_executed]  DEFAULT ((0)) FOR [is_executed]
GO
