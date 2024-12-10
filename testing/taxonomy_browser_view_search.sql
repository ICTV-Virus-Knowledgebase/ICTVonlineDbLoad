USE ICTVonline39;

-------------------------------------------------------------------------------------------
-- Query that runs when selecting a search result after inputing some search text in the 
-- Taxonomy Browser. In this case the search text was 'monkey'.
-- There were two queries that were captured in SQL profiler when doing this.
-- The 2nd query will be at the bottom.
-------------------------------------------------------------------------------------------

-- Replace these with actual values or declare them in a procedure if needed:
SET @treeID = 202300000;
SET @topLevelRank = 'realm';
SET @preExpandToRank = 'family';

SET @topLevelID = (SELECT id FROM taxonomy_level WHERE name = @topLevelRank LIMIT 1);
SET @preExpandToLevelID = (SELECT id FROM taxonomy_level WHERE name = @preExpandToRank LIMIT 1);

-- First SELECT block
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
    ELSE SUBSTR(tn.name, 1, tn.start_num_sort) 
END,
CASE 
    WHEN tn.start_num_sort IS NULL THEN NULL 
    ELSE FLOOR(TRIM(LEADING ' ' FROM SUBSTR(tn.name, tn.start_num_sort + 1, 50)))
END;

-- Second SELECT block
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
    ELSE SUBSTR(tn.name, 1, tn.start_num_sort)
END,
CASE
    WHEN tn.start_num_sort IS NULL THEN NULL
    ELSE FLOOR(TRIM(LEADING ' ' FROM SUBSTR(tn.name, tn.start_num_sort + 1, 50)))
END;

-- Third SELECT block
SELECT @topLevelID AS top_level_id, @preExpandToLevelID AS pre_expand_to_level_id;


-------------------------------------------------------------------------------------------
-- Second query
-------------------------------------------------------------------------------------------

-- Set your parameters/variables as needed:
SET @topLevelRank = 'realm';
SET @preExpandToRank = 'family';
SET @msl_release_num = 39;
SET @selectedTaxnodeID = 202304771;

-- Derive @treeID, @topLevelID, @preExpandToLevelID, @selectedLevelID, @selectedLeftIdx
-- Assuming a similar logic to SQL Server:
-- @treeID = dbo.udf_getTreeId(39) replacement:
-- If you know the tree_id for MSL=39:
SET @treeID = (SELECT tree_id FROM taxonomy_toc WHERE msl_release_num = @msl_release_num LIMIT 1);

SET @topLevelID = (SELECT id FROM taxonomy_level WHERE name = @topLevelRank LIMIT 1);
SET @preExpandToLevelID = (SELECT id FROM taxonomy_level WHERE name = @preExpandToRank LIMIT 1);

SET @selectedLevelID = (SELECT level_id FROM taxonomy_node WHERE taxnode_id = @selectedTaxnodeID LIMIT 1);
SET @selectedLeftIdx = (SELECT left_idx FROM taxonomy_node WHERE taxnode_id = @selectedTaxnodeID LIMIT 1);

-- Now the main SELECT query:
SELECT 
    parent.level_id AS parent_level_id,
    parent_level.name AS parent_level_name,
    CASE 
        WHEN parent.level_id < @topLevelID THEN 0 
        ELSE 1 
    END AS visible_parent,
    CASE
        WHEN tn.level_id >= @topLevelID AND tn.level_id < @preExpandToLevelID THEN 1
        WHEN tn.level_id >= @preExpandToLevelID
             AND @selectedLeftIdx BETWEEN tn.left_idx AND tn.right_idx
             AND tn.taxnode_id <> @selectedTaxnodeID THEN 1
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
  AND parent.taxnode_id IN (
    SELECT ancestor_node.taxnode_id
    FROM taxonomy_node ancestor_node
    JOIN taxonomy_node target_node ON (
        target_node.left_idx BETWEEN ancestor_node.left_idx AND ancestor_node.right_idx
        AND target_node.tree_id = ancestor_node.tree_id
    )
    WHERE target_node.taxnode_id = @selectedTaxnodeID
      AND ancestor_node.level_id >= @preExpandToLevelID
)
AND tn.level_id <= @selectedLevelID
ORDER BY tn.left_idx,
CASE
    WHEN tn.start_num_sort IS NULL THEN IFNULL(tn.name, 'ZZZZ')
    ELSE SUBSTR(tn.name, 1, tn.start_num_sort)
END,
CASE
    WHEN tn.start_num_sort IS NULL THEN NULL
    ELSE FLOOR(TRIM(LEADING ' ' FROM SUBSTR(tn.name, tn.start_num_sort + 1, 50)))
END;

-- Second SELECT block:
SELECT @topLevelID AS top_level_id,
       @preExpandToLevelID AS pre_expand_to_level_id,
       (
         SELECT ancestor_node.taxnode_id
         FROM taxonomy_node ancestor_node
         JOIN taxonomy_node target_node ON (
             target_node.left_idx BETWEEN ancestor_node.left_idx AND ancestor_node.right_idx
             AND target_node.tree_id = ancestor_node.tree_id
         )
         WHERE target_node.taxnode_id = @selectedTaxnodeID
           AND ancestor_node.level_id >= @preExpandToLevelID
         ORDER BY ancestor_node.level_id ASC
         LIMIT 1
       ) AS parent_taxnode_id,
       @selectedLevelID AS selected_level_id;