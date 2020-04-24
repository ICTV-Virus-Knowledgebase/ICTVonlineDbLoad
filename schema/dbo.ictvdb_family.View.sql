USE [ICTVonlnie34]
GO
/****** Object:  View [dbo].[ictvdb_family]    Script Date: 4/24/2020 3:40:38 PM ******/
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
