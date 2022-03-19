USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[load_next_msl_isOk] as select * from load_next_msl where isWrong is null
GO
