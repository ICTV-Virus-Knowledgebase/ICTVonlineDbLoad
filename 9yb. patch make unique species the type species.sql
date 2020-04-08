--
-- patch 33.2: make only species in a genus w/o a type species, the type species. 
--
select report='unique species in genera w/o type species'
	, genus as genus, count(species) as species_count, sum(is_type_species) as tspecies_ct, max(species) as species
from MSL_export_fast where msl_release_num = 33 AND genus <> ''
group by genus
having sum(is_type_species) < 1  and count(species) = 1
order by species_count, genus

select report='candidate type species in msl_33 additions'
	 ,* 
from load_next_msl_33 
where _dest_taxon_name in (
	select max(species) as species--, genus as genus, count(species) as species_count, sum(is_type_species) as tspecies_ct
	from MSL_export_fast where msl_release_num = 33 AND genus <> ''
	group by genus
	having sum(is_type_species) < 1  and count(species) = 1
	--order by species_count, genus
)
update load_next_msl_33 set isType=1
from load_next_msl_33 
where _dest_taxon_name in (
	select max(species) as species--, genus as genus, count(species) as species_count, sum(is_type_species) as tspecies_ct
	from MSL_export_fast where msl_release_num = 33 AND genus <> ''
	group by genus
	having sum(is_type_species) < 1  and count(species) = 1
	--order by species_count, genus
) 

select report='candidate type species in taxonomy_node'
	 , lineage, is_ref
from taxonomy_node 
where name in (
	select max(species) as species--, genus as genus, count(species) as species_count, sum(is_type_species) as tspecies_ct
	from MSL_export_fast where msl_release_num = 33 AND genus <> ''
	group by genus
	having sum(is_type_species) < 1  and count(species) = 1
	--order by species_count, genus
) and tree_id = (select top 1 tree_id from taxonomy_toc order by msl_release_num desc)

update taxonomy_node set 
	is_ref=1
from taxonomy_node 
where name in (
	select max(species) as species--, genus as genus, count(species) as species_count, sum(is_type_species) as tspecies_ct
	from MSL_export_fast where msl_release_num = 33 AND genus <> ''
	group by genus
	having sum(is_type_species) < 1  and count(species) = 1
	--order by species_count, genus
) and tree_id =  (select top 1 tree_id from taxonomy_toc order by msl_release_num desc)


-- rebuild delta nodes to include type change flags. 
declare @tree int; SET @tree= (select top 1 tree_id from taxonomy_toc order by msl_release_num desc)
exec dbo.rebuild_delta_nodes @tree