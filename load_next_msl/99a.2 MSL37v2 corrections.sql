/*
 * MSL37v2 correction proposals
 *
 * apply the proposals 
 *   2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
 *     renames 4 specices
 *   2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
 *     Rename 7 species, 2 families
 * directly to 
 *    load_next_msl
 *    taxonomy_node
 * and rebuild
 *    taxonomy_node_delta
 */

BEGIN TRANSACTION
--ROLLBACK TRANSACTION
 --
 -- find all the taxa that need fixing
 --
select rank, name, lineage, taxnode_id, ictv_id,* 
from taxonomy_node_names
where msl_release_num = 37 
and (
	name in (
	-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
	'Alpharicinrhavirus blanchesco',  'Alpharicinrhavirus blanchseco'
	,'Emaravirus chrysantemi',  'Emaravirus chrysanthemi'
	,'Orthophasmavirus bastukasense',  'Orthophasmavirus barstukasense'
	,'Orthophasmavirus moglotasense',  'Orthophasmavirus miglotasense'
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
	,'Olluvirus shayangense',  'Ollusvirus shayangense'
	,'Sunrhaviruys nasoule' ,  'Sunrhavirus nasoule'
	,'Queuoviridae',  'Druskaviridae'
	,'Flexireviridae', 'Graaviviridae'
	,'Sprivirus cyprinus', 'Sprivivirus cyprinus'
	,'Sprivirus esox', 'Sprivivirus esox'
	,'Lumbo orthbunyavirus', 'Lumbo orthobunyavirus'
	,'Seewis orhtohantavirus', 'Seewis orthohantavirus'
	,'Thottopalayam thottimvirus', 'Thottapalayam thottimvirus'
) /*or name in (
	-- 2021.097B.R.error_correction_Caudoviricetes.zip
	-- move 3 genera
	'Nevevirus', ''
	,'Pharaohvirus', ''
	,'Refugevirus', ''
)
*/	
)
order by left_idx

select _dest_taxon_rank, _dest_taxon_name, _src_taxon_name, * 
from load_next_msl
where _dest_taxon_name in  (
	-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
	'Alpharicinrhavirus blanchesco',  'Alpharicinrhavirus blanchseco' --
	,'Emaravirus chrysantemi',  'Emaravirus chrysanthemi'             --
	,'Orthophasmavirus bastukasense',  'Orthophasmavirus barstukasense' --
	,'Orthophasmavirus moglotasense',  'Orthophasmavirus miglotasense' -- 
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
	,'Olluvirus shayangense',  'Ollusvirus shayangense'		-- no change in 2021
	,'Sunrhaviruys nasoule' ,  'Sunrhavirus nasoule'		--
	,'Queuoviridae',  'Druskaviridae'						--
	,'Flexireviridae', 'Graaviviridae'						-- 
	,'Sprivirus cyprinus', 'Sprivivirus cyprinus'			--
	,'Sprivirus esox', 'Sprivivirus esox'					--
	,'Lumbo orthbunyavirus', 'Lumbo orthobunyavirus'		-- no change in 2021
	,'Seewis orhtohantavirus', 'Seewis orthohantavirus'		-- no change in 2021
	,'Thottopalayam thottimvirus', 'Thottapalayam thottimvirus' -- no change in 2021
)

--
-- add change records to load_next_msl for fixes that did not yet have a 2021/MSL37 change
--


insert into load_next_msl (
	filename
	, proposal
	, proposal_abbrev
	,comments
	,srcRealm, srcKingdom, srcPhylum, srcSubPhylum, srcClass, srcOrder, srcFamily,srcSubFamily, srcGenus, srcSpecies
	,Realm, Kingdom, Phylum, SubPhylum, Class, [Order], Family,SubFamily, Genus
	, Species
	, change, _action, rank
	, prev_taxnode_id
	, dest_taxnode_id
	, dest_tree_id 
	, dest_ictv_id
	, dest_parent_id 
	, dest_level_id 
	, isDone
	, sort
)
select
	filename='ICTVonlineDbLoad\load_next_msl\99a.2 MSL37v2 corrections.sql'
	,proposal = '2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'
	,proposal_abbrev='2021.042M'
	, comments = 'MSL37v2'
	,srcRealm=n.realm, srcKingdom=n.kingdom, srcPhylum=n.phylum, srcSubPhylum=n.subphylum, srcClass=n.class, srcOrder=n.[order], srcFamily=n.family,srcSubFamily= n.subfamily, srcGenus=n.genus, srcSpecies= n.species
	,Realm=n.realm, Kingdom=n.kingdom, Phylum=n.phylum, SubPhylum=n.subphylum, Class=n.class, [Order]=n.[order], Family=n.family,SubFamily= n.subfamily, Genus=n.genus
	, Species= (case n.species
		when 'Olluvirus shayangense' then 'Ollusvirus shayangense'		-- no change in 2021
		when 'Lumbo orthbunyavirus'  then 'Lumbo orthobunyavirus'		-- no change in 2021
		when 'Seewis orhtohantavirus' then 'Seewis orthohantavirus'		-- no change in 2021
		when'Thottopalayam thottimvirus' then 'Thottapalayam thottimvirus' -- no change in 202
	end)
	, change='rename', _action='rename', rank='species'
	, prev_taxnode_id=dx.prev_id
	, dest_taxnode_id = dx.taxnode_id
	, dest_tree_id = n.tree_id
	, dest_ictv_id = n.ictv_id
	, dest_parent_id = n.parent_id
	, dest_level_id = n.level_id
	, isDone = 'MSL37v2'
	, sort='MSL37v2'+rtrim(n.ictv_id) -- I don't remember what this is for
from taxonomy_node_dx dx
join taxonomy_node_names n on n.taxnode_id = dx.taxnode_id
where dx.name in (
	'Olluvirus shayangense'--,  'Ollusvirus shayangense'		-- no change in 2021
	,'Lumbo orthbunyavirus'--, 'Lumbo orthobunyavirus'		-- no change in 2021
	,'Seewis orhtohantavirus'--, 'Seewis orthohantavirus'		-- no change in 2021
	,'Thottopalayam thottimvirus'--, 'Thottapalayam thottimvirus' -- no change in 202
)
and dx.msl_release_num = 37
and not exists (select * from load_next_msl where srcSpecies = dx.name)


--
-- update load_next_msl for taxa already covered
-- 



-- species
update load_next_msl set --select species, proposal, 
	species =(case species 
		when 'Alpharicinrhavirus blanchesco' then 'Alpharicinrhavirus blanchseco' --
		when 'Emaravirus chrysantemi' then  'Emaravirus chrysanthemi'             --
		when 'Orthophasmavirus bastukasense' then 'Orthophasmavirus barstukasense' --
		when 'Orthophasmavirus moglotasense' then  'Orthophasmavirus miglotasense' -- 
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
	--,'Olluvirus shayangense',  'Ollusvirus shayangense'		-- no change in 2021
		when 'Sunrhaviruys nasoule' then  'Sunrhavirus nasoule'		--
	--,'Queuoviridae',  'Druskaviridae'						--
	--,'Flexireviridae', 'Graaviviridae'						-- 
		when 'Sprivirus cyprinus' then 'Sprivivirus cyprinus'			--
		when'Sprivirus esox' then 'Sprivivirus esox'					--
	end)
	,proposal = proposal + ';' + (case species
		-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
		when 'Alpharicinrhavirus blanchesco' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' --
		when 'Emaravirus chrysantemi' then			'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip'             --
		when 'Orthophasmavirus bastukasense' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' --
		when 'Orthophasmavirus moglotasense' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' -- 
		-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
		-- Rename 7 species, 2 families
		when 'Olluvirus shayangense' then   '2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- no change in 2021
		when 'Sunrhaviruys nasoule' then	'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- family
		when 'Queuoviridae'	then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- family
		when 'Flexireviridae' then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
		when 'Sprivirus cyprinus' then		'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
		when 'Sprivirus esox' then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
	end)
from load_next_msl
where species in   (
	-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
	'Alpharicinrhavirus blanchesco'--,  'Alpharicinrhavirus blanchseco' --
	,'Emaravirus chrysantemi'--,  'Emaravirus chrysanthemi'             --
	,'Orthophasmavirus bastukasense'--,  'Orthophasmavirus barstukasense' --
	,'Orthophasmavirus moglotasense'--,  'Orthophasmavirus miglotasense' -- 
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
--	,'Olluvirus shayangense'--,  'Ollusvirus shayangense'		-- no change in 2021
	,'Sunrhaviruys nasoule' --,  'Sunrhavirus nasoule'		--
	,'Queuoviridae'--,  'Druskaviridae'						--
	,'Flexireviridae'--, 'Graaviviridae'						-- 
	,'Sprivirus cyprinus'--, 'Sprivivirus cyprinus'			--
	,'Sprivirus esox'--, 'Sprivivirus esox'					--
--	,'Lumbo orthbunyavirus'--, 'Lumbo orthobunyavirus'		-- no change in 2021
--	,'Seewis orhtohantavirus'--, 'Seewis orthohantavirus'		-- no change in 2021
--	,'Thottopalayam thottimvirus'--, 'Thottapalayam thottimvirus' -- no change in 2021
)

-- families
update load_next_msl set --
--select family, proposal, change, _action,
	family =(case family 
		when 'Alpharicinrhavirus blanchesco' then 'Alpharicinrhavirus blanchseco' --
		when 'Emaravirus chrysantemi' then  'Emaravirus chrysanthemi'             --
		when 'Orthophasmavirus bastukasense' then 'Orthophasmavirus barstukasense' --
		when 'Orthophasmavirus moglotasense' then  'Orthophasmavirus miglotasense' -- 
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
	--,'Olluvirus shayangense',  'Ollusvirus shayangense'		-- no change in 2021
		when 'Sunrhaviruys nasoule' then  'Sunrhavirus nasoule'		--
		when 'Queuoviridae' then 'Druskaviridae'						--
		when 'Flexireviridae' then 'Graaviviridae'						-- 
		when 'Sprivirus cyprinus' then 'Sprivivirus cyprinus'			--
		when'Sprivirus esox' then 'Sprivivirus esox'					--
	end)
	,proposal = proposal + ';' + (case family
		-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
		when 'Alpharicinrhavirus blanchesco' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' --
		when 'Emaravirus chrysantemi' then			'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip'             --
		when 'Orthophasmavirus bastukasense' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' --
		when 'Orthophasmavirus moglotasense' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' -- 
		-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
		-- Rename 7 species, 2 families
		when 'Olluvirus shayangense' then   '2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- no change in 2021
		when 'Sunrhaviruys nasoule' then	'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- family
		when 'Queuoviridae'	then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- family
		when 'Flexireviridae' then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
		when 'Sprivirus cyprinus' then		'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
		when 'Sprivirus esox' then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
	end)
from load_next_msl
where _dest_taxon_name in   (
	-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
	'Alpharicinrhavirus blanchesco'--,  'Alpharicinrhavirus blanchseco' --
	,'Emaravirus chrysantemi'--,  'Emaravirus chrysanthemi'             --
	,'Orthophasmavirus bastukasense'--,  'Orthophasmavirus barstukasense' --
	,'Orthophasmavirus moglotasense'--,  'Orthophasmavirus miglotasense' -- 
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
--	,'Olluvirus shayangense'--,  'Ollusvirus shayangense'		-- no change in 2021
	,'Sunrhaviruys nasoule' --,  'Sunrhavirus nasoule'		--
	,'Queuoviridae'--,  'Druskaviridae'						--
	,'Flexireviridae'--, 'Graaviviridae'						-- 
	,'Sprivirus cyprinus'--, 'Sprivivirus cyprinus'			--
	,'Sprivirus esox'--, 'Sprivivirus esox'					--
--	,'Lumbo orthbunyavirus'--, 'Lumbo orthobunyavirus'		-- no change in 2021
--	,'Seewis orhtohantavirus'--, 'Seewis orthohantavirus'		-- no change in 2021
--	,'Thottopalayam thottimvirus'--, 'Thottapalayam thottimvirus' -- no change in 2021
)

--
-- implement renames in taxonomy_node and in_filename in current MSL
--
update taxonomy_node set 
--select name, level_id, in_change, in_filename,
	name =(case name 
		when 'Alpharicinrhavirus blanchesco' then 'Alpharicinrhavirus blanchseco' --
		when 'Emaravirus chrysantemi' then  'Emaravirus chrysanthemi'             --
		when 'Orthophasmavirus bastukasense' then 'Orthophasmavirus barstukasense' --
		when 'Orthophasmavirus moglotasense' then  'Orthophasmavirus miglotasense' -- 
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
		when 'Olluvirus shayangense' then  'Ollusvirus shayangense'		-- no change in 2021
		when 'Sunrhaviruys nasoule' then  'Sunrhavirus nasoule'		--
		when 'Queuoviridae' then 'Druskaviridae'						--
		when 'Flexireviridae' then 'Graaviviridae'						-- 
		when 'Sprivirus cyprinus' then 'Sprivivirus cyprinus'			--
		when'Sprivirus esox' then 'Sprivivirus esox'					--
		when 'Lumbo orthbunyavirus' then 'Lumbo orthobunyavirus'		-- no change in 2021
		when 'Seewis orhtohantavirus' then 'Seewis orthohantavirus'		-- no change in 2021
		when 'Thottopalayam thottimvirus' then 'Thottapalayam thottimvirus' -- no change in 2021
	end)
	,in_filename = in_filename + ';' + (case name
		-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
		when 'Alpharicinrhavirus blanchesco' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' --
		when 'Emaravirus chrysantemi' then			'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip'             --
		when 'Orthophasmavirus bastukasense' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' --
		when 'Orthophasmavirus moglotasense' then	'2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip' -- 
		-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
		-- Rename 7 species, 2 families
		when 'Olluvirus shayangense' then   '2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- no change in 2021
		when 'Sunrhaviruys nasoule' then	'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- family
		when 'Queuoviridae'	then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- family
		when 'Flexireviridae' then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
		when 'Sprivirus cyprinus' then		'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
		when 'Sprivirus esox' then			'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- species
		when 'Lumbo orthbunyavirus'then		'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- no change in 2021
		when 'Seewis orhtohantavirus' then	'2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'		-- no change in 2021
		when 'Thottopalayam thottimvirus' then '2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip'    -- no change in 2021
	end)
from taxonomy_node
where msl_release_num = 37
 and
name in   (
	-- 2021.043M.R.Corrections_Mononegavirales_Bunyavirales.zip
	'Alpharicinrhavirus blanchesco'--,  'Alpharicinrhavirus blanchseco' --
	,'Emaravirus chrysantemi'--,  'Emaravirus chrysanthemi'             --
	,'Orthophasmavirus bastukasense'--,  'Orthophasmavirus barstukasense' --
	,'Orthophasmavirus moglotasense'--,  'Orthophasmavirus miglotasense' -- 
	-- 2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip
	-- Rename 7 species, 2 families
	,'Olluvirus shayangense'--,  'Ollusvirus shayangense'		-- no change in 2021
	,'Sunrhaviruys nasoule' --,  'Sunrhavirus nasoule'		--
	,'Queuoviridae'--,  'Druskaviridae'						--
	,'Flexireviridae'--, 'Graaviviridae'						-- 
	,'Sprivirus cyprinus'--, 'Sprivivirus cyprinus'			--
	,'Sprivirus esox'--, 'Sprivivirus esox'					--
	,'Lumbo orthbunyavirus'--, 'Lumbo orthobunyavirus'		-- no change in 2021
	,'Seewis orhtohantavirus'--, 'Seewis orthohantavirus'		-- no change in 2021
	,'Thottopalayam thottimvirus'--, 'Thottapalayam thottimvirus' -- no change in 2021
)


--
-- implement out_filename in prev MSL
--
update taxonomy_node set 
--select name, level_id, out_change, out_filename, out_target,
	out_change = 'rename'
	, out_filename = (select proposal from load_next_msl m where m.prev_taxnode_id = taxnode_id)
	, out_target =  (select _dest_taxon_name from load_next_msl m where m.prev_taxnode_id = taxnode_id)
from taxonomy_node
where msl_release_num = 36
and 
taxnode_id in ( 
	(select prev_taxnode_id from load_next_msl where proposal like '%2021.042M.R.Corrections_Riboviria_Duplodnaviria.zip%' and prev_taxnode_id is not null)
	union all
	(select prev_taxnode_id from load_next_msl where proposal like '%2021.043M.R.%Corrections_Mononegavirales_Bunyavirales.zip%' and prev_taxnode_id is not null)
)



--
-- update proposal names and change flags in taxonomy_node_delta
--
exec rebuild_delta_nodes @msl=37

select taxnode_id  from taxonomy_node where msl_release_num = 37 and name in( 'Thottopalayam thottimvirus', 'Thottapalayam thottimvirus')

--
-- problem with the ones that didn't change this year already!
--
-- taxonomy_node.name = null
-- 
select * from taxonomy_node where  msl_release_num > 34 and (name like 'Thott%palayam thottimvirus' or ictv_id = 19910608)
order by msl_release_num
select * from load_next_msl where dest_taxnode_id = 202100059 or species like  'Thott%palayam thottimvirus'

select * from load_next_msl where desT_taxnode_id is null
select *   from load_next_msl where isDone = 'MSL37v2'

-- COMMIT TRANSACTION
-- ROLLBACK TRANSACTION
