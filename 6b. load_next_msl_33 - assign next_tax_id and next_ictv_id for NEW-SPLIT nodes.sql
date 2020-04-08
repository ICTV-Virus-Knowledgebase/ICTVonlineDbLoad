--
-- load_new_msl_33 - assign new taxnode_id's
--
BEGIN TRANSACTION

DECLARE @tree_id int; SET @tree_id=20180000
DECLARE @msl int; SET @msl=33
DECLARE @next_taxnode_id int; SET @next_taxnode_id = (select max(taxnode_id+1) from taxonomy_node where msl_release_num=@msl)

PRINT 'set tree_id '+rtrim(@tree_id)+' and msl_release_num '+rtrim(@msl)

-- clean out parents - we're about to assign new ids
update load_next_msl_33 set
	dest_parent_id = NULL

-- make sure tree and msl are correct
update load_next_msl_33 set
	dest_tree_id = @tree_id
	, dest_msl_release_num = @msl

PRINT ''
PRINT 'Starting taxnode ID: '+rtrim(@next_taxnode_id)

-- cursor to assign IDs?

SET NOCOUNT ON
DECLARE @dest_taxnode_id int


DECLARE UP_CURSOR CURSOR FOR
SELECT @dest_taxnode_id FROM load_next_msl_33 WHERE dest_taxnode_id is null and _action in ('new', 'split') FOR UPDATE OF dest_taxnode_id
OPEN UP_CURSOR
FETCH NEXT FROM UP_CURSOR INTO @dest_taxnode_id

WHILE(@@FETCH_STATUS=0)
BEGIN
	UPDATE load_next_msl_33 SET dest_taxnode_id = @next_taxnode_id WHERE CURRENT OF UP_CURSOR

	-- NEXT
	SET @next_taxnode_id =@next_taxnode_id + 1
	FETCH NEXT FROM UP_CURSOR INTO @dest_taxnode_id
END

CLOSE UP_CURSOR
DEALLOCATE UP_CURSOR

SET NOCOUNT OFF

--
-- replicate that into next_ictv_id
--
update load_next_msl_33 set
--select 
	dest_ictv_id=dest_taxnode_id
from load_next_msl_33
where _action in ('new','split')
and dest_ictv_id is NULL


--
-- show what we did
--
SELECT * FROM load_next_msl_33 where _action in ('new','split')

--ROLLBACK TRANSACTION
COMMIT TRANSACTION

