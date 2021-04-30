--
-- fix-up CSVs, where people tend to put quotes and semi-colons
--
begin transaction

--
-- hand edit: MSL36
--
select report='CSVs with parenthetical seg names, instead of pre-fix colon-separated'
	, sort, exemplarAccessions, '>>',
-- RUN -- update load_next_msl set 
	exemplarAccessions='DNA-A:MK430076, DNA-B:MK430077, DNA-C:MK430078'
from load_next_msl 
where 
	exemplarAccessions='MK430076 (DNA-A), MK430077 (DNA-B), MK430078 (DNA-C)' 
	and 
	sort=12246                         

select report='CSVs with "and" and a half-paren'
	, sort, exemplarAccessions, '>>',
-- RUN -- update load_next_msl set 
	exemplarAccessions='L1:MN567049, L2:MN567050, S:MN567048'
from load_next_msl 
where 
	exemplarAccessions='L: MN567049 and MN567050; S:MN567048)' 
	and 
	sort=42892    
--
-- scan for hand-fix problems
--
select 
	report='CSVs with "and" or "()" embedded', 
	sort, isnull(_src_lineage, _dest_lineage), exemplarIsolate, exemplarAccessions, exemplarRefSeq, Abbrev
from load_next_msl 
where 	
	exemplarIsolate like '% and %' or exemplarIsolate like '%)%' or exemplarIsolate like '%(%'
	or
	exemplarAccessions like '% and %' or exemplarAccessions like '%)%' or exemplarAccessions like '%(%'
	or
	exemplarRefSeq like '% and %' or exemplarRefSeq like '%)%' or exemplarRefSeq like '%(%'
	or
	Abbrev like '% and %' or Abbrev like '%)%' or Abbrev like '%(%'
	


select 
	report='CSVs with semi-colon separators and/or quotes embedded', 
	sort, isnull(_src_lineage, _dest_lineage), exemplarIsolate, exemplarAccessions, exemplarRefSeq, Abbrev  ,
--RUN-- update load_nexT_msl set
	 exemplarIsolate = replace(replace(exemplarIsolate,'"',''),';',',') 
	 , exemplarAccessions= replace(replace(replace(exemplarAccessions,'"',''),';',','),' and ',', ')
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

--
-- historic records we should consider fixing
---
select genbank_accession_csv
from taxonomy_node
where genbank_accession_csv is not null
and genbank_accession_csv like '%;%'
order by msl_release_num desc

-- COMMIT TRANSACTION 