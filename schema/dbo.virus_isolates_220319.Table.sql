USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[virus_isolates_220319]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[virus_isolates_220319](
	[order] [nvarchar](4000) NULL,
	[family] [nvarchar](4000) NULL,
	[subfamily] [nvarchar](4000) NULL,
	[genus] [nvarchar](4000) NULL,
	[species] [nvarchar](4000) NULL,
	[exemplar] [nvarchar](4000) NULL,
	[exemplar_isolate] [nvarchar](4000) NULL,
	[exemplar_genbank_accession] [nvarchar](4000) NULL,
	[exemplar_refseq_accession] [nvarchar](4000) NULL,
	[exemplar_seq_complete] [nvarchar](4000) NULL,
	[isolate_csv] [nvarchar](4000) NULL,
	[isolate_genbank_accession_csv] [nvarchar](4000) NULL,
	[isolate_seq_complete_csv] [nvarchar](4000) NULL,
	[alternative_name_csv] [nvarchar](4000) NULL,
	[abbrev_csv] [nvarchar](4000) NULL,
	[isolate_abbrev] [nvarchar](4000) NULL,
	[sort] [int] NULL,
	[taxnode_id] [int] NULL
) ON [PRIMARY]
GO
