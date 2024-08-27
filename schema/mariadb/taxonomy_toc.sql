CREATE TABLE taxonomy_toc (
    tree_id INT NOT NULL,
    msl_release_num INT NULL,
    comments TEXT NULL,
    
    -- Unique index on tree_id
    UNIQUE KEY IX_taxonomy_toc_tree_id (tree_id),
    
    -- Primary key on tree_id and msl_release_num
    PRIMARY KEY (tree_id, msl_release_num)
) ENGINE=InnoDB;