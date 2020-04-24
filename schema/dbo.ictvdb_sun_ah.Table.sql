USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ictvdb_sun_ah](
	[line_num] [int] NULL,
	[rank] [int] NULL,
	[code] [varchar](25) NULL,
	[name] [varchar](255) NULL,
	[children] [int] NULL,
	[src_filename] [varchar](255) NULL
) ON [PRIMARY]
GO
