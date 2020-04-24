USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[load_next_msl_unicode](
	[src_tree_id] [nvarchar](50) NULL,
	[src_msl_release_num] [nvarchar](50) NULL,
	[src_left_idx] [nvarchar](50) NULL,
	[src_taxnode_id] [nvarchar](50) NULL,
	[src_ictv_id] [nvarchar](50) NULL,
	[src_is_hidden] [nvarchar](50) NULL,
	[src_lineage] [nvarchar](500) NULL,
	[src_level] [nvarchar](50) NULL,
	[src_name] [nvarchar](500) NULL,
	[src_is_type] [nvarchar](50) NULL,
	[src_isolates] [nvarchar](500) NULL,
	[src_ncbi_accessions] [nvarchar](500) NULL,
	[src_abbrevs] [nvarchar](500) NULL,
	[src_molecule] [nvarchar](50) NULL,
	[dest_in_change] [nvarchar](50) NULL,
	[src_out_change] [nvarchar](50) NULL,
	[dest_target name or lineage with ;'s] [nvarchar](500) NULL,
	[old_ref_filename] [nvarchar](500) NULL,
	[ref_filename] [nvarchar](500) NULL,
	[ref_notes] [nvarchar](500) NULL,
	[ref_problems] [nvarchar](500) NULL,
	[dest_level] [nvarchar](50) NULL,
	[dest_is_type] [nvarchar](50) NULL,
	[dest_is_hidden] [nvarchar](50) NULL,
	[dest_isolates] [nvarchar](500) NULL,
	[dest_ncbi_accessions] [nvarchar](500) NULL,
	[dest_Abbrevs] [nvarchar](500) NULL,
	[dest_molecule] [nvarchar](50) NULL,
	[dest_ msl_release_num] [nvarchar](50) NULL,
	[dest_ tree_id] [nvarchar](50) NULL,
	[dest_ taxnode_id] [nvarchar](50) NULL,
	[edit_comments Data Entry Notes] [nvarchar](500) NULL
) ON [PRIMARY]
GO
