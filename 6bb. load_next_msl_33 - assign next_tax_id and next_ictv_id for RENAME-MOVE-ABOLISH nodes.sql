--
-- load_new_msl_33 - assign new taxnode_id's
--
BEGIN TRANSACTION

DECLARE @tree_id int; SET @tree_id=20180000
DECLARE @msl int; SET @msl=33

PRINT 'set tree_id '+rtrim(@tree_id)+' and msl_release_num '+rtrim(@msl)

--
-- match up to prev MSL by name, and link
--


update load_next_msl_33 set 
--select srcPrev.taxnode_id, srcNew.taxnode_id, load_next_msl_33.*, 
	prev_taxnode_id = srcPrev.taxnode_id
	,dest_taxnode_id = srcNew.taxnode_id
	,dest_ictv_id = srcNew.ictv_id
from load_next_msl_33
left outer join taxonomy_node srcPrev on srcPrev.msl_release_num=load_next_msl_33.dest_msl_release_num-1 and srcPrev.name= load_next_msl_33._src_taxon_name
left outer join taxonomy_node srcNew  on srcNew.msl_release_num=load_next_msl_33.dest_msl_release_num and srcNew.name= load_next_msl_33._src_taxon_name
where _action NOT in ('new') --and  _dest_taxon_name in ('Mononegavirales','Bunyavirales')
/*and (
prev_taxnode_id is NULL or dest_taxnode_id is nuLL or dest_ictv_id is null
or
prev_taxnode_id <> src.taxnode_id or dest_taxnode_id <> src.taxnode_id+10000 or dest_ictv_id <> src.ictv_id
)
*/


--
-- show what we migth have missed
--
SELECT [ERROR]='Still NULL', * FROM load_next_msl_33 where _action not in ('new')
and  prev_taxnode_id is NULL or dest_taxnode_id is nuLL or dest_ictv_id is null

--ROLLBACK TRANSACTION
COMMIT TRANSACTION
