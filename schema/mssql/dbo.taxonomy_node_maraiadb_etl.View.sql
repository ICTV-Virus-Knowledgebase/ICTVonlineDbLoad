USE [ICTVonline40]
GO
/****** Object:  View [dbo].[taxonomy_node_mariadb_etl]    Script Date: 2/28/2025 04:10:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER view [dbo].[taxonomy_node_mariadb_etl] as
--
-- Export used to load MariaDB mirror database
-- MariaDB does not (yet) have functional update SP/Triggers
-- so we include all the trigger-maintained columns
--
-- export: select * from taxonomy_node_export 
select 
	top 10000000 -- add top so we can use 'order by' in a view
     tn.[taxnode_id]
    ,tn.[parent_id]
    ,tn.[tree_id]
    ,tn.[msl_release_num]
    ,tn.[level_id]
    ,tn.[name]
    ,tn.[ictv_id]
    ,tn.[molecule_id]
    ,[abbrev_csv] = replace(tn.[abbrev_csv],char(9),'')
    ,[genbank_accession_csv] = replace(tn.[genbank_accession_csv],char(9),'')
    ,[genbank_refseq_accession_csv] = replace(tn.[genbank_refseq_accession_csv],char(9),'')
    ,[refseq_accession_csv]= replace(tn.[refseq_accession_csv],char(9),'')
    ,[isolate_csv] = replace(tn.[isolate_csv],char(9),'')
    ,notes=(case when tn.[notes] like '%"%' then
				-- internal double quotes need escaping in a mariaDB friendly format
				'"'+replace(replace(replace(tn.[notes]
				, char(13),'') -- DOS newline
				, char(9),'') -- TAB
				, '"','""') -- escape quotes
				+'"'
			else 
				-- no internal quotes
				replace(replace(tn.[notes]
				, char(13),'') -- DOS newline
				, char(9),'') -- TAB
			end)
    ,tn.[is_ref]
    ,tn.[is_official]
    ,tn.[is_hidden]
    ,tn.[is_deleted]
    ,tn.[is_deleted_next_year]
    ,tn.[is_typo]
    ,tn.[is_renamed_next_year]
    ,tn.[is_obsolete]
    ,[in_change] =    replace(tn.[in_change],char(9),'')
    ,[in_target] =    replace(tn.[in_target],char(9),'')
    ,[in_filename] =  replace(tn.[in_filename],char(9),'')
    ,[in_notes] =     replace(tn.[in_notes],char(9),'')
    ,[out_change] =   replace(tn.[out_change],char(9),'')
    ,[out_target] =   replace(tn.[out_target],char(9),'')
    ,[out_filename] = replace(tn.[out_filename],char(9),'')
    ,[out_notes] =	  replace(tn.[out_notes],char(9),' ')
	-- Trigger-maintained and computed columns
    ,tn.[start_num_sort]
    ,tn.[row_num]
    ,[filename] = replace(tn.[filename],char(9),'')
    ,[xref]     = replace(tn.[xref]    ,char(9),'')
    ,tn.[realm_id]
    ,tn.[realm_kid_ct]
    ,tn.[realm_desc_ct]
    ,tn.[subrealm_id]
    ,tn.[subrealm_kid_ct]
    ,tn.[subrealm_desc_ct]
    ,tn.[kingdom_id]
    ,tn.[kingdom_kid_ct]
    ,tn.[kingdom_desc_ct]
    ,tn.[subkingdom_id]
    ,tn.[subkingdom_kid_ct]
    ,tn.[subkingdom_desc_ct]
    ,tn.[phylum_id]
    ,tn.[phylum_kid_ct]
    ,tn.[phylum_desc_ct]
    ,tn.[subphylum_id]
    ,tn.[subphylum_kid_ct]
    ,tn.[subphylum_desc_ct]
    ,tn.[class_id]
    ,tn.[class_kid_ct]
    ,tn.[class_desc_ct]
    ,tn.[subclass_id]
    ,tn.[subclass_kid_ct]
    ,tn.[subclass_desc_ct]
    ,tn.[order_id]
    ,tn.[order_kid_ct]
    ,tn.[order_desc_ct]
    ,tn.[suborder_id]
    ,tn.[suborder_kid_ct]
    ,tn.[suborder_desc_ct]
    ,tn.[family_id]
    ,tn.[family_kid_ct]
    ,tn.[family_desc_ct]
    ,tn.[subfamily_id]
    ,tn.[subfamily_kid_ct]
    ,tn.[subfamily_desc_ct]
    ,tn.[genus_id]
    ,tn.[genus_kid_ct]
    ,tn.[genus_desc_ct]
    ,tn.[subgenus_id]
    ,tn.[subgenus_kid_ct]
    ,tn.[subgenus_desc_ct]
    ,tn.[species_id]
    ,tn.[species_kid_ct]
    ,tn.[species_desc_ct]
    ,tn.[taxa_kid_cts]
    ,tn.[taxa_desc_cts]
    ,tn.[inher_molecule_id]
    ,tn.[left_idx]
    ,tn.[right_idx]
    ,tn.[node_depth]
    ,[lineage] = replace(tn.[lineage],char(9),'')
	-- mask computed columns;
	-- those ARE implemented in MariaDB
    --,tn.[cleaned_name]
    --,tn.[cleaned_problem]
    --,tn.[flags]
    --,tn.[_numKids]
    --,tn.[_out_target_parent]
    --,tn.[_out_target_name]
    ,[exemplar_name] = replace(tn.[exemplar_name],char(9),'')
    ,[genome_coverage] = replace(tn.[genome_coverage],char(9),'')
    ,[host_source] = replace(tn.[host_source],char(9),'')
from taxonomy_node tn
/*
-- turn these off: some ICTV_ID's are defined by rows with is_deleted = 1
-- need to clean that up first!
where tn.msl_release_num is not null
-- remove legacy deleted/hidden/obsolete nodes
and tn.is_deleted = 0 
-- but hidden tree root nodes must be kept
and (tn.level_id = 100 or tn.is_hidden = 0) 
and tn.is_obsolete=0
*/
-- order so satisfies FK parent_id=>taxnode_id during load
order by tn.msl_release_num, tn.left_idx
GO


