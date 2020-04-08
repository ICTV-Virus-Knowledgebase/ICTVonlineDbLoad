-- 
-- Query current MSL
-- 
-- with fields to fill in per proposals 
-- for future import of changes. 
select
	'tree_id', 'msl_release_num', 'sort_idx', 'taxnode_id', 'ictv_id'
	, 'hidden'
	, 'lineage', 'level', 'name'
	, 'type'
--	, 'indent_name'
	, 'rep_iso', 'GenBank','GenBankOfRefSeq', 'RefSeq','Abbrev', 'Molecule'

select 
	n.tree_id, n.msl_release_num, n.left_idx as sort_idx, n.taxnode_id, n.ictv_id
	, n.is_hidden as hidden
	, n.lineage, l.name as [level], ISNULL(n.name,'') as [name]
	, n.is_ref as [type]
	-- additional info we track
	, ISNULL(isolate_csv,'')					as rep_iso
	, ISNULL(genbank_accession_csv,'')			as GenBank
	, ISNULL(genbank_refseq_accession_csv,'')	as GenBankOfRefSeq
	, ISNULL(refseq_accession_csv,'')			as RefSeq
	, ISNULL(abbrev_csv,'')						as Abbrev
	, ISNULL(m.abbrev,'')						as Molecule
--	, replicate('|--', n.level_id/100)+n.name
from taxonomy_node n
join taxonomy_level l on l.id = n.level_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
where n.msl_release_num =(select MAX(msl_release_num) from taxonomy_node) 
and n.is_deleted = 0 and n.is_obsolete=0
order by left_idx

select abbrev from taxonomy_molecule
