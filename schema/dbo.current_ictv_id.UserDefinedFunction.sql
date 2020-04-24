USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[current_ictv_id] (@ictv_id int)
RETURNS int
AS 
BEGIN
	DECLARE @result int

	SELECT TOP 1 @result=final_id
	FROM taxonomy_node_merge
	WHERE merged_id = @ictv_id
	ORDER BY closure_length DESC

	RETURN ISNULL(@result, @ictv_id)
END
GO
