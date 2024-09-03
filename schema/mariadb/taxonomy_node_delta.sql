CREATE TABLE taxonomy_node_delta (
    prev_taxid INT NULL DEFAULT NULL,
    new_taxid INT NULL DEFAULT NULL,
    proposal VARCHAR(255) NULL DEFAULT NULL,
    notes VARCHAR(255) NULL DEFAULT NULL,
    is_merged INT NOT NULL DEFAULT 0,
    is_split INT NOT NULL DEFAULT 0,
    is_moved INT NOT NULL DEFAULT 0,
    is_promoted INT NOT NULL DEFAULT 0,
    is_demoted INT NOT NULL DEFAULT 0,
    is_renamed INT NOT NULL DEFAULT 0,
    is_new INT NOT NULL DEFAULT 0,
    is_deleted INT NOT NULL DEFAULT 0,
    is_now_type INT NOT NULL DEFAULT 0,
    tag_csv VARCHAR(255) GENERATED ALWAYS AS (
        CONCAT(
            CASE WHEN is_merged = 1 THEN 'Merged,' ELSE '' END,
            CASE WHEN is_split = 1 THEN 'Split,' ELSE '' END,
            CASE WHEN is_renamed = 1 THEN 'Renamed,' ELSE '' END,
            CASE WHEN is_new = 1 THEN 'New,' ELSE '' END,
            CASE WHEN is_deleted = 1 THEN 'Abolished,' ELSE '' END,
            CASE WHEN is_moved = 1 THEN 'Moved,' ELSE '' END,
            CASE WHEN is_promoted = 1 THEN 'Promoted,' ELSE '' END,
            CASE WHEN is_demoted = 1 THEN 'Demoted,' ELSE '' END,
            CASE 
                WHEN is_now_type = 1 THEN 'Assigned as Type Species,' 
                WHEN is_now_type = -1 THEN 'Removed as Type Species,' 
                ELSE '' 
            END
        )
    ),
    tag_csv2 VARCHAR(255) GENERATED ALWAYS AS (
        CONCAT(
            CASE WHEN is_merged = 1 THEN 'Merged,' ELSE '' END,
            CASE WHEN is_split = 1 THEN 'Split,' ELSE '' END,
            CASE WHEN is_renamed = 1 THEN 'Renamed,' ELSE '' END,
            CASE WHEN is_new = 1 THEN 'New,' ELSE '' END,
            CASE WHEN is_deleted = 1 THEN 'Abolished,' ELSE '' END,
            CASE WHEN is_moved = 1 THEN 'Moved,' ELSE '' END,
            CASE WHEN is_promoted = 1 THEN 'Promoted,' ELSE '' END,
            CASE WHEN is_demoted = 1 THEN 'Demoted,' ELSE '' END,
            CASE 
                WHEN is_now_type = 1 THEN 'Assigned as Type Species,' 
                WHEN is_now_type = -1 THEN 'Removed as Type Species,' 
                ELSE '' 
            END,
            CASE WHEN is_lineage_updated = 1 THEN 'LineageUpdated,' ELSE '' END
        )
    ) PERSISTENT,
    tag_csv_min VARCHAR(255) GENERATED ALWAYS AS (
        CONCAT(
            CASE WHEN is_merged = 1 THEN 'Merged,' ELSE '' END,
            CASE WHEN is_split = 1 THEN 'Split,' ELSE '' END,
            CASE WHEN is_renamed = 1 THEN 'Renamed,' ELSE '' END,
            CASE WHEN is_new = 1 THEN 'New,' ELSE '' END,
            CASE WHEN is_deleted = 1 THEN 'Abolished,' ELSE '' END,
            CASE WHEN is_moved = 1 THEN 'Moved,' ELSE '' END,
            CASE WHEN is_promoted = 1 THEN 'Promoted,' ELSE '' END,
            CASE WHEN is_demoted = 1 THEN 'Demoted,' ELSE '' END
        )
    ) PERSISTENT,
    is_lineage_updated INT NOT NULL,
    msl INT NOT NULL,
    CONSTRAINT CK_taxonomy_node_delta_is_deleted CHECK (is_deleted IN (0, 1)),
    CONSTRAINT CK_taxonomy_node_delta_is_merged CHECK (is_merged IN (0, 1)),
    CONSTRAINT CK_taxonomy_node_delta_is_moved CHECK (is_moved IN (0, 1)),
    CONSTRAINT CK_taxonomy_node_delta_is_new CHECK (is_new IN (0, 1)),
    CONSTRAINT CK_taxonomy_node_delta_is_now_type CHECK (is_now_type IN (0, 1, -1)),
    CONSTRAINT CK_taxonomy_node_delta_is_renamed CHECK (is_renamed IN (0, 1))
) ENGINE=InnoDB;
