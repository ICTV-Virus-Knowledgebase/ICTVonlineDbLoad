-- --------------------------------------------------------------
-- monitor status during load
-- --------------------------------------------------------------

declare  @new_tree int; set @new_tree = 20170000
declare @prev_tree int; set @prev_tree = @new_tree - 10000

SELECT tab='taxonomy_node', tree_id, LEVEL_id, ct=count(*) 
from taxonomy_node where tree_id=@new_tree 
group by tree_id, level_id
union 
SELECT tab='taxonomy_node', tree_id, level_id=0, ct=count(*) 
from taxonomy_node where tree_id=@new_tree 
group by tree_id

select tab='load_next_msl', dest_tree_id, count(*)
from [load_nexT_msl]
where not (src_lineage is  null and dest_target is null)
group by dest_tree_id

SELECT tab='taxonomy_node', tree_id, out_change, ct=count(*) 
from taxonomy_node where tree_id=@prev_tree 
group by tree_id, out_change
union 
SELECT tab='taxonomy_node', tree_id, out_change='total', ct=count(*) 
from taxonomy_node where tree_id=@prev_tree 
group by tree_id


SELECT tab='taxonomy_node', tree_id, LEVEL_id, ct=count(*) 
from taxonomy_node where tree_id=@prev_tree 
group by tree_id, level_id
union 
SELECT tab='taxonomy_node', tree_id, level_id=0, ct=count(*) 
from taxonomy_node where tree_id=@prev_tree 
group by tree_id

select lvl.id, lvl.name, count((ot.name)) as oldtree, count((nt.name)) as newtree
from taxonomy_level lvl
left outer  join taxonomy_node nt on nt.level_id = lvl.id and nt.tree_id = @new_tree
left outer  join taxonomy_node ot on ot.level_id = lvl.id and ot.tree_id = @prev_tree
group by lvl.id, lvl.name
order by lvl.id

SELECT tab='taxonomy_molecule', *, MESSAGE=case when [taxnode_id] < [load_next_msl] then 'ERROR: some missing!' else '' end 
FROM (
	SELECT m.id, m.abbrev, m.name
		, [taxnode_id]=(select count(*) from taxonomy_node where molecule_id = m.id and msl_release_num = (select max(msl_release_num) from taxonomy_node))
		, [load_next_msl]=(select count(*) from load_next_msl ld where isnull(ld.dest_molecule, ld.src_molecule) = m.name and not ld.src_out_change in ('abolish','merge'))
	from taxonomy_molecule as m

) AS SRC
order by id


/*

select dest_level, count(*) from load_next_msl group by dest_level

select * from taxonomy_node where name = 'Escherichia virus AE2' --taxnode_id in (20154536, 20164528)

*/
