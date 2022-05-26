--
-- QC report: abbrev, isolate or accession number changes between MSLs
--
select 
	prev_msl = prev.msl_release_num
	,prev_idx = prev.left_idx
	,prev_name = prev.name
	,prev_lineage = prev.lineage
	,a='|-|'
	,prev_abbrev = prev.abbrev_csv
	,abbrDiff = (case when prev.abbrev_csv <> next.abbrev_csv then '<<DIFF>>' else '' end)
	,next_abbrev = next.abbrev_csv
	,b='|-|'
	,prev_access = prev.genbank_accession_csv
	,accessDiff = (case when prev.genbank_accession_csv <> next.genbank_accession_csv then '<<DIFF>>' else '' end)
	,next_access = next.genbank_accession_csv
	,c='|-|'
	,prev_iso = prev.isolate_csv
	,isoDiff = (case when prev.isolate_csv <> next.isolate_csv then '<<DIFF>>' else '' end)
	,next_iso = next.isolate_csv
	,d='|-|'
	,next_idx= next.left_idx
	,next_name = next.name
	,next_lineage = next.lineage
	,msl_release_num = next.msl_release_num
from taxonomy_node_delta delta 
left outer join taxonomy_node prev on prev.taxnode_id = delta.prev_taxid
left outer join taxonomy_node next on next.taxnode_id = delta.new_taxid
where 
	-- latest MSL
	next.msl_release_num = (select max(msl_release_num) from taxonomy_toc) 
and (
	prev.abbrev_csv <> next.abbrev_csv 
	or
	prev.genbank_accession_csv <> next.genbank_accession_csv
	or 
	prev.isolate_csv <> next.isolate_csv
)



GO


