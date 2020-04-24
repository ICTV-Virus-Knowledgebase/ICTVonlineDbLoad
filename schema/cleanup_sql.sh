#!/usr/bin/bash

echo "Convert 'USE [ICTVonlineXXX]' to [ICTVonline]"
perl -pi -e 's/USE \[ICTVonline.*\]/USE [ICTVonline]/g' *.sql
# clean up perl's backup files
rm *.bak
