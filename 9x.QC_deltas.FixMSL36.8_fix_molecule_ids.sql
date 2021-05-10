begin transaction 

-- select abbrev, id from taxonomy_molecule


-- 
-- QC: family Polyomaviridae
--    family: ssDNA
--    new species: dsDNA
--    Elliot: would family should be dsDNA
-- 
select report='report on molecule', n.taxnode_id, n.[rank], n.molecule, n.inher_molecule, n.lineage
from taxonomy_node_names n 
join taxonomy_node t on n.left_idx between t.left_idx and t.right_idx and n.tree_id = t.tree_id
where t.msl_release_num=36
and t.name ='Polyomaviridae' 
order by n.left_idx
--
-- FIX: family Polyomaviridae: correct molecule MSL35:ssDNA -> MSL36:dsDNA
--
update taxonomy_node set 
	-- SELECT molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='dsDNA')
from taxonomy_node  
where msl_release_num=36
and name ='Polyomaviridae' 
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='dsDNA') or molecule_id is null)

-- cleanup 
exec sp_simplify_molecule_id_settings

-- 
-- QC: family Pleolipoviridae
--    family: NULL (already NULL, inherits from Monodnaviria)
--	  species: Alphapleolipovirus/* are mixed: All ssDNA except HHPV-* is dsDNA
--    Species: Betapleolipovirus/* are dsDNA except HRPV-* and HGPV-* are 'dsDNA; ssDNA'
--	  Genus: Gammapleolipovirus is dsDNA (already ok)
-- 
select report='report on molecule', n.taxnode_id, n.[rank], n.molecule, n.inher_molecule, n.name, n.lineage
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
where t.msl_release_num=36
and t.name ='Pleolipoviridae' 
order by n.left_idx

--
-- FIX: species Pleolipoviridae/Alphapleolipovirus/HHPV-1: correct molecule dsDNA
--
update taxonomy_node set 
	-- SELECT lineage, molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='dsDNA')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Alphapleolipovirus;Alphapleolipovirus HHPV1'
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='dsDNA') or molecule_id is null)

--
-- FIX: species Pleolipoviridae/Alphapleolipovirus/ & NOT HHPV%: correct molecule ssDNA
--
update taxonomy_node set 
	-- SELECT lineage, molecule_id, inher_molecule_id, name, 
	molecule_id = (select id from taxonomy_molecule where abbrev='ssDNA')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Alphapleolipovirus;%'
and lineage NOT like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Alphapleolipovirus;Alphapleolipovirus HHPV1'
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='ssDNA') or molecule_id is null)

--
-- FIX: species Pleolipoviridae/Betapleolipovirus/ & HGPV1 or HRPV3: correct molecule 'dsDNA; ssDNA'
--
update taxonomy_node set 
	-- SELECT lineage, molecule_id, inher_molecule_id, name,
	molecule_id = (select id from taxonomy_molecule where abbrev='dsDNA; ssDNA')
from taxonomy_node  
where msl_release_num=36
and (
	lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Betapleolipovirus'
	or 
	lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Betapleolipovirus;Betapleolipovirus HGPV1'
	or 
	lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Betapleolipovirus;Betapleolipovirus HRPV3'
)
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='dsDNA; ssDNA') or molecule_id is null)

--
-- FIX: species Pleolipoviridae/Betapleolipovirus/ & NOT (HGPV% or HRPV%): correct molecule dsDNA
--
update taxonomy_node set 
	-- SELECT lineage, molecule_id, inher_molecule_id, name,
	molecule_id = (select id from taxonomy_molecule where abbrev='dsDNA')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Betapleolipovirus;%'
and NOT (
	lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Betapleolipovirus;Betapleolipovirus HGPV1'
	or 
	lineage like 'Monodnaviria;Trapavirae;Saleviricota;Huolimaviricetes;Haloruvirales;Pleolipoviridae;Betapleolipovirus;Betapleolipovirus HRPV3'
)
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='dsDNA') or molecule_id is null)

-- 
-- QC: genus Riboviria;Orthornavirae;Negarnaviricota;Haploviricotina;Monjiviricetes;Jingchuvirales;Chuviridae;Culicidavirus
--	  Genus: Culicidavirus is ssRNA(-) 
-- 
select report='report on molecule', n.taxnode_id, n.[rank], n.molecule, n.inher_molecule, n.lineage
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
where t.msl_release_num=36
and t.name ='Culicidavirus' 
order by n.left_idx

-- FIX
update taxonomy_node set 
	-- SELECT molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Riboviria;Orthornavirae;Negarnaviricota;Haploviricotina;Monjiviricetes;Jingchuvirales;Chuviridae;Culicidavirus'
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='ssRNA(-)') or molecule_id is null)

-- cleanup 
exec sp_simplify_molecule_id_settings

-- 
-- QC: genus Riboviria;Orthornavirae;Negarnaviricota;Haploviricotina;Monjiviricetes;Mononegavirales;Mymonaviridae;Auricularimonavirus
--	  Genus: Culicidavirus is ssRNA(-) 
-- 
select report='report on molecule', n.taxnode_id, n.[rank], n.molecule, n.inher_molecule, n.lineage
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
where t.msl_release_num=36
and t.name ='Auricularimonavirus' 
order by n.left_idx

-- FIX
update taxonomy_node set 
	-- SELECT molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Riboviria;Orthornavirae;Negarnaviricota;Haploviricotina;Monjiviricetes;Mononegavirales;Mymonaviridae;Auricularimonavirus'
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='ssRNA(-)') or molecule_id is null)

-- cleanup 
exec sp_simplify_molecule_id_settings

-- 
-- QC: genus Riboviria;Orthornavirae;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae
--	  Genus: Culicidavirus is ssRNA(-) 
-- 
select report='report on molecule', n.taxnode_id, n.lineage, n.[rank], n.molecule, n.inher_molecule
	, status = (case when  n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then 'dup' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id and m.left_idx between mip.left_idx and mip.right_idx then 'narrows' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'OVERRIDES' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
		end)
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
left outer join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mip on mip.id = p.inher_molecule_id
where t.msl_release_num=36
and t.name ='Phenuiviridae' 
order by n.left_idx

-- FIX
update taxonomy_node set 
	-- SELECT molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)')
from taxonomy_node  
where msl_release_num=36
and lineage in ( 
	'Riboviria;Orthornavirae;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae;Phasivirus;Dipteran phasivirus'
	,'Riboviria;Orthornavirae;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae;Phasivirus;Fly phasivirus' 
)
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='ssRNA(-)') or molecule_id is null)

-- cleanup 
exec sp_simplify_molecule_id_settings


-- 
-- QC: genus Riboviria;Orthornavirae;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae
--	  Genus: Culicidavirus is ssRNA(-) 
-- 
select report='report on molecule', n.taxnode_id, n.lineage, n.[rank], n.molecule, n.inher_molecule
	, status = (case when  n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then 'dup' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id and m.left_idx between mip.left_idx and mip.right_idx then 'narrows' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'OVERRIDES' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
		end)
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
left outer join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mip on mip.id = p.inher_molecule_id
where t.msl_release_num=36
and t.name ='Alphabaculovirus' 
order by n.left_idx


-- FIX
update taxonomy_node set 
	-- SELECT molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='dsDNA')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Naldaviricetes;Lefavirales;Baculoviridae;Alphabaculovirus;%'
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='dsDNA') )

-- cleanup 
exec sp_simplify_molecule_id_settings

-- 
-- QC: genus Riboviria;Orthornavirae;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;...;Coguviris
--	  Genus: Coguviris is ssRNA(+/-) 
-- 
select report='QC report on molecule', n.taxnode_id, n.lineage, n.[rank], n.molecule, n.inher_molecule
	, status = (case when  n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then 'dup' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id and m.left_idx between mip.left_idx and mip.right_idx then 'narrows' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'OVERRIDES' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
		end)
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
left outer join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mip on mip.id = p.inher_molecule_id
where t.msl_release_num=36
and t.name ='Coguvirus'
order by n.left_idx

-- FIX
update taxonomy_node set 
	-- SELECT lineage, molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(+/-)')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Riboviria;Orthornavirae;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae;Coguvirus%'
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='ssRNA(+/-)') or molecule_id is null)

-- cleanup 
exec sp_simplify_molecule_id_settings

-- 
-- QC: genus Riboviria;Orthornavirae;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae
--	  Genus: Culicidavirus is ssRNA(-) 
-- 
select report='QC report on molecule', n.taxnode_id, N.name, n.[rank], n.molecule, n.inher_molecule, n.lineage
	, status = (case when  n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then 'dup' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id and m.left_idx between mip.left_idx and mip.right_idx then 'narrows' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'OVERRIDES' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
		end)
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
left outer join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mip on mip.id = p.inher_molecule_id
where t.msl_release_num=36
and t.name ='Culicidavirus' 
order by n.left_idx


--
-- QC: Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Caudovirales;Podoviridae;Firingavirus;Ralstonia virus RSK1: dsRNA => dsDNA
--
select report='QC report on molecule', n.taxnode_id ,n.name, n.[rank], n.molecule, n.inher_molecule, n.lineage
	, status = (case when  n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then 'dup' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id and m.left_idx between mip.left_idx and mip.right_idx then 'narrows' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'OVERRIDES' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
		end)
from taxonomy_node_names n 
join taxonomy_node t on n.tree_id = t.tree_id
and (n.left_idx between t.left_idx and t.right_idx or t.left_idx between n.left_idx and n.right_idx)
left outer join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mip on mip.id = p.inher_molecule_id
where t.msl_release_num=36
and t.name ='Firingavirus' 
order by n.left_idx

-- FIX
update taxonomy_node set 
	-- SELECT lineage, molecule_id, inher_molecule_id, 
	molecule_id = (select id from taxonomy_molecule where abbrev='dsDNA')
from taxonomy_node  
where msl_release_num=36
and lineage like 'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Caudovirales;Podoviridae;Firingavirus;Ralstonia virus RSK1'
and ( molecule_id <> (select id from taxonomy_molecule where abbrev='dsDNA') or molecule_id is null)

-- cleanup 
exec sp_simplify_molecule_id_settings

--rollback transaction 
-- commit transaction
