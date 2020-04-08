--
-- hand exit load_next_msl_33 to fix Mononegavirales problems
--



-----------------------------------------------------------------------------------------------------------------------------------
-- new family: add a row to create  'Lispiviridae'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal=proposal
	, [order]=[order]
	, [suborder]= [suborder]
	, family =  'Lispiviridae'
	--, subfamily =subfamily
	--, genus = genus
	--, subgenus=subgenus
	, change = 'new family (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id = (select id from taxonomy_level where name ='family')
from load_next_msl_33
where _dest_taxon_name = 'Xinmoviridae ' -- another a family in the same order

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Lispiviridae' and dest_taxnode_id  is NULL

-----------------------------------------------------------------------------------------------------------------------------------
-- new family: add a row to create  'Lispiviridae'
-- missing from proposal .xlsx
--
insert into load_next_msl_33
(proposal, [order], suborder, family, change, dest_tree_id, dest_msl_release_num, dest_level_id)
select
	proposal=proposal
	, [order]=[order]
	, [suborder]= [suborder]
	, family =  'Artoviridae'
	--, subfamily =subfamily
	--, genus = genus
	--, subgenus=subgenus
	, change = 'new family (omitted from original spreadsheet)' 
	, dest_tree_id
	, dest_msl_release_num
	, dest_level_id = (select id from taxonomy_level where name ='family')
from load_next_msl_33
where _dest_taxon_name = 'Xinmoviridae ' -- another a family in the same order

-- assign a taxnode Id
update load_next_msl_33 set
--select  dest_taxnode_id, dest_ictv_id, 
	dest_taxnode_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
	, dest_ictv_id = (select max(dest_taxnode_id)+1 from load_next_msl_33)
from load_next_msl_33
where _dest_taxon_name ='Artoviridae' and dest_taxnode_id  is NULL
