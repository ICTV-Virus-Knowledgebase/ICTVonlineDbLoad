USE ICTVonline39;

DELIMITER $$

CREATE PROCEDURE species_isolates_update_sorts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur_species_name VARCHAR(200);
    DECLARE cur_isolate_id INT;
    DECLARE prev_species_name VARCHAR(200) DEFAULT '';
    DECLARE species_sort INT DEFAULT 0;
    DECLARE isolate_sort INT DEFAULT 1;
    DECLARE mesg VARCHAR(4000);

    DECLARE isolates_cursor CURSOR FOR
        SELECT vmr.isolate_id, vmr.species_name
        FROM species_isolates_alpha_num1_num2 vmr
        JOIN taxonomy_node tn ON tn.taxnode_id = vmr.taxnode_id
        ORDER BY
            tn.left_idx,
            isolate_type DESC,
            _isolate_name_alpha,
            _isolate_name_num1,
            _isolate_name_num2;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT 'updating [species_isolates_update_sorts].[species_sort] and [isolate_sort]' AS info_message;

    OPEN isolates_cursor;

    read_loop: LOOP
        FETCH isolates_cursor INTO cur_isolate_id, cur_species_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF prev_species_name <> cur_species_name THEN
            SET species_sort = species_sort + 1;
            SET isolate_sort = 1;
            SET prev_species_name = cur_species_name;
        ELSE
            SET isolate_sort = isolate_sort + 1;
        END IF;

        UPDATE species_isolates
        SET species_sort = species_sort,
            isolate_sort = isolate_sort
        WHERE isolate_id = cur_isolate_id;

        SET mesg = CONCAT('UPDATE [species_isolates] SET species_sort=', species_sort, ', isolate_sort=', isolate_sort, ' where isolate_id=', cur_isolate_id);
        SELECT mesg AS debug_message;
    END LOOP read_loop;

    CLOSE isolates_cursor;
END$$

DELIMITER ;