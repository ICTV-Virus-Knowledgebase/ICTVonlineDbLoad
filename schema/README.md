# ICTVonline SCHEMA

Tables form several major groups:

## Primary Data & supporting controlled vocabularies

 1. [taxonomy_node](dbo.taxonomy_node.Table.sql) 
  * This table contains all the taxonomy hierarchies for all the years, and the information needed to link between years. 


 1. Supporting TABLES that define years and controled vocabularies:
  * [taxonomy_toc](dbo.taxonomy_toc.Table.sql) - Table of Contents - defines MSL release numbers and tree IDs. Must have a row for each taxonomy stored in ```taxonomy_node```
  * [taxonomy_change_in](dbo.taxonomy_change_in.Table.sql) - defines values for ```taxonomy_node.in_change```
  * [taxonomy_change_out](dbo.taxonomy_change_out.Table.sql) - defines values for ```taxonomy_node.out_change```
  * [taxonomy_level](dbo.taxonomy_level.Table.sql) - defines values for ```taxonomy_node.level_id```, maps level_id to rank name. 
  * [taxonomy_molecule](dbo.taxonomy_molecule.Table.sql) - defines values for ```taxonomy_node.molecule_id```. Also defines a hierarchy for molecule types, see [taxonomy_molecule.design_nested_sets.png](taxonomy_molecule.design_nested_sets.png)

## Supporting VIEWS that simplify access

  * [MSL_export_fast](dbo.MSL_export_fast.View.sql)
  * [taxonomy_node_dx](dbo.taxonomy_node_dx.View.sql) - join of taxonomy_node through taxonomy_node_delta (twice) with previous and next year's taxonomies.
  * [taxonomy_node_names](dbo.taxonomy_node_names.View.sql) - join of taxonomy_node with controlled vocabulary tables, so in addition to "genus_id" actually has "genus" with the actual name of the genus.
  * [taxonomy_node_x](dbo.taxonomy_node_x.View.sql) - join of taxonom_node thorugh ```taxonomy_node_merge_split```, to list all previous and future versions of this taxon
  * [taxonomy_toc_dx](dbo.taxonomy_toc_dx.View.sql) - join of taxonomy_toc with itself to link current year to previous year, used for lookup of previous year's tree_id
  * [view_taxa_level_counts_by_release](dbo.view_taxa_level_counts_by_release.View.sql)
  * [view_taxonomy_stats](dbo.view_taxonomy_stats.View.sql)

##  Cache Tables

these store data pre-computed from taxonomy_node, which makes the queries that serve the website possible in real time. 
  * [taxonomy_node_delta](dbo.taxonomy_node_delta.Table.sql) - link the taxa of one year in ```taxonomy_node```, to the taxa of the next year, annotate what changed and why
  * [taxonomy_node_merge_split](dbo.taxonomy_node_merge_split.Table.sql) - link each taxa in ```taxonomy_node``` to all previous and future versions of that taxon. This is essentially a transitive closure of the ```taxonomy_node_delta```.

##  Virus isolate tables - these are additional data linked to the species described in taxonomy_node, but not linked to the specific year. 

  * [virus_isolates](dbo.virus_isolates.Table.sql)
  * [virus_prop](dbo.virus_prop.Table.sql)
  * [vmr_load](dbo.vmr_load.Table.sql)
  * [VMR-new](dbo.VMR-new.Table.sql)
  * [virus_isolates_051420](dbo.virus_isolates_051420.Table.sql)
  * [virus_isolates_051821](dbo.virus_isolates_051821.Table.sql)
  * [virus_isolates_072021](dbo.virus_isolates_072021.Table.sql)
  * [virus_isolates_080120](dbo.virus_isolates_080120.Table.sql)
  * [virus_isolates_093019](dbo.virus_isolates_093019.Table.sql)
  * [virus_isolates_112321](dbo.virus_isolates_112321.Table.sql)
  * [virus_isolates_120219](dbo.virus_isolates_120219.Table.sql)
  * [virus_isolates_220319](dbo.virus_isolates_220319.Table.sql)
  * [virus_isolates_load](dbo.virus_isolates_load.Table.sql)

## ETL/Load tables & Views

  * [load_next_msl](dbo.load_next_msl.Table.sql)
  * [load_next_msl_isOk](dbo.load_next_msl_isOk.View.sql)
  * [load_next_msl_28](dbo.load_next_msl_28.Table.sql)
  * [load_next_msl_29](dbo.load_next_msl_29.Table.sql)
  * [load_next_msl_30](dbo.load_next_msl_30.Table.sql)
  * [load_next_msl_31](dbo.load_next_msl_31.Table.sql)
  * [load_next_msl_32](dbo.load_next_msl_32.Table.sql)
  * [load_next_msl_33](dbo.load_next_msl_33.Table.sql)
  * [load_next_msl_34a](dbo.load_next_msl_34a.Table.sql)
  * [load_next_msl_34b](dbo.load_next_msl_34b.Table.sql)
  * [load_next_msl_35](dbo.load_next_msl_35.Table.sql)
  * [load_next_msl_36](dbo.load_next_msl_36.Table.sql)
  * [load_next_msl_scList](dbo.load_next_msl_scList.Table.sql)
  * [load_next_msl_taxonomy_31](dbo.load_next_msl_taxonomy_31.Table.sql)
  * [load_next_msl_tpList](dbo.load_next_msl_tpList.Table.sql)
  * [load_next_msl_unicode](dbo.load_next_msl_unicode.Table.sql)

## Membership
### Tables
  * [committee](dbo.committee.Table.sql)
  * [committee_type_cv](dbo.committee_type_cv.Table.sql)
  * [membership](dbo.membership.Table.sql)
  * [member](dbo.member.Table.sql)
  * [position](dbo.position.Table.sql)
### Views
  * [view_membership_committee_with_subchairs](dbo.view_membership_committee_with_subchairs.View.sql)
  * [view_membership_committee_with_submembers](dbo.view_membership_committee_with_submembers.View.sql)
  * [view_membership_x](dbo.view_membership_x.View.sql)

## Obsolete
  * [queue_delta](dbo.queue_delta.Table.sql)
  * [queue_patch](dbo.queue_patch.Table.sql)
  * [log_change](dbo.log_change.Table.sql)


## ICTVdb
### Tables
  * [ictvdb_index](dbo.ictvdb_index.Table.sql)
  * [ictvdb_sun_ah](dbo.ictvdb_sun_ah.Table.sql)
### Views
  * [ictvdb_family](dbo.ictvdb_family.View.sql)
  * [ictvdb_genus](dbo.ictvdb_genus.View.sql)
  * [ictvdb_order](dbo.ictvdb_order.View.sql)
  * [ictvdb_species](dbo.ictvdb_species.View.sql)
  * [ictvdb_subfamily](dbo.ictvdb_subfamily.View.sql)


