USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ictvdb_family]
AS
SELECT * 
FROM ictvdb_index
WHERE len(ictv_code) = 7 -- family ##.###.
GO
