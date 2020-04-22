/*
From: Dempsey, Donald M (Campus) <ddempsey@uab.edu> 
Sent: Tuesday, April 21, 2020 6:27 PM
To: Hendrickson, Curtis (Campus) <curtish@uab.edu>; Lefkowitz, Elliot J <elliotl@uab.edu>
Subject: RE: The SQL we discussed

Curtis,

Background info: my 2 UDFs that lookup child taxa counts (results like “2 phyla, 2 classes, 2 orders, 12 families, 47 subfamilies, 690 genera, 2089 species”) are making the query crawl.  What do you think about pre-calculating data like this text (and maybe num_children, next_delta_count, and prev_delta_count) and populating a new table keyed by taxnode_id, then I can just join it in for related queries?

My first thought was that we could add columns to taxonomy_node and write a stored proc to populate them, but I suspect this might interfere with your data pipeline?

Here’s the query with some all-caps annotations in comments:

*/


DECLARE @topLevelRank AS VARCHAR(20) = 'realm';

DECLARE @preExpandToRank AS VARCHAR(20) = 'family';


-- Lookup the ID of the top-level rank.
DECLARE @topLevelID AS int = (SELECT id FROM taxonomy_level WHERE name = @topLevelRank); 

-- Lookup the ID of the rank we will pre-expand to.
DECLARE @preExpandToLevelID AS int = (SELECT id FROM taxonomy_level WHERE name = @preExpandToRank); 

-- THIS IS NOT USED
--DECLARE @maxLevelID AS int = (SELECT MAX(id) FROM taxonomy_level); 


-----------------------------------------------------------------------------------------------------------------------------------
-- Build the query for the pre-expanded taxa.
-----------------------------------------------------------------------------------------------------------------------------------
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
dbo.udf_getChildTaxaCounts(tn.taxnode_id) AS child_count_text, 

tn.[filename], 

-- COMMENT THIS OUT TO SEE SPEED BOOST
dbo.udf_getImmediateChildTaxaCounts(tn.taxnode_id) AS immediate_child_count_text,

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
num_children = (
       SELECT count(*) 
       FROM taxonomy_node ctn 
       WHERE ctn.parent_id = tn.taxnode_id 
),  
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
CASE 
    WHEN tn.start_num_sort IS NULL THEN ISNULL(tn.name, 'ZZZZ') 
    ELSE left(tn.name, tn.start_num_sort) 
END, 
CASE 
    WHEN tn.start_num_sort IS NULL THEN NULL 
    ELSE floor(ltrim(substring(tn.name, tn.start_num_sort + 1, 50))) 
END 


-----------------------------------------------------------------------------------------------------------------------------------
-- Add a query for the sorted, visible, top-level taxa.
-----------------------------------------------------------------------------------------------------------------------------------
SELECT tn.taxnode_id AS taxnode_id 
FROM taxonomy_node tn 
JOIN taxonomy_level tl ON tl.id = tn.level_id 
JOIN taxonomy_node parent ON parent.taxnode_id = tn.parent_id 
WHERE tn.tree_id = dbo.udf_getTreeId(NULL) -- or 35
AND tn.is_hidden = 0 
AND tn.is_deleted = 0 
AND tn.level_id >= @topLevelID 
AND parent.level_id < @topLevelID 
ORDER BY tn.level_id, 
CASE 
       WHEN tn.start_num_sort IS NULL THEN ISNULL(tn.name, 'ZZZZ') 
    ELSE left(tn.name, tn.start_num_sort) 
END, 
CASE 
       WHEN tn.start_num_sort IS NULL THEN NULL 
       ELSE floor(ltrim(substring(tn.name, tn.start_num_sort + 1, 50))) 
END 


-----------------------------------------------------------------------------------------------------------------------------------
-- Add a query to get the level IDs of the top level rank and the rank we will pre-expand to.
-----------------------------------------------------------------------------------------------------------------------------------
SELECT top_level_id = @topLevelID, pre_expand_to_level_id = @preExpandToLevelID 


