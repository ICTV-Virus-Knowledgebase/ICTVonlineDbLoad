CREATE TABLE `taxonomy_json` (
  `id` INT AUTO_INCREMENT NOT NULL,
  `taxnode_id` INT,
  `child_counts` VARCHAR(1000),
  `child_json` LONGTEXT,
  `has_assigned_siblings` TINYINT(1),
  `has_species` TINYINT(1),
  `has_unassigned_siblings` CHAR(10),
  `is_ghost_node` TINYINT(1) NOT NULL,
  `json` LONGTEXT,
  `json_lineage` LONGTEXT,
  `parent_distance` INT,
  `parent_id` INT,
  `parent_taxnode_id` INT,
  `rank_index` INT NOT NULL,
  `source` CHAR(1),
  `species_json` LONGTEXT,
  `tree_id` INT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE `taxonomy_json`
  ADD CONSTRAINT `FK_taxonomy_json_parent_taxonomy_node` 
  FOREIGN KEY (`parent_taxnode_id`) REFERENCES `taxonomy_node` (`taxnode_id`);

ALTER TABLE `taxonomy_json`
  ADD CONSTRAINT `FK_taxonomy_json_taxonomy_node` 
  FOREIGN KEY (`taxnode_id`) REFERENCES `taxonomy_node` (`taxnode_id`);

ALTER TABLE `taxonomy_json`
  ADD CONSTRAINT `FK_taxonomy_json_tree_id` 
  FOREIGN KEY (`tree_id`) REFERENCES `taxonomy_node` (`taxnode_id`);