
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[grantSpecificExecutePermissions]
	@dbUser AS VARCHAR(100)
AS
BEGIN
/* usage
			exec grantSpecificExecutePermissions [IIS APPPOOL\ICTVonline]
			exec grantSpecificExecutePermissions [IIS APPPOOL\CSProd11]
 */
        SET XACT_ABORT, NOCOUNT ON

        -- A constant error code to use when throwing exceptions.
        DECLARE @errorCode AS INT = 50000

        BEGIN TRY

                -- Validate the dbUser parameter
                IF (ISNULL(@dbUser, '') = '') THROW @errorCode, 'DB user parameter is invalid (empty)', 1
                
                SET @dbUser = QUOTENAME(@dbUser);

                --==========================================================================================================
                -- TODO: add a line for every stored procedure and UDF that needs execute permissions.
                --==========================================================================================================
				-- STORED PROCEDURES
				EXEC ('GRANT EXECUTE ON [dbo].[createGhostNodes] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[createIntermediateGhostNodes] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[createParentGhostNodes] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[exportNonSpeciesTaxonomyJSON] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[exportReleasesJSON] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[exportSpeciesTaxonomyJSON] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[getTaxonReleaseHistory] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[getVirusIsolates] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[initializeJsonColumn] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[initializeJsonLineageColumn] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[initializeTaxonomyJsonFromTaxonomyNode] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[initializeTaxonomyJsonRanks] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[populateTaxonomyJSON] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[populateTaxonomyJsonForAllReleases] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[searchTaxonomy] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[searchVisualTaxonomy] TO '+@dbUser);


				-- TYPES
				EXEC ('GRANT CONTROL    ON TYPE::[dbo].[SingleIntTableType] TO '+@dbUser);
				EXEC ('GRANT REFERENCES ON TYPE::[dbo].[SingleIntTableType] TO '+@dbUser);

				-- USER DEFINED FUNCTIONS
				EXEC ('GRANT EXECUTE ON [dbo].[udf_getChildTaxaCounts] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[udf_getMSL] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[udf_getTaxNodeChildInfo] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[udf_getTreeID] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[udf_rankCountsToStringWithPurals] TO '+@dbUser);
				EXEC ('GRANT EXECUTE ON [dbo].[udf_singularOrPluralTaxLevelNames] TO '+@dbUser);
               -- (etc)
        


                --==========================================================================================================
                -- Generate a report of all relevant objects.
                -- Courtesy of https://stackoverflow.com/questions/1987190/scripting-sql-server-permissions
                --==========================================================================================================
                SELECT (
                        dp.state_desc + ' ' +
                        dp.permission_name collate latin1_general_cs_as + 
                        ' ON ' + '[' + s.name + ']' + '.' + '[' + o.name + ']' +
                        ' TO ' + '[' + dpr.name + ']'
                ) AS GRANT_STMT
                FROM sys.database_permissions AS dp
                  INNER JOIN sys.objects AS o ON dp.major_id=o.object_id
                  INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
                  INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id=dpr.principal_id
                WHERE dpr.name NOT IN ('public','guest')
                ORDER BY o.name ASC

        END TRY
        BEGIN CATCH
                DECLARE @errorMsg AS VARCHAR(200) = ERROR_MESSAGE()
                RAISERROR(@errorMsg, 18, 1)
        END CATCH 
END

GO

