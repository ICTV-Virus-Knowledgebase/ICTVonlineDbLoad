--
-- set load_new_msl.prev_taxnode_id and dest_taxnode_id
--
begin transaction

select 	
	rpt='Map _src_taxon_name to last MSL'
	,msg=(case 
		when toc.msl_release_num is null			then 'ERROR: MSL='+rtrim(dest_msl_release_num)+' missing from taxonomy_toc table!!!' 
		when n.taxnode_id is not null				
		and dest._action not in ('new','split')	    then 'set src & dest taxnode_id'

		when n.taxnode_id is not null				then 'set src taxnode_id' 
		when dest._action not in ('new','split')	then 'set dest taxnode_id'
	end)
	, '['+dest._src_taxon_name+']', n.lineage, n.taxnode_id, dest._src_taxon_name, dest._action, dest.*,
--
-- RUN FROM HERE TO UPDATE (skip ORDER BY at bottom) ---
-- update load_next_msl set 
--
	prev_taxnode_id = n.taxnode_id
	, dest_taxnode_id = (case when dest._action not in ('new','split') 
						then n.taxnode_id+toc.tree_id_delta
						else dest.dest_taxnode_id end)
from load_next_msl as dest
left outer join taxonomy_toc_dx toc on  toc.msl_release_num=dest_msl_release_num 
left outer join taxonomy_node n on
	n.msl_release_num = dest.dest_msl_release_num -1
	and
	n.name=dest._src_taxon_name
where 
dest._action not in ('new')--, 'split')
--and n.taxnode_id is not null
and (dest.prev_taxnode_id is null or dest.prev_taxnode_id <> n.taxnode_id)
--
-- TO HERE only for UPDATE
--
-- don't order when updating
order by msg, sort -- put ERROR first, alphabetically.

-- --------------------------------------------------------------------
-- QC - unmapped rows
-- --------------------------------------------------------------------
select 
	STEP='2.c load_next_msl - set prev_tax_id.sql'
	,QC_ERROR='ERROR: prev_taxnode_id=NULL'
	, action=_action
	, * 
from load_next_msl 
where 
    prev_taxnode_id is null
and isWrong is null
and not (_action = 'new' and _src_taxon_name is null)
order by action, sort

-- --------------------------------------------------------------------
-- QC - try to map all taxon names at all levels
--
-- mostly this doesn't matter, if lowest rank taxon maps, which is done above.
-- --------------------------------------------------------------------
select * 
from (
	select 
		TAXA_NAMES_NOT_FOUND_IN_PREV_MSL=
		  (case when  load_next_msl.srcrealm  is not null and srcrealm.name is null then '"'+srcrealm+'": realm not found, '   else '' end)
		  +(case when  load_next_msl.srcsubrealm  is not null and srcsubrealm.name is null then '"'+srcsubrealm+'": subrealm not found, '   else '' end)
		  +(case when  load_next_msl.srckingdom  is not null and srckingdom.name is null then '"'+srckingdom+'": kingdom not found, '   else '' end)
		  +(case when  load_next_msl.srcsubkingdom  is not null and srcsubkingdom.name is null then '"'+srcsubkingdom+'": subkingdom not found, '   else '' end)
		  +(case when  load_next_msl.srcphylum  is not null and srcphylum.name is null then '"'+srcphylum+'": phylum not found, '   else '' end)
		  +(case when  load_next_msl.srcsubphylum  is not null and srcsubphylum.name is null then '"'+srcsubphylum+'": subphylum not found, '   else '' end)
		  +(case when  load_next_msl.srcclass  is not null and srcclass.name is null then '"'+srcclass+'": class not found, '   else '' end)
		  +(case when  load_next_msl.srcsubclass  is not null and srcsubclass.name is null then '"'+srcsubclass+'": subclass not found, '   else '' end)
		  +(case when  load_next_msl.srcorder  is not null and srcorder.name is null then '"'+srcorder+'": order not found, '   else '' end)
		  +(case when  load_next_msl.srcsuborder  is not null and srcsuborder.name is null then '"'+srcsuborder+'": suborder not found, '   else '' end)
		  +(case when  load_next_msl.srcfamily  is not null and srcfamily.name is null then '"'+srcfamily+'": family not found, '   else '' end)
		  +(case when  load_next_msl.srcsubfamily  is not null and srcsubfamily.name is null then '"'+srcsubfamily+'": subfamily not found, '   else '' end)
		  +(case when  load_next_msl.srcgenus  is not null and srcgenus.name is null then '"'+srcgenus+'": genus not found, '   else '' end)
		  +(case when  load_next_msl.srcsubgenus  is not null and srcsubgenus.name is null then '"'+srcsubgenus+'": subgenus not found, '   else '' end)
		  +(case when  load_next_msl.srcspecies  is not null and srcspecies.name is null then '"'+srcspecies+'": species not found, '   else '' end)
		, sort, isWrong, proposal, spreadsheet, _action, spreadsheet_lineage=_src_lineage, correct_prev_msl_lineage=mapped.lineage, correct_taxnode_id=mapped.taxnode_id
	from load_next_msl
	 left outer join taxonomy_node mapped on mapped.taxnode_id = load_next_msl.prev_taxnode_id
	 left outer join taxonomy_node srcrealm on srcrealm.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcrealm.name = load_next_msl.srcrealm
	 left outer join taxonomy_node srcsubrealm on srcsubrealm.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcsubrealm.name = load_next_msl.srcsubrealm
	 left outer join taxonomy_node srckingdom on srckingdom.msl_release_num=load_next_msl.dest_msl_release_num -1 and srckingdom.name = load_next_msl.srckingdom
	 left outer join taxonomy_node srcsubkingdom on srcsubkingdom.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcsubkingdom.name = load_next_msl.srcsubkingdom
	 left outer join taxonomy_node srcphylum on srcphylum.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcphylum.name = load_next_msl.srcphylum
	 left outer join taxonomy_node srcsubphylum on srcsubphylum.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcsubphylum.name = load_next_msl.srcsubphylum
	 left outer join taxonomy_node srcclass on srcclass.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcclass.name = load_next_msl.srcclass
	 left outer join taxonomy_node srcsubclass on srcsubclass.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcsubclass.name = load_next_msl.srcsubclass
	 left outer join taxonomy_node srcorder on srcorder.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcorder.name = load_next_msl.srcorder
	 left outer join taxonomy_node srcsuborder on srcsuborder.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcsuborder.name = load_next_msl.srcsuborder
	 left outer join taxonomy_node srcfamily on srcfamily.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcfamily.name = load_next_msl.srcfamily
	 left outer join taxonomy_node srcsubfamily on srcsubfamily.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcsubfamily.name = load_next_msl.srcsubfamily
	 left outer join taxonomy_node srcgenus on srcgenus.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcgenus.name = load_next_msl.srcgenus
	 left outer join taxonomy_node srcsubgenus on srcsubgenus.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcsubgenus.name = load_next_msl.srcsubgenus
	 left outer join taxonomy_node srcspecies on srcspecies.msl_release_num=load_next_msl.dest_msl_release_num -1 and srcspecies.name = load_next_msl.srcspecies
) as src 
where len(src.TAXA_NAMES_NOT_FOUND_IN_PREV_MSL) > 0
and src.isWrong IS NULL -- dont list fixed records
order by sort







-- =========================================================================================
-- =========================================================================================
--
-- fix errors
-- 
-- =========================================================================================
-- =========================================================================================

-- 2020.053B.R.Emmerichvirinae.zip
-- remove srcGenus="unassigned"
update load_next_msl set srcGenus = NULL
    -- select sort, srcGenus, *
	from load_next_msl where sort=71243

select genus, ct=count(*)
from taxonomy_node_names 
where genus like 'Lev%virus'
group by genus 


-- 2020.095B.R.Leviviricetes-orig.zip
-- fix typo in srcKingdom: Orth[n]ornavirae => Orthornavirae
-- fix typo in srcGenus: Levi[vi]virus => Levivirus
select * --update load_next_msl set srcKingdom = 'Orthornavirae' 
	from load_next_msl where srcKingdom like 'Orthnornavirae'
select * --update load_next_msl set srcGenus = 'Levivirus' 
	from load_next_msl where srcGenus like 'Levivivirus'


--
-- several records were new species created with typos. 
-- Then a 2nd, corrective, proposal (in the same MSL) renames the species to correct that. 
--
-- we are going to merge those into one record. The following fields will contain two
-- values separated by a **semi-colon**: primary, then fix (and fix2, etc) 
--    proposal_abbrev
--    proposal
-- for the primary record, a comment will be added with the fix.sort. 

-- for the records that 2ndary and Nary records, isWrong will be set to primary.sort, 
-- and a comment will be added. 

-- The 2ndary and N-iary records will then be deleted. 
-- 
-- Action will be that appropriate for the combination of fixes:
--    new + rename = new
--    new + move = new 
--    etc
--

--
-- 48859  NEW     Zhezhang alphacrustrhavirus
-- 130390 RENAME  Zhejiang alphacrustrhavirus
select 
	p='PRIMARY>>',load_next_msl.sort, load_next_msl.proposal_abbrev, load_next_msl.proposal, load_next_msl._action
	,f='FIX>>',             fix.sort,           fix.proposal_abbrev,           fix.proposal,           fix._action
	,m='UPDATE>>',
	-- UPDATE load_next_msl SET 
		-- APPEND comment about fix
		  [comments]     =isnull(load_next_msl.[comments]+'; ','')+'updated (fixed) with sort='+ltrim(fix.sort)+' proposal='+fix.proposal+' comment='+isnull(fix.comments,'') 
		-- CONCATENATE with SEMICOLON
		, proposal_abbrev=load_next_msl.proposal_abbrev+';'+fix.proposal_abbrev
		, proposal       =load_next_msl.proposal+';'+fix.proposal
		-- REPLACE
		, realm          =fix.realm
		, subrealm       =fix.subrealm
		, kingdom        =fix.kingdom
		, subkingdom     =fix.subkingdom
		, phylum         =fix.phylum
		, subphylum      =fix.subphylum
		, class          =fix.class
		, subclass       =fix.subclass
		, [order]        =fix.[order]
		, suborder       =fix.suborder
		, family         =fix.family
		, subfamily      =fix.subfamily
		, genus          =fix.genus
		, subgenus       =fix.subgenus
		, species        =fix.species
	--,a='ALL>>', *
from load_next_msl, load_next_msl fix 
where load_next_msl.sort=48859 and fix.sort=130390
and load_next_msl.proposal not like '%;%'

-- mark fix record as applied
update load_next_msl set isWrong='48859', [comments]=isnull([comments]+'; ','')+'Fixes 48859; records were merged' where sort=130390 and isWrong is null

--QC
select * from load_next_msl where sort in (48859,130390)


--
--  54855 -- NEW     Saphire orthonairovirus
-- 130391 -- RENAME  Sapphire orthonairovirus
--select * from taxonomy_level
select 
	p='PRIMARY>>',load_next_msl.sort, load_next_msl.proposal_abbrev, load_next_msl.proposal, load_next_msl._action, load_next_msl.species
	,f='FIX>>',             fix.sort,           fix.proposal_abbrev,           fix.proposal,           fix._action,           fix.species
	,m='UPDATE>>',
	-- UPDATE load_next_msl SET 
		-- APPEND comment about fix
		  [comments]     =isnull(load_next_msl.[comments]+'; ','')+'updated (fixed) with sort='+ltrim(fix.sort)+' proposal='+fix.proposal+' comment='+isnull(fix.comments,'') 
		-- CONCATENATE with SEMICOLON
		, proposal_abbrev=load_next_msl.proposal_abbrev+';'+fix.proposal_abbrev
		, proposal       =load_next_msl.proposal+';'+fix.proposal
		-- REPLACE
		, realm          =fix.realm
		, subrealm       =fix.subrealm
		, kingdom        =fix.kingdom
		, subkingdom     =fix.subkingdom
		, phylum         =fix.phylum
		, subphylum      =fix.subphylum
		, class          =fix.class
		, subclass       =fix.subclass
		, [order]        =fix.[order]
		, suborder       =fix.suborder
		, family         =fix.family
		, subfamily      =fix.subfamily
		, genus          =fix.genus
		, subgenus       =fix.subgenus
		, species        =fix.species
	--,a='ALL>>', *
from load_next_msl, load_next_msl fix 
where load_next_msl.sort=54855 and fix.sort=130391
and load_next_msl.proposal not like '%;%'
-- mark fix record as applied
update load_next_msl set isWrong='54855', [comments]=isnull([comments]+'; ','')+'Fixes 54855; records were merged' where sort=130391 and isWrong is null

--QC
select * from load_next_msl where sort in (54855,130391)


--
--  29947 -- NEW     Buffalo Creek orhtobunyavirus
-- 130392 -- RENAME  Buffalo Creek orthobunyavirus
--select * from taxonomy_level
select 
	p='PRIMARY>>',load_next_msl.sort, load_next_msl.proposal_abbrev, load_next_msl.proposal, load_next_msl._action, load_next_msl.species
	,f='FIX>>',             fix.sort,           fix.proposal_abbrev,           fix.proposal,           fix._action,           fix.species
	,m='UPDATE>>',
	-- UPDATE load_next_msl SET 
		-- APPEND comment about fix
		  [comments]     =isnull(load_next_msl.[comments]+'; ','')+'updated (fixed) with sort='+ltrim(fix.sort)+' proposal='+fix.proposal+' comment='+isnull(fix.comments,'') 
		-- CONCATENATE with SEMICOLON
		, proposal_abbrev=load_next_msl.proposal_abbrev+';'+fix.proposal_abbrev
		, proposal       =load_next_msl.proposal+';'+fix.proposal
		-- REPLACE
		, realm          =fix.realm
		, subrealm       =fix.subrealm
		, kingdom        =fix.kingdom
		, subkingdom     =fix.subkingdom
		, phylum         =fix.phylum
		, subphylum      =fix.subphylum
		, class          =fix.class
		, subclass       =fix.subclass
		, [order]        =fix.[order]
		, suborder       =fix.suborder
		, family         =fix.family
		, subfamily      =fix.subfamily
		, genus          =fix.genus
		, subgenus       =fix.subgenus
		, species        =fix.species
	--,a='ALL>>', *
from load_next_msl, load_next_msl fix 
where load_next_msl.sort=29947 and fix.sort=130392
and load_next_msl.proposal not like '%;%'
-- mark fix record as applied
update load_next_msl set isWrong='29947', [comments]=isnull([comments]+'; ','')+'Fixes 29947; records were merged' where sort=130392 and isWrong is null

--QC
select * from load_next_msl where sort in (29947,130392)


--  56844 -- NEW     Guadaloupe phasivirus
-- 130393 -- RENAME  Guadeloupe phasivirus 
--
--select * from taxonomy_level
select 
	p='PRIMARY>>',load_next_msl.sort, load_next_msl.proposal_abbrev, load_next_msl.proposal, load_next_msl._action, load_next_msl.species
	,f='FIX>>',             fix.sort,           fix.proposal_abbrev,           fix.proposal,           fix._action,           fix.species
	,m='UPDATE>>',
	-- UPDATE load_next_msl SET 
		-- APPEND comment about fix
		  [comments]     =isnull(load_next_msl.[comments]+'; ','')+'updated (fixed) with sort='+ltrim(fix.sort)+' proposal='+fix.proposal+' comment='+isnull(fix.comments,'') 
		-- CONCATENATE with SEMICOLON
		, proposal_abbrev=load_next_msl.proposal_abbrev+';'+fix.proposal_abbrev
		, proposal       =load_next_msl.proposal+';'+fix.proposal
		-- REPLACE
		, realm          =fix.realm
		, subrealm       =fix.subrealm
		, kingdom        =fix.kingdom
		, subkingdom     =fix.subkingdom
		, phylum         =fix.phylum
		, subphylum      =fix.subphylum
		, class          =fix.class
		, subclass       =fix.subclass
		, [order]        =fix.[order]
		, suborder       =fix.suborder
		, family         =fix.family
		, subfamily      =fix.subfamily
		, genus          =fix.genus
		, subgenus       =fix.subgenus
		, species        =fix.species
	--,a='ALL>>', *
from load_next_msl, load_next_msl fix 
where load_next_msl.sort=56844 and fix.sort=130393
and load_next_msl.proposal not like '%;%'
-- mark fix record as applied
update load_next_msl set isWrong='56844', [comments]=isnull([comments]+'; ','')+'Fixes 56844; records were merged' where sort=130393 and isWrong is null

--QC
select * from load_next_msl where sort in (56844, 130393)


--
-- final QC
--
select sort, iswrong, prev_taxnode_id, srcspecies, species, proposal_abbrev, proposal, comments
from load_next_msl
where cast(sort as int) in (
130390,130391,130392,130393
,
48859,54855,29947,56844
)


--
-- sort=11022
-- action=move species
-- proposal=2020.005B.R.Ackermannviridae.zip
-- ERROR: species name is "Erwinia virus Ea2810", should be "Erwinia virus Ea2809"
update load_next_msl set
	-- SELECT srcSpecies,
	srcSpecies = 'Erwinia virus Ea2809'
from load_next_msl 
where sort=11022 and srcSpecies='Erwinia virus Ea2810'

-- 
-- sort=1216, 
-- action=move subfamily 
-- 2020.001M_014M_015M_016M.R.Rhabdoviridae.zip 
-- ERROR: no previous subfamily named, appears it should be "create subfamily". 
--  Changing and proceeding. 
update load_next_msl set 
	-- SELECT _action,
	_action = 'new'
from load_next_msl 
where sort=1216 and _action='move'

-- 
-- sort=122400, 
-- action=abolish 
-- 2020.169B.R.Tunavirus.zip 
-- ERROR: no prev taxon. Doesn't exist in proposal; remove;
-- 
update load_next_msl set 
	-- SELECT _action,
	isWrong = 'not_in_proposal', comments='not_in_proposal'
from load_next_msl 
where sort=122400 and isWrong is null


--rollback transaction
--commit transaction 