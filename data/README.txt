MSSQL ICTVOnline: EXPORT PROTOCOL

1. copy export_current_msl_tables.bat onto Windows MSSQL server
2. double click to run .bat file
3. Use RDC mounting of MacOSX directory to copy *.utf8.txt back to
       Mac:Documents/ICTV/xfer/prod/export_msl/
4. run push_to_box_rclone.sh
   (which will run convert_terminators_msdos2osx.sh before hand)
   (which will run push_to_git_repo.sh afterwards)
5. go do git add/commit/push by hand
