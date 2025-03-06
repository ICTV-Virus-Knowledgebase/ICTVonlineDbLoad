
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[VMR_update_from_new_MSL] 
as
/*
-- *************************************************************
--
-- Assuming a new MSL has been loaded into [taxonomy_node]
--
-- Update all the VMR records to match
-- Add any new isolates listed in MSL
--
-- *************************************************************
-- protocol:
-- *************************************************************


 -- -----------------------------------------------------------------
 -- backup VMR
 -- -----------------------------------------------------------------

SELECT * INTO [species_isolates_20250128_premsl40] FROM [species_isolates]

 -- -----------------------------------------------------------------
 -- recover
 -- -----------------------------------------------------------------
TRUNCATE TABLE species_isolates; 
go
SET IDENTITY_INSERT [species_isolates] ON
go 
INSERT INTO [species_isolates] ([isolate_id]
    ,[taxnode_id]
    ,[species_sort]
    ,[isolate_sort]
    ,[species_name]
    ,[isolate_type]
    ,[isolate_names]
    --,[_isolate_name]
    ,[isolate_abbrevs]
    ,[isolate_designation]
    ,[genbank_accessions]
    ,[refseq_accessions]
    ,[genome_coverage]
    ,[molecule]
    ,[host_source]
    ,[refseq_organism]
    ,[refseq_taxids]
    ,[update_change]
    ,[update_prev_species]
    ,[update_prev_taxnode_id]
    ,[update_change_proposal]
    ,[notes])
SELECT [isolate_id]
    ,[taxnode_id]
    ,[species_sort]
    ,[isolate_sort]
    ,[species_name]
    ,[isolate_type]
    ,[isolate_names]
    --,[_isolate_name]
    ,[isolate_abbrevs]
    ,[isolate_designation]
    ,[genbank_accessions]
    ,[refseq_accessions]
    ,[genome_coverage]
    ,[molecule]
    ,[host_source]
    ,[refseq_organism]
    ,[refseq_taxids]
    ,[update_change]
    ,[update_prev_species]
    ,[update_prev_taxnode_id]
    ,[update_change_proposal]
    ,[notes]
	FROM [species_isolates_20250128_premsl40]
go
SET IDENTITY_INSERT [species_isolates] OFF 

--
-- update VMR
-- 
EXEC [VMR_update_from_new_MSL]
EXEC [species_isolates_update_sorts]

--
-- export VMR
--
SELECT * FROM [vmr_export]

*/
-- *************************************************************
--
-- Actual update code
--
-- *************************************************************

--
-- move "current" data into old
-- reset "change" tracking column
--
select 'row_count'='[species_isolates]',
	 ct=count(*), abolish_ct=count(case when update_change='abolished' then 1 end)
	, ct_non_ab=count(*)-count(case when update_change='abolished' then 1 end)
 from species_isolates 

update species_isolates set
-- select *,
	update_change =  NULL
	, update_change_proposal = NULL
	, update_prev_taxnode_id = taxnode_id
	, update_prev_species = species_name
--from species_isolates
from species_isolates
where update_change is null
or update_change <> 'abolished'

-- ******************************************************************* 
--
-- NO CHANGE species 
--
-- ******************************************************************* 

update species_isolates set
--select  species_isolates.*,
	species_name           = dx.name 
	, update_change          = 'same'
	, update_change_proposal = NULL
	, taxnode_id      = dx.taxnode_id
	--, dx.prev_tags
from species_isolates
join taxonomy_node_dx dx on 
	dx.prev_id = species_isolates.update_prev_taxnode_id
where 
	update_change is null
	and dx.prev_name = species_isolates.update_prev_species
	and dx.prev_tags = ''
	--and dx.msl_release_num = (select max(msl_release_num) from taxonomy_toc)

-- ******************************************************************* 
--
--  RENAMES 
--
-- ******************************************************************* 

update species_isolates set
-- select  species_isolates.*,
	species_name = dx.name 
	,update_change		 = dx.prev_tags--'renamed'
	, update_change_proposal = dx.prev_proposal
	, taxnode_id= dx.taxnode_id
from species_isolates
join taxonomy_node_dx  dx on dx.prev_id=species_isolates.update_prev_taxnode_id-- and  dx.prev_name= vmr.old_species
where 
	(dx.prev_tags  like '%renamed%' or dx.prev_tags like '%moved%')
	and dx.msl_release_num = (select max(msl_release_num) from taxonomy_toc)
	and update_change is NULL

-- *******************************************************************
--
-- ABOLISH species 
--
-- use taxonomy_node_delta, as abolished records are not in taxonomy_node_dx
--
-- ******************************************************************* 


update species_isolates set
-- select species_isolates.*,
	species_name		 = 'abolished' -- ick: sentinal value, since [species] NOT NULL
	,update_change		 = 'abolished'
	, update_change_proposal = dx.proposal
	, taxnode_id= dx.new_taxid
from species_isolates
join taxonomy_node_delta  dx on dx.prev_taxid=species_isolates.update_prev_taxnode_id-- and  dx.prev_name= vmr.old_species
--select * from taxonomy_node_delta dx 
where 
	dx.is_deleted = 1 
	and dx.msl = (select max(msl_release_num) from taxonomy_toc)
--	and update_change <> 'abolished'
	and update_change is NULL

-- *******************************************************************
-- 
-- INSERT new species
--
-- *******************************************************************
INSERT INTO [dbo].[species_isolates]
           ([species_name]
           ,[isolate_type]
           ,[isolate_names]
		   ,[isolate_designation]
           ,[genbank_accessions]
           ,[isolate_abbrevs]
           ,[taxnode_id]
		   ,[molecule]
		   ,[host_source]
		   ,[genome_coverage]
		   ,update_change
		   ,update_change_proposal
		   ,update_prev_taxnode_id
		   ,update_prev_species)

--select alternative_name_csv= max(len(alternative_name_csv)) from (
SELECT 
      species_name=dx.name
	  ,[isolate_type] = 'E'
	  ,[isolate_names] = [exemplar_name]
	  ,[isolate_designation] = [isolate_csv]
      ,[genbank_accessions]=[genbank_accession_csv]
	  ,[isolate_abbrevs] = [abbrev_csv]
	  ,[taxnode_id]=[taxnode_id]
	  ,[molecule]=mol.abbrev
	  ,[host_source]=[host_source]
	  ,[genome_coverage]=gc.name
	  ,[update_change]= (case when dx.prev_name is null then 'created' else 'updated' end)
	  ,[update_change_proposal] = dx.prev_proposal
	  ,[update_prev_taxnode_id] = dx.prev_id
	  ,[udpate_prev_species] = (case when dx.prev_name is null then 'created' else dx.prev_name end)
	 -- ,[in_change] -- DEBUG
  FROM [taxonomy_node_dx] dx
  JOIN [taxonomy_genome_coverage] gc on gc.genome_coverage=dx.genome_coverage
  JOIN [taxonomy_molecule] mol on mol.id = dx.inher_molecule_id
  where
	-- latest MSL
	msl_release_num = (select max(msl_release_num) from taxonomy_toc)
	AND dx.level_id = 600 /* species*/ AND is_hidden = 0 
	-- not already there
	AND dx.[genbank_accession_csv] NOT IN ( select [genbank_accessions] from species_isolates where  [genbank_accessions] is not null and [genbank_accessions] <> '' )
	--and  ictv_id=201908644

-- summary: done
select title='[species_isolates] DONE', update_change, ct_change=count(*)
from [species_isolates] 
group by update_change

-- summary: todo 
select title='[species_isolates] TODO', delta.tag_csv2, ct=count(*), ct_old_taxnode_id=count(update_prev_taxnode_id)
 from [species_isolates] 
 left outer join  taxonomy_node_delta delta on  update_prev_taxnode_id =  delta.prev_taxid
 where update_change is null
 group by delta.tag_csv2

 
-- report on abolished species WITH accessions
select
	report='abolished exemplars, with genbnak entries'
	, *
	, proposal_url='https://ictv.global/ictv/proposals/'+update_change_proposal 
from species_isolates 
where update_change = 'abolished'
and (
	genome_coverage <> 'No entry in Genbank' 
	or genbank_accessions <> ''
)

GO

