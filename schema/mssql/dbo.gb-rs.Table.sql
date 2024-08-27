USE [ICTVonline]
GO
/****** Object:  Table [dbo].[gb-rs]    Script Date: 8/20/2024 4:10:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[gb-rs](
	[refseq] [varchar](25) NULL,
	[genbank] [varchar](25) NOT NULL,
	[virus_name] [varchar](255) NULL
) ON [PRIMARY]
GO
