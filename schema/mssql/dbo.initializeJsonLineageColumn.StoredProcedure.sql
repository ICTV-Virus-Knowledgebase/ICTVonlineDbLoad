
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[initializeJsonLineageColumn]
    @treeID AS INT
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON

	-- Variables used by ranked_node_cursor
	DECLARE @id AS INT
	DECLARE @parentLineage AS NVARCHAR(MAX)
	
	--==========================================================================================================
	-- Iterate over every node one rank at a time from realm down to species.
	--==========================================================================================================
	DECLARE ranked_node_cursor CURSOR FOR
		
		SELECT 
			tj.id,
			parentTJ.json_lineage AS parent_lineage

		FROM taxonomy_json tj
		LEFT JOIN taxonomy_json parentTJ ON parentTJ.id = tj.parent_id
		WHERE tj.tree_id = @treeID
		ORDER BY tj.rank_index ASC

	OPEN ranked_node_cursor  
	FETCH NEXT FROM ranked_node_cursor INTO @id, @parentLineage

	WHILE @@FETCH_STATUS = 0  
	BEGIN

      -- If the parent lineage isn't empty, append a comma.
      IF @parentLineage IS NOT NULL AND LEN(@parentLineage) > 0 
         SET @parentLineage = @parentLineage+','
		ELSE 
         SET @parentLineage = ''
			
		-- Populate the node's JSON lineage with its parent lineage and it's own ID.
		UPDATE taxonomy_json SET json_lineage = @parentLineage+CAST(@id AS VARCHAR(12))
		WHERE id = @id

		FETCH NEXT FROM ranked_node_cursor INTO @id, @parentLineage
	END 

	CLOSE ranked_node_cursor  
	DEALLOCATE ranked_node_cursor 
END
GO

