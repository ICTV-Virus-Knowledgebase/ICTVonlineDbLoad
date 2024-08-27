CREATE TABLE taxonomy_genome_coverage (
    genome_coverage VARCHAR(50) NOT NULL,
    name VARCHAR(50) NULL,
    priority INT NULL,
    PRIMARY KEY (genome_coverage),
    UNIQUE INDEX idx_name (name)
);