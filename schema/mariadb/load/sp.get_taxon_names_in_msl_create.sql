DELIMITER $$

DROP PROCEDURE IF EXISTS get_taxon_names_in_msl $$

CREATE PROCEDURE get_taxon_names_in_msl(IN name_param VARCHAR(250), IN msl_param INT)
BEGIN
    SELECT sd.old_msl, sd.old_name, sd.new_count, dest.name
    FROM (
        SELECT 
            *
        FROM (
            SELECT 
                src.msl_release_num AS old_msl,
                src.name AS old_name,
                src.ictv_id AS old_ictv_id,
                dest.msl_release_num AS new_msl,
                COUNT(DISTINCT dest.name) AS new_count,
                CASE WHEN COUNT(DISTINCT dest.name) > 1 THEN 'multiple' ELSE MAX(dest.name) END AS new_name
            FROM taxonomy_node src
            JOIN taxonomy_node_merge_split ms ON ms.prev_ictv_id = src.ictv_id
            JOIN taxonomy_node dest ON dest.ictv_id = ms.next_ictv_id
            WHERE src.name = name_param
                AND dest.msl_release_num = msl_param
                AND ms.rev_count = 0
            GROUP BY src.msl_release_num, src.name, src.ictv_id, dest.msl_release_num
        ) AS grouped_sd
        ORDER BY new_msl DESC, old_msl DESC
        LIMIT 1
    ) AS sd
    JOIN taxonomy_node_merge_split ms ON ms.prev_ictv_id = sd.old_ictv_id
    JOIN taxonomy_node dest ON dest.ictv_id = ms.next_ictv_id
        AND ms.rev_count = 0
        AND dest.msl_release_num = sd.new_msl;
END $$

DELIMITER ;


-- Testing:

-- CALL get_taxon_names_in_msl('Bovine enterovirus', 38)
-- CALL get_taxon_names_in_msl('Bovine enterovirus', 8)