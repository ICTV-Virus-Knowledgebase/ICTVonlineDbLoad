CREATE TABLE `taxonomy_json_rank` (
  `id` INT AUTO_INCREMENT NOT NULL,
  `level_id` INT NOT NULL,
  `rank_index` INT NOT NULL,
  `rank_name` VARCHAR(50) NOT NULL,
  `tree_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `UK_taxonomy_json_rank` (`level_id`, `tree_id`),
  UNIQUE `UK_taxonomy_json_rank_rank_tree` (`rank_index`, `tree_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `taxonomy_json_rank`
  ADD CONSTRAINT `FK_taxonomy_json_rank_taxonomy_level` 
  FOREIGN KEY (`level_id`) REFERENCES `taxonomy_level` (`id`);

ALTER TABLE `taxonomy_json_rank`
  ADD CONSTRAINT `FK_taxonomy_json_rank_tree_id` 
  FOREIGN KEY (`tree_id`) REFERENCES `taxonomy_node` (`taxnode_id`);