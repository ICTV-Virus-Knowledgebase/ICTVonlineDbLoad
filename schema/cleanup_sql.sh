#!/usr/bin/env bash

echo "Remove 'USE [ICTVonlineXXX]' "
perl -pi -e 's/^USE \[ICTV[online]+.*\]//g' *.sql
echo "Strip script dates"
perl -pi -e 's/\/\*.*Object:.* Script Date: .*\*\///;' *.sql
echo "Strip DOS line terminations"
perl -pi -e 's/\r$//;' *.sql
# clean up perl's backup files
rm *.bak
