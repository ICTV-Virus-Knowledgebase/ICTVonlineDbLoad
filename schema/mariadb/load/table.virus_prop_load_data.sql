-- virus_prop
LOAD DATA LOCAL INFILE '../../../data//virus_prop.utf8.osx.txt'
INTO TABLE virus_prop
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  taxon,
  sub_taxon,
  molecule,
  envelope,
  morphology,
  virion_size,
  genome_segments,
  genome_configuration,
  genome_size,
  host
);