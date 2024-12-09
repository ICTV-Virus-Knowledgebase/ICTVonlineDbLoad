USE ICTVonline39;

--------------------------------------------------------------------------------------
-- lrm 12-4-2024
-- This query was captured on sql server profiler when the app was first opened.
-- It was then converted to mariadb. The original sql server version is at the bottom.
--------------------------------------------------------------------------------------

-- Set parameters
SET @topLevelRank = 'realm';
SET @preExpandToRank = 'realm';

-- Set variables
SET @treeID = udf_getTreeId(39);
SET @topLevelID = (SELECT id FROM taxonomy_level WHERE name = @topLevelRank);
SET @preExpandToLevelID = (SELECT id FROM taxonomy_level WHERE name = @preExpandToRank);

-- First SELECT query
SELECT 
    parent.level_id AS parent_level_id,
    parent_level.name AS parent_level_name,
    CASE 
        WHEN parent.level_id < @topLevelID THEN 0 
        ELSE 1 
    END AS visible_parent,
    CASE 
        WHEN tn.level_id >= @topLevelID AND tn.level_id < @preExpandToLevelID THEN 1 
        ELSE 0 
    END AS is_expanded,
    tn.taxa_desc_cts AS child_count_text,
    tn.filename,
    tn.taxa_kid_cts AS immediate_child_count_text,
    tn.is_ref AS is_reference,
    tl.name AS level_name,
    tl.id AS level_id,
    tn.lineage,
    (
        SELECT COUNT(*) 
        FROM taxonomy_node_delta 
        WHERE prev_taxid = tn.taxnode_id 
        AND (tag_csv IS NOT NULL AND tag_csv <> '')
    ) AS next_delta_count,
    tn.node_depth,
    tn._numKids AS num_children,
    tn.parent_id,
    (
        SELECT COUNT(*) 
        FROM taxonomy_node_delta 
        WHERE new_taxid = tn.taxnode_id 
        AND (tag_csv IS NOT NULL AND tag_csv <> '')
    ) AS prev_delta_count,
    tn.cleaned_name AS taxon_name,
    tn.taxnode_id,
    tn.tree_id
FROM taxonomy_node tn
JOIN taxonomy_level tl ON tl.id = tn.level_id
JOIN taxonomy_node parent ON parent.taxnode_id = tn.parent_id
JOIN taxonomy_level parent_level ON parent_level.id = parent.level_id
WHERE tn.tree_id = @treeID
AND tn.is_hidden = 0
AND tn.is_deleted = 0
AND tn.level_id >= @topLevelID
AND parent.level_id < @preExpandToLevelID
ORDER BY tn.left_idx,
    CASE 
        WHEN tn.start_num_sort IS NULL THEN IFNULL(tn.name, 'ZZZZ') 
        ELSE LEFT(tn.name, tn.start_num_sort) 
    END,
    CASE 
        WHEN tn.start_num_sort IS NULL THEN NULL 
        ELSE FLOOR(LTRIM(SUBSTRING(tn.name, tn.start_num_sort + 1, 50))) 
    END;

-- Second SELECT query
SELECT tn.taxnode_id AS taxnode_id
FROM taxonomy_node tn
JOIN taxonomy_level tl ON tl.id = tn.level_id
JOIN taxonomy_node parent ON parent.taxnode_id = tn.parent_id
WHERE tn.tree_id = @treeID
AND tn.is_hidden = 0
AND tn.is_deleted = 0
AND tn.level_id >= @topLevelID
AND parent.level_id < @topLevelID
ORDER BY tn.level_id,
    CASE 
        WHEN tn.start_num_sort IS NULL THEN IFNULL(tn.name, 'ZZZZ') 
        ELSE LEFT(tn.name, tn.start_num_sort) 
    END,
    CASE 
        WHEN tn.start_num_sort IS NULL THEN NULL 
        ELSE FLOOR(LTRIM(SUBSTRING(tn.name, tn.start_num_sort + 1, 50))) 
    END;

-- Third SELECT query
SELECT @topLevelID AS top_level_id, @preExpandToLevelID AS pre_expand_to_level_id;


--------------------------------------------------------------------------------------
-- sql server version --
--------------------------------------------------------------------------------------

-- exec sp_executesql N'DECLARE @treeID AS INT = dbo.udf_getTreeId(39); DECLARE @topLevelID AS int = (SELECT id FROM taxonomy_level WHERE name = @topLevelRank); 
-- DECLARE @preExpandToLevelID AS int = (SELECT id FROM taxonomy_level WHERE name = @preExpandToRank); 
-- SELECT 
-- parent_level_id = parent.level_id, 
-- parent_level_name = parent_level.name, 
-- visible_parent = CASE 
-- 	WHEN parent.level_id < @topLevelID THEN 0 
-- 	ELSE 1 
-- END, 
-- is_expanded = CASE 
--     WHEN tn.level_id >= @topLevelID AND tn.level_id < @preExpandToLevelID THEN 1 
--     ELSE 0 
-- END, 
-- tn.taxa_desc_cts AS child_count_text, 
-- tn.[filename], 
-- tn.taxa_kid_cts AS immediate_child_count_text, 
-- tn.is_ref AS is_reference, 
-- tl.name AS level_name, 
-- tl.id AS level_id,  
-- tn.lineage, 
-- next_delta_count = (
-- 	SELECT count(*) 
-- 	FROM taxonomy_node_delta 
-- 	WHERE prev_taxid = tn.taxnode_id 
-- 	AND (tag_csv IS NOT NULL AND tag_csv <> '''') 
-- ),  
-- tn.node_depth, 
-- num_children = tn._numKids, 
-- tn.parent_id, 
-- prev_delta_count = (
-- 	SELECT count(*) 
-- 	FROM taxonomy_node_delta 
-- 	WHERE new_taxid = tn.taxnode_id 
-- 	AND (tag_csv IS NOT NULL AND tag_csv <> '''') 
-- ), 
-- tn.cleaned_name as taxon_name, 
-- tn.taxnode_id, 
-- tn.tree_id 
-- FROM taxonomy_node tn 
-- JOIN taxonomy_level tl on tl.id = tn.level_id 

-- JOIN taxonomy_node parent ON parent.taxnode_id = tn.parent_id 
-- JOIN taxonomy_level parent_level ON parent_level.id = parent.level_id 
-- WHERE tn.tree_id = @treeID 
-- AND tn.is_hidden = 0 
-- AND tn.is_deleted = 0 
-- AND tn.level_id >= @topLevelID 
-- AND parent.level_id < @preExpandToLevelID 
-- ORDER BY tn.left_idx, 
-- CASE 
--     WHEN tn.start_num_sort IS NULL THEN ISNULL(tn.name, ''ZZZZ'') 
--     ELSE left(tn.name, tn.start_num_sort) 
-- END, 
-- CASE 
--     WHEN tn.start_num_sort IS NULL THEN NULL 
--     ELSE floor(ltrim(substring(tn.name, tn.start_num_sort + 1, 50))) 
-- END 
-- SELECT tn.taxnode_id AS taxnode_id 
-- FROM taxonomy_node tn 
-- JOIN taxonomy_level tl ON tl.id = tn.level_id 
-- JOIN taxonomy_node parent ON parent.taxnode_id = tn.parent_id 
-- WHERE tn.tree_id = @treeID 
-- AND tn.is_hidden = 0 
-- AND tn.is_deleted = 0 
-- AND tn.level_id >= @topLevelID 
-- AND parent.level_id < @topLevelID 
-- ORDER BY tn.level_id, 
-- CASE 
-- 	WHEN tn.start_num_sort IS NULL THEN ISNULL(tn.name, ''ZZZZ'') 
--     ELSE left(tn.name, tn.start_num_sort) 
-- END, 
-- CASE 
-- 	WHEN tn.start_num_sort IS NULL THEN NULL 
-- 	ELSE floor(ltrim(substring(tn.name, tn.start_num_sort + 1, 50))) 
-- END 
-- SELECT top_level_id = @topLevelID, pre_expand_to_level_id = @preExpandToLevelID 
-- ',N'@topLevelRank varchar(5),@preExpandToRank varchar(5)',@topLevelRank='realm',@preExpandToRank='realm'

