--
-- fix-up CSVs, where people tend to put quotes and semi-colons
--

select 
	report='CSVs with semi-colon separators and/or quotes embedded', 
	sort, isnull(_src_lineage, _dest_lineage), exemplarIsolate, exemplarAccessions, exemplarRefSeq, Abbrev  ,
--RUN-- update load_nexT_msl set
	 exemplarIsolate = replace(replace(exemplarIsolate,'"',''),';',',') 
	 , exemplarAccessions= replace(replace(exemplarAccessions,'"',''),';',',')
	 , exemplarRefSeq = replace(replace(exemplarRefSeq, '"',''),';',',')
	 , Abbrev = replace(replace(Abbrev,'"',''),';',',')
	from load_next_msl 
where 	
exemplarIsolate like '%"%' or exemplarIsolate like '%;%'
or
exemplarAccessions like '%"%' or exemplarAccessions like '%;%'
or
exemplarRefSeq like '%"%' or exemplarRefSeq like '%;%'
or 
Abbrev like '%"%' or Abbrev like '%;%'

select genbank_accession_csv
from taxonomy_node
where genbank_accession_csv is not null
and genbank_accession_csv like '%;%'
order by msl_release_num desc