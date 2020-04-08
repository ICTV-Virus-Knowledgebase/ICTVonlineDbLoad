--
-- QC species with no molecule type, and their ancestors
--

select 
	 [species w/o molecule and their ancestors] = (case when lvl.name='species' then '**' when a.taxnode_id in (201854347, 201854350) then '**DUP**' else '' end)
	 , msl=a.msl_release_num, a.lineage,a.taxnode_id
	 , molShort=m.abbrev
	 , a.molecule_id, a.inher_molecule_id
	 , flag=(case when lvl.name='species' then '**' else ''end)
	 ,rank=lvl.name
	 , a.prev_tags, a.next_tags, a.left_idx
	 -- number of kids with molecule
	 ,kids=count(k.taxnode_id), kidsWMol=count(k.molecule_id)
	 -- name
from taxonomy_node tn
join taxonomy_node_dx a on tn.tree_id = a.tree_id and tn.left_idx between a.left_idx and a.right_idx
left outer join taxonomy_node k on k.parent_id = a.taxnode_id
join taxonomy_level lvl on lvl.id = a.level_id
left outer join taxonomy_molecule m  on m.id = a.molecule_id
where tn.tree_id=(select top 1 tree_id from taxonomy_toc order by msl_release_num desc)
AND (
	-- species missing with no molecule, local or inherited
	(tn.inher_molecule_id is NULL and tn.level_id=600)
	-- all taxa with a locally set molecule - provides context for deciding what rank to assign molecule at
	--or (tn.molecule_id is not null)
)
--tn.taxnode_id=201856595 or tn.parent_id =201850001
group by 
	  a.msl_release_num, a.level_id, lvl.name,a.lineage,a.taxnode_id, a.molecule_id, a.inher_molecule_id, a.prev_tags, a.next_tags, a.left_idx, m.abbrev
order by a.left_idx


/****
 * MSL 34 patches
 ****
begin transaction
-- rollback transaction


update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Leishbuviridae' -- family
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Peribunyaviridae;Pacuvirus' -- genus
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae;Kabutovirus' -- genus
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae;Laulavirus' -- genus
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Phenuiviridae;Wenrivirus' -- genus
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(+/-)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Tospoviridae' -- family
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(-)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Coguvirus' -- genus

update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(+)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Botourmiaviridae' -- family
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='NULL') from taxonomy_node where molecule_id =4/*'ssRNA(+)'*/ AND msl_release_num=34 AND lineage='Riboviria;Botourmiaviridae;Ourmiavirus' -- genus - move annotation to parent family

update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(+)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Kitaviridae' -- family
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='NULL') from taxonomy_node where molecule_id =4/*'ssRNA(+)'*/ AND msl_release_num=34 AND lineage='Riboviria;Kitaviridae;Blunervirus' -- genus - move annotation to parent family
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='NULL') from taxonomy_node where molecule_id =4/*'ssRNA(+)'*/ AND msl_release_num=34 AND lineage='Riboviria;Kitaviridae;Cilevirus' -- genus - move annotation to parent family
update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='NULL') from taxonomy_node where molecule_id =4/*'ssRNA(+)'*/ AND msl_release_num=34 AND lineage='Riboviria;Kitaviridae;Higrevirus' -- genus - move annotation to parent family

update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='ssRNA(+)') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Riboviria;Matonaviridae' -- family

update taxonomy_node set molecule_id = (select id from taxonomy_molecule where abbrev='dsDNA') from taxonomy_node where molecule_id IS NULL AND msl_release_num=34 AND lineage='Ovaliviridae' -- family

--commit transaction
*/
