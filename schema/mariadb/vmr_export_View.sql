CREATE VIEW `vmr_export` AS 
SELECT
    si.isolate_id AS `Isolate ID`,
    si.species_sort AS `Species Sort`,
    si.isolate_sort AS `Isolate Sort`,
    tn.realm AS `Realm`,
    tn.subrealm AS `Subrealm`,
    tn.kingdom AS `Kingdom`,
    tn.subkingdom AS `Subkingdom`,
    tn.phylum AS `Phylum`,
    tn.subphylum AS `Subphylum`,
    tn.class AS `Class`,
    tn.subclass AS `Subclass`,
    tn.`order` AS `Order`,
    tn.suborder AS `Suborder`,
    tn.family AS `Family`,
    tn.subfamily AS `Subfamily`,
    tn.genus AS `Genus`,
    tn.subgenus AS `Subgenus`,
    tn.species AS `Species`,
    CONCAT(si.isolate_type, '') AS `Exemplar or additional isolate`,
    CONCAT(si.isolate_names, '') AS `Virus name(s)`,
    CONCAT(si.isolate_abbrevs, '') AS `Virus name abbreviation(s)`,
    CONCAT(si.isolate_designation, '') AS `Virus isolate designation`,
    CONCAT(si.genbank_accessions, '') AS `Virus GENBANK accession`,
    CONCAT(si.refseq_accessions, '') AS `Virus REFSEQ accession`,
    CONCAT(si.refseq_taxids, '') AS `Virus REFSEQ NCBI taxid`,
    CONCAT(si.genome_coverage, '') AS `Genome coverage`,
    CONCAT(si.molecule, '') AS `Genome composition`,
    CONCAT(si.host_source, '') AS `Host source`,
    -- QC fields
    CASE WHEN si.molecule <> tn.inher_molecule THEN 'ERROR:molecule ' ELSE '' END AS `QC_status`,
    tn.inher_molecule AS `QC_taxon_inher_molecule`,
    si.update_change AS `QC_taxon_change`,
    IF(si.update_change_proposal IS NOT NULL,
       CONCAT('=HYPERLINK("https://ictv.global/ictv/proposals/', si.update_change_proposal, '","', si.update_change_proposal, '")'),
       '') AS `QC_taxon_proposal`
FROM species_isolates si
JOIN taxonomy_node_names tn ON tn.taxnode_id = si.taxnode_id
WHERE si.species_name <> 'abolished'
ORDER BY si.species_sort, si.isolate_sort
LIMIT 1000000;
