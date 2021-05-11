--
-- 9x.QC_deltas.FixMSL36.B_MSL35_dual_filename_add_file_ext.sql
--
-- https://github.com/rusalkaguy/ICTVonlineDbLoad/issues/8
--

--
-- QC
-- 
select 'PRE-fix', out_change, out_filename, out_notes, in_change, in_filename, in_notes, * from taxonomy_node where taxnode_id in (201900160, 201850160, 201907416    )
select 'PRE-fix (DX)', [>>]='>>', prev_proposal, [<<]='<<', * from taxonomy_node_dx where taxnode_id in (201900160, 201907416    )


--
-- update
--
update taxonomy_node set 
	-- select out_filename, 
	out_filename='2019.022M.zip;2019.026M.zip'
from taxonomy_node 
where taxnode_id = 201850160
and out_filename = '2019.022M;2019.026M.zip'

update taxonomy_node set 
	-- select out_filename, 
	in_filename='2019.014M.zip;2019.025M.zip'
from taxonomy_node 
where taxnode_id = 201907416
and in_filename = '2019.014M;2019.025M.zip'

-- propagate
exec rebuild_delta_nodes 35

--
-- QC (post-fix)
-- 
select 'PRE-fix', out_change, out_filename, out_notes, in_change, in_filename, in_notes, * from taxonomy_node where taxnode_id in (201900160, 201850160, 201907416    )
select 'PRE-fix (DX)', [>>]='>>', prev_proposal, [<<]='<<', * from taxonomy_node_dx where taxnode_id in (201900160, 201907416    )



