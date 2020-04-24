USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[ictvdb_index]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ictvdb_index](
	[filename] [varchar](200) NOT NULL,
	[ictv_code] [varchar](30) NOT NULL,
	[name] [varchar](200) NOT NULL,
	[info_url] [varchar](200) NULL,
	[struct_url] [varchar](200) NULL
) ON [PRIMARY]
GO
