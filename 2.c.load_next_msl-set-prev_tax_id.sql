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
	STEP='3. load_next_msl_33 - set prev_tax_id.sql'
	,QC_ERROR='ERROR: prev_taxnode_id=NULL'
	, action=_action
	, * 
from load_next_msl 
where prev_taxnode_id is null
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
		, sort, proposal, spreadsheet, _action, spreadsheet_lineage=_src_lineage, correct_prev_msl_lineage=mapped.lineage, correct_taxnode_id=mapped.taxnode_id
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

select taxnode_id, parent_id, name, level_id from taxonomy_node where name like '%Bunyvirales%' 
or taxnode_id in (201850142,201856221,201850137, 201850001)
order by tree_id desc




-- 
-- fix errors
-- 

-- 2019.054B.Caudovirales_mov4gen_renam2sp.xlsx

select * --update load_next_msl set srcSpecies = 'Salmonella virus HB2014' 
	from load_next_msl where srcSpecies like 'Salmonella virus BH2014' 

-- 2019.006G.Riboviria.xlsx
select * --update load_next_msl set srcFamily = 'Flaviviridae' 
	from load_next_msl where srcFamily like 'Flaviriviridae'

-- 2019.008P.Sadwavirus_3subg.xlsx
select * --update load_next_msl set srcSpecies =		'Dioscorea mosaic associated virus'
	from load_next_msl where srcSpecies like		'Discorea mosaic associated virus'
select * --update load_next_msl set Species =		'Dioscorea mosaic associated virus'
	from load_next_msl where Species like		'Discorea mosaic associated virus'

--2019.009G.Riboviria_corrections.xlsx
select * --update load_next_msl set srcFamily =		'Avsunviroidae'
	from load_next_msl where srcFamily like		'Asunviroidae'
select * --update load_next_msl set Family =		'Avsunviroidae'
	from load_next_msl where Family like		'Asunviroidae'

--
-- Orthopteran densovirus 1
-- search
-- >> Orthopteran miniambidensovirus 1
select * --update load_next_msl set srcSpecies =		'Orthopteran densovirus 1'
	from load_next_msl where srcSpecies like		'Orthoptean densovirus 1'
--select * --update load_next_msl set Species =		'Dioscorea mosaic associated virus'
--	from load_next_msl where Species like		'Orthopteran miniambidensovirus 1'

-- 2019.021M.1newgenus_Hexartovirus.xlsx
-- Riboviria;Negarnaviricota;Haploviricotina;Monjiviricetes;Mononegavirales;Artoviridae;Peropuvirus;Barnacle[s] peropuvirus
select * --update load_next_msl set srcSpecies =		'Balanid hexartovirus', srcSubGenus=NULL
	from load_next_msl where srcSubGenus  like		'Barnacles peropuvirus'
select * --update load_next_msl set srcSpecies =		'Barnacle peropuvirus'
	from load_next_msl where srcSpecies  like	     	'Balanid hexartovirus'
select * --update load_next_msl set Species =		'Barnacle hexartovirus'
	from load_next_msl where Species  like	     	'Balanid hexartovirus'


-- 2019.031M.Nucleorhabdovirus_splitgen.xlsx
-- Riboviria;Mononegavirales;Rhabdoviridae;Nucleorhabdovirus;Sonchus yellow net nucleorhabdovirus  
-- FIX BY IMPROVING WHITE_SPACE removal code earlier in process.
--select replace(srcSpecies,char(160),'X')+']', * --update load_next_msl set srcSpecies =		'Barnacle peropuvirus', srcSubGenus=NULL
--	from load_next_msl where srcSpecies  like		'Sonchus yellow net nucleorhabdovirus '+CHAR(160)

-- 2019.061B.Tubulavirales_1ord1fam19gen.xlsx
select * --update load_next_msl set srcSpecies =		'Propionibacterium virus B5'
	from load_next_msl where srcSpecies  like	     	'Propionobacterium virus B5'
select * --update load_next_msl set Species =		'Propionibacterium virus B5'
	from load_next_msl where Species  like	     	'Propionobacterium virus B5'

-- 2019.090B.Taipeivirus_1gen6sp.xlsx
select * --update load_next_msl set srcSpecies =		'Klebsiella virus 0507KN21'
	from load_next_msl where srcSpecies  like	     	'Klebsiella virus 0507KN2-1'
select * --update load_next_msl set Species =		'Klebsiella virus 0507KN21'
	from load_next_msl where Species  like	     	'Klebsiella virus 0507KN2-1'

-- 2019.099B.Demerecviridae_1fam3subfam6gen.xlsx
select * --update load_next_msl set srcOrder='Caudovirales', srcFamily='Siphoviridae', srcGenus='Jesfedecavirus'
	from load_next_msl where sort like 1347 and (srcOrder is null or srcFamily is null or srcGenus is null)
	

-- 2019.100B.Drexlerviridae_1newfam.xlsx
select * --update load_next_msl set srcGenus='Sertoctavirus'
	from load_next_msl where srcGenus  like  'Seroctavirus'
select * --update load_next_msl set Genus='Sertoctavirus'
	from load_next_msl where Genus  like  'Seroctavirus'
	

-- 2019.059B.Halspiviridae_1fam.xlsx
select * --update load_next_msl set srcSpecies =		'His 1 virus'
	from load_next_msl where srcSpecies  like	     	'Virus His 1'	

--
-- ad hoc searches
--
/*
select rpt='adhoc query', lineage, * 
from taxonomy_node_names 
where 
name like 'Sertoctavirus' --Riboviria;Mononegavirales;Rhabdoviridae;Nucleorhabdovirus;Sonchus yellow net nucleorhabdovirus 
--																												 Sonchus yellow net nucleorhabdovirus  
--																												 Sonchus yellow net nucleorhabdovirus
--and level_id=300
--lineage like 'Riboviria%Asunviroidae%'
order by msl_release_num desc, left_idx

*/
--rollback transaction
--commit transaction 