USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[ictvdb_sun_ah]    Script Date: 4/24/2020 3:40:38 PM ******/
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
