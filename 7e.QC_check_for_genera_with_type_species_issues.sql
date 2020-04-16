
-- -----------------------------------------------------------------------------
--
-- QUERY genera with wrong # of type species
--
-- -----------------------------------------------------------------------------
select 
	report='type species directly in genus'
	, genus.msl_release_num, genus.lineage
	, species_ct = count(species.taxnode_id)
	, type_species_ct=sum(species.is_ref)
	,[genera with wrong type species counts]= case 
		when genus.name='unassigned' and sum(species.is_ref)=0 then 'OK'
		when genus.name<>'unassigned' and sum(species.is_ref)=1 then 'OK'
		when genus.name='unassigned' and sum(species.is_ref)>0 then 'ERROR: [Unassigned] genera should not have type species'
		when genus.name<>'unassigned' and sum(species.is_ref)<>1 then 'ERROR: genera should have EXACTLY 1 type species'
		when count(species.taxnode_id)=0 then 'ERROR: genera should have AT LEAST 1 species'
		else 'ERROR: unanticpated by author of this query'
		end 
from taxonomy_node genus
join taxonomy_node species on species.parent_id = genus.taxnode_id
where genus.level_id=500 and genus.msl_release_num is not null --and genus.msl_release_num=31
group by genus.msl_release_num, genus.name, genus.lineage, genus.left_idx
having not (
	(genus.name='unassigned' and sum(species.is_ref)=0)
	or 
	(genus.name<>'unassigned' and sum(species.is_ref)=1)
)
order by 
--	genus.lineage,
	genus.msl_release_num desc,
	type_species_ct desc

select 
	report='type species directly in genus/subgenera'
	, genus.msl_release_num, genus.lineage
	, genus_rank=(select name from taxonomy_level l where l.id = genus.level_id)
	, species_ct = count(species.taxnode_id)
	, type_species_ct=sum(species.is_ref)
	,[genera with wrong type species counts]= case 
		when genus.name='unassigned' and sum(species.is_ref)=0 then 'OK'
		when genus.name<>'unassigned' and sum(species.is_ref)=1 then 'OK'
		when genus.name='unassigned' and sum(species.is_ref)>0 then 'ERROR: [Unassigned] genera should not have type species'
		when genus.name<>'unassigned' and sum(species.is_ref)<>1 then 'ERROR: genera should have EXACTLY 1 type species'
		when count(species.taxnode_id)=0 then 'ERROR: genera should have AT LEAST 1 species'
		else 'ERROR: unanticpated by author of this query'
		end 
from taxonomy_node genus
join taxonomy_node species on species.parent_id = genus.taxnode_id
where genus.level_id in (500,550) and genus.msl_release_num is not null --and genus.msl_release_num=31
group by genus.msl_release_num, genus.name, genus.lineage, genus.left_idx, genus.level_id
having  not (
	(genus.name='unassigned' and sum(species.is_ref)=0)
	or 
	(genus.name<>'unassigned' and sum(species.is_ref)=1)
)
order by 
--	genus.lineage,
	genus.msl_release_num desc,
	type_species_ct desc

--
-- UPDATE (MSL32) remov extra type species
--
--
/*update taxonomy_node set
	--select orig_is_ref=is_ref, lineage,in_c
	is_ref = 0
from taxonomy_node
where lineage like  'Picornavirales;Picornaviridae;Unassigned;Megrivirus;%'  and name <> 'Megrivirus A'
and msl_release_num between 32 and 32

--
-- UPDATE (MSL32,31) add missing type species
--
-- according to 2009.005a-fV.A.v2.Aquaparamyxovirus.pdf / 2009.005fV 
--
update taxonomy_node set
	--select orig_is_ref=is_ref, lineage, in_change, out_change,
	is_ref = 1
from taxonomy_node
where lineage like  'Mononegavirales;Paramyxoviridae;Unassigned;Aquaparamyxovirus;%'  and is_ref = 0
and msl_release_num between 31 and 32

-- 
-- MSL32 type species completely omitted. 
--

insert into taxonomy_node
SELECT [taxnode_id]=(select max(taxnode_id)+1 from taxonomy_node)
      ,[parent_id]
      ,[tree_id]
      ,[msl_release_num]
      ,[level_id]
      ,[name] = 'Ageratum yellow vein Singapore alphasatellite'
      ,[ictv_id]=(select max(taxnode_id)+1 from taxonomy_node)
      ,[molecule_id]
      ,[abbrev_csv]='AYVSGA'
      ,[genbank_accession_csv]='AJ416153'
      ,[genbank_refseq_accession_csv]
      ,[refseq_accession_csv]
      ,[isolate_csv]='ageratum yellow vein Singapore alphasatellite (AYVSGA-[SG-98])'
      ,[notes]
      ,[is_ref]='1'
      ,[is_official]
      ,[is_hidden]
      ,[is_deleted]
      ,[is_deleted_next_year]
      ,[is_typo]
      ,[is_renamed_next_year]
      ,[is_obsolete]
      ,[in_change]
      ,[in_target]='Unassigned;Alphasatellitidae;Geminialphasatellitinae;Ageratum yellow vein Singapore alphasatellite'
      ,[in_filename]
      ,[in_notes]
      ,[out_change]
      ,[out_target]
      ,[out_filename]
      ,[out_notes]
      ,[start_num_sort]
      ,[row_num]
      ,[filename]
      ,[xref]
      ,[order_id]
      ,[family_id]
      ,[subfamily_id]
      ,[genus_id]
      ,[species_id]
      ,[inher_molecule_id]
      ,[left_idx]
      ,[right_idx]
      ,[node_depth]
      ,[lineage]
	-- select *
  FROM [dbo].[taxonomy_node]
  where lineage like 'Unassigned;Alphasatellitidae;Geminialphasatellitinae;Ageyesisatellite;Cotton leaf curl Saudi Arabia alphasatellite'
  and not exists (select * from taxonomy_node where lineage = 'Unassigned;Alphasatellitidae;Geminialphasatellitinae;Ageratum yellow vein Singapore alphasatellite')
  */
  


GO

