CREATE TABLE taxonomy_json_v2 (
    id INT NOT NULL AUTO_INCREMENT,
    taxnode_id INT NULL,
    child_counts VARCHAR(1000) NULL,
    child_json TEXT NULL,
    has_assigned_siblings BOOLEAN NULL,
    has_species BOOLEAN NULL,
    has_unassigned_siblings CHAR(10) NULL,
    is_ghost_node BOOLEAN NOT NULL,
    json TEXT NULL,
    parent_distance INT NULL,
    parent_id INT NULL,
    parent_taxnode_id INT NULL,
    rank_index INT NOT NULL,
    source CHAR(1) NULL,
    tree_id INT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;