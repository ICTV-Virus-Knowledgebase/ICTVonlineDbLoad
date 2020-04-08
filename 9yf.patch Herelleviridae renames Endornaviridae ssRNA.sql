
--
-- initial investigation
--

select msg='before: new parents', msl_release_num, taxnode_id, lineage, in_change, in_filename, * from taxonomy_node where msl_release_num=34 and name in ('Bastillevirinae','Twortvirinae','Spounavirinae') 
select msg='before: taxa to move', msl_release_num, ictv_id, lineage, in_change, in_filename, * from taxonomy_node where name in ('Bequatrovirus','Sepunavirus')

BEGIN TRANSACTION

-- ====================================================
-- move genera: Bequatrovirus, Nitunavirus 
-- ====================================================

--
-- update OUT_CHANGE for previous MSL=33
-- 

update taxonomy_node set 
--select msl_release_num, taxnode_id, parent_id, lineage, out_change, out_filename, out_target,out_notes,
		out_change='move', out_filename='2018.118B.A.v4.Herelleviridae.zip', out_target='Caudovirales;Herelleviridae;Bastillevirinae;'+'Nitunavirus', out_notes='renamed'
from taxonomy_node
where msl_release_num=33
and ictv_id = (select ictv_id from taxonomy_node where msl_release_num=34 and name ='Nitunavirus')

update taxonomy_node set 
--select msl_release_num, taxnode_id, parent_id, lineage, out_change, out_filename, out_target, out_notes,
		out_change='move', out_filename='2018.118B.A.v4.Herelleviridae.zip', out_target='Caudovirales;Herelleviridae;Bastillevirinae;'+'Bequatrovirus', out_notes='renamed'
from taxonomy_node
where msl_release_num=33
and ictv_id = (select ictv_id from taxonomy_node where msl_release_num=34 and name ='Bequatrovirus')
	
--
-- update PARENT_ID for current MSL=34
--

update taxonomy_node set 
--select msl_release_num, taxnode_id, parent_id, lineage, out_change, out_filename, out_target,
			parent_id = (select taxnode_id from taxonomy_node where msl_release_num=34 and name='Bastillevirinae')
from taxonomy_node
where msl_release_num=34
and name in ('Nitunavirus','Bequatrovirus')
	
--
-- QC
-- 
select msg='QC FIXED Nitunavirus,Bequatrovirus', msl=msl_release_num, lineage, in_change, in_filename, in_target, out_change, out_filename, out_target, * 
from taxonomy_node 
where ictv_id in (20150186, 20150202 ) -- name in  ('Nitunavirus','Bequatrovirus')
order by ictv_id, msl  

-- ====================================================
-- move genus: Sepunavirus (Herelleviridae:Twortvirinae), Siminovitchvirus (Herelleviridae:Spounavirinae)
-- ====================================================

select msg='before Sepunavirus,Siminovitchvirus',  msl=msl_release_num, lineage, in_change, in_filename, in_target, out_change, out_filename, out_target, * 
from taxonomy_node 
where ictv_id in (select ictv_id from taxonomy_node where msl_release_num=34 and name in ('Sepunavirus','Siminovitchvirus'))
order by ictv_id, msl  

--
-- update OUT_CHANGE for previous MSL=33
-- 

update taxonomy_node set 
--select msl_release_num, taxnode_id, parent_id, lineage, out_change, out_filename, out_target,out_notes,
		out_change='move', out_filename='2018.118B.A.v4.Herelleviridae.zip', out_target='Caudovirales;Herelleviridae;'+'Twortvirinae'+';'+'Sepunavirus', out_notes='renamed'
from taxonomy_node
where msl_release_num=33
and ictv_id = (select ictv_id from taxonomy_node where msl_release_num=34 and name ='Sepunavirus')

--
-- update OUT_CHANGE for previous MSL=33
-- 

update taxonomy_node set 
--select msl_release_num, taxnode_id, parent_id, lineage, out_change, out_filename, out_target,out_notes,
		out_change='move', out_filename='2018.118B.A.v4.Herelleviridae.zip', out_target='Caudovirales;Herelleviridae;'+'Spounavirinae'+';'+'Siminovitchvirus', out_notes='renamed'
from taxonomy_node
where msl_release_num=33
and ictv_id = (select ictv_id from taxonomy_node where msl_release_num=34 and name ='Siminovitchvirus')

--
-- update PARENT_ID for current MSL=34
--

update taxonomy_node set 
--select msl_release_num, taxnode_id, parent_id, lineage, out_change, out_filename, out_target,
			parent_id = (select taxnode_id from taxonomy_node where msl_release_num=34 and name='Twortvirinae')
from taxonomy_node
where msl_release_num=34
and name in ('Sepunavirus')

--
-- update PARENT_ID for current MSL=34
--

update taxonomy_node set 
--select msl_release_num, taxnode_id, parent_id, lineage, out_change, out_filename, out_target,
			parent_id = (select taxnode_id from taxonomy_node where msl_release_num=34 and name='Spounavirinae')
from taxonomy_node
where msl_release_num=34
and name in ('Siminovitchvirus')

select msg='QC FIXED Sepunavirus,Siminovitchvirus', msl=msl_release_num, lineage, in_change, in_filename, in_target, out_change, out_filename, out_target, * 
from taxonomy_node 
where ictv_id in (select ictv_id from taxonomy_node where msl_release_num=34 and name in ('Sepunavirus','Siminovitchvirus'))
order by ictv_id, msl  


-- ====================================================
-- update delta nodes - 1:46 min
-- ====================================================

exec [rebuild_delta_nodes]

--
-- QC - parent updates and delta rebuild
--
select 'QC FIXED (after delta rebuild) 4 genera', *
from taxonomy_node_dx
where ictv_id in (select ictv_id from taxonomy_node where msl_release_num=34 and name in ('Sepunavirus','Siminovitchvirus','Nitunavirus','Bequatrovirus'))
order by ictv_id, msl_release_num  

-- ====================================================
-- update Endornaviridae to ssRNA(+)
-- ====================================================

-- 
-- QC - check for molecule_id on ancestors and descendants
--
select msg='QC before Endornaviridae dsRNA->ssRNA+: check ancestors/descendants', d.ictv_id, d.lineage,m.abbrev, d.molecule_id, d.inher_molecule_id, d.in_change, d.out_change
from taxonomy_node tn
join taxonomy_node d  on d.tree_id = tn.tree_id and (d.left_idx between tn.left_idx and tn.right_idx or tn.left_idx between d.left_idx and d.right_idx)
left outer join taxonomy_molecule m on m.id= d.molecule_id
where tn.name = 'Endornaviridae' and tn.msl_release_num=34
order by tn.left_idx, d.left_idx

--
-- QC - check molecule_id across MSLs
--
select msg='QC before Endornaviridae dsRNA->ssRNA+: check across time', msl_release_num, ictv_id, lineage, molecule_id, in_change, out_change 
from taxonomy_node 
where ictv_id =20080339 
order by msl_release_num

-- 
-- UPDATE molecule_id: dsRNA->ssRNA(+)
--
update taxonomy_node set 
	-- select	msl_release_num, ictv_id, lineage, molecule_id, in_change, out_change,
	molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(+)')
from taxonomy_node
where ictv_id = (select ictv_id from taxonomy_node where msl_release_num=34 and name='Endornaviridae')
--and msl_release_num = 34 -- fix across all time: MSL24-34

-- 
-- QC - check for molecule_id on ancestors and descendants
--
select msg='QC FIXED Endornaviridae dsRNA->ssRNA+: check ancestors/descendants', d.ictv_id, d.lineage,m.abbrev, d.molecule_id, d.inher_molecule_id, d.in_change, d.out_change
from taxonomy_node tn
join taxonomy_node d  on d.tree_id = tn.tree_id and (d.left_idx between tn.left_idx and tn.right_idx or tn.left_idx between d.left_idx and d.right_idx)
left outer join taxonomy_molecule m on m.id= d.molecule_id
where tn.name = 'Endornaviridae' and tn.msl_release_num=34
order by tn.left_idx, d.left_idx

--
-- QC - check molecule_id across MSLs
--
select msg='QC FIXED Endornaviridae dsRNA->ssRNA+: check across time', msl_release_num, ictv_id, lineage, molecule_id, in_change, out_change 
from taxonomy_node 
where ictv_id =20080339 
order by msl_release_num

--rollback transaction
commit transaction 
