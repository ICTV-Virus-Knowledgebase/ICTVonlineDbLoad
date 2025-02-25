-- call QC_run_modules('%'); to get all okay records.
-- call QC_run_modules('') or QC_run_modules(NULL) to get all records with errors.

DELIMITER $$

DROP PROCEDURE IF EXISTS QC_run_modules $$

CREATE PROCEDURE QC_run_modules(IN module_filter VARCHAR(200))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE sp_name VARCHAR(200);
    DECLARE sql_statement VARCHAR(255);

    DECLARE qc_module_cursor CURSOR FOR
        SELECT ROUTINE_NAME
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_TYPE = 'PROCEDURE'
          AND ROUTINE_SCHEMA = DATABASE()
          AND ROUTINE_NAME NOT LIKE 'dt_%'
          AND ROUTINE_NAME NOT LIKE 'sp_%diagram%'
          AND ROUTINE_NAME LIKE CONCAT('QC_module_',
              CASE
                  WHEN module_filter IS NULL OR module_filter = '' THEN '%'
                  ELSE module_filter
              END,
              '%')
        ORDER BY ROUTINE_NAME;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN qc_module_cursor;

    read_loop: LOOP
        FETCH qc_module_cursor INTO sp_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF module_filter IS NULL OR module_filter = '' THEN
            SET sql_statement = CONCAT('CALL ', sp_name, '("ERROR%")');
        ELSE
            SET sql_statement = CONCAT('CALL ', sp_name, '("', module_filter, '")');
        END IF;

        SELECT CONCAT('SQL: ', sql_statement) AS debug_output;

        PREPARE stmt FROM sql_statement;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP read_loop;

    CLOSE qc_module_cursor;
END$$

DELIMITER ;