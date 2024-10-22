USE ICTVonline39;

DELIMITER $$

CREATE PROCEDURE linked_ictv_id(IN in_ictv_id INT)
BEGIN
    SELECT in_ictv_id AS ictv_id, 'self' AS source
    UNION
    SELECT final_id AS ictv_id, 'merged to' AS source
    FROM taxonomy_node_merge
    WHERE merged_id = in_ictv_id
    UNION
    SELECT merged_id AS ictv_id, 'merged from' AS source
    FROM taxonomy_node_merge
    WHERE final_id = in_ictv_id;
END $$

DELIMITER ;
