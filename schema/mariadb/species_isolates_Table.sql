CREATE TABLE `species_isolates` (
  `isolate_id` INT AUTO_INCREMENT NOT NULL,
  `taxnode_id` INT,
  `species_sort` INT,
  `isolate_sort` INT NOT NULL DEFAULT 1,
  `species_name` VARCHAR(100) NOT NULL,
  `isolate_type` CHAR(1) NOT NULL,
  `isolate_names` VARCHAR(500),
  `isolate_abbrevs` VARCHAR(255),
  `isolate_designation` VARCHAR(500),
  `genbank_accessions` VARCHAR(4000),
  `refseq_accessions` VARCHAR(4000),
  `genome_coverage` VARCHAR(50),
  `molecule` VARCHAR(50),
  `host_source` VARCHAR(50),
  `refseq_organism` VARCHAR(255),
  `refseq_taxids` VARCHAR(4000),
  `update_change` VARCHAR(50),
  `update_prev_species` VARCHAR(100),
  `update_prev_taxnode_id` INT,
  `update_change_proposal` VARCHAR(512),
  PRIMARY KEY (`isolate_id`),
  `_isolate_name` VARCHAR(500) GENERATED ALWAYS AS (
    CASE 
      WHEN `isolate_names` LIKE '%;%' 
      THEN LEFT(`isolate_names`, LOCATE(';', `isolate_names`) - 1) 
      ELSE `isolate_names` 
    END
  ) PERSISTENT,
  `notes` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Adding Foreign Key Constraints
ALTER TABLE `species_isolates` 
ADD CONSTRAINT `FK_species_isolates_taxonomy_genome_coverage` 
FOREIGN KEY (`genome_coverage`) 
REFERENCES `taxonomy_genome_coverage` (`name`);

ALTER TABLE `species_isolates` 
ADD CONSTRAINT `FK_species_isolates_taxonomy_host_source` 
FOREIGN KEY (`host_source`) 
REFERENCES `taxonomy_host_source` (`host_source`);

ALTER TABLE `species_isolates` 
ADD CONSTRAINT `FK_species_isolates_taxonomy_molecule` 
FOREIGN KEY (`molecule`) 
REFERENCES `taxonomy_molecule` (`abbrev`);

ALTER TABLE `species_isolates` 
ADD CONSTRAINT `FK_species_isolates_taxonomy_node` 
FOREIGN KEY (`taxnode_id`) 
REFERENCES `taxonomy_node` (`taxnode_id`);

ALTER TABLE `species_isolates` 
ADD CONSTRAINT `FK_species_isolates_taxonomy_update_prev_taxnode_id` 
FOREIGN KEY (`update_prev_taxnode_id`) 
REFERENCES `taxonomy_node` (`taxnode_id`);