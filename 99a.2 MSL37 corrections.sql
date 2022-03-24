--
-- Apply corrections to issues discovered in MSL37
--
-- "Database corrections 032322.xlsx" from Elliot Lefkowitz
--    None of these need to be documented as changes or updates. 
--    They should all be considered to have been done with the original proposal. 
--     The spreadsheet ‘Database corrections 032322.xlsx’ provides taxon additions/corrections.
--

begin transaction

-- 
-- Genus=Glaucusvirus, proposal=2021.082B.R.Tevens_new_families.zip
--
-- these were marked "isWrong" during original load
-- Un-set "isWrong" then re-run script to push them from load_next_msl to taxonomy_node and build deltas
--
select * from load_next_msl where taxnode_id=202113995 or (genus = 'Glaucusvirus' and proposal like '2021.082B%') -- 1 genus, 1 species
update  load_next_msl set isWrong = NULL from load_next_msl where genus = 'Glaucusvirus' and proposal like '2021.082B%' and isWrong is not null -- 1 genus, 1 species
-- ops, dest_parent_id is wrong for species
update load_next_msl set -- select *,
	dest_parent_id = (select dest_taxnode_id from load_next_msl_isOk where _dest_taxon_name='Glaucusvirus'  and proposal like '2021.082B%')
from load_next_msl 
where _dest_taxon_name= 'Glaucusvirus ssm5' and proposal like '2021.082B%'
-- RUN: 4.a.apply_create_actions_RANK_high_to_low.sql
-- RUN: 8a.rebuild_delta_nodes_and_merge-split_table
-- ops, dest_parent_id is wrong for species
update  taxonomy_node set -- select *,
	parent_id = (select taxnode_id from  taxonomy_node where name='Glaucusvirus'  and in_filename like '2021.082B%')
from taxonomy_node 
where name= 'Glaucusvirus ssm5' and in_filename like '2021.082B%'

select * from taxonomy_node_names where msl_release_num=37 and genus = 'Glaucusvirus'


-- originally named Glaucusvirus, this genus is now to be named Pariacacavirus.
-- update records, remove isWrong, and go insert with normal machinery.
select * from load_next_msl where genus in ('Glaucusvirus', 'Pariacacavirus') and proposal like '2021.076B.%Schitoviridae_%'-- 1 genus, 2 species
update  load_next_msl set  -- select *, 
	isWrong = NULL, genus='Pariacacavirus', species=replace(species, 'Glaucusvirus', 'Pariacacavirus') 
from load_next_msl 
where genus = 'Glaucusvirus' and proposal like '2021.076B%' and isWrong is not null -- 1 genus, 1 species
-- RUN: 4.a.apply_create_actions_RANK_high_to_low.sql
-- RUN: 8a.rebuild_delta_nodes_and_merge-split_table


-- species created in refugevirus genus w/o binomial naming
select * from load_next_msl where genus='refugevirus' and species is not null
update  load_next_msl set  -- select *, 
	species=replace(species, 'Pharaohvirus', 'Refugevirus') 
from load_next_msl  
where genus='Refugevirus' and species not like 'Refugevirus%' 

update taxonomy_node set  -- select *, 
	name=replace(name, 'Pharaohvirus', 'Refugevirus') 
from taxonomy_node
where msl_release_num=37 and lineage like '%Refugevirus%Pharaohvirus%' and level_id=600/*species*/


--commit transaction