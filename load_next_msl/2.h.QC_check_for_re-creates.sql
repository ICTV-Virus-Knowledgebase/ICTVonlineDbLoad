--
-- QC : do any of these action='new' taxa exist already?
--

--
-- QUERY bad taxa
--
select report='TAXON ALREADY EXISTS in MSL'+rtrim(tn.msl_release_num)
	, msl.filename
	-- load_next_msl fields
	,sort, proposal, change, _dest_lineage, _dest_taxon_name
	-- taxonomy_node fields
	, tn.taxnode_id,ictv_id, tn.lineage,  tn.is_ref,  tn.in_filename, tn. in_change
	, isWrong
	--
	-- !!  MARK BAD TAXA !!
	--
    -- UPDATE load_next_msl set isWrong = 'taxon already exists: taxnode_id='+rtrim(tn.taxnode_id)+', ictv_id='+rtrim(tn.ictv_id)+', lineage='+tn.lineage 
	--
from load_next_msl msl
-- prev MSL in taxnomy_node
join taxonomy_node tn  on tn.msl_release_num in( msl.dest_msl_release_num-1) and tn.name = msl._dest_taxon_name
where  msl._action = 'new'
--
-- skip this part to get a report of bads already set to isWrong=[message]
--
AND isWrong is NULL



--
-- FIXES 
--

--
-- MSL36.88750
-- 
/*
sort=88750, proposal=2020.094B.R.Leuconostoc_siphoviruses.zip, change=Create new, 
_dest_lineage=Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Caudovirales;Siphoviridae;Mccleskeyvirinae;Unaquatrovirus;Leuconostoc virus 1A4
*/

-- "remove" by setting isWrong='message'
select sort, isWrong, proposal, spreadsheet, _src_lineage, _src_taxon_rank, change, species,  _dest_lineage, rank,
-- RUN:
-- update load_next_msl set
--
	isWrong = 'already exists: taxnode=20175520'
from load_next_msl
where isWrong is null and sort=88750
