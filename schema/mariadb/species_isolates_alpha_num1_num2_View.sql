CREATE VIEW `species_isolates_alpha_num1_num2` AS
-- separate [isolate_name] (aka first entry in [alternative_name_csv]) 
-- into base alpha-sort string and numeric sort suffix
SELECT src3.*
FROM (
    SELECT
        src2.*,
        CASE 
            WHEN _isolate_name_num1_str REGEXP '^[0-9]+$' THEN CAST(_isolate_name_num1_str AS DECIMAL(10,2)) 
        END AS _isolate_name_num1,
        CASE 
            WHEN _isolate_name_num2_str REGEXP '^[0-9]+$' THEN CAST(_isolate_name_num2_str AS DECIMAL(10,2)) 
        END AS _isolate_name_num2
    FROM (
        SELECT  
            src.*,
            COALESCE(LEFT(_isolate_name, COALESCE(isolate_start_num1_sort, isolate_start_num2_sort)), _isolate_name) AS _isolate_name_alpha,
            CASE
                WHEN LOCATE(SUBSTRING(_isolate_name, isolate_start_num1_sort + 1, 1), '._-') > 0 
                     AND isolate_start_num2_sort > isolate_start_num1_sort + 1 THEN
                    SUBSTRING(_isolate_name, isolate_start_num1_sort + 2, isolate_start_num2_sort - isolate_start_num1_sort - 2)
                WHEN LOCATE(SUBSTRING(_isolate_name, isolate_start_num1_sort + 1, 1), '._-') = 0 
                     AND isolate_start_num2_sort > isolate_start_num1_sort THEN
                    SUBSTRING(_isolate_name, isolate_start_num1_sort + 1, isolate_start_num2_sort - isolate_start_num1_sort - 1)
            END AS _isolate_name_num1_str,
            CASE
                WHEN LOCATE(SUBSTRING(_isolate_name, isolate_start_num2_sort + 1, 1), '._') > 0 
                     AND isolate_start_num2_sort + 1 < CHAR_LENGTH(_isolate_name) THEN
                    SUBSTRING(_isolate_name, isolate_start_num2_sort + 2, 100)
                WHEN LOCATE(SUBSTRING(_isolate_name, isolate_start_num2_sort + 1, 1), '._') = 0 
                     AND isolate_start_num2_sort < CHAR_LENGTH(_isolate_name) THEN
                    SUBSTRING(_isolate_name, isolate_start_num2_sort + 1, 100)
            END AS _isolate_name_num2_str
        FROM (
            SELECT species_isolates.*,
                CHAR_LENGTH(_isolate_name) - 
                CASE
                    WHEN LOCATE(RIGHT(_isolate_name, 1), '1234567890._-') > 0
                         AND LOCATE(SUBSTRING(RIGHT(_isolate_name, 2), 1, 1), '1234567890._-') > 0 
                         AND LOCATE(SUBSTRING(RIGHT(_isolate_name, 3), 1, 1), '1234567890._-') > 0 THEN 3
                    -- Check for up to the last 10 characters being numeric
                    ELSE NULL
                END AS isolate_start_num1_sort,
                CHAR_LENGTH(_isolate_name) - 
                CASE
                    WHEN LOCATE(RIGHT(_isolate_name, 1), '1234567890.') > 0
                         AND LOCATE(SUBSTRING(RIGHT(_isolate_name, 2), 1, 1), '1234567890.') > 0 THEN 2
                    ELSE NULL
                END AS isolate_start_num2_sort
            FROM species_isolates
        ) AS src
    ) AS src2
) AS src3;
