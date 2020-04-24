USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[udf_getChildTaxaCounts]
(
	@taxnode_id as int
)
RETURNS varchar(max)
AS
BEGIN
	
	RETURN (SELECT ISNULL(STUFF((
		SELECT ', ' + CAST(count(*) AS varchar(6)) + ' ' + (CASE WHEN count(*) > 1 THEN tl.plural ELSE tl.name END)
		FROM taxonomy_node sub
		JOIN taxonomy_node tn on tn.left_idx between sub.left_idx and sub.right_idx and tn.tree_id = sub.tree_id
		JOIN taxonomy_level tl on tl.id = tn.level_id
		WHERE sub.taxnode_id = @taxnode_id
		AND tn.taxnode_id <> sub.taxnode_id
		GROUP BY tl.plural, tl.name, tn.level_id
		ORDER BY tn.level_id
		FOR XML PATH('')
	), 1, 2, ''), ''));

	/*
	RETURN (SELECT ISNULL(STUFF((
			SELECT ', ' + CAST(count(*) AS varchar(6)) + ' ' + (CASE WHEN count(*) > 1 THEN lvl.plural ELSE lvl.name END)
			FROM taxonomy_node tn
			JOIN taxonomy_level lvl ON lvl.id = tn.level_id
			WHERE tn.parent_id = @taxnode_id
			AND tn.taxnode_id <> @taxnode_id 
			GROUP BY lvl.plural, lvl.name, tn.level_id
			ORDER BY tn.level_id
			FOR XML PATH('')

		), 1, 2, ''), '')
	);*/
END
GO
