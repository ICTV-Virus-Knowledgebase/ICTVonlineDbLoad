DELIMITER $$

DROP PROCEDURE IF EXISTS rebuild_delta_nodes $$

CREATE PROCEDURE rebuild_delta_nodes(
    IN in_msl INT
)
BEGIN
    DECLARE errorCode INT DEFAULT 50000;
    DECLARE current_msl INT;

    -- If in_msl is null or < 1, set current_msl to max MSL
    IF in_msl IS NULL OR in_msl < 1 THEN
        SELECT IFNULL(MAX(msl_release_num),1) INTO current_msl FROM taxonomy_node;
    ELSE
        SET current_msl = in_msl;
    END IF;

    SELECT CONCAT('TARGET MSL: ', current_msl) AS debug_output;

    -- Delete deltas for this MSL
    DELETE FROM taxonomy_node_delta
    WHERE msl = current_msl;
    SELECT '-- MSL deltas DELETED' AS debug_output;

    -- IN_CHANGE: NEW / SPLIT
    INSERT INTO taxonomy_node_delta (msl, prev_taxid, new_taxid, proposal, notes, is_new, is_split, is_now_type, is_promoted, is_demoted)
    SELECT 
        n.msl_release_num,
        p.taxnode_id,
        n.taxnode_id,
        n.in_filename AS proposal,
        n.in_notes AS notes,
        CASE WHEN n.in_change='new' THEN 1 ELSE 0 END AS is_new,
        CASE WHEN n.in_change='split' THEN 1 ELSE 0 END AS is_split,
        CASE 
            WHEN p.is_ref = 1 AND n.is_ref = 0 THEN -1
            WHEN p.is_ref = 0 AND n.is_ref = 1 THEN 1
            ELSE 0
        END AS is_now_type,
        CASE WHEN p.level_id > n.level_id THEN 1 ELSE 0 END AS is_promoted,
        CASE WHEN p.level_id < n.level_id THEN 1 ELSE 0 END AS is_demoted
    FROM taxonomy_node n
    LEFT JOIN taxonomy_node p ON p.msl_release_num = n.msl_release_num - 1
       AND (n.in_target = p.lineage OR n.in_target = p.name)
    LEFT JOIN taxonomy_node_delta d ON d.new_taxid = n.taxnode_id
    WHERE n.in_change IN ('new','split')
      AND d.new_taxid IS NULL
      AND n.msl_release_num = current_msl
      AND n.is_deleted = 0
    ORDER BY n.taxnode_id, n.msl_release_num, n.lineage;
    SELECT '-- MSL_delta new/split INSERTED' AS debug_output;

    -- OUT_CHANGE: rename, merge, promote, move, abolish
    INSERT INTO taxonomy_node_delta (msl, prev_taxid, new_taxid, proposal, notes, is_renamed, is_merged, is_lineage_updated, is_promoted, is_demoted, is_now_type, is_deleted)
    SELECT
        src.msl,
        src.prev_taxid,
        src.new_taxid,
        src.proposal,
        src.notes,
        CASE WHEN prev_msl.name <> next_msl.name AND src.is_merged=0 THEN 1 ELSE 0 END AS is_renamed,
        src.is_merged,
        CASE WHEN (prev_pmsl.lineage <> next_pmsl.lineage AND (prev_pmsl.level_id<>100 OR next_pmsl.level_id<>100)) THEN 1 ELSE 0 END AS is_lineage_updated,
        CASE WHEN prev_msl.level_id > next_msl.level_id THEN 1 ELSE 0 END AS is_promoted,
        CASE WHEN prev_msl.level_id < next_msl.level_id THEN 1 ELSE 0 END AS is_demoted,
        CASE 
            WHEN prev_msl.is_ref=1 AND next_msl.is_ref=0 THEN -1
            WHEN prev_msl.is_ref=0 AND next_msl.is_ref=1 THEN 1
            ELSE 0
        END AS is_now_type,
        src.is_abolish AS is_deleted
    FROM (
        SELECT DISTINCT
            p.msl_release_num+1 AS msl,
            p.taxnode_id AS prev_taxid,
            CASE
                WHEN p.out_change <> 'promote' AND p.level_id > targ.level_id AND targ_child.taxnode_id IS NOT NULL THEN targ_child.taxnode_id
                WHEN p.level_id=500 AND targ.level_id=600 AND p.name <> 'Unassigned' THEN targ.parent_id
                ELSE targ.taxnode_id
            END AS new_taxid,
            p.out_filename AS proposal,
            CAST(p.out_notes AS CHAR(200)) AS notes,
            CASE WHEN p.out_change='merge' THEN 1 ELSE 0 END AS is_merged,
            CASE WHEN p.out_change='abolish' THEN 1 ELSE 0 END AS is_abolish
        FROM taxonomy_node p
        LEFT JOIN taxonomy_node targ ON p.msl_release_num = targ.msl_release_num-1
           AND (p.out_target = targ.lineage OR p.out_target = targ.name OR p._out_target_name = targ.name)
           AND p.is_deleted=0
        LEFT JOIN taxonomy_node targ_child ON 
             targ_child.parent_id = targ.taxnode_id
             AND (targ_child.name = p.name OR targ_child.name = p.out_target)
             AND targ_child.level_id = p.level_id
             AND p.out_change <> 'promote'
             AND targ_child.name <> 'Unassigned'
             AND targ_child.name IS NOT NULL
             AND targ_child.is_hidden = 0
        LEFT JOIN taxonomy_node_delta d ON d.prev_taxid = p.taxnode_id
        WHERE p.out_change IS NOT NULL
          AND p.msl_release_num = (current_msl-1)
          AND d.prev_taxid IS NULL
    ) src
    JOIN taxonomy_node prev_msl ON prev_msl.taxnode_id = src.prev_taxid
    JOIN taxonomy_node prev_pmsl ON prev_pmsl.taxnode_id = prev_msl.parent_id
    LEFT JOIN taxonomy_node next_msl ON next_msl.taxnode_id = src.new_taxid
    LEFT JOIN taxonomy_node next_pmsl ON next_pmsl.taxnode_id = next_msl.parent_id;

    SELECT '-- MSL_delta OUT_CHANGE: rename, merge, promote, move, abolish INSERTED' AS debug_output;

    -- NO CHANGE
    INSERT INTO taxonomy_node_delta (msl,prev_taxid, new_taxid, proposal, notes, is_lineage_updated, is_promoted, is_demoted, is_now_type)
    SELECT 
        n.msl_release_num,
        p.taxnode_id,
        n.taxnode_id,
        p.out_filename,
        p.out_notes,
        CASE WHEN pp.lineage <> pn.lineage AND pp.level_id<>100 THEN 1 ELSE 0 END,
        CASE WHEN p.level_id > n.level_id THEN 1 ELSE 0 END,
        CASE WHEN p.level_id < n.level_id THEN 1 ELSE 0 END,
        CASE 
            WHEN p.is_ref=1 AND n.is_ref=0 THEN -1
            WHEN p.is_ref=0 AND n.is_ref=1 THEN 1
            ELSE 0
        END
    FROM taxonomy_node p
    JOIN taxonomy_node n ON n.msl_release_num = p.msl_release_num + 1
       AND (
          n.lineage = p.lineage
          OR (n.name = p.name AND n.name<>'Unassigned' AND n.level_id=p.level_id)
          OR (n.level_id=100 AND p.level_id=100)
       )
       AND ((p.is_hidden=0 AND n.is_hidden=0) OR (n.level_id=100 AND p.level_id=100))
    LEFT JOIN taxonomy_node_delta pd ON pd.prev_taxid = p.taxnode_id AND pd.is_split=0
    LEFT JOIN taxonomy_node_delta nd ON nd.new_taxid = n.taxnode_id AND nd.is_merged=0
    JOIN taxonomy_node pp ON pp.taxnode_id = p.parent_id
    JOIN taxonomy_node pn ON pn.taxnode_id = n.parent_id
    WHERE n.msl_release_num=current_msl
      AND pd.prev_taxid IS NULL AND nd.new_taxid IS NULL
      AND p.is_deleted=0 AND n.is_deleted=0
    ORDER BY p.name, p.msl_release_num;
    SELECT '-- MSL_delta NO_CHANGE: INSERTED' AS debug_output;

    -- MOVED
    UPDATE taxonomy_node_delta d
    JOIN taxonomy_node_names prev_node ON d.prev_taxid=prev_node.taxnode_id
    JOIN taxonomy_node prev_parent ON prev_parent.taxnode_id=prev_node.parent_id
    JOIN taxonomy_node_names next_node ON next_node.taxnode_id=d.new_taxid
    JOIN taxonomy_node next_parent ON next_parent.taxnode_id=next_node.parent_id
    LEFT JOIN taxonomy_node_delta parent_delta ON parent_delta.prev_taxid=prev_parent.taxnode_id AND parent_delta.new_taxid=next_parent.taxnode_id
    SET d.is_moved =
        (CASE WHEN prev_parent.ictv_id <> next_parent.ictv_id THEN 1 ELSE 0 END)
        * (CASE WHEN prev_node.out_change LIKE '%promot%' THEN 0 ELSE 1 END)
        * (CASE WHEN next_node.out_change LIKE '%demot%' THEN 0 ELSE 1 END)
        * (CASE WHEN parent_delta.is_merged=1 THEN (CASE WHEN prev_parent.name<>next_parent.name THEN 1 ELSE 0 END) ELSE 1 END)
        * (CASE WHEN parent_delta.is_split=1 THEN (CASE WHEN prev_parent.name<>next_parent.name THEN 1 ELSE 0 END) ELSE 1 END)
        * (CASE WHEN prev_parent.level_id=100 AND next_parent.level_id=100 THEN 0 ELSE 1 END)
    WHERE prev_node.msl_release_num+1=current_msl
      AND (
         prev_node.out_change LIKE '%move%'
         OR (parent_delta.is_merged=1 AND prev_parent.name<>next_parent.name)
         OR (parent_delta.is_split=1 AND prev_parent.name<>next_parent.name)
         OR prev_parent.ictv_id<>next_parent.ictv_id
      );
    SELECT '-- MSL_delta IS_MOVED: UPDATED' AS debug_output;

    SELECT msl, IF(tag_csv='', 'UNCHANGED', tag_csv) AS change_type, COUNT(*) AS counts
    FROM taxonomy_node_delta
    WHERE msl = current_msl
    GROUP BY msl, tag_csv
    ORDER BY msl, tag_csv;
    SELECT '-- MSL_delta stats' AS debug_output;

    SELECT msl, IF(tag_csv2='', 'UNCHANGED', tag_csv2) AS change_type, COUNT(*) AS counts
    FROM taxonomy_node_delta
    WHERE msl = current_msl
    GROUP BY msl, tag_csv2
    ORDER BY msl, tag_csv2;
    SELECT '-- MSL_delta stats2' AS debug_output;

END$$

DELIMITER ;