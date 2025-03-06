
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[species_isolates](
	[isolate_id] [int] IDENTITY(1,1) NOT NULL,
	[taxnode_id] [int] NULL,
	[species_sort] [int] NULL,
	[isolate_sort] [int] NOT NULL,
	[species_name] [nvarchar](100) NOT NULL,
	[isolate_type] [char](1) NOT NULL,
	[isolate_names] [nvarchar](500) NULL,
	[_isolate_name]  AS (case when [isolate_names] like '%;%' then left([isolate_names],charindex(';',[isolate_names])-(1)) else [isolate_names] end) PERSISTED,
	[isolate_abbrevs] [nvarchar](255) NULL,
	[isolate_designation] [nvarchar](500) NULL,
	[genbank_accessions] [varchar](4000) NULL,
	[refseq_accessions] [varchar](4000) NULL,
	[genome_coverage] [nvarchar](50) NULL,
	[molecule] [varchar](50) NULL,
	[host_source] [nvarchar](50) NULL,
	[refseq_organism] [nvarchar](255) NULL,
	[refseq_taxids] [nvarchar](4000) NULL,
	[update_change] [varchar](50) NULL,
	[update_prev_species] [nvarchar](100) NULL,
	[update_prev_taxnode_id] [int] NULL,
	[update_change_proposal] [nvarchar](512) NULL,
	[notes] [text] NULL,
 CONSTRAINT [PK_species_isolates] PRIMARY KEY CLUSTERED 
(
	[isolate_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[species_isolates] ADD  CONSTRAINT [DF_species_isolates_isolate_sort]  DEFAULT ((1)) FOR [isolate_sort]
GO

ALTER TABLE [dbo].[species_isolates]  WITH CHECK ADD  CONSTRAINT [FK_species_isolates_taxonomy_genome_coverage] FOREIGN KEY([genome_coverage])
REFERENCES [dbo].[taxonomy_genome_coverage] ([name])
GO

ALTER TABLE [dbo].[species_isolates] CHECK CONSTRAINT [FK_species_isolates_taxonomy_genome_coverage]
GO

ALTER TABLE [dbo].[species_isolates]  WITH CHECK ADD  CONSTRAINT [FK_species_isolates_taxonomy_host_source] FOREIGN KEY([host_source])
REFERENCES [dbo].[taxonomy_host_source] ([host_source])
GO

ALTER TABLE [dbo].[species_isolates] CHECK CONSTRAINT [FK_species_isolates_taxonomy_host_source]
GO

ALTER TABLE [dbo].[species_isolates]  WITH CHECK ADD  CONSTRAINT [FK_species_isolates_taxonomy_molecule] FOREIGN KEY([molecule])
REFERENCES [dbo].[taxonomy_molecule] ([abbrev])
GO

ALTER TABLE [dbo].[species_isolates] CHECK CONSTRAINT [FK_species_isolates_taxonomy_molecule]
GO

ALTER TABLE [dbo].[species_isolates]  WITH CHECK ADD  CONSTRAINT [FK_species_isolates_taxonomy_node] FOREIGN KEY([taxnode_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO

ALTER TABLE [dbo].[species_isolates] CHECK CONSTRAINT [FK_species_isolates_taxonomy_node]
GO

ALTER TABLE [dbo].[species_isolates]  WITH CHECK ADD  CONSTRAINT [FK_species_isolates_taxonomy_update_prev_taxnode_id] FOREIGN KEY([update_prev_taxnode_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO

ALTER TABLE [dbo].[species_isolates] CHECK CONSTRAINT [FK_species_isolates_taxonomy_update_prev_taxnode_id]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cached copy of taxonomy_node.left_idx' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'species_isolates', @level2type=N'COLUMN',@level2name=N'species_sort'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First name, extracted from ;-separated list in isolate_names' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'species_isolates', @level2type=N'COLUMN',@level2name=N'_isolate_name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sort order w/in species and isolate_type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'species_isolates'
GO

