#!/usr/bin/env bash
#
# convert all .utf8.txt files to .utf8.osx.txt
#
# These files originate on a windows machine, MSSQL PROD, with MSDOS endings. 
# This converts them to OSX endings (running on Curtis' mac), before loading them up to box, to be 
# downloaded onto Logan's mac, and being scp'ed to the linux machine for loading into MariaDB
#
for x in *utf8.dos.txt; do 

	# build output filenames
	y=$(basename $x .dos.txt).txt; 

	# announce 
	echo "$x => $y"; 

	# do the terminator transformation
	sed 's/\r$//' $x > $y; 
done

# bat files
perl -pi -e 's/\r$//;' export_current_msl_tables.bat

# QC display
(echo -e "SRC_FILE SRC_LINES OSX_LINES";join -1 2 -2 2 <(wc -l *.utf8.txt) <(wc -l *.utf8.dos.txt|sed 's/dos.//;') )| column -t
