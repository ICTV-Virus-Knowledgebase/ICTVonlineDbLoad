--
-- remove NBSP from 2 taxa, historically (MSL36 and before)
--
-- Sitke waterborne virus => Sikte waterborne virus
--   ^^                        ^^
-- 
BEGIN TRANSACTION

--
-- QC
--
select report='pre-fix: scan for NBSP=char(160)', msl_release_num, name, *-- taxnode_id, ictv_id, level_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target, name
from taxonomy_node_dx  dx
where name like 'Sitke waterborne virus' or out_target like '%Sitke waterborne virus%' or ictv_id in (19952286)
order by dx.msl_release_num, left_idx

--
-- Change MSL36 name
--

update taxonomy_node set
 	--select taxnode_id, ictv_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target,
	name='Sikte waterborne virus'
	, notes=isnull(notes+';','')+'20210511 ElloitL: MSL36 addendum name change'

from taxonomy_node where 
	name like 'Sitke waterborne virus'
	and msl_release_num = 36

--
-- change MSL35 out_* linkage for the rename


-- from out_target
update taxonomy_node set
 	--select taxnode_id, ictv_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target,
	out_target='Riboviria;Orthornavirae;Kitrinoviricota;Tolucaviricetes;Tolivirales;Tombusviridae;Procedovirinae;Tombusvirus;Sikte waterborne virus'
	, out_change='rename'
	, out_filename='XXXX.pdf'
	, out_notes=isnull(in_notes+';','')+'20210512: The species, "Sitke waterborne virus"  is misspelled and needs to be change to "Sikte waterborne virus", While it has been misspelled since 1995, we will make this change starting in 2020, MSL36'
from taxonomy_node where 
	taxnode_id = 201905264 
	and (out_target not like '%Sikte waterborne virus' or out_target is null)
	and msl_release_num= 35
	

exec rebuild_delta_nodes

-- 
-- QC - post-fix
-- check that the rename MSL35/36 worked for delta rebuilds.
--


select report='pre-fix: scan for NBSP=char(160)', msl_release_num, name, *-- taxnode_id, ictv_id, level_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target, name
from taxonomy_node_dx  dx
where name like 'Sitke waterborne virus' or out_target like '%Sitke waterborne virus%' or ictv_id in (19952286)
order by dx.msl_release_num, left_idx

--
-- finalize - choose one
-- 
/*
ROLLBACK TRANSACTION
COMMIT TRANSACTION
*/

-- 
-- MSL export
--
--exec MSL_export_official