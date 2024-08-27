CREATE TABLE virus_prop (
    taxon VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    sub_taxon VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    molecule VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    envelope VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    morphology VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    virion_size VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    genome_segments VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    genome_configuration VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    genome_size VARCHAR(100) CHARACTER SET utf8mb4 NULL,
    host VARCHAR(100) CHARACTER SET utf8mb4 NULL
) ENGINE=InnoDB;