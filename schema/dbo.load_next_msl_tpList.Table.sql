USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[load_next_msl_tpList](
	[refNum] [smallint] NULL,
	[proposal] [nvarchar](40) NULL,
	[authors] [nvarchar](300) NULL,
	[shortTitle] [nvarchar](234) NULL,
	[studySection] [nvarchar](15) NULL
) ON [PRIMARY]
GO
