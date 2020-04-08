print '--'
print '-- pull metadata from previous years and from load_next_msl'
print '--'
print ''
print '--'
print '-- from prev year'
print '--'


/*
-- debug
select 
	srcMsl = src.msl_release_num , srcLineage=src.lineage
	, srcAbbrev = src.abbrev_csv, srcMolId=src.molecule_id, srcAccess=src.genbank_accession_csv,srcIso=src.[isolate_csv]
	, d.tag_csv
	, destAbbrev = taxonomy_node.abbrev_csv, destMolId = taxonomy_node.molecule_id, destAccess=taxonomy_node.genbank_accession_csv, destIso=taxonomy_node.[isolate_csv]
	, destLineage = taxonomy_node.lineage
	,'||',
*/	
update taxonomy_node set	
	abbrev_csv = src.abbrev_csv, molecule_id=src.molecule_id, genbank_accession_csv=src.genbank_accession_csv,[isolate_csv]=src.[isolate_csv]
from taxonomy_node
join taxonomy_node_delta d on d.new_taxid = taxonomy_node.taxnode_id
join taxonomy_node src on src.taxnode_id = d.prev_taxid
where taxonomy_node.msl_release_num = (select max(msl_release_num) from taxonomy_toc) -- latest MSL
and (
	(src.abbrev_csv is not null and taxonomy_node.abbrev_csv is null or src.abbrev_csv <> taxonomy_node.abbrev_csv)
	or
	(src.molecule_id is not null and taxonomy_node.molecule_id is null or src.molecule_id <> taxonomy_node.molecule_id)
	or
	(src.genbank_accession_csv is not null and taxonomy_node.genbank_accession_csv is null or src.genbank_accession_csv <> taxonomy_node.genbank_accession_csv)
	or
	(src.[isolate_csv] is not null and taxonomy_node.[isolate_csv] is null or src.[isolate_csv] <> taxonomy_node.[isolate_csv])
)


print '--'
print '-- pull from the load'
print '--'
/*
select 
	ldMsl = ld.dest_msl_release_num , ldLineage=ld._dest_lineage
	, ldAbbrev = ld.Abbrev
	--, ldMolId=src.molecule_id
	, ldAccess=ld.Accessions
	,ldIso=ld.exemplarName
	, ldIsoID = ld.exemplarID
	, ld.change
	,'||'
	,abbrev_csv
	,molecule_id
	,genbank_accession_csv
	,[isolate_csv]
	,'||',*/
update taxonomy_node set	
	abbrev_csv = isnull(ld.Abbrev, abbrev_csv)
	--, molecule_id=isnull(ld.???, src.molecule_id)
	, genbank_accession_csv=isnull(ld.exemplarAccessions, genbank_accession_csv)
	,[isolate_csv]=isnull(ld.exemplarName+isnull(' '+ld.exemplarIsolate,''),[isolate_csv])
from taxonomy_node
join load_next_msl ld on ld.dest_taxnode_id = taxonomy_node.taxnode_id
where taxonomy_node.msl_release_num = (select max(msl_release_num) from taxonomy_toc) -- latest MSL
and (
	(ld.Abbrev is not null and taxonomy_node.abbrev_csv is null or ld.Abbrev <> taxonomy_node.abbrev_csv)
--	or
--	(src.molecule_id is not null and taxonomy_node.molecule_id is null or src.molecule_id <> taxonomy_node.molecule_id)
	or
	(ld.exemplarAccessions is not null and taxonomy_node.genbank_accession_csv is null or ld.exemplarAccessions <> taxonomy_node.genbank_accession_csv)
	or
	(ld.exemplarName is not null and taxonomy_node.[isolate_csv] is null or taxonomy_node.[isolate_csv] <> (ld.exemplarName+isnull(' '+ld.exemplarIsolate,'')) )
)


