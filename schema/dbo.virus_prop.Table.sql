USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[virus_prop](
	[taxon] [nvarchar](100) NULL,
	[sub_taxon] [nvarchar](100) NULL,
	[molecule] [nvarchar](100) NULL,
	[envelope] [nvarchar](100) NULL,
	[morphology] [nvarchar](100) NULL,
	[virion_size] [nvarchar](100) NULL,
	[genome_segments] [nvarchar](100) NULL,
	[genome_configuration] [nvarchar](100) NULL,
	[genome_size] [nvarchar](100) NULL,
	[host] [nvarchar](100) NULL
) ON [PRIMARY]
GO
