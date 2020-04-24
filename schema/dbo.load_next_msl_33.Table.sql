USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[load_next_msl_33](
	[proposal] [varchar](100) NOT NULL,
	[srcHigherTaxon] [varchar](100) NULL,
	[srcOrder] [varchar](100) NULL,
	[srcFamily] [varchar](100) NULL,
	[srcSubfamily] [varchar](100) NULL,
	[srcGenus] [varchar](100) NULL,
	[srcSpecies] [varchar](100) NULL,
	[srcIsType] [varchar](10) NULL,
	[srcAccessions] [varchar](5000) NULL,
	[realm] [varchar](100) NULL,
	[subrealm] [varchar](100) NULL,
	[kingdom] [varchar](100) NULL,
	[subkingdom] [varchar](100) NULL,
	[phylum] [varchar](100) NULL,
	[subphylum] [varchar](100) NULL,
	[class] [varchar](100) NULL,
	[subclass] [varchar](100) NULL,
	[order] [varchar](100) NULL,
	[suborder] [varchar](100) NULL,
	[family] [varchar](100) NULL,
	[subfamily] [varchar](100) NULL,
	[genus] [varchar](100) NULL,
	[subgenus] [varchar](100) NULL,
	[species] [varchar](100) NULL,
	[isType] [varchar](10) NULL,
	[accessions] [varchar](5000) NULL,
	[exemplarName] [nvarchar](4000) NULL,
	[exemplarID] [nvarchar](500) NULL,
	[isComplete] [varchar](100) NULL,
	[Abbrev] [nvarchar](100) NULL,
	[change] [nvarchar](100) NULL,
	[_action]  AS (case when [change] like 'news%' then 'new' when [change] like 'family%assigned%' then 'move' when [change] like '"move%' then 'move' when [change] like 'species assign%' then 'move' when [change] like 'assign%' then 'move' else left([change],charindex(' ',[change])) end),
	[_src_taxon_name]  AS (Trim(isnull([srcSpecies],isnull([srcGenus],isnull([srcSubFamily],isnull([srcFamily],isnull([srcOrder],[srcHigherTaxon]))))))),
	[_src_taxon_rank]  AS (case when [srcSpecies] IS NOT NULL then 'species' when [srcgenus] IS NOT NULL then 'genus' when [srcsubfamily] IS NOT NULL then 'subfamily' when [srcfamily] IS NOT NULL then 'family' when [order] IS NOT NULL then 'order' when [srcHigherTaxon] IS NOT NULL then 'higherRank'  end) PERSISTED,
	[_src_lineage]  AS (substring(((((isnull(';'+[srcHigherTaxon],'')+isnull(';'+[srcorder],''))+isnull(';'+[srcfamily],''))+isnull(';'+[srcsubfamily],''))+isnull(';'+[srcgenus],''))+isnull(';'+[srcspecies],''),(2),(2000))),
	[_dest_taxon_name]  AS (Trim(isnull([Species],isnull([subGenus],isnull([Genus],isnull([SubFamily],isnull([Family],isnull([subOrder],isnull([order],isnull([subclass],isnull([class],isnull([subphylum],isnull([phylum],isnull([subkingdom],isnull([kingdom],isnull([subrealm],[realm])))))))))))))))),
	[_dest_taxon_rank]  AS (case when [Species] IS NOT NULL then 'species' when [subgenus] IS NOT NULL then 'subgenus' when [genus] IS NOT NULL then 'genus' when [subfamily] IS NOT NULL then 'subfamily' when [family] IS NOT NULL then 'family' when [suborder] IS NOT NULL then 'suborder' when [order] IS NOT NULL then 'order' when [subclass] IS NOT NULL then 'subclass' when [class] IS NOT NULL then 'class' when [subphylum] IS NOT NULL then 'subphylum' when [phylum] IS NOT NULL then 'phylum' when [subkingdom] IS NOT NULL then 'subkingdom' when [subrealm] IS NOT NULL then 'subrealm' when [realm] IS NOT NULL then 'realm'  end),
	[_dest_lineage]  AS (substring((((((((((((((isnull(';'+[realm],'')+isnull(';'+[subrealm],''))+isnull(';'+[kingdom],''))+isnull(';'+[subkingdom],''))+isnull(';'+[phylum],''))+isnull(';'+[subphylum],''))+isnull(';'+[class],''))+isnull(';'+[subclass],''))+isnull(';'+[order],''))+isnull(';'+[suborder],''))+isnull(';'+[family],''))+isnull(';'+[subfamily],''))+isnull(';'+[genus],''))+isnull(';'+[subgenus],''))+isnull(';'+[species],''),(2),(2000))),
	[_dest_parent_name]  AS (rtrim(ltrim(reverse(substring(replace(reverse((((((((((((((isnull(';'+[realm],'')+isnull(';'+[subrealm],''))+isnull(';'+[kingdom],''))+isnull(';'+[subkingdom],''))+isnull(';'+[phylum],''))+isnull(';'+[subphylum],''))+isnull(';'+[class],''))+isnull(';'+[subclass],''))+isnull(';'+[order],''))+isnull(';'+[suborder],''))+isnull(';'+[family],''))+isnull(';'+[subfamily],''))+isnull(';'+[genus],''))+isnull(';'+[subgenus],''))+isnull(';'+[species],'')),';',replicate(' ',(1000))),(500),(1500)))))),
	[prev_taxnode_id] [int] NULL,
	[dest_tree_id] [int] NULL,
	[dest_msl_release_num] [int] NULL,
	[dest_taxnode_id] [int] NULL,
	[dest_ictv_id] [int] NULL,
	[dest_parent_id] [int] NULL,
	[dest_level_id] [int] NULL,
	[isDone] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[load_next_msl_33] ADD  CONSTRAINT [DF_load_next_msl_33__msl_release_num]  DEFAULT ((33)) FOR [dest_msl_release_num]
GO
ALTER TABLE [dbo].[load_next_msl_33] ADD  CONSTRAINT [DF_load_next_msl_33_isDone]  DEFAULT ((0)) FOR [isDone]
GO
