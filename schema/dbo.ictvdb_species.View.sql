USE [ICTVonlnie34]
GO
/****** Object:  View [dbo].[ictvdb_species]    Script Date: 4/24/2020 3:40:38 PM ******/
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
