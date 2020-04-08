select '|'+_dest_taxon_name+'|', * from load_next_msl_33 where _dest_taxon_name in ('Mononegavirales','Negarnaviricota','Haploviricotina','Monjiviricetes',
																			'Bunyavirales', 'Negarnaviricota','Polyploviricotina','Ellioviricetes'
																			, 'Monjiviricetes ')

select lineage, * from taxonomy_node where msl_release_num = 33 and name in ('Mononegavirales','Negarnaviricota','Haploviricotina','Monjiviricetes',
																			'Bunyavirales', 'Negarnaviricota','Polyploviricotina','Ellioviricetes')
order by left_idx


-- Bunyavirales make the change
update taxonomy_node set
	parent_id = 20186018, notes = 'assign order to class'
where taxnode_id = 20180001 and parent_id <> 20186018

Negarnaviricota;Haploviricotina;Monjiviricetes ;Mononegavirales

-- Mononegavirales make the change
update taxonomy_node set
	parent_id = 20186020, notes = 'assign order to class'
where taxnode_id = 20181548 and parent_id <> 20186018

select lineage, * from taxonomy_node where msl_release_num = 33 and name in ('Mononegavirales','Negarnaviricota','Haploviricotina','Monjiviricetes',
																			'Bunyavirales', 'Negarnaviricota','Polyploviricotina','Ellioviricetes')
order by left_idx


--
-- make both changes
--

update taxonomy_node set
	parent_id = (case 
				when taxnode_id =20180001 -- Bunyavirales
				then  20186018
				when  taxnode_id =20181548-- Mononegavirales
				then  20186020
				end)
				, notes = 'assign order to class'
where taxnode_id in (
	20180001 -- Bunyavirales
	,
	20181548-- Mononegavirales
	) 
and parent_id = 20180000


select lineage, * from taxonomy_node where msl_release_num = 33 and name in ('Mononegavirales','Negarnaviricota','Haploviricotina','Monjiviricetes',
																			'Bunyavirales', 'Negarnaviricota','Polyploviricotina','Ellioviricetes')
order by left_idx



-- Bunyavirales undo the change
update taxonomy_node set
	parent_id = 20180000, notes = NULL
where taxnode_id = 20180001 and parent_id <> 20180000

-- Mononegavirales undo the change
update taxonomy_node set
	parent_id = 20180000, notes = NULL
where taxnode_id = 20181548 and parent_id <> 20180000


select lineage, * from taxonomy_node where msl_release_num = 33 and name in ('Mononegavirales','Negarnaviricota','Haploviricotina','Monjiviricetes',
																			'Bunyavirales', 'Negarnaviricota','Polyploviricotina','Ellioviricetes')
order by left_idx
