--
-- load_new_msl - assign new taxnode_id's
--
BEGIN TRANSACTION
--COMMIT TRANSACTION
--ROLLBACK TRANSACTION

DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl)
DECLARE @tree_id int; SET @tree_id=(select tree_id from taxonomy_toc where msl_release_num=@msl)
DECLARE @next_taxnode_id int; SET @next_taxnode_id = (select max(taxnode_id+1) from taxonomy_node where msl_release_num=@msl)

PRINT 'set tree_id '+rtrim(@tree_id)+' and msl_release_num '+rtrim(@msl)+'; next taxnode_id='+rtrim(@next_taxnode_id)

--
-- match up to prev MSL by name, and link
--


--update load_next_msl set 
select srcPrev.taxnode_id, srcNew.taxnode_id, load_next_msl.*, 
	prev_taxnode_id = srcPrev.taxnode_id
	,dest_taxnode_id = srcNew.taxnode_id
	,dest_ictv_id = srcNew.ictv_id
from load_next_msl
left outer join taxonomy_node srcPrev on srcPrev.msl_release_num=load_next_msl.dest_msl_release_num-1 and srcPrev.name= load_next_msl._src_taxon_name
left outer join taxonomy_node srcNew  on srcNew.msl_release_num=load_next_msl.dest_msl_release_num and srcNew.name= load_next_msl._src_taxon_name
where isWrong is null
AND _action NOT in ('new') --and  _dest_taxon_name in ('Mononegavirales','Bunyavirales')
and (
prev_taxnode_id is NULL or dest_taxnode_id is nuLL or dest_ictv_id is null
or
prev_taxnode_id <> srcPrev.taxnode_id or dest_taxnode_id <> srcPrev.taxnode_id+201850000-20180000 or dest_ictv_id <> srcPrev.ictv_id
)

--
-- show what we migth have missed
--
SELECT [ERROR]='Still NULL', * FROM load_next_msl_33 where _action not in ('new')
and  prev_taxnode_id is NULL or dest_taxnode_id is nuLL or dest_ictv_id is null

--ROLLBACK TRANSACTION
--COMMIT TRANSACTION
