/*
 * MSL37
 *
 * export data by running queries in MSSQL
 * select results and do "Save As" > TSV
 *
 */
SELECT 'taxonomy_node', rows=count(*) from taxonomy_node
select * from taxonomy_node

select 'taxonomy_node_delta', rows=count(*) from taxonomy_node_delta
select * from taxonomy_node_delta


select 'taxonomy_node_merge_split', rows=count(*) from taxonomy_node_merge_split
select * from taxonomy_node_merge_split


select 'taxonomy_toc', rows=count(*) from taxonomy_toc
select * from taxonomy_toc

select 'taxonomy_molecule', rows=count(*) from taxonomy_molecule
select * from taxonomy_molecule

select 'taxonomy_level', rows=count(*) from taxonomy_level
select * from taxonomy_level

select 'taxonomy_change_in', rows=count(*) from taxonomy_change_in
select * from taxonomy_change_in

select 'taxonomy_change_out', rows=count(*) from taxonomy_change_out
select * from taxonomy_change_out


