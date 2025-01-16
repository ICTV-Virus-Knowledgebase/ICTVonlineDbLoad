#!/usr/bin/env bash
#
# run throught the steps to drop, create, load and QC taxonomy_node table
#
TDB="ICTVonline39_forProd"

# mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node.1.drop_create.sql
# mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node.2.load_data.sql
# mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node.3.add_fks.sql
#
# mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node.5.qc_load.sql

# drop tables
mariadb -D $TDB -vvv --show-warnings < drop_tables.sql

# create tables
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_change_in_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_change_out_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_genome_coverage_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_host_source_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_level_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_molecule_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_toc_create.sql
mariadb -D $TDB -vvv --show-warnings < table.species_isolates_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node.1.drop_create.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node_merge_split_create.sql

# load data into the tables
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_change_in_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_change_out_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_genome_coverage_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_host_source_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_level_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_molecule_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_toc_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node.2.load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.species_isolates_load_data.sql
mariadb -D $TDB -vvv --show-warnings < table.taxonomy_node_merge_split_load_data.sql

# add views
mariadb -D $TDB -vvv --show-warnings < add_views.sql

# add indexes
mariadb -D $TDB -vvv --show-warnings < add_indexes.sql

# add foreign keys to tables
mariadb -D $TDB -vvv --show-warnings < add_foreign_keys.sql
