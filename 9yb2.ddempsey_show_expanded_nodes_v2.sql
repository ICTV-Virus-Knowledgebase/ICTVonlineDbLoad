/*
 * show expanded nodes 2.0
 */
 DECLARE @topLevelRank AS VARCHAR(20) = 'realm';

DECLARE @preExpandToRank AS VARCHAR(20) = 'family';


-- Lookup the ID of the top-level rank.
DECLARE @topLevelID AS int = (SELECT id FROM taxonomy_level WHERE name = @topLevelRank); 

-- Lookup the ID of the rank we will pre-expand to.
DECLARE @preExpandToLevelID AS int = (SELECT id FROM taxonomy_level WHERE name = @preExpandToRank); 



SELECT 
parent_level_id = parent.level_id, 
parent_level_name = parent_level.name, 

-- Is the parent taxon visible?
visible_parent = CASE 
       WHEN parent.level_id < @topLevelID THEN 0 
       ELSE 1 
END, 

is_expanded = CASE 
    WHEN tn.level_id >= @topLevelID AND tn.level_id < @preExpandToLevelID THEN 1 
    ELSE 0 
END, 

-- COMMENT THIS OUT TO SEE SPEED BOOST
tn.taxa_desc_cts AS child_count_text, 

tn.[filename], 

-- COMMENT THIS OUT TO SEE SPEED BOOST
tn.taxa_kid_cts AS immediate_child_count_text,

-- THIS IS NOT USED
ictvdb_index.info_url AS info_url, 

tn.is_ref AS is_reference, 
tl.name AS level_name, 
tl.id AS level_id,  
tn.lineage, 
next_delta_count = (
       SELECT count(*) 
       FROM taxonomy_node_delta 
       WHERE prev_taxid = tn.taxnode_id 
       AND (tag_csv IS NOT NULL AND tag_csv <> '') 
),  
tn.node_depth, 
num_children = tn._numKids,  
tn.parent_id, 
prev_delta_count = (
       SELECT count(*) 
       FROM taxonomy_node_delta 
       WHERE new_taxid = tn.taxnode_id 
       AND (tag_csv IS NOT NULL AND tag_csv <> '') 
), 
-- THIS IS NOT USED
ictvdb_index.struct_url, 

tn.cleaned_name as taxon_name, 
tn.taxnode_id, 
tn.tree_id 

FROM taxonomy_node tn 
JOIN taxonomy_level tl on tl.id = tn.level_id 

-- THIS JOIN IS UNNECESSARY
LEFT JOIN ictvdb_index ON tn.name = ictvdb_index.name 

JOIN taxonomy_node parent ON parent.taxnode_id = tn.parent_id 
JOIN taxonomy_level parent_level ON parent_level.id = parent.level_id 
WHERE tn.tree_id = dbo.udf_getTreeId(NULL)
AND tn.is_hidden = 0 
AND tn.is_deleted = 0 

-- Constrain by the top level rank and "pre-expand to" rank.
AND tn.level_id >= @topLevelID 
AND parent.level_id < @preExpandToLevelID 

ORDER BY tn.left_idx, 
/*
 * this sorting is already built into left_idx
 *
CASE 
    WHEN tn.start_num_sort IS NULL THEN ISNULL(tn.name, 'ZZZZ') 
    ELSE left(tn.name, tn.start_num_sort) 
END, 
CASE 
    WHEN tn.start_num_sort IS NULL THEN NULL 
    ELSE floor(ltrim(substring(tn.name, tn.start_num_sort + 1, 50))) 
END 
*/
