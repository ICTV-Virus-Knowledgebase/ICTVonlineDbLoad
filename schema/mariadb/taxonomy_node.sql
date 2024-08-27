CREATE TABLE taxonomy_node (
    taxnode_id INT NOT NULL,
    parent_id INT NULL,
    tree_id INT NOT NULL,
    msl_release_num INT NULL,
    level_id INT NULL,
    name VARCHAR(100) NULL,
    ictv_id INT NULL,
    molecule_id INT NULL,
    abbrev_csv TEXT NULL,
    genbank_accession_csv TEXT NULL,
    genbank_refseq_accession_csv TEXT NULL,
    refseq_accession_csv TEXT NULL,
    isolate_csv TEXT NULL,
    notes TEXT NULL,
    is_ref INT NOT NULL DEFAULT 0,
    is_official INT NOT NULL DEFAULT 0,
    is_hidden INT NOT NULL DEFAULT 0,
    is_deleted INT NOT NULL DEFAULT 0,
    is_deleted_next_year INT NOT NULL DEFAULT 0,
    is_typo INT NOT NULL DEFAULT 0,
    is_renamed_next_year INT NOT NULL DEFAULT 0,
    is_obsolete INT NOT NULL DEFAULT 0,
    in_change VARCHAR(10) NULL,
    in_target VARCHAR(255) NULL,
    in_filename VARCHAR(255) NULL,
    in_notes TEXT NULL,
    out_change VARCHAR(10) NULL,
    out_target VARCHAR(255) NULL,
    out_filename VARCHAR(255) NULL,
    out_notes TEXT NULL,
    start_num_sort INT NULL DEFAULT NULL,
    row_num VARCHAR(25) NULL,
    filename VARCHAR(255) NULL,
    xref VARCHAR(255) NULL,
    realm_id INT NULL,
    realm_kid_ct INT NULL,
    realm_desc_ct INT NULL,
    subrealm_id INT NULL,
    subrealm_kid_ct INT NULL,
    subrealm_desc_ct INT NULL,
    kingdom_id INT NULL,
    kingdom_kid_ct INT NULL,
    kingdom_desc_ct INT NULL,
    subkingdom_id INT NULL,
    subkingdom_kid_ct INT NULL,
    subkingdom_desc_ct INT NULL,
    phylum_id INT NULL,
    phylum_kid_ct INT NULL,
    phylum_desc_ct INT NULL,
    subphylum_id INT NULL,
    subphylum_kid_ct INT NULL,
    subphylum_desc_ct INT NULL,
    class_id INT NULL,
    class_kid_ct INT NULL,
    class_desc_ct INT NULL,
    subclass_id INT NULL,
    subclass_kid_ct INT NULL,
    subclass_desc_ct INT NULL,
    order_id INT NULL,
    order_kid_ct INT NULL,
    order_desc_ct INT NULL,
    suborder_id INT NULL,
    suborder_kid_ct INT NULL,
    suborder_desc_ct INT NULL,
    family_id INT NULL,
    family_kid_ct INT NULL,
    family_desc_ct INT NULL,
    subfamily_id INT NULL,
    subfamily_kid_ct INT NULL,
    subfamily_desc_ct INT NULL,
    genus_id INT NULL,
    genus_kid_ct INT NULL,
    genus_desc_ct INT NULL,
    subgenus_id INT NULL,
    subgenus_kid_ct INT NULL,
    subgenus_desc_ct INT NULL,
    species_id INT NULL,
    species_kid_ct INT NULL,
    species_desc_ct INT NULL,
    taxa_kid_cts VARCHAR(200) NULL,
    taxa_desc_cts VARCHAR(200) NULL,
    inher_molecule_id INT NULL,
    left_idx INT NULL,
    right_idx INT NULL,
    node_depth INT NULL,
    lineage VARCHAR(500) NULL,
    cleaned_name VARCHAR(100) AS (
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(name, 'í', 'i'), 'é', 'e'), 'ó', 'o'), 'ú', 'u'), 'á', 'a'),
    'ì', 'i'), 'è', 'e'), 'ò', 'o'), 'ù', 'u'), 'à', 'a'), 'î', 'i'), 'ê', 'e'),
    'ô', 'o'), 'û', 'u'), 'â', 'a'), 'ü', 'u'), 'ö', 'o'), 'ï', 'i'), 'ë', 'e'),
    'ä', 'a'), 'ç', 'c'), 'ñ', 'n'), '‘', ''''), '’', ''''), '`', ' '), '  ', ' '),
    'ā', 'a'), 'ī', 'i'), 'ĭ', 'i'), 'ǎ', 'a'), 'ē', 'e'), 'ō', 'o')
) PERSISTENT,
    cleaned_problem VARCHAR(100) AS (
    CASE 
        WHEN INSTR(name, 'í') > 0 THEN 'í (accented i)'
        WHEN INSTR(name, 'é') > 0 THEN 'é (accented e)'
        WHEN INSTR(name, 'ó') > 0 THEN 'ó (accented o)'
        WHEN INSTR(name, 'ú') > 0 THEN 'ú (accented u)'
        WHEN INSTR(name, 'á') > 0 THEN 'á (accented a)'
        WHEN INSTR(name, 'ì') > 0 THEN 'ì (accented i)'
        WHEN INSTR(name, 'è') > 0 THEN 'è (accented e)'
        WHEN INSTR(name, 'ò') > 0 THEN 'ò (accented o)'
        WHEN INSTR(name, 'ù') > 0 THEN 'ù (accented u)'
        WHEN INSTR(name, 'à') > 0 THEN 'à (accented a)'
        WHEN INSTR(name, 'î') > 0 THEN 'î (accented i)'
        WHEN INSTR(name, 'ê') > 0 THEN 'ê (accented e)'
        WHEN INSTR(name, 'ô') > 0 THEN 'ô (accented o)'
        WHEN INSTR(name, 'û') > 0 THEN 'û (accented u)'
        WHEN INSTR(name, 'â') > 0 THEN 'â (accented a)'
        WHEN INSTR(name, 'ü') > 0 THEN 'ü (accented u)'
        WHEN INSTR(name, 'ö') > 0 THEN 'ö (accented o)'
        WHEN INSTR(name, 'ï') > 0 THEN 'ï (accented i)'
        WHEN INSTR(name, 'ë') > 0 THEN 'ë (accented e)'
        WHEN INSTR(name, 'ä') > 0 THEN 'ä (accented a)'
        WHEN INSTR(name, 'ç') > 0 THEN 'ç (accented c)'
        WHEN INSTR(name, 'ñ') > 0 THEN 'ñ (accented n)'
        WHEN INSTR(name, '‘') > 0 THEN '‘ (Microsoft curvy open single-quote)'
        WHEN INSTR(name, '’') > 0 THEN '’ (Microsoft curvy close single-quote)'
        WHEN INSTR(name, '`') > 0 THEN '` (ASCII back-quote)'
        WHEN INSTR(name, '  ') > 0 THEN '(double space)'
        WHEN INSTR(name, 'ā') > 0 THEN 'a-macron'
        WHEN INSTR(name, 'ī') > 0 THEN 'i-macron'
        WHEN INSTR(name, 'ĭ') > 0 THEN 'i-breve'
        WHEN INSTR(name, 'ǎ') > 0 THEN 'a-caron'
        WHEN INSTR(name, 'ē') > 0 THEN 'e-macron'
        WHEN INSTR(name, 'ō') > 0 THEN 'o-macron'
    END
) PERSISTENT,

    flags VARCHAR(255) AS (
    CONCAT(
        IF(tree_id = taxnode_id, 'root;', ''),
        IF(is_hidden = 1, 'hidden;', ''),
        IF(is_deleted = 1, 'deleted;', ''),
        IF(is_deleted_next_year = 1, 'removed_next_year;', ''),
        IF(is_typo = 1, 'typo;', ''),
        IF(is_renamed_next_year = 1, 'renamed_next_year;', ''),
        IF(is_obsolete = 1, 'obsolete;', '')
    )
) VIRTUAL,
    _numKids INT AS (((right_idx - left_idx) - 1) / 2) PERSISTENT,
    _out_target_parent VARCHAR(1000) AS (TRIM(TRAILING FROM TRIM(LEADING FROM REVERSE(SUBSTRING(REPLACE(REVERSE(out_target), ';', REPEAT(' ', 1000)), 500, 1500))))) PERSISTENT,
    _out_target_name VARCHAR(500) AS (TRIM(TRAILING FROM TRIM(LEADING FROM REVERSE(SUBSTRING(REPLACE(REVERSE(out_target), ';', REPEAT(' ', 1000)), 0, 500))))) PERSISTENT,
    exemplar_name TEXT NULL,
    genome_coverage VARCHAR(50) NULL,
    host_source VARCHAR(50) NULL,
    PRIMARY KEY (taxnode_id)
) ENGINE=InnoDB;

-- Foreign Key Constraints
ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_change_in
FOREIGN KEY (in_change)
REFERENCES taxonomy_change_in (`change`);

ALTER TABLE taxonomy_node 
ADD CONSTRAINT FK_taxonomy_node_taxonomy_change_out 
FOREIGN KEY (out_change) REFERENCES taxonomy_change_out (`change`);

ALTER TABLE taxonomy_node 
ADD CONSTRAINT FK_taxonomy_node_taxonomy_genome_coverage 
FOREIGN KEY (genome_coverage) REFERENCES taxonomy_genome_coverage (genome_coverage);

ALTER TABLE taxonomy_node 
ADD CONSTRAINT FK_taxonomy_node_taxonomy_host_source 
FOREIGN KEY (host_source) REFERENCES taxonomy_host_source (host_source);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_level_level_id
FOREIGN KEY (level_id)
REFERENCES taxonomy_level (id)
ON DELETE CASCADE;

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_molecule_inher_molecule_id
FOREIGN KEY (inher_molecule_id)
REFERENCES taxonomy_molecule (id);

ALTER TABLE taxonomy_node 
ADD CONSTRAINT FK_taxonomy_node_taxonomy_molecule_molecule_id 
FOREIGN KEY (molecule_id) REFERENCES taxonomy_molecule (id);

ALTER TABLE taxonomy_node 
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_family_id 
FOREIGN KEY (family_id) REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node 
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_genus_id 
FOREIGN KEY (genus_id) REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_ictv_id
FOREIGN KEY (ictv_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_order_id
FOREIGN KEY (order_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_species_id
FOREIGN KEY (species_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_subfamily_id
FOREIGN KEY (subfamily_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_tree_id
FOREIGN KEY (tree_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_class_id
FOREIGN KEY (class_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_kingdom_id
FOREIGN KEY (kingdom_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_phylum_id
FOREIGN KEY (phylum_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_realm_id
FOREIGN KEY (realm_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_subclass_id
FOREIGN KEY (subclass_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_subgenus_id
FOREIGN KEY (subgenus_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_subkingdom_id
FOREIGN KEY (subkingdom_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_suborder_id
FOREIGN KEY (suborder_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_subphylum_id
FOREIGN KEY (subphylum_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_node_subrealm_id
FOREIGN KEY (subrealm_id)
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_node
ADD CONSTRAINT FK_taxonomy_node_taxonomy_toc
FOREIGN KEY (tree_id, msl_release_num)
REFERENCES taxonomy_toc (tree_id, msl_release_num);