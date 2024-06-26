/****** example nested set queries, applied to this year's taxonomy  ******/
SELECT  'top levels of 2021 taxonomy tree', msl_release_num, taxnode_id, n.parent_id, level_id, ictv_id, rnk.name, lineage, left_idx, right_idx, sub_node_count= _numKids
  FROM [ICTVonline37].[dbo].[taxonomy_node] n
  left outer join taxonomy_level rnk on rnk.id = level_id
  where tree_id=202100000
   -- show only 
  and level_id <= 160
  order by left_idx


SELECT 'descendents of Adnaviria;Zilligvirae;Taleaviricota',  msl_release_num, taxnode_id, n.parent_id, level_id, ictv_id, rnk.name, lineage, left_idx, right_idx, _numKids
  FROM [ICTVonline37].[dbo].[taxonomy_node] n
  left outer join taxonomy_level rnk on rnk.id = level_id
  where tree_id=202100000
  and left_idx between  4 and  107
  order by left_idx




 SELECT 'ancestors of Adnaviria;Zilligvirae;Taleaviricota',  msl_release_num, taxnode_id, n.parent_id, level_id, ictv_id, rnk.name, lineage, left_idx, right_idx,  _numKids
  FROM [ICTVonline37].[dbo].[taxonomy_node] n
  left outer join taxonomy_level rnk on rnk.id = level_id
  where tree_id=202100000
  and left_idx < 4 and right_idx >  107
  order by left_idx
