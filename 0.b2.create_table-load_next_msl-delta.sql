
/*********************************************************************
 ** load_next_msl (delta version)                                   **
 **                                                                 **
 ** !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! **
 ** !!!                          BEFORE RUNNING                 !!! **
 ** !!!      UPDATE MSL default number in constraint at bottom  !!! **
 ** !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! **
 **                                                                 **
 *********************************************************************/
 /** 
  ** DELTA VERSION
  **   designed to only load new and changed taxa
  **
  ** todo: 
  **   move _action and other computed columns into a trigger
  **   complicated cases are messy in computed columns
  **/

-- drop  table [load_next_msl]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[load_next_msl](
	[filename] [nvarchar](200) NOT NULL,  -- name of the spreadsheet loaded
	[sort] [float] NULL, -- -- row ID from excel spreadsheet
	[isWrong] [nvarchar](500) NULL,-- flag records to ignore entirely
	[proposal_abbrev] [varchar](100) NULL,
	[proposal] [varchar](100) NOT NULL, -- proposal filename
	[spreadsheet] [varchar](100) NULL, -- MSL35 proposal change excel file
	[srcRealm] [varchar](100) NULL,
	[srcSubRealm] [varchar](100) NULL,
	[srcKingdom] [varchar](100) NULL,
	[srcSubkingdom] [varchar](100) NULL,
	[srcPhylum] [varchar](100) NULL,
	[srcSubphylum] [varchar](100) NULL,
	[srcClass] [varchar](100) NULL,
	[srcSubclass] [varchar](100) NULL,
	[srcHigherTaxon] [varchar](100) NULL,
	[srcOrder] [varchar](100) NULL,
	[srcSubOrder] [varchar](100) NULL,
	[srcFamily] [varchar](100) NULL,
	[srcSubfamily] [varchar](100) NULL,
	[srcGenus] [varchar](100) NULL,
	[srcSubGenus] [varchar](100) NULL,
	[srcSpecies] [varchar](100) NULL,
	[srcIsType] [varchar](10) NULL,
	[srcAccessions] [varchar](5000) NULL,
	[empty1] [varchar](1) NULL, -- MSL35 - not used; visual separator in excel
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
	[exemplarAccessions] [varchar](5000) NULL,
	[exemplarRefSeq] [varchar](5000) NULL, -- MSL35 no longer used
	[exemplarName] [nvarchar](4000) NULL,
	[exemplarIsolate] [nvarchar](500) NULL,
	[isComplete] [varchar](100) NULL,
	[Abbrev] [nvarchar](100) NULL,
	[molecule] [nvarchar](100) NULL,
	[change] [nvarchar](100) NULL,
	[rank] [nvarchar](100) NULL,
	[_action]  AS (case when [change] like '%merge%' then 'merge' when [change] like 'new%' then 'new' when [change] like 'family%assigned%' then 'move' when [change] like '%move%rename%' then 'move' when [change] like '%move%' then 'move' when [change] like 'species assign%' then 'move' when [change] like 'assign%' then 'move' when [change] like '%rename%' then 'rename' when [change] like 'abolish%' then 'abolish' else [change] end) PERSISTED,
	[_src_taxon_name]  AS (Trim(isnull([srcSpecies],isnull([srcSubGenus],isnull([srcGenus],isnull([srcSubFamily],isnull([srcFamily],isnull([srcSubOrder],isnull([srcOrder],isnull([srcSubClass],isnull([srcClass],isnull([srcSubPhylum],isnull([srcPhylum],isnull([srcSubKingdom],isnull([srcKingdom],isnull([srcSubRealm],[srcRealm])))))))))))))))) PERSISTED,
	[_src_taxon_rank]  AS (case when [srcSpecies] IS NOT NULL then 'species' when [srcsubgenus] IS NOT NULL then 'subgenus' when [srcgenus] IS NOT NULL then 'genus' when [srcsubfamily] IS NOT NULL then 'subfamily' when [srcfamily] IS NOT NULL then 'family' when [srcSubOrder] IS NOT NULL then 'suborder' when [srcOrder] IS NOT NULL then 'order' when [srcSubClass] IS NOT NULL then 'subclass' when [srcClass] IS NOT NULL then 'class' when [srcSubPhylum] IS NOT NULL then 'subphylum' when [srcPhylum] IS NOT NULL then 'phylum' when [srcSubKingdom] IS NOT NULL then 'subkingdom' when [srcKingdom] IS NOT NULL then 'kingdom' when [srcSubRealm] IS NOT NULL then 'subrealm' when [srcRealm] IS NOT NULL then 'realm'  end) PERSISTED,
	[_src_lineage]  AS (substring(((((((((((((((((isnull(';'+[srcRealm],'')+isnull(';'+[srcSubRealm],''))+isnull(';'+[srckingdom],''))+isnull(';'+[srcSubkingdom],''))+isnull(';'+[srcphylum],''))+isnull(';'+[srcsubphylum],''))+isnull(';'+[srcClass],''))+isnull(';'+[srcsubclass],''))+isnull(';'+[srcRealm],''))+isnull(';'+[srcRealm],''))+isnull(';'+[srcRealm],''))+isnull(';'+[srcorder],''))+isnull(';'+[srcsuborder],''))+isnull(';'+[srcfamily],''))+isnull(';'+[srcsubfamily],''))+isnull(';'+[srcgenus],''))+isnull(';'+[srcsubgenus],''))+isnull(';'+[srcspecies],''),(2),(2000))) PERSISTED,
	[_dest_taxon_name]  AS (Trim(isnull([Species],isnull([subGenus],isnull([Genus],isnull([SubFamily],isnull([Family],isnull([subOrder],isnull([order],isnull([subclass],isnull([class],isnull([subphylum],isnull([phylum],isnull([subkingdom],isnull([kingdom],isnull([subrealm],[realm])))))))))))))))) PERSISTED,
	[_dest_taxon_rank]  AS (case when [Species] IS NOT NULL then 'species' when [subgenus] IS NOT NULL then 'subgenus' when [genus] IS NOT NULL then 'genus' when [subfamily] IS NOT NULL then 'subfamily' when [family] IS NOT NULL then 'family' when [suborder] IS NOT NULL then 'suborder' when [order] IS NOT NULL then 'order' when [subclass] IS NOT NULL then 'subclass' when [class] IS NOT NULL then 'class' when [subphylum] IS NOT NULL then 'subphylum' when [phylum] IS NOT NULL then 'phylum' when [subkingdom] IS NOT NULL then 'subkingdom' when [subrealm] IS NOT NULL then 'subrealm' when [realm] IS NOT NULL then 'realm'  end) PERSISTED,
	[_dest_lineage]  AS (substring((((((((((((((isnull(';'+[realm],'')+isnull(';'+[subrealm],''))+isnull(';'+[kingdom],''))+isnull(';'+[subkingdom],''))+isnull(';'+[phylum],''))+isnull(';'+[subphylum],''))+isnull(';'+[class],''))+isnull(';'+[subclass],''))+isnull(';'+[order],''))+isnull(';'+[suborder],''))+isnull(';'+[family],''))+isnull(';'+[subfamily],''))+isnull(';'+[genus],''))+isnull(';'+[subgenus],''))+isnull(';'+[species],''),(2),(2000))) PERSISTED,
	[_dest_parent_name]  AS (rtrim(ltrim(reverse(substring(replace(reverse((((((((((((((isnull(';'+[realm],'')+isnull(';'+[subrealm],''))+isnull(';'+[kingdom],''))+isnull(';'+[subkingdom],''))+isnull(';'+[phylum],''))+isnull(';'+[subphylum],''))+isnull(';'+[class],''))+isnull(';'+[subclass],''))+isnull(';'+[order],''))+isnull(';'+[suborder],''))+isnull(';'+[family],''))+isnull(';'+[subfamily],''))+isnull(';'+[genus],''))+isnull(';'+[subgenus],''))+isnull(';'+[species],'')),';',replicate(' ',(1000))),(500),(1500)))))) PERSISTED,
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

ALTER TABLE [dbo].[load_next_msl] ADD  CONSTRAINT [DF_load_next_msl__msl_release_num]  DEFAULT ((35)) FOR [dest_msl_release_num]
GO

ALTER TABLE [dbo].[load_next_msl] ADD  CONSTRAINT [DF_load_next_msl_isDone]  DEFAULT ((0)) FOR [isDone]
GO


/****** Object:  Index [IX_load_next_msl-dest_parent_name]    Script Date: 2/27/2019 12:50:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_parent_name] ON [dbo].[load_next_msl]
(
	[_dest_parent_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



/****** Object:  Index [IX_load_next_msl-dest_taxon_name]    Script Date: 2/27/2019 12:50:04 AM ******/
CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_taxon_name] ON [dbo].[load_next_msl]
(
	[_dest_taxon_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


/****** Object:  Index [IX_load_next_msl-dest_taxon_name]    Script Date: 2/27/2019 12:50:04 AM ******/
CREATE NONCLUSTERED INDEX [IX_load_next_msl-src_taxon_name] ON [dbo].[load_next_msl]
(
	[_src_taxon_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

