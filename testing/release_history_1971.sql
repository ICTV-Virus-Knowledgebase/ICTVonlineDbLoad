USE ICTVonline39;

-------------------------------------------------------------------------------------------
-- This query was captured when selecting 1971 on the Release History Page.
-------------------------------------------------------------------------------------------

-- Set these variables as needed
SET @topLevelRank = 'realm';
SET @preExpandToRank = 'family';

-- Derive @treeID from logic that replaces dbo.udf_getTreeId(1).
-- If udf_getTreeId(1) returns a known tree_id, set @treeID = that value directly.
-- Otherwise, if udf_getTreeId(1) means "the tree_id for MSL=1", do:
SET @treeID = (SELECT tree_id FROM taxonomy_toc WHERE msl_release_num = 1 LIMIT 1);

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
SELECT @topLevelID AS top_level_id,
       @preExpandToLevelID AS pre_expand_to_level_id;