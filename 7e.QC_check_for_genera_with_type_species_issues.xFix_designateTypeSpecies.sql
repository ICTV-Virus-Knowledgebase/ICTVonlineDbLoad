
-- -----------------------------------------------------------------------------
--
-- FIX make a single, designated species the type for a genus, and make all the other NOT
--
-- given a list of correct TYPE_SPECIES
-- look up each species' genus
-- then set isType=0 for all other species in that genus
-- and set isType=1 for the specified type species. 
--
-- -----------------------------------------------------------------------------


--
-- UPDATE - make listed species the one-and-only type species in it's genus
--
--
select genus=genus.name, genus_sub_taxa=genus._numKids, typeSpecies=typeSpecies.name, dx.prev_proposal, dx.prev_tags,  d.new_taxid, d.prev_taxid, d.tag_csv, d.proposal, sep='||', species.taxnode_id, species.lineage, species.is_ref, updates='>>>',
--
-- UPDATE species SET 
	is_ref=(case when species.name = typeSpecies.name then 1 else 0 end)
from taxonomy_node species
join taxonomy_node_names genus on genus.rank='genus' and genus.tree_id = species.tree_id and species.left_idx between genus.left_idx and genus.right_idx
join taxonomy_node_names typeSpecies on typeSpecies.rank='species' and typeSpecies.tree_id=genus.tree_id and typeSpecies.left_idx between genus.left_idx and genus.right_idx
left outer join taxonomy_node_dx dx on dx.next_id = species.taxnode_id
left outer join taxonomy_node_delta d on d.new_taxid=species.taxnode_id
where species.level_id=(select id from taxonomy_level where name='species')
and typeSpecies.msl_release_num=dbo.udf_getMSL(NULL)
and typeSpecies.name in (
	'Satsuma dwarf virus', -- Sadwavirus
	'Ball python nidovirus 1', -- Pregotovirus: 
	'Proteus virus PM135' -- Novosibvirus
)
--END_RUN-- UPDATE can't have ORDER BY
order by species.left_idx

--
-- rebuild delta nodes so is_type flag gets set correctly on delta nodes. 
-- 

exec rebuild_delta_nodes