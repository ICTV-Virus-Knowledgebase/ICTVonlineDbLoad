# ICTVonline SCHEMA

Tables form several major groups:

1. Primary Data & supporting controlled vocabularies

 1. [taxonomy_node](schema/dbo.taxonomy_node.Table.sql) This table contains all the taxonomy hierarchies for all the years, and the information needed to link between years. 


 1. Supporting TABLES that define years and controled vocabularies:
schema/dbo.taxonomy_toc.Table.sql
schema/dbo.taxonomy_change_in.Table.sql
schema/dbo.taxonomy_change_out.Table.sql
schema/dbo.taxonomy_level.Table.sql
schema/dbo.taxonomy_molecule.Table.sql

 1.Supporting VIEWS that simplify access
## Views 
schema/dbo.load_next_msl_isOk.View.sql
schema/dbo.MSL_export_fast.View.sql
schema/dbo.taxonomy_node_dx.View.sql
schema/dbo.taxonomy_node_names.View.sql
schema/dbo.taxonomy_node_x.View.sql
schema/dbo.taxonomy_toc_dx.View.sql
schema/dbo.view_taxa_level_counts_by_release.View.sql
schema/dbo.view_taxonomy_stats.View.sql

 1. Cache Tables - these store data pre-computed from taxonomy_node, which makes the queries that serve the website possible in real time. 
schema/dbo.taxonomy_node_delta.Table.sql
schema/dbo.taxonomy_node_merge_split.Table.sql

 1. Virus isolate tables - these are additional data linked to the species described in taxonomy_node, but not linked to the specific year. 
Isolate 
schema/dbo.virus_isolates.Table.sql
schema/dbo.virus_prop.Table.sql
schema/dbo.vmr_load.Table.sql
schema/dbo.VMR-new.Table.sql
schema/dbo.virus_isolates_051420.Table.sql
schema/dbo.virus_isolates_051821.Table.sql
schema/dbo.virus_isolates_072021.Table.sql
schema/dbo.virus_isolates_080120.Table.sql
schema/dbo.virus_isolates_093019.Table.sql
schema/dbo.virus_isolates_112321.Table.sql
schema/dbo.virus_isolates_120219.Table.sql
schema/dbo.virus_isolates_220319.Table.sql
schema/dbo.virus_isolates_load.Table.sql

 1. ETL/Load tables
ETL/Load tables
schema/dbo.load_next_msl.Table.sql
schema/dbo.load_next_msl_28.Table.sql
schema/dbo.load_next_msl_29.Table.sql
schema/dbo.load_next_msl_30.Table.sql
schema/dbo.load_next_msl_31.Table.sql
schema/dbo.load_next_msl_32.Table.sql
schema/dbo.load_next_msl_33.Table.sql
schema/dbo.load_next_msl_34a.Table.sql
schema/dbo.load_next_msl_34b.Table.sql
schema/dbo.load_next_msl_35.Table.sql
schema/dbo.load_next_msl_36.Table.sql
schema/dbo.load_next_msl_scList.Table.sql
schema/dbo.load_next_msl_taxonomy_31.Table.sql
schema/dbo.load_next_msl_tpList.Table.sql
schema/dbo.load_next_msl_unicode.Table.sql

1. Membership
schema/dbo.committee.Table.sql
schema/dbo.committee_type_cv.Table.sql
schema/dbo.membership.Table.sql
schema/dbo.member.Table.sql
schema/dbo.position.Table.sql

schema/dbo.view_membership_committee_with_subchairs.View.sql
schema/dbo.view_membership_committee_with_submembers.View.sql
schema/dbo.view_membership_x.View.sql

1. Obsolete
schema/dbo.queue_delta.Table.sql
schema/dbo.queue_patch.Table.sql
schema/dbo.log_change.Table.sql


1. ICTVdb
Tables
schema/dbo.ictvdb_index.Table.sql
schema/dbo.ictvdb_sun_ah.Table.sql
Views
schema/dbo.ictvdb_family.View.sql
schema/dbo.ictvdb_genus.View.sql
schema/dbo.ictvdb_order.View.sql
schema/dbo.ictvdb_species.View.sql
schema/dbo.ictvdb_subfamily.View.sql


