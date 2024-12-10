USE ICTVonline39;

DELIMITER $$

CREATE PROCEDURE searchTaxonomy(
    IN currentMslRelease INT,
    IN includeAllReleases BOOLEAN,
    IN searchText NVARCHAR(100),
    IN selectedMslRelease INT
)
BEGIN
    -- Declare variables
    DECLARE filteredSearchText VARCHAR(100);
    DECLARE trimmedSearchText NVARCHAR(100);

    -- Validate the current MSL release
    IF currentMslRelease IS NULL OR currentMslRelease < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Please enter a valid current MSL release';
    END IF;

    -- Validate the search text
    SET trimmedSearchText = TRIM(searchText);
    IF trimmedSearchText IS NULL OR CHAR_LENGTH(trimmedSearchText) < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Please enter non-empty search text';
    END IF;

    -- Replace the same characters that were replaced in the cleaned_name column.
    SET filteredSearchText = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        trimmedSearchText,
        'í','i'),'é','e'),'ó','o'),'ú','u'),'á','a'),'ì','i'),'è','e'),'ò','o'),'ù','u'),'à','a'),'î','i'),'ê','e'),'ô','o'),'û','u'),'â','a'),'ü','u'),'ö','o'),'ï','i'),'ë','e'),'ä','a'),'ç','c'),'ñ','n'),'‘',''''),'’',''''),'`',' '),'  ',' '),'ā','a'),'ī','i'),'ĭ','i'),'ǎ','a'),'ē','e'),'ō','o');

    -- Make sure "include all releases" isn't null.
    IF includeAllReleases IS NULL THEN
        SET includeAllReleases = FALSE;
    END IF;

    -- If we aren't including all releases and the MSL release number is null, default to the current release.
    IF includeAllReleases = FALSE AND selectedMslRelease IS NULL THEN
        SET selectedMslRelease = currentMslRelease;
    END IF;

    -- We need to replicate the logic for display_order. In SQL Server, it uses a subquery with DENSE_RANK
    -- on siblings, then picks the corresponding taxnode_id.
    -- In MariaDB, we can use a CTE or derived table. We'll use a CTE here.

    WITH sibling_ranks AS (
        SELECT 
            s.taxnode_id,
            s.parent_id,
            s.level_id,
            DENSE_RANK() OVER (PARTITION BY s.parent_id, s.level_id ORDER BY s.left_idx ASC) AS display_order
        FROM taxonomy_node s
        WHERE s.taxnode_id <> s.tree_id  -- exclude the tree node itself as in SQL Server logic
    )

    SELECT
        sr.display_order,
        tn.ictv_id AS ictv_id,
        REPLACE(IFNULL(tn.lineage, ''), ';', '>') AS lineage,
        tn.parent_id AS parent_taxnode_id,
        tl.name AS rank_name,
        tn.msl_release_num AS release_number,
        searchText AS search_text,
        tn.taxnode_id AS taxnode_id,
        CONCAT(
            tn.tree_id,
            IF(tn.realm_id IS NOT NULL, CONCAT(',', tn.realm_id), ''),
            IF(tn.subrealm_id IS NOT NULL, CONCAT(',', tn.subrealm_id), ''),
            IF(tn.kingdom_id IS NOT NULL, CONCAT(',', tn.kingdom_id), ''),
            IF(tn.subkingdom_id IS NOT NULL, CONCAT(',', tn.subkingdom_id), ''),
            IF(tn.phylum_id IS NOT NULL, CONCAT(',', tn.phylum_id), ''),
            IF(tn.subphylum_id IS NOT NULL, CONCAT(',', tn.subphylum_id), ''),
            IF(tn.class_id IS NOT NULL, CONCAT(',', tn.class_id), ''),
            IF(tn.subclass_id IS NOT NULL, CONCAT(',', tn.subclass_id), ''),
            IF(tn.order_id IS NOT NULL, CONCAT(',', tn.order_id), ''),
            IF(tn.suborder_id IS NOT NULL, CONCAT(',', tn.suborder_id), ''),
            IF(tn.family_id IS NOT NULL, CONCAT(',', tn.family_id), ''),
            IF(tn.subfamily_id IS NOT NULL, CONCAT(',', tn.subfamily_id), ''),
            IF(tn.genus_id IS NOT NULL, CONCAT(',', tn.genus_id), ''),
            IF(tn.subgenus_id IS NOT NULL, CONCAT(',', tn.subgenus_id), ''),
            IF(tn.species_id IS NOT NULL, CONCAT(',', tn.species_id), '')
        ) AS taxnode_lineage,
        tn.tree_id AS tree_id,
        tree.name AS tree_name
    FROM taxonomy_node tn
    JOIN taxonomy_level tl ON tl.id = tn.level_id
    JOIN taxonomy_node tree ON tree.taxnode_id = tn.tree_id AND tree.msl_release_num IS NOT NULL
    LEFT JOIN sibling_ranks sr ON sr.taxnode_id = tn.taxnode_id
        AND sr.parent_id = tn.parent_id
        AND sr.level_id = tn.level_id
    WHERE tn.cleaned_name LIKE CONCAT('%', filteredSearchText, '%')
      AND tn.is_hidden = 0
      AND tn.is_deleted = 0
      AND (includeAllReleases = TRUE OR tn.msl_release_num = selectedMslRelease)
      AND tn.msl_release_num <= currentMslRelease
    ORDER BY tn.tree_id DESC, tn.left_idx;

END $$

DELIMITER ;