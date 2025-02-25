USE ICTVonline39;

DELIMITER $$

CREATE PROCEDURE rebuild_node_merge_split()
BEGIN
    -- Truncate the table
    TRUNCATE TABLE taxonomy_node_merge_split;

    -- Add forward links
    INSERT INTO taxonomy_node_merge_split
    SELECT p.ictv_id AS prev_ictv_id, n.ictv_id AS next_ictv_id,
           d.is_merged, d.is_split, 1 AS dist, 0 AS rev_count
    FROM taxonomy_node_delta d
    JOIN taxonomy_node p ON d.prev_taxid = p.taxnode_id
    JOIN taxonomy_node n ON d.new_taxid = n.taxnode_id
    WHERE p.level_id > 100 AND n.level_id > 100
      AND p.ictv_id <> n.ictv_id
      AND p.msl_release_num = n.msl_release_num - 1
      AND p.is_hidden = 0 AND n.is_hidden = 0;

    -- Add identities
    INSERT INTO taxonomy_node_merge_split (prev_ictv_id, next_ictv_id, is_merged, is_split, dist, rev_count)
    SELECT ictv_id, ictv_id, 0, 0, 0, 0
    FROM taxonomy_node
    WHERE msl_release_num IS NOT NULL
      AND is_hidden = 0
    GROUP BY ictv_id;

    -- Add reverse links
    INSERT INTO taxonomy_node_merge_split
    SELECT n.ictv_id AS prev_ictv_id, p.ictv_id AS next_ictv_id,
           d.is_merged, d.is_split, 1 AS dist, 1 AS rev_count
    FROM taxonomy_node_delta d
    JOIN taxonomy_node p ON d.prev_taxid = p.taxnode_id
    JOIN taxonomy_node n ON d.new_taxid = n.taxnode_id
    WHERE p.level_id > 100 AND n.level_id > 100
      AND p.ictv_id <> n.ictv_id
      AND p.msl_release_num = n.msl_release_num - 1
      AND p.is_hidden = 0 AND n.is_hidden = 0;

    SELECT 'start closure' AS start_closure;

    -- Closure computation
    DECLARE rows_affected INT DEFAULT 1;

    WHILE rows_affected > 0 DO
        INSERT INTO taxonomy_node_merge_split
        SELECT src.prev_ictv_id, src.next_ictv_id,
               MAX(src.is_merged) AS is_merged, MAX(src.is_split) AS is_split,
               MIN(src.dist) AS dist, SUM(src.rev_count) AS rev_count
        FROM (
            SELECT p.prev_ictv_id, n.next_ictv_id,
                   (p.is_merged + n.is_merged) AS is_merged,
                   (p.is_split + n.is_split) AS is_split,
                   (p.dist + n.dist) AS dist,
                   (p.rev_count + n.rev_count) AS rev_count
            FROM taxonomy_node_merge_split p
            JOIN taxonomy_node_merge_split n ON p.next_ictv_id = n.prev_ictv_id
            WHERE p.dist > 0 AND n.dist > 0
        ) src
        GROUP BY src.prev_ictv_id, src.next_ictv_id
        HAVING NOT EXISTS (
            SELECT * 
            FROM taxonomy_node_merge_split cur
            WHERE cur.prev_ictv_id = src.prev_ictv_id
              AND cur.next_ictv_id = src.next_ictv_id
        );

        SET rows_affected = ROW_COUNT();
    END WHILE;

    SELECT 'closure done' AS closure_done;

    -- Optional testing SELECTs can remain, or be removed if not needed.
    -- SELECT 'TEST', * FROM taxonomy_node_merge_split WHERE prev_ictv_id = 19710158;
    -- SELECT 'TEST', * FROM taxonomy_node_merge_split WHERE next_ictv_id = 19710158;
    -- SELECT 'TEST', * FROM taxonomy_node_merge_split WHERE prev_ictv_id = 20093515;
    -- SELECT 'TEST', * FROM taxonomy_node_merge_split WHERE next_ictv_id = 20093515;

END$$

DELIMITER ;