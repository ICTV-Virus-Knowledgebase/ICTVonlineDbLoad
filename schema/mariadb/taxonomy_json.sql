CREATE TABLE taxonomy_json (
    id INT AUTO_INCREMENT NOT NULL,
    taxnode_id INT NULL,
    child_counts VARCHAR(1000) NULL,
    child_json TEXT NULL,  -- Adjusted for large text storage
    has_assigned_siblings BOOLEAN NULL,  -- BIT converted to BOOLEAN
    has_species BOOLEAN NULL,  -- BIT converted to BOOLEAN
    has_unassigned_siblings CHAR(10) NULL,
    is_ghost_node BOOLEAN NOT NULL,  -- BIT converted to BOOLEAN
    json TEXT NULL,  -- Adjusted for large text storage
    json_lineage TEXT NULL,  -- Adjusted for large text storage
    parent_distance INT NULL,
    parent_id INT NULL,
    parent_taxnode_id INT NULL,
    rank_index INT NOT NULL,
    source CHAR(1) NULL,
    species_json TEXT NULL,  -- Adjusted for large text storage
    tree_id INT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- Adding Foreign Key Constraints
ALTER TABLE taxonomy_json 
ADD CONSTRAINT FK_taxonomy_json_parent_taxonomy_node 
FOREIGN KEY (parent_taxnode_id) REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_json 
ADD CONSTRAINT FK_taxonomy_json_taxonomy_node 
FOREIGN KEY (taxnode_id) REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE taxonomy_json 
ADD CONSTRAINT FK_taxonomy_json_tree_id 
FOREIGN KEY (tree_id) REFERENCES taxonomy_node (taxnode_id);