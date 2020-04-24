USE [ICTVonlnie34]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_getImmediateChildTaxaCounts]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[udf_getImmediateChildTaxaCounts]
(
	@taxnode_id as int
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	RETURN (ISNULL((
		SELECT TOP 1 CAST(count(*) AS varchar(6)) + ' ' + (CASE WHEN count(*) > 1 THEN lvl.plural ELSE lvl.name END)
		FROM taxonomy_node tn
		JOIN taxonomy_level lvl ON lvl.id = tn.level_id
		WHERE tn.parent_id = @taxnode_id
		AND tn.taxnode_id <> @taxnode_id 
		GROUP BY lvl.plural, lvl.name, tn.level_id
		ORDER BY tn.level_id ASC
	),''));
END
GO
