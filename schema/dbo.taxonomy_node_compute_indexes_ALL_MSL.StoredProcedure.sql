USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[taxonomy_node_compute_indexes_ALL_MSL] AS

BEGIN
/*
 * for taxonomy_node_compute_indexes on ALL MSLs
 */

SET NOCOUNT ON
DECLARE @tree_id int

DECLARE UP_CURSOR CURSOR FOR
SELECT tree_id FROM taxonomy_toc WHERE msl_release_num is not null ORDER BY tree_id -- FOR UPDATE OF dest_taxnode_id, dest_ictv_id
OPEN UP_CURSOR
FETCH NEXT FROM UP_CURSOR INTO @tree_id

WHILE(@@FETCH_STATUS=0)
BEGIN
	PRINT '-- ##############################################################################'
	PRINT '-- ## tree_id='+rtrim(@tree_id)+''
	PRINT '-- ##############################################################################'
	exec taxonomy_node_compute_indexes @tree_id

	FETCH NEXT FROM UP_CURSOR INTO @tree_id
END

CLOSE UP_CURSOR
DEALLOCATE UP_CURSOR

SET NOCOUNT OFF

END

/* test
 *

 exec taxonomy_node_compute_indexes_ALL_MSL

 */
GO
