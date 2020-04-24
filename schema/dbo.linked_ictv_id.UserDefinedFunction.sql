USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[linked_ictv_id] (@ictv_id int)
RETURNS TABLE
AS
RETURN 
(
	--DECLARE @ictv_id int; set @ictv_id=20074425

    SELECT ictv_id=@ictv_id, source='self'
	UNION
	SELECT ictv_id=final_id, source='merged to' 
	FROM taxonomy_node_merge
	WHERE merged_id = @ictv_id
	UNION 
	SELECT ictv_id=merged_id, source='merged from'
	FROM taxonomy_node_merge
	WHERE final_id = @ictv_id
);
GO
