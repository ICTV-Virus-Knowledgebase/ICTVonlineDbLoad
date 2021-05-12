--
-- remove NBSP from 2 taxa, historically (MSL36 and before)
--
-- 'Serra do Navio mammarenavirus'+char(160)
-- 'Shigella'+char(160)+'virus'+char(160)+'ISF002'

--
-- QC
--
select report='pre-fix: scan for NBSP=char(160)', *-- taxnode_id, ictv_id, level_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target, name
from taxonomy_node_dx 
where name like '%'+char(160)+'%' or out_target like '%'+char(160)+'%'
order by msl_release_num, left_idx

--
-- remove trailling NBSP
--

-- from name
update taxonomy_node set
 	--select taxnode_id, ictv_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target,
	name=replace(name,char(160),'')
	, notes=isnull(notes+';','')+'20210511 ElloitL: remove trailing no break line space from name'
from taxonomy_node where 
	name like 'Serra do Navio mammarenavirus'+char(160)


-- from out_target
update taxonomy_node set
 	--select taxnode_id, ictv_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target,
	out_target=replace(out_target,char(160),'')
	, notes=isnull(notes+';','')+'20210511 ElloitL: remove trailing no break line space from name'
from taxonomy_node where 
	out_target like '%Serra do Navio mammarenavirus'+char(160)
	

update taxonomy_node set
    -- select taxnode_id, name, notes, in_change, in_filename, in_notes, in_target,
	name=replace(name,char(160),' ')
	, notes=isnull(notes+';','')+'20210511 ElloitL: remove no break line space from name'
from taxonomy_node where 
	name like 'Shigella'+char(160)+'virus'+char(160)+'ISF002'


exec rebuild_delta_nodes

-- 
-- QC - post-fix
-- check that the rename in MSL32 didn't get broken
--
select [post-fix: scan for NBSP=char(160)]='ERROR: NBSP!', *-- taxnode_id, ictv_id, level_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target, name
from taxonomy_node_dx 
where name like '%'+char(160)+'%' or out_target like '%'+char(160)+'%'
order by msl_release_num, left_idx

select [pre-fix: scan for itcv_ids]='19710127, 201857089', *-- taxnode_id, ictv_id, level_id, name, notes, in_change, in_filename, in_notes, in_target, out_change, out_filename, out_target, name
from taxonomy_node_dx 
where ictv_id in (19710127, 201857089)
order by msl_release_num, left_idx


-- 
-- MSL export
--
exec MSL_export_official