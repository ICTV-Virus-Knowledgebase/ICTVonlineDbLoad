--
-- QC : do any of these taxa exist already?
--

select report='TAXON ALREADY EXISTS in MSL'+rtrim(tn.msl_release_num)
	, msl.filename
	-- load_next_msl fields
	,sort, proposal, change, _dest_lineage, _dest_taxon_name
	-- taxonomy_node fields
	, tn.taxnode_id,ictv_id, tn.lineage,  tn.is_ref,  tn.in_filename, tn. in_change
	--!!  MARK BAD TAXA !!
    --update load_next_msl set isWrong = 'taxon already exists: taxnode_id='+rtrim(tn.taxnode_id)+', ictv_id='+rtrim(tn.ictv_id)+', lineage='+tn.lineage 
from load_next_msl msl
-- prev MSL in taxnomy_node
join taxonomy_node tn  on tn.msl_release_num in( msl.dest_msl_release_num-1) and tn.name = msl._dest_taxon_name
where isWrong is NULL
AND msl._action = 'new'

