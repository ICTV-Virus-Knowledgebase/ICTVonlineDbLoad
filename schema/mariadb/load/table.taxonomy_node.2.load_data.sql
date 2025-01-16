-- taxonomy_node
LOAD DATA LOCAL INFILE '../../../data//taxonomy_node_mariadb_etl.utf8.osx.txt'
INTO TABLE taxonomy_node
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  taxnode_id,
  parent_id,
  tree_id,
  msl_release_num,
  level_id,
  name,
  ictv_id,
  molecule_id,
  abbrev_csv,
  genbank_accession_csv,
  genbank_refseq_accession_csv,
  refseq_accession_csv,
  isolate_csv,
  notes,
  is_ref,
  is_official,
  is_hidden,
  is_deleted,
  is_deleted_next_year,
  is_typo,
  is_renamed_next_year,
  is_obsolete,
  in_change,
  in_target,
  in_filename,
  in_notes,
  out_change,
  out_target,
  out_filename,
  out_notes,
  start_num_sort,
  row_num,
  filename,
  xref,
  realm_id,
  realm_kid_ct,
  realm_desc_ct,
  subrealm_id,
  subrealm_kid_ct,
  subrealm_desc_ct,
  kingdom_id,
  kingdom_kid_ct,
  kingdom_desc_ct,
  subkingdom_id,
  subkingdom_kid_ct,
  subkingdom_desc_ct,
  phylum_id,
  phylum_kid_ct,
  phylum_desc_ct,
  subphylum_id,
  subphylum_kid_ct,
  subphylum_desc_ct,
  class_id,
  class_kid_ct,
  class_desc_ct,
  subclass_id,
  subclass_kid_ct,
  subclass_desc_ct,
  order_id,
  order_kid_ct,
  order_desc_ct,
  suborder_id,
  suborder_kid_ct,
  suborder_desc_ct,
  family_id,
  family_kid_ct,
  family_desc_ct,
  subfamily_id,
  subfamily_kid_ct,
  subfamily_desc_ct,
  genus_id,
  genus_kid_ct,
  genus_desc_ct,
  subgenus_id,
  subgenus_kid_ct,
  subgenus_desc_ct,
  species_id,
  species_kid_ct,
  species_desc_ct,
  taxa_kid_cts,
  taxa_desc_cts,
  inher_molecule_id,
  left_idx,
  right_idx,
  node_depth,
  lineage,
  exemplar_name,
  genome_coverage,
  host_source
);

SELECT COUNT(*) AS total_count, '154166' AS should_be FROM taxonomy_node;


-- virus_prop
-- LOAD DATA LOCAL INFILE '../../../data//virus_prop.utf8.osx.txt'
-- INTO TABLE virus_prop
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   taxon,
--   sub_taxon,
--   molecule,
--   envelope,
--   morphology,
--   virion_size,
--   genome_segments,
--   genome_configuration,
--   genome_size,
--   host
-- );

-- -- taxonomy_toc
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_toc.utf8.osx.txt'
-- INTO TABLE taxonomy_toc
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   tree_id,
--   msl_release_num,
--   comments
-- );

-- -- taxonomy_node_merge_split
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_node_merge_split.utf8.osx.txt'
-- INTO TABLE taxonomy_node_merge_split
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   prev_ictv_id,
--   next_ictv_id,
--   is_merged,
--   is_split,
--   dist,
--   rev_count
-- );

-- -- taxonomy_node_delta
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_node_delta.utf8.osx.txt'
-- INTO TABLE taxonomy_node_delta
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   prev_taxid,
--   new_taxid,
--   proposal,
--   notes,
--   is_merged,
--   is_split,
--   is_moved,
--   is_promoted,
--   is_demoted,
--   is_renamed,
--   is_new,
--   is_deleted,
--   is_now_type,
--   is_lineage_updated,
--   msl
-- );

-- -- taxonomy_molecule
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_molecule.utf8.osx.txt'
-- INTO TABLE taxonomy_molecule
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   id,
--   abbrev,
--   name,
--   balt_group,
--   balt_roman,
--   description,
--   left_idx,
--   right_idx
-- );

-- -- taxonomy_level
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_level.utf8.osx.txt'
-- INTO TABLE taxonomy_level
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   id,
--   parent_id,
--   name,
--   plural,
--   suffix,
--   suffix_viroid,
--   suffix_nuc_acid,
--   suffix_viriform,
--   notes
-- );

-- -- taxonomy_json_rank
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_json_rank.utf8.osx.txt'
-- INTO TABLE taxonomy_json_rank
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   id,
--   level_id,
--   rank_index,
--   rank_name,
--   tree_id
-- );

-- -- taxonomy_json
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_json.utf8.osx.txt'
-- INTO TABLE taxonomy_json
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
-- id,
-- taxnode_id,
-- child_counts,
-- child_json,
-- has_assigned_siblings,
-- has_species,
-- has_unassigned_siblings,
-- is_ghost_node,
-- json,
-- parent_distance,
-- parent_id,
-- parent_taxnode_id,
-- rank_index,
-- source,
-- tree_id
-- );

-- -- taxonomy_host_source
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_host_source.utf8.osx.txt'
-- INTO TABLE taxonomy_host_source
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
-- host_source
-- );

-- -- taxonomy_genome_coverage
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_genome_coverage.utf8.osx.txt'
-- INTO TABLE taxonomy_genome_coverage
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
-- genome_coverage,
-- name,
-- priority
-- );

-- -- taxonomy_change_out
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_change_out.utf8.osx.txt'
-- INTO TABLE taxonomy_change_out
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
-- change,
-- notes
-- );

-- -- taxonomy_change_in
-- LOAD DATA LOCAL INFILE '../../../data//taxonomy_change_in.utf8.osx.txt'
-- INTO TABLE taxonomy_change_in
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
-- `change`,
-- notes
-- );

-- -- species_isolates
-- LOAD DATA LOCAL INFILE '../../../data//species_isolates.utf8.osx.txt'
-- INTO TABLE species_isolates
-- FIELDS TERMINATED BY '\t'
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (
--   isolate_id,
--   taxnode_id,
--   species_sort,
--   isolate_sort,
--   species_name,
--   isolate_type,
--   isolate_names,
--   isolate_abbrevs,
--   isolate_designation,
--   genbank_accessions,
--   refseq_accessions,
--   genome_coverage,
--   molecule,
--   host_source,
--   refseq_organism,
--   refseq_taxids,
--   update_change,
--   update_prev_species,
--   update_prev_taxnode_id,
--   update_change_proposal
-- );
