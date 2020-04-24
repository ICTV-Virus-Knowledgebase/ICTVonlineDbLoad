USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[load_next_msl_taxonomy_31]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[load_next_msl_taxonomy_31](
	[srcOrder] [nvarchar](50) NULL,
	[srcFamily] [nvarchar](50) NULL,
	[srcSubFamily] [nvarchar](50) NULL,
	[srcGenus] [nvarchar](50) NULL,
	[srcSpecies] [nvarchar](100) NULL,
	[srcIsType] [smallint] NULL,
	[srcAccession] [nvarchar](500) NULL,
	[srcIsolate] [nvarchar](500) NULL,
	[x1] [nvarchar](1) NULL,
	[destOrder] [nvarchar](50) NULL,
	[destFamily] [nvarchar](50) NULL,
	[destSubFamily] [nvarchar](50) NULL,
	[destGenus] [nvarchar](50) NULL,
	[destSpecies] [nvarchar](100) NULL,
	[destIstype] [smallint] NULL,
	[destAccession] [nvarchar](500) NULL,
	[destIsolate] [nvarchar](500) NULL,
	[change] [nvarchar](200) NULL,
	[proposal] [nvarchar](200) NULL,
	[subcommittee] [nvarchar](1) NULL,
	[refNum] [nvarchar](50) NULL,
	[row] [int] IDENTITY(3,1) NOT NULL,
	[corrected] [varchar](500) NULL,
	[proposal2] [varchar](50) NULL,
	[proposal3] [varchar](50) NULL,
	[srcSubFamilyU]  AS (isnull([srcSubFamily],'UNASSIGNED')),
	[destSubFamilyU]  AS (isnull([destSubFamily],'UNASSIGNED')),
	[srcLineageFamily]  AS ((isnull([srcOrder],'NULL')+';')+isnull([srcFamily],'NULL')),
	[srcLineageSubFamily]  AS ((((isnull([srcOrder],'NULL')+';')+isnull([srcFamily],'NULL'))+';')+isnull([srcSubFamily],'UNASSIGNED')),
	[srcLineageGenus]  AS ((((((isnull([srcOrder],'NULL')+';')+isnull([srcFamily],'NULL'))+';')+isnull([srcSubFamily],'UNASSIGNED'))+';')+isnull([srcGenus],'NULL')),
	[srcLineageSpecies]  AS ((((((((isnull([srcOrder],'NULL')+';')+isnull([srcFamily],'NULL'))+';')+isnull([srcSubFamily],'UNASSIGNED'))+';')+isnull([srcGenus],'NULL'))+';')+isnull([srcSpecies],'NULL')),
	[destLineageFamily]  AS ((isnull([destOrder],'NULL')+';')+isnull([destFamily],'NULL')),
	[destLineageSubFamily]  AS ((((isnull([destOrder],'NULL')+';')+isnull([destFamily],'NULL'))+';')+isnull([destSubFamily],'UNASSIGNED')),
	[destLineageGenus]  AS ((((((isnull([destOrder],'NULL')+';')+isnull([destFamily],'NULL'))+';')+isnull([destSubFamily],'UNASSIGNED'))+';')+isnull([destGenus],'NULL')),
	[destLineageSpecies]  AS ((((((((isnull([destOrder],'NULL')+';')+isnull([destFamily],'NULL'))+';')+isnull([destSubFamily],'UNASSIGNED'))+';')+isnull([destGenus],'NULL'))+';')+isnull([destSpecies],'NULL'))
) ON [PRIMARY]
GO
