--
-- hand exit load_next_msl_33 to fix Nidovirales problems
--

-----------------------------------------------------------------------------------------------------------------------------------
-- fixed genus/subgenus name
update load_nexT_msl_33 set --select 
	genus='Deltaarterivirus'	
	, subgenus='Pedartevirus'
from load_next_msl_33 where subgenus like 'Peiartevirus'



-----------------------------------------------------------------------------------------------------------------------------------
-- new subgenus: add a row to create  'Hedartevirus'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, subfamily, genus, subgenus, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal='2017.012_015S.A.v1.Nidovirales'
	, [order]=[order]
	, [suborder]= [suborder]
	, family = family
	, subfamily =subfamily
	, genus = genus
	, subgenus=subgenus
	, change = 'new subgenus (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id = (select id from taxonomy_level where name ='subgenus')
from load_next_msl_33
where _dest_taxon_name = 'Deltaarterivirus hemfev' -- another a species in the subgenus

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Hedartevirus' and dest_taxnode_id  is NULL

-----------------------------------------------------------------------------------------------------------------------------------
-- rename subfamily: add a row to Nidovirales;Coronaviridae;Coronavirinae=>Nidovirale;Cornidovirineae;Coronaviridae;Orthocoronavirinae
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, srcOrder, srcFamily, srcSubFamily, [order], suborder, family, subfamily, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select 
	_src_taxon_name, _src_lineage,
	proposal='2017.012_015S.A.v1.Nidovirales'
	, srcOrder = srcOrder
	,srcFamily = srcFamily
	, srcSubfamily = srcSubfamily
	,[order]=[order]
	, [suborder]= [suborder]
	, family = family
	, subfamily =subfamily
	, change = 'rename subfamily (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id = (select id from taxonomy_level where name ='subfamily')
from load_next_msl_33
where _dest_taxon_name = 'Alphacoronavirus 1' -- another a species in the subfamily

-- assign a taxnode Id - copy from srcTaxon
update load_next_msl_33 set
--select _src_taxon_name, _src_lineage, prev_taxnode_id, dest_taxnode_id, dest_ictv_id, 
	prev_taxnode_id = t.taxnode_id --(select taxnode_id from taxonomy_node where msl_release_num=load_next_msl_33.dest_msl_release_num-1 and name=load_next_msl_33._src_taxon_name)
	,dest_taxnode_id = t.taxnode_id +10000 --(select taxnode_id from taxonomy_node where msl_release_num=load_next_msl_33.dest_msl_release_num-1 and name=load_next_msl_33._src_taxon_name) + 10000
	, dest_ictv_id = t.ictv_id --(select taxnode_id from taxonomy_node where msl_release_num=load_next_msl_33.dest_msl_release_num-1 and name=load_next_msl_33._src_taxon_name)
from load_next_msl_33 
join taxonomy_node t on t.msl_release_num=load_next_msl_33.dest_msl_release_num-1 and t.name=load_next_msl_33._src_taxon_name
where _dest_taxon_name ='Orthocoronavirinae' and prev_taxnode_id  is NULL

select * from taxonomy_node where name='Coronavirinae'


-----------------------------------------------------------------------------------------------------------------------------------
-- new subgenus: add a row to create  'Nyctacovirus'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, subfamily, genus, subgenus, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal='2017.012_015S.A.v1.Nidovirales'
	, [order]=[order]
	, [suborder]= [suborder]
	, family = family
	, subfamily =subfamily
	, genus = genus
	, subgenus='Nyctacovirus'
	, change = 'new subgenus (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id
from load_next_msl_33
where _dest_taxon_name = 'Myotacovirus' -- another new subgenus in same genus

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Nyctacovirus'

-----------------------------------------------------------------------------------------------------------------------------------
-- new subgenus: add a row to create  'Buldecovirus'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, subfamily, genus, subgenus, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal='2017.012_015S.A.v1.Nidovirales'
	, [order]='Nidovirales'
	, [suborder]= 'Cornidovirineae'
	, family = 'Coronaviridae'
	, subfamily ='Orthocoronavirinae'
	, genus = 'Deltacoronavirus'
	, subgenus='Buldecovirus'
	, change = 'new subgenus (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id
from load_next_msl_33
where _dest_taxon_name = 'Moordecovirus' -- another new subgenus in same genus

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Buldecovirus'

-----------------------------------------------------------------------------------------------------------------------------------
-- fix move row for  subfamily 'Torovirinae' (it was promoting a genus to a subfamily, not the desired effect)
-- missing from proposal .xlsx
--
update load_next_msl_33 set
--select *, 
	srcGenus = null
from load_next_msl_33
where _src_lineage = 'Nidovirales;Coronaviridae;Torovirinae;Torovirus' and 
change like '%move subfamily%torovirus%'

-----------------------------------------------------------------------------------------------------------------------------------
-- new genus:  'Sectovirus'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, subfamily, genus, /*subgenus,*/ change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal=proposal
	, [order]=[order]
	, [suborder]= [suborder]
	, family = family
	, subfamily =subfamily
	, genus = 'Sectovirus'
	--, subgenus='Buldecovirus'
	, change = 'new genus (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id  = (select id from taxonomy_level where name ='genus')
from load_next_msl_33
where _dest_taxon_name = 'Infratovirus' -- another new genus in same genus

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Sectovirus'

-----------------------------------------------------------------------------------------------------------------------------------
-- new subgenus: add a row to create  'Sanematovirus'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, subfamily, genus, subgenus, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal=proposal
	, [order]=[order]
	, [suborder]= [suborder]
	, family = family
	, subfamily =subfamily
	, genus = genus
	, subgenus='Sanematovirus'
	, change = 'new subgenus (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id = (select id from taxonomy_level where name ='subgenus')
from load_next_msl_33
where _dest_taxon_name = 'Sectovirus' -- another new subgenus in same genus

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Sanematovirus'

-----------------------------------------------------------------------------------------------------------------------------------
-- new genus:  'Tiruvirus'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, subfamily, genus, /*subgenus,*/ change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal=proposal
	, [order]=[order]
	, [suborder]= [suborder]
	, family = family
	, subfamily =subfamily
	, genus = 'Tiruvirus'
	--, subgenus='Buldecovirus'
	, change = 'new genus (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id= (select id from taxonomy_level where name ='genus')
from load_next_msl_33
where _dest_taxon_name = 'Infratovirus' -- another new genus in same genus

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Tiruvirus'

-----------------------------------------------------------------------------------------------------------------------------------
-- new subgenus: add a row to create  'Tilitovirus'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, subfamily, genus, subgenus, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal=proposal
	, [order]=[order]
	, [suborder]= [suborder]
	, family = family
	, subfamily =subfamily
	, genus = genus
	, subgenus='Tilitovirus'
	, change = 'new subgenus (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id = (select id from taxonomy_level where name ='subgenus')
from load_next_msl_33
where _dest_taxon_name = 'Tiruvirus' -- another new subgenus in same genus

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Tilitovirus'

----------------------------------------------------------------------------------------------------
-- fix exemplar for a new species
--
update load_next_msl_33 set
--select *,
exemplarName = 'Planarian Secretory Cell Nidovirus'
from load_next_msl_33
where _dest_taxon_name = 'Planidovirus 1'
-- set dest_parent_id? NO one else's is set? 
-- next step after that? 
-- did the species in here make it into taxonomy_node? 
-- what fixups are needed.