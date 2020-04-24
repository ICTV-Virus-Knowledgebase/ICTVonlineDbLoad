USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ictvdb_genus]
AS
SELECT * 
FROM ictvdb_index
WHERE len(ictv_code) = 12 -- genus ##.###.#.##.
GO
