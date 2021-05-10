--
-- QC
--
-- MSL36 - many species have no inherited molecule ID, but had one in previous MSLs
--
select taxonomy_node.taxnode_id, taxonomy_node.ictv_id, taxonomy_node.lineage, mol_id=taxonomy_node.molecule_id, inher_id=taxonomy_node.inher_molecule_id
from taxonomy_node 
where taxonomy_node.msl_release_num =36
and taxonomy_node.inher_molecule_id is null and taxonomy_node.level_id=(select id from taxonomy_level where name='species') 

--
-- QC - 'Antheraea eucalypti virus'
--
-- MSL34 - molecule annotated on Familiy: Alphatetraviridae
-- MSL35 - just inherited, no actual IDs in high ranks! (inconceivable) 
-- MSL36 - no molecules

-- MSL 34
select MSL=n.msl_release_num, n.ictv_id,n.rank, n.name, flag=(case when n.name='Alphatetraviridae' then '*' end), n.molecule_id, n.molecule, n.inher_molecule_id, n.inher_molecule
from taxonomy_node_names n
join taxonomy_node_names t on t.tree_id=n.tree_id and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
where n.msl_release_num = 34
and t.name ='Antheraea eucalypti virus'
order by n.left_idx

-- MSL 35
select MSL=n.msl_release_num, n.ictv_id,n.rank, n.name,flag=(case when n.name='Alphatetraviridae' then '*' end),  n.molecule_id, n.molecule, n.inher_molecule_id, n.inher_molecule
from taxonomy_node_names n
join taxonomy_node_names t on t.tree_id=n.tree_id and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
where n.msl_release_num = 35
and t.name ='Antheraea eucalypti virus'
order by n.left_idx

-- MSL 36
select MSL=n.msl_release_num, n.ictv_id, n.rank, n.name, flag=(case when n.name='Alphatetraviridae' then '*' end), n.molecule_id, n.molecule, n.inher_molecule_id, n.inher_molecule
from taxonomy_node_names n
join taxonomy_node_names t on t.tree_id=n.tree_id and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
where n.msl_release_num = 36
and t.name ='Antheraea eucalypti virus'
order by n.left_idx

--
-- MSL *: Riboviria;Orthornavirae;Kitrinoviricota;Alsuviricetes;Martellivirales;Endornaviridae;Alphaendornavirus;Bell pepper alphaendornavirus
--
select MSL=n.msl_release_num, n.ictv_id, n.rank, n.name, flag=(case when n.name='Endornaviridae' then '*' end), n.molecule_id, n.molecule, n.inher_molecule_id, n.inher_molecule
from taxonomy_node_names n
join taxonomy_node_names t on t.tree_id=n.tree_id and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
where 
--n.msl_release_num = 36 and 
t.name ='Bell pepper alphaendornavirus'
order by n.msl_release_num desc, n.left_idx

select msl_release_num, rank, count(*)
from taxonomy_node_names
where 
--level_id=(select id from taxonomy_level where name='species') and 
inher_molecule_id is null 
and msl_release_num >= 20
group by msl_release_num, level_id, rank
order by msl_release_num, level_id
-- ===================================================================================================================================================
--
-- FIX
--
-- pull species in from previous years
-- then use sp_simplify_molecule_id_settings to push up the hierarchy from there. 
-- 
-- ===================================================================================================================================================
update taxonomy_node set 
--select taxonomy_node.taxnode_id, taxonomy_node.ictv_id, taxonomy_node.lineage, mol_id=taxonomy_node.molecule_id, inher_id=taxonomy_node.inher_molecule_id,
	molecule_id=(
		select top 1 src.inher_molecule_id
		from taxonomy_node src
		where src.ictv_id = taxonomy_node.ictv_id
		and src.inher_molecule_id is not null
		order by msl_release_num desc
		)
from taxonomy_node 
where taxonomy_node.msl_release_num =36
and taxonomy_node.inher_molecule_id is null and taxonomy_node.level_id=(select id from taxonomy_level where name='species') 

-- merge molecule_ids up to the highest rank they are consistent. 
exec sp_simplify_molecule_id_settings


