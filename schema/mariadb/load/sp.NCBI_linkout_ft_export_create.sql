DELIMITER $$

DROP PROCEDURE IF EXISTS NCBI_linkout_ft_export $$

CREATE PROCEDURE NCBI_linkout_ft_export(
    IN in_msl INT DEFAULT NULL,
    IN in_newline VARCHAR(10) DEFAULT '|'
)
BEGIN
    DECLARE URL VARCHAR(500);
    DECLARE LINKOUT_PROVIDER_ID VARCHAR(10);
    DECLARE newline_str VARCHAR(10);

    SET LINKOUT_PROVIDER_ID = '7640';
    SET URL = 'https://ictv.global/taxonomy/taxondetails?taxnode_id=';

    -- Get the most recent MSL if not specified
    IF in_msl IS NULL THEN
        SELECT IFNULL(MAX(msl_release_num),1) INTO in_msl FROM taxonomy_node;
    END IF;

    -- If newline is NULL or not provided, default to Windows style CR+LF
    IF in_newline IS NULL OR in_newline = '' THEN
        SET newline_str = CONCAT(CHAR(13), CHAR(10)); -- Windows line endings
    ELSE
        SET newline_str = in_newline;
    END IF;

    -- Now we produce the output using a SELECT
    -- We replicate the union logic by using a subquery union.

    SELECT t AS `# linkout.ft`
    FROM
    (
        -- Header section
        SELECT 
          CONCAT(
            '---------------------------------------------------------------', newline_str,
            'prid:   ', LINKOUT_PROVIDER_ID, newline_str,
            'dbase:  taxonomy', newline_str,
            'stype:  taxonomy/phylogenetic', newline_str,
            '!base:  ', URL, newline_str,
            '---------------------------------------------------------------'
          ) AS t,
          NULL AS left_idx,
          NULL AS msl_release_num
        UNION ALL
        -- Actual taxa
        SELECT 
          CONCAT(
            'linkid:   ', RTRIM(CAST(MAX(taxnode_id) AS CHAR)), newline_str,
            'query:  ', name, ' [name]', newline_str,
            'base:  &base;', newline_str,
            'rule:  ', RTRIM(CAST(MAX(taxnode_id) AS CHAR)), newline_str,
            'name:  ', name, newline_str,
            '---------------------------------------------------------------'
          ) AS t,
          MAX(left_idx) AS left_idx,
          MAX(msl_release_num) AS msl_release_num
        FROM taxonomy_node_names taxa
        WHERE msl_release_num <= in_msl
          AND is_deleted = 0
          AND is_hidden = 0
          AND is_obsolete = 0
          AND name IS NOT NULL
          AND name <> 'Unassigned'
        GROUP BY name
    ) AS src
    ORDER BY src.left_idx;

END$$

DELIMITER ;