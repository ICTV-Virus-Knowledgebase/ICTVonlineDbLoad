USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ictvdb_species]
AS
SELECT * 
FROM ictvdb_index
WHERE len(ictv_code) = 16 -- species ##.###.#.##.###.
GO
