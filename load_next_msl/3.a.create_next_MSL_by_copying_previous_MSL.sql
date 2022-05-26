--
-- create new MSL in taxonomy_node BY copying all nodes from previous MSL
--

DECLARE @msl int;  
DECLARE @tree_id int;
SELECT top 1 @msl=msl_release_num, @tree_id=tree_id from taxonomy_toc order by msl_release_num desc
print 'SET @MSL='+rtrim(@msl)
print 'SET @TREE_ID='+rtrim(@tree_id)

-- 
-- taxonomy_toc and taxonomy_node(root_node) both created previously
--
select rpt='taxonomy_toc  created previously', *
from taxonomy_toc 
where msl_release_num=@msl

select rpt='taxonomy_node (root) created previously', *
from taxonomy_node 
where taxnode_id = @tree_id

-- 
-- copy over non-abolished nodes with a simple offset
--
insert into taxonomy_node ( 
	taxnode_id
	, parent_id
	, tree_id
	, msl_release_num
	, level_id
	, name
	, ictv_id
	, molecule_id
	, abbrev_csv
	, genbank_accession_csv
	, isolate_csv
	, is_ref
	, is_hidden
) s
select 
	-- DEBUG
	-- DECLARE @msl int; SET @msl=36; select  taxonomy_node.tree_id, taxnode_id, parent_id, dx.msl_release_num, dx.tree_id_delta,
	-- ACTUAL
	taxnode_id=taxnode_id+dx.tree_id_delta -- normally 100k, but half that if 2nd MSL in a year
	, parent_id=parent_id+dx.tree_id_delta
	, tree_id = @tree_id
	, msl_release_num = @msl 
	, level_id
	, name
	, ictv_id
	, molecule_id
	, abbrev_csv
	, genbank_accession_csv
	, isolate_csv
	, is_ref
	, is_hidden
from taxonomy_node 
join taxonomy_toc_dx dx on dx.prev_tree_id = taxonomy_node.tree_id
where  taxonomy_node.msl_release_num= (@msl-1)
-- skip stuff already copied
and not exists (select * from taxonomy_node as test where test.taxnode_id = taxonomy_node.taxnode_id+dx.tree_id_delta)
order by left_idx


select report='copied MSL'+rtrim(@msl), level_id, count(*) from taxonomy_node 
where msl_release_num = @msl
group by level_id
