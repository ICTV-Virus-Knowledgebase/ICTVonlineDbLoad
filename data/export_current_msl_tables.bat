@REM
@REM export tables to tsv needed for proposal_validator's current_msl/ cache
@REM
@REM 20250307 CurtisH switch copy back to ICTVdatabase/data/
@REM 20250306 CurtisH switch export file suffix to .utf8.dos.txt
@REM 20250227 CurtisH MSL40v1 fix taxobnomy_node_marisdb_etl to also be MSL40
@REM 20250130 CurtisH MSL40v1
@REM 20250113 CurtisH MSL39v4 +taxonomy_node_mariadb_etl, +virus_prop 
@REM 20230614 CurtisH MSL38
@REM
@REM basic method from 
@REM   https://stackoverflow.com/questions/1355876/export-table-to-file-with-column-headers-column-names-using-the-bcp-utility-an
@REM utf-8 (-f o:65001 ) from 
@REM   https://stackoverflow.com/questions/41561658/i-need-dump-table-from-sql-server-to-csv-in-utf-8
@REM


@REM primary data tables
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_toc]"| findstr /v /c:"-" /b > "taxonomy_toc.utf8.dos.txt"
@REM used by ProposalQC 
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_node_export]"| findstr /v /c:"-" /b > "taxonomy_node_export.utf8.dos.txt"
@REM used for ETL to MariaDB, until MariaDB is primary
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_node_mariadb_etl]"| findstr /v /c:"-" /b > "taxonomy_node_mariadb_etl.utf8.dos.txt"

@REM replaced with species_isolates
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[species_isolates]"| findstr /v /c:"-" /b > "species_isolates.utf8.dos.txt"

@REM CV tables
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_level]"| findstr /v /c:"-" /b > "taxonomy_level.utf8.dos.txt"
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_molecule]"| findstr /v /c:"-" /b > "taxonomy_molecule.utf8.dos.txt"
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_host_source]"| findstr /v /c:"-" /b > "taxonomy_host_source.utf8.dos.txt"
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_genome_coverage]"| findstr /v /c:"-" /b > "taxonomy_genome_coverage.utf8.dos.txt"
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_change_in]"| findstr /v /c:"-" /b > "taxonomy_change_in.utf8.dos.txt"
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_change_out]"| findstr /v /c:"-" /b > "taxonomy_change_out.utf8.dos.txt"



@REM cache tables
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_node_delta]"| findstr /v /c:"-" /b > "taxonomy_node_delta.utf8.dos.txt"
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[taxonomy_node_merge_split]"| findstr /v /c:"-" /b > "taxonomy_node_merge_split.utf8.dos.txt"

@REM convenience views
sqlcmd -s"	" -f o:65001 -W -Q "set nocount on; select * from [ICTVonline40].[dbo].[vmr_export]"| findstr /v /c:"-" /b > "vmr_export.utf8.dos.txt"

@REM copy back to laptop
copy /Y  *.txt \\tsclient\ICTV\ICTVdatabase\data
copy /Y  *.bat \\tsclient\ICTV\ICTVdatabase\data
