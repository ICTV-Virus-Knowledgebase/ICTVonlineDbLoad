USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[taxonomy_node](
	[taxnode_id] [int] NOT NULL,
	[parent_id] [int] NULL,
	[tree_id] [int] NOT NULL,
	[msl_release_num] [int] NULL,
	[level_id] [int] NULL,
	[name] [nvarchar](100) NULL,
	[ictv_id] [int] NULL,
	[molecule_id] [int] NULL,
	[abbrev_csv] [nvarchar](max) NULL,
	[genbank_accession_csv] [nvarchar](max) NULL,
	[genbank_refseq_accession_csv] [nvarchar](max) NULL,
	[refseq_accession_csv] [nvarchar](max) NULL,
	[isolate_csv] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[is_ref] [int] NOT NULL,
	[is_official] [int] NOT NULL,
	[is_hidden] [int] NOT NULL,
	[is_deleted] [int] NOT NULL,
	[is_deleted_next_year] [int] NOT NULL,
	[is_typo] [int] NOT NULL,
	[is_renamed_next_year] [int] NOT NULL,
	[is_obsolete] [int] NOT NULL,
	[in_change] [varchar](10) NULL,
	[in_target] [nvarchar](255) NULL,
	[in_filename] [nvarchar](255) NULL,
	[in_notes] [nvarchar](max) NULL,
	[out_change] [varchar](10) NULL,
	[out_target] [nvarchar](255) NULL,
	[out_filename] [nvarchar](255) NULL,
	[out_notes] [nvarchar](max) NULL,
	[start_num_sort] [int] NULL,
	[row_num] [nvarchar](25) NULL,
	[filename] [nvarchar](255) NULL,
	[xref] [nvarchar](255) NULL,
	[realm_id] [int] NULL,
	[subrealm_id] [int] NULL,
	[kingdom_id] [int] NULL,
	[subkingdom_id] [int] NULL,
	[phylum_id] [int] NULL,
	[subphylum_id] [int] NULL,
	[class_id] [int] NULL,
	[subclass_id] [int] NULL,
	[order_id] [int] NULL,
	[suborder_id] [int] NULL,
	[family_id] [int] NULL,
	[subfamily_id] [int] NULL,
	[genus_id] [int] NULL,
	[subgenus_id] [int] NULL,
	[species_id] [int] NULL,
	[inher_molecule_id] [int] NULL,
	[left_idx] [int] NULL,
	[right_idx] [int] NULL,
	[node_depth] [int] NULL,
	[lineage] [nvarchar](500) NULL,
	[cleaned_name]  AS (CONVERT([varchar](100),replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace([name],'í','i'),'é','e'),'ó','o'),'ú','u'),'á','a'),'ì','i'),'è','e'),'ò','o'),'ù','u'),'à','a'),'î','i'),'ê','e'),'ô','o'),'û','u'),'â','a'),'ü','u'),'ö','o'),'ï','i'),'ë','e'),'ä','a'),'ç','c'),'ñ','n'),'‘',''''),'’',''''),'`',' '),'  ',' '),N'a','a'),N'i','i'),N'i','i'),N'a','a'),N'e','e'),N'o','o'),(0))) PERSISTED,
	[cleaned_problem]  AS (case when charindex('í',[name])>(0) then 'í (accented i)' when charindex('é',[name])>(0) then 'é (accented e)' when charindex('ó',[name])>(0) then 'ó (accented o)' when charindex('ú',[name])>(0) then 'ú (accented u)' when charindex('á',[name])>(0) then 'á (accented a)' when charindex('ì',[name])>(0) then 'ì (accented i)' when charindex('è',[name])>(0) then 'è (accented e)' when charindex('ò',[name])>(0) then 'ò (accented o)' when charindex('ù',[name])>(0) then 'ù (accented u)' when charindex('à',[name])>(0) then 'à (accented a)' when charindex('î',[name])>(0) then 'î (accented i)' when charindex('ê',[name])>(0) then 'ê (accented e)' when charindex('ô',[name])>(0) then 'ô (accented o)' when charindex('û',[name])>(0) then 'û (accented u)' when charindex('â',[name])>(0) then 'â (accented a)' when charindex('ü',[name])>(0) then 'ü (accented u)' when charindex('ö',[name])>(0) then 'ö (accented o)' when charindex('ï',[name])>(0) then 'ï (accented i)' when charindex('ë',[name])>(0) then 'ë (accented e)' when charindex('ä',[name])>(0) then 'ä (accented a)' when charindex('ç',[name])>(0) then 'ç (accented c)' when charindex('ñ',[name])>(0) then 'ñ (accented n)' when charindex('‘',[name])>(0) then '‘ (Microsoft curvy open single-quote)' when charindex('’',[name])>(0) then '’ (Microsoft curvy close single-quote)' when charindex('`',[name])>(0) then '` (ASCII back-quote)' when charindex('  ',[name])>(0) then '(double space)' when charindex(N'a',[name])>(0) then 'a-macron' when charindex(N'i',[name])>(0) then 'i-macron' when charindex(N'i',[name])>(0) then 'i-breve' when charindex(N'a',[name])>(0) then 'a-caron' when charindex(N'e',[name])>(0) then 'e-macron' when charindex(N'o',[name])>(0) then 'o-macron'  end) PERSISTED,
	[flags]  AS ((((((case when [tree_id]=[taxnode_id] then 'root;' else '' end+case when [is_hidden]=(1) then 'hidden;' else '' end)+case when [is_deleted]=(1) then 'deleted;' else '' end)+case when [is_deleted_next_year]=(1) then 'removed_next_year;' else '' end)+case when [is_typo]=(1) then 'typo;' else '' end)+case when [is_renamed_next_year]=(1) then 'renamed_next_year;' else '' end)+case when [is_obsolete]=(1) then 'obsolete;' else '' end),
 CONSTRAINT [pk_taxonomy_node] PRIMARY KEY CLUSTERED 
(
	[taxnode_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_ref]  DEFAULT ((0)) FOR [is_ref]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_official]  DEFAULT ((0)) FOR [is_official]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_hidden]  DEFAULT ((0)) FOR [is_hidden]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_deleted]  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_deleted_ny]  DEFAULT ((0)) FOR [is_deleted_next_year]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_typo]  DEFAULT ((0)) FOR [is_typo]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_renamed]  DEFAULT ((0)) FOR [is_renamed_next_year]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_is_obsolete]  DEFAULT ((0)) FOR [is_obsolete]
GO
ALTER TABLE [dbo].[taxonomy_node] ADD  CONSTRAINT [DF_taxonomy_node_sort_start]  DEFAULT (NULL) FOR [start_num_sort]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_change_in] FOREIGN KEY([in_change])
REFERENCES [dbo].[taxonomy_change_in] ([change])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_change_in]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_change_out] FOREIGN KEY([out_change])
REFERENCES [dbo].[taxonomy_change_out] ([change])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_change_out]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_level-level_id] FOREIGN KEY([level_id])
REFERENCES [dbo].[taxonomy_level] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_level-level_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_molecule_inher_molecule_id] FOREIGN KEY([inher_molecule_id])
REFERENCES [dbo].[taxonomy_molecule] ([id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_molecule_inher_molecule_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_molecule_molecule_id] FOREIGN KEY([molecule_id])
REFERENCES [dbo].[taxonomy_molecule] ([id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_molecule_molecule_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node_family_id] FOREIGN KEY([family_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node_family_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node_genus_id] FOREIGN KEY([genus_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node_genus_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node_ictv_id] FOREIGN KEY([ictv_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node_ictv_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node_order_id] FOREIGN KEY([order_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node_order_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_Taxonomy_node_species_id] FOREIGN KEY([species_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_Taxonomy_node_species_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node_subfamily_id] FOREIGN KEY([subfamily_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node_subfamily_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node_tree_id] FOREIGN KEY([tree_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node_tree_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-class_id] FOREIGN KEY([class_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-class_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-kingdom_id] FOREIGN KEY([kingdom_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-kingdom_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-phylum_id] FOREIGN KEY([phylum_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-phylum_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-realm_id] FOREIGN KEY([realm_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-realm_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-subclass_id] FOREIGN KEY([subclass_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-subclass_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-subgenus_id] FOREIGN KEY([subgenus_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-subgenus_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-subkingdom_id] FOREIGN KEY([subkingdom_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-subkingdom_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-suborder_id] FOREIGN KEY([suborder_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-suborder_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-subphylum_id] FOREIGN KEY([subphylum_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-subphylum_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_node-subrealm_id] FOREIGN KEY([subrealm_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_node-subrealm_id]
GO
ALTER TABLE [dbo].[taxonomy_node]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_taxonomy_toc] FOREIGN KEY([tree_id], [msl_release_num])
REFERENCES [dbo].[taxonomy_toc] ([tree_id], [msl_release_num])
GO
ALTER TABLE [dbo].[taxonomy_node] CHECK CONSTRAINT [FK_taxonomy_node_taxonomy_toc]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'MSL#, as there can be more than one MSL per year, and some years w/o an MSL. This column is set only for the root node of the tree.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'msl_release_num'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Genomic molecule type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'molecule_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'standard species abbreviation(s). Separated by commas, with no surounding spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'abbrev_csv'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Non-RefSeq Genbank accession numbers in a comma-separate list, no spaces. (previously named ncbi_accession_csv)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'genbank_accession_csv'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Genbank accession numbers matching the RefSeq accession numbers in refseq_accession_csv, in a comma-separate list, no spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'genbank_refseq_accession_csv'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'RefSeq accession numbers in a comma-separate list, no spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'refseq_accession_csv'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Isolate names in a comma-separate list, no spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'isolate_csv'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 if this is intentionally deleted in the next year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'is_deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 if this is intentionally deleted in the next year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'is_deleted_next_year'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 if this matches what is published, but is thought to contain a typo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'is_typo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 if this is intentionally renamed in the next year. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'is_renamed_next_year'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 if there is more current record for the same entry in the current tree_id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'is_obsolete'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'change of this taxa relative to the previous MSL. Primarily used for importing the historical MSLs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'in_change'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name or lineage referencing a taxa in the previous MSL from which this changed. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'in_target'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'filename of a document justifying the change of this taxa from the previous MSL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'in_filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'change of this taxa in the next MSL. Primarily used for importing the historical MSLs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'out_change'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name or lineage referencing a taxa in the NEXT MSL into which this changed. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'out_target'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'filename of a document justifying the change of this taxa in the next MSL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'out_filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'if not null, use the first (sort_start) characters of name for alphabetic sorting, followed by the characters after (sort_start+1) for numeric sorting. This handles correct sorting of species names where they are numbered, but not right justified with spaces or zeros.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'start_num_sort'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] taxnode_id of closest ancestor (or self) taxon with level of ORDER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'order_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] taxnode_id of closest ancestor (or self) taxon with level of FAMILY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'family_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] taxnode_id of closest ancestor (or self) taxon with level of SUBFAMILY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'subfamily_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] taxnode_id of closest ancestor (or self) taxon with level of GENUS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'genus_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] taxnode_id of closest ancestor (or self) taxon with level of SPECIES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'species_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] Inherited Genomic molecule type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'inher_molecule_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] depth first traversal entry index of this node within this MSL, sort by this to get taxonomic order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'left_idx'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] depth first traversal exit index of this node within this MSL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'right_idx'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] depth this node within this MSL tree' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'node_depth'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[computed by trigger: TR_taxonomy_node_UPDATE_indexes] semi-colon separated list of all ancestors, including self, within this MSL tree' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'taxonomy_node', @level2type=N'COLUMN',@level2name=N'lineage'
GO
