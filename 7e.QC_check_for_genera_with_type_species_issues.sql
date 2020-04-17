
-- -----------------------------------------------------------------------------
--
-- QUERY genera with wrong # of type species
--
-- now that we have subgenus ranks, the rule is 
-- "one and only one type specices per genus, across all it's subgenera, if any"
--
-- -----------------------------------------------------------------------------
select 
	report='too many/few type species under a genus'
	, genus.msl_release_num, genus.lineage, genus.name
	, species_ct = count(species.taxnode_id)
	, type_species_ct=sum(species.is_ref)
	,[genera with wrong type species counts]= case 
		when genus.name='unassigned' and sum(species.is_ref)=0 then 'OK'
		when genus.name<>'unassigned' and sum(species.is_ref)=1 then 'OK'
		when genus.name='unassigned' and sum(species.is_ref)>0 then 'ERROR: [Unassigned] genera should not have type species'
		when genus.name<>'unassigned' and sum(species.is_ref)>1 then 'ERROR: too MANY type species: each genus should have EXACTLY 1 type species'
		when count(species.taxnode_id)=1 and sum(species.is_ref)=0 then 'ERROR: genus has only 1 species, but it is NOT a type species. A genus must have have EXACTLY 1 species'
		when sum(species.is_ref)=0 then 'ERROR: genera should have EXACTLY 1 species'
		else 'ERROR: unanticpated by author of this query'
		end 
from taxonomy_node_names genus
join taxonomy_node_names species on 
	species.tree_id = genus.tree_id 
	and species.left_idx between genus.left_idx and genus.right_idx 
	and species.rank='species'
where genus.rank='genus'  
and genus.msl_release_num is not null 
--and genus.msl_release_num=dbo.udf_getMSL(NULL)-5
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

