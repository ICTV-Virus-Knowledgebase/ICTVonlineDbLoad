USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VMR-new](
	[sort] [int] NULL,
	[order] [nvarchar](4000) NULL,
	[family] [nvarchar](4000) NULL,
	[subfamily] [nvarchar](4000) NULL,
	[genus] [nvarchar](4000) NULL,
	[species] [nvarchar](4000) NULL,
	[exemplar] [nvarchar](4000) NULL,
	[alternative_name_csv] [nvarchar](4000) NULL,
	[abbrev_csv] [nvarchar](4000) NULL,
	[exemplar_isolate] [nvarchar](4000) NULL,
	[genbank] [nvarchar](4000) NULL,
	[refseq] [nvarchar](4000) NULL,
	[seq_complete] [nvarchar](4000) NULL,
	[genome_comp] [nvarchar](4000) NULL,
	[host] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
