#!/usr/bin/bash

echo "Convert 'USE [ICTVonlineXXX]' to [ICTVonline]"
perl -pi -e 's/USE \[ICTVonline.*\]/USE [ICTVonline]/g' *.sql
echo "Strip script dates"
perl -pi -e 's/\/\*.*Object:.* Script Date: .*\*\///;' *.sql
# clean up perl's backup files
rm *.bak
