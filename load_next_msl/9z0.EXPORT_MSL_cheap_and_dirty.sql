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

select name, notes
from taxonomy_node
where level_id=100 and msl_release_num = (select max(msl_release_num) from taxonomy_toc)

select *
from MSL_export_fast
where msl_release_num = (select max(msl_release_num) from taxonomy_node)
--and last_change_proposal <> ''
-- debug
--and tn.lineage like 'Unassigned;Hepadnaviridae;Orthohepadnavirus%'
--and tn.lineage like 'Bunyavirales;Feraviridae;unassigned%'
--and species like 'zika virus'
order by left_idx



