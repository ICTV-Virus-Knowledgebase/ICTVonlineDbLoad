/*
* QC: load_next_msl.exemplarAccessions
*/

-- 
-- check for "ranges" of numbers
--
select [REPORT: illegal exemplarAccessions values]='ERROR'
	, exemplarAccessions, '||||', * 
from load_next_msl 
where exemplarAccessions like '% to %' or exemplarAccessions like '%-%'

/*
--
-- MSL37 fixes
--

update load_next_msl_isok set 
--select *,
	exemplarAccessions = '1:KX882061; 2:KX882062; 3:KX882063; 4:KX882064; 5:KX882065; 6:KX882066; 7:KX882067; 8:KX882068'
from load_next_msl_isok where species='Mykissvirus tructae' and exemplarAccessions like 'KX882061%' --or genus='Mykissvirus'

update taxonomy_node set 
-- select *,
	genbank_accession_csv = '1:KX882061; 2:KX882062; 3:KX882063; 4:KX882064; 5:KX882065; 6:KX882066; 7:KX882067; 8:KX882068'
from taxonomy_node 
where msl_release_num=37 and name='Mykissvirus tructae' and genbank_accession_csv like 'KX882061%'

*/