USE [ICTVonlnie34]
GO
/****** Object:  UserDefinedFunction [dbo].[lineage1]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[lineage1] (
	@taxnode_id int
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @seperator as varchar(50); SET @seperator = ';'

	RETURN(dbo.lineage(@taxnode_id, @seperator))
END
GO
