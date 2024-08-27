CREATE TABLE taxonomy_molecule (
    id INT NOT NULL,
    abbrev VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    balt_group INT NULL,
    balt_roman VARCHAR(5) NULL,
    description TEXT NULL,
    left_idx INT NULL,
    right_idx INT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;