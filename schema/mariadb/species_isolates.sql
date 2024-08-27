CREATE TABLE species_isolates (
    isolate_id INT NOT NULL AUTO_INCREMENT,
    taxnode_id INT NULL,
    species_sort INT NULL,
    isolate_sort INT NOT NULL DEFAULT 1,
    species_name VARCHAR(100) NOT NULL,
    isolate_type CHAR(1) NOT NULL,
    isolate_names VARCHAR(500) NULL,
    _isolate_name VARCHAR(500) AS (
        CASE 
            WHEN isolate_names LIKE '%;%' THEN LEFT(isolate_names, LOCATE(';', isolate_names) - 1)
            ELSE isolate_names 
        END
    ) PERSISTENT,
    isolate_abbrevs VARCHAR(255) NULL,
    isolate_designation VARCHAR(500) NULL,
    genbank_accessions VARCHAR(4000) NULL,
    refseq_accessions VARCHAR(4000) NULL,
    genome_coverage VARCHAR(50) NULL,
    molecule VARCHAR(50) NULL,
    host_source VARCHAR(50) NULL,
    refseq_organism VARCHAR(255) NULL,
    refseq_taxids VARCHAR(4000) NULL,
    update_change VARCHAR(50) NULL,
    update_prev_species VARCHAR(100) NULL,
    update_prev_taxnode_id INT NULL,
    update_change_proposal VARCHAR(512) NULL,
    PRIMARY KEY (isolate_id)
) ENGINE=InnoDB;

-- Adding Foreign Key Constraints
ALTER TABLE species_isolates 
ADD CONSTRAINT FK_species_isolates_taxonomy_genome_coverage 
FOREIGN KEY (genome_coverage) 
REFERENCES taxonomy_genome_coverage (name);

ALTER TABLE species_isolates 
ADD CONSTRAINT FK_species_isolates_taxonomy_host_source 
FOREIGN KEY (host_source) 
REFERENCES taxonomy_host_source (host_source);

ALTER TABLE species_isolates 
ADD CONSTRAINT FK_species_isolates_taxonomy_molecule 
FOREIGN KEY (molecule) 
REFERENCES taxonomy_molecule (abbrev);

ALTER TABLE species_isolates 
ADD CONSTRAINT FK_species_isolates_taxonomy_node 
FOREIGN KEY (taxnode_id) 
REFERENCES taxonomy_node (taxnode_id);

ALTER TABLE species_isolates 
ADD CONSTRAINT FK_species_isolates_taxonomy_update_prev_taxnode_id 
FOREIGN KEY (update_prev_taxnode_id) 
REFERENCES taxonomy_node (taxnode_id);