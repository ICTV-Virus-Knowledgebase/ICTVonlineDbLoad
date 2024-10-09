CREATE VIEW `taxonomy_node_changes` AS
/*
 * All ictv_ids in all MSL, with in/out change lists.
 * To be used to generate a history grid in R or elsewhere.
 */

SELECT *
FROM (
    SELECT 
        bone.*,
        
        -- Change going out (next_tag)
        (SELECT GROUP_CONCAT(ct_tag SEPARATOR '|') 
         FROM (
             SELECT 
                 d.prev_taxid AS id,
                 CONCAT(
                    LEFT(tag_csv_min, CASE WHEN tag_csv_min = '' THEN 1 ELSE LENGTH(tag_csv_min) - 1 END),
                    CASE WHEN COUNT(*) > 1 THEN CONCAT('(N=', RTRIM(COUNT(*)), ')') ELSE '' END
                 ) AS ct_tag
             FROM taxonomy_node_delta d
             WHERE d.prev_taxid = n.taxnode_id
             GROUP BY d.prev_taxid, d.tag_csv_min
             ORDER BY d.tag_csv_min
             LIMIT 500
         ) AS tags 
         GROUP BY id
        ) AS next_tag,
        
        -- Count of outgoing changes (next_tag_ct)
        (SELECT COUNT(tag_csv) 
         FROM taxonomy_node_delta d
         WHERE d.prev_taxid = n.taxnode_id 
         GROUP BY d.prev_taxid
        ) AS next_tag_ct,
        
        -- MSL data
        n.left_idx AS left_idx,
        n.taxnode_id AS taxnode_id,
        n.rank AS rank,
        n.name AS name,
        
        -- Change coming in (prev_tag)
        (SELECT REPLACE(
                GROUP_CONCAT(ct_tag SEPARATOR '|'),
                ',(','('
            )
         FROM (
             SELECT 
                 d.new_taxid AS id,
                 CONCAT(
                    LEFT(tag_csv_min, CASE WHEN tag_csv_min = '' THEN 1 ELSE LENGTH(tag_csv_min) - 1 END),
                    CASE WHEN COUNT(*) > 1 THEN CONCAT('(N=', RTRIM(COUNT(*)), ')') ELSE '' END
                 ) AS ct_tag
             FROM taxonomy_node_delta d
             WHERE d.new_taxid = n.taxnode_id
             GROUP BY d.new_taxid, d.tag_csv_min
             ORDER BY d.tag_csv_min
             LIMIT 500
         ) AS tags 
         GROUP BY id
        ) AS prev_tag,
        
        -- Count of incoming changes (prev_tag_ct)
        (SELECT COUNT(tag_csv) 
         FROM taxonomy_node_delta d
         WHERE d.new_taxid = n.taxnode_id 
         GROUP BY d.new_taxid
        ) AS prev_tag_ct
        
    FROM (
        -- All IDs and MSLs
        SELECT 
            ids.ictv_id,
            msl.msl
        FROM (
            -- Get all distinct ictv_ids
            SELECT ictv_id
            FROM taxonomy_node_names
            WHERE msl IS NOT NULL
            GROUP BY ictv_id
        ) AS ids,
        (
            -- Get all distinct MSLs
            SELECT msl_release_num AS msl
            FROM taxonomy_toc
            WHERE msl_release_num IS NOT NULL
            GROUP BY msl_release_num
        ) AS msl
    ) AS bone
    LEFT OUTER JOIN taxonomy_node_names n 
        ON n.msl_release_num = bone.msl AND n.ictv_id = bone.ictv_id
    GROUP BY bone.msl, bone.ictv_id, n.taxnode_id, n.left_idx, n.rank, n.name
) AS src;
