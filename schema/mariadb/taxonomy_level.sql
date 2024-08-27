CREATE TABLE taxonomy_level (
    id INT NOT NULL,
    parent_id INT NULL,
    name VARCHAR(255) NOT NULL,
    plural VARCHAR(50) NULL,
    suffix VARCHAR(50) NULL,
    suffix_viroid VARCHAR(50) NULL,
    suffix_nuc_acid VARCHAR(50) NULL,
    suffix_viriform VARCHAR(50) NULL,
    notes TEXT NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_taxonomy_level_taxonomy_level FOREIGN KEY (parent_id) REFERENCES taxonomy_level(id)
) ENGINE=InnoDB;