CREATE TABLE taxonomy_json (
    `id` INT NOT NULL,
    `taxnode_id` INT NULL,
    `child_counts` VARCHAR(1000) CHARACTER SET utf8mb4 NULL,
    `child_json` LONGTEXT CHARACTER SET utf8mb4 NULL,
    `has_assigned_siblings` TINYINT(1) NULL,
    `has_species` TINYINT(1) NULL,
    `has_unassigned_siblings` CHAR(10) CHARACTER SET utf8mb4 NULL,
    `is_ghost_node` TINYINT(1) NOT NULL,
    `json` LONGTEXT CHARACTER SET utf8mb4 NULL,
    `parent_distance` INT NULL,
    `parent_id` INT NULL,
    `parent_taxnode_id` INT NULL,
    `rank_index` INT NOT NULL,
    `source` CHAR(1) CHARACTER SET utf8mb4 NULL,
    `tree_id` INT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;