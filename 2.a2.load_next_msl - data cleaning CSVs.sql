--
-- fix-up CSVs, where people tend to put quotes and semi-colons
--
begin transaction

/*
* MSL37 QC spot checks
*/
-- MSL long dashes
select proposal, species, exemplarAccessions from load_next_msl where exemplarAccessions like '%â€%' or exemplarAccessions like 'LC57644%LC576451' -- long dash
-- check I18N
select proposal, species, Abbrev, correct=N'Wǔhàn',
	status=(case when Abbrev like N'Wǔhàn%' then 'OK' else 'ERROR' end)
from load_next_msl where Abbrev like '%sharpbelly bornavirus%' -- accented vowels
-- there should be no "-" in Accession lists.
select proposal, species, exemplarAccessions from load_next_msl where exemplarAccessions like '%–%'

/*
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
	*/
--
-- scan for hand-fix problems
--
select 
	report='CSVs with "and" or "()" embedded', 
	proposal, sort, isnull(_src_lineage, _dest_lineage), exemplarIsolate, exemplarAccessions, exemplarRefSeq, Abbrev,
	errors=
			(case when exemplarIsolate like '% and %' then 'exemplarIsolate-and;' else '' end)+
			(case when exemplarIsolate like '%(%' then 'exemplarIsolate-(;' else '' end)+
			(case when exemplarIsolate like '%)%' then 'exemplarIsolate-);' else '' end)+
			(case when exemplarAccessions like '% and %' then 'exemplarAccessions-and;' else '' end)+
			(case when exemplarAccessions like '%(%' then 'exemplarAccessions-(;' else '' end)+
			(case when exemplarAccessions like '%)%' then 'exemplarAccessions-);' else '' end)+
			(case when exemplarRefSeq like '% and %' then 'exemplarRefSeq-and;' else '' end)+
			(case when exemplarRefSeq like '%(%' then 'exemplarRefSeq-(;' else '' end)+
			(case when exemplarRefSeq like '%)%' then 'exemplarRefSeq-);' else '' end)+
			(case when Abbrev like '% and %' then 'Abbrev-and;' else '' end)+
			(case when Abbrev like '%(%' then 'Abbrev-(;' else '' end)+
			(case when Abbrev like '%)%' then 'Abbrev-);' else '' end)
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
	proposal, sort, isnull(_src_lineage, _dest_lineage), exemplarIsolate, exemplarAccessions, exemplarRefSeq, Abbrev  ,
	errors=
			(case when exemplarIsolate like '%"%' then 'exemplarIsolate-quote;' else '' end)+
			(case when exemplarIsolate like '%;%' then 'exemplarIsolate-semicolon;' else '' end)+
			(case when exemplarAccessions like '%"%' then 'exemplarAccessions-quote' else '' end)+
			(case when exemplarAccessions like '%;%' then 'exemplarAccessions-semicolon'   else '' end)+
			(case when exemplarRefSeq like '%"%' then 'exemplarRefSeq-quote' else '' end)+
			(case when exemplarRefSeq like '%;%' then 'exemplarRefSeq-semicolon' else '' end)+
			(case when Abbrev like '%"%' then 'Abbrev-quote' else '' end)+
			(case when Abbrev like '%;%' then 'Abbrev-semicolon' else '' end),
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
select msl_release_num, genbank_accession_csv
from taxonomy_node
where genbank_accession_csv is not null
and genbank_accession_csv like '%;%'
order by msl_release_num desc

-- COMMIT TRANSACTION 