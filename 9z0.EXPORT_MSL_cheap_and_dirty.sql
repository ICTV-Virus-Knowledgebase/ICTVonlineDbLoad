-- ------------------------------------------------------------------------------------------------
-- EXPORT MSL --- **FAST** --- version 
-- 
-- DOES NOT inherit extended fields from previous versions of MSL
-- 		ncbi, isoalte, molecule, last_change, last_change_msl, history_url
-- NON-included extended fields:
--		FYI_molecule_type
--
-- Run time 
--  1 < 3 minutes 

select warning = 'QUICK AND DIRTY EXPORT - no pull-forward of historic properties'

select 
	-- basic MSL - one line per species
	--TN.msl_release_num, -- debugging
	order_name = ord.name
	, family_name = family.name
	, subfamily_name =  case when subfamily.is_hidden=1 then ''  else isnull(subfamily.name,'') end 
	, genus_name = genus.name
	, species_name = tn.name
	, type_species = tn.is_ref
	-- add info on most recent change to that taxon
	--,tn.taxnode_id, tn.ictv_id, 
	-- select msl_release_num, ictV_id, name, abbrev from taxonomy_node where abbrev is not null
	,last_ncbi=isnull(tn.genbank_accession_csv,'')
	,last_isolates=isnull(tn.isolate_csv,'')
	-- add info on most recent molecule type designation to that taxon (or it's ancestors)
	,molecule = isnull(mol.abbrev,'')
	-- add info on most recent change to that taxon (or it's ancestors)
	, last_change=isnull((select tag_csv from taxonomy_node_delta where new_taxid = tn.taxnode_id),'')
	, last_change_msl=case when (select tag_csv from taxonomy_node_delta where new_taxid = tn.taxnode_id) <> '' then rtrim(tn.msl_release_num) else '' end
	, last_change_proposal=isnull(tn.in_filename,'')
	, history_url = '=HYPERLINK("http://ictvonline.org/taxonomyHistory.asp?taxnode_id='+rtrim(tn.taxnode_id)+'","ICTVonline='+rtrim(tn.taxnode_id)+'")'
	-- these columns are not currently released in the official MSL
	-- ICTV does not OFFICIALLY track abbreviations 
	, FYI_last_abbrev=isnull(tn.abbrev_csv,'')
from taxonomy_node tn
left outer join taxonomy_node genus on genus.taxnode_id=tn.genus_id
left outer join taxonomy_node subfamily on subfamily.taxnode_id=tn.subfamily_id
left outer join taxonomy_node family on family.taxnode_id=tn.family_id
left outer join taxonomy_node ord on ord.taxnode_id=tn.order_id
left outer join taxonomy_molecule mol on mol.id = tn.inher_molecule_id
where tn.is_deleted = 0 and tn.is_hidden = 0 and tn.is_obsolete=0
and tn.msl_release_num = (select max(msl_release_num) from taxonomy_node)
and tn.level_id = 600 /* species */
-- debug
--and tn.lineage like 'Unassigned;Hepadnaviridae;Orthohepadnavirus%'
--and tn.lineage like 'Bunyavirales;Feraviridae;unassigned%'
-- and tn.name like 'zika virus'
order by tn.left_idx

