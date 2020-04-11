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
-- QC
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