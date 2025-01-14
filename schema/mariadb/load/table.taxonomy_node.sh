#!/usr/bin/env bash
#
# run throught the steps to drop, create, load and QC taxonomy_node table
#
TDB="ICTVonline39_forProd"

mariadb -D $TBD -vvv --show-warnings < table.taxonomy_node.1.drop_create.sql
mariadb -D $TBD -vvv --show-warnings < table.taxonomy_node.2.load_data.sql
mariadb -D $TBD -vvv --show-warnings < table.taxonomy_node.5.qc_load.sql

