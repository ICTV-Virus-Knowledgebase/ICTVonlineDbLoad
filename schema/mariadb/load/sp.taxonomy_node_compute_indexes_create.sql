DELIMITER $$

DROP PROCEDURE IF EXISTS taxonomy_node_compute_indexes $$

CREATE PROCEDURE taxonomy_node_compute_indexes(
    IN in_taxnode_id INT,
    IN in_left_idx INT,
    OUT out_right_idx INT,
    IN in_node_depth INT,
    IN in_realm_id INT,
    IN in_subrealm_id INT,
    IN in_kingdom_id INT,
    IN in_subkingdom_id INT,
    IN in_phylum_id INT,
    IN in_subphylum_id INT,
    IN in_class_id INT,
    IN in_subclass_id INT,
    IN in_order_id INT,
    IN in_suborder_id INT,
    IN in_family_id INT,
    IN in_subfamily_id INT,
    IN in_genus_id INT,
    IN in_subgenus_id INT,
    IN in_species_id INT,
    OUT out_realm_desc_ct INT,
    OUT out_subrealm_desc_ct INT,
    OUT out_kingdom_desc_ct INT,
    OUT out_subkingdom_desc_ct INT,
    OUT out_phylum_desc_ct INT,
    OUT out_subphylum_desc_ct INT,
    OUT out_class_desc_ct INT,
    OUT out_subclass_desc_ct INT,
    OUT out_order_desc_ct INT,
    OUT out_suborder_desc_ct INT,
    OUT out_family_desc_ct INT,
    OUT out_subfamily_desc_ct INT,
    OUT out_genus_desc_ct INT,
    OUT out_subgenus_desc_ct INT,
    OUT out_species_desc_ct INT,
    IN in_inher_molecule_id INT,
    IN in_lineage VARCHAR(1000)
)
BEGIN
    DECLARE hidden_as_unassigned INT DEFAULT 1;
    DECLARE use_my_lineage INT;
    DECLARE my_lineage VARCHAR(1000);

    -- direct kid counts
    DECLARE realm_kid_ct INT DEFAULT 0;
    DECLARE subrealm_kid_ct INT DEFAULT 0;
    DECLARE kingdom_kid_ct INT DEFAULT 0;
    DECLARE subkingdom_kid_ct INT DEFAULT 0;
    DECLARE phylum_kid_ct INT DEFAULT 0;
    DECLARE subphylum_kid_ct INT DEFAULT 0;
    DECLARE class_kid_ct INT DEFAULT 0;
    DECLARE subclass_kid_ct INT DEFAULT 0;
    DECLARE order_kid_ct INT DEFAULT 0;
    DECLARE suborder_kid_ct INT DEFAULT 0;
    DECLARE family_kid_ct INT DEFAULT 0;
    DECLARE subfamily_kid_ct INT DEFAULT 0;
    DECLARE genus_kid_ct INT DEFAULT 0;
    DECLARE subgenus_kid_ct INT DEFAULT 0;
    DECLARE species_kid_ct INT DEFAULT 0;

    -- local copies of input, to modify if needed
    DECLARE realm_id INT DEFAULT in_realm_id;
    DECLARE subrealm_id INT DEFAULT in_subrealm_id;
    DECLARE kingdom_id INT DEFAULT in_kingdom_id;
    DECLARE subkingdom_id INT DEFAULT in_subkingdom_id;
    DECLARE phylum_id INT DEFAULT in_phylum_id;
    DECLARE subphylum_id INT DEFAULT in_subphylum_id;
    DECLARE class_id INT DEFAULT in_class_id;
    DECLARE subclass_id INT DEFAULT in_subclass_id;
    DECLARE order_id INT DEFAULT in_order_id;
    DECLARE suborder_id INT DEFAULT in_suborder_id;
    DECLARE family_id INT DEFAULT in_family_id;
    DECLARE subfamily_id INT DEFAULT in_subfamily_id;
    DECLARE genus_id INT DEFAULT in_genus_id;
    DECLARE subgenus_id INT DEFAULT in_subgenus_id;
    DECLARE species_id INT DEFAULT in_species_id;
    DECLARE inher_molecule_id INT DEFAULT in_inher_molecule_id;
    DECLARE lineage VARCHAR(1000) DEFAULT in_lineage;

    -- descendant counts start as OUT parameters, so set to zero here
    SET out_realm_desc_ct=0;
    SET out_subrealm_desc_ct=0;
    SET out_kingdom_desc_ct=0;
    SET out_subkingdom_desc_ct=0;
    SET out_phylum_desc_ct=0;
    SET out_subphylum_desc_ct=0;
    SET out_class_desc_ct=0;
    SET out_subclass_desc_ct=0;
    SET out_order_desc_ct=0;
    SET out_suborder_desc_ct=0;
    SET out_family_desc_ct=0;
    SET out_subfamily_desc_ct=0;
    SET out_genus_desc_ct=0;
    SET out_subgenus_desc_ct=0;
    SET out_species_desc_ct=0;

    -- Retrieve node info and update variables
    SELECT 
        -- fallback for realm_id etc
        IFNULL(realm_id, IF(level.name='realm', taxnode_id, NULL)),
        IFNULL(subrealm_id, IF(level.name='subrealm', taxnode_id, NULL)),
        IFNULL(kingdom_id, IF(level.name='kingdom', taxnode_id, NULL)),
        IFNULL(subkingdom_id, IF(level.name='subkingdom', taxnode_id, NULL)),
        IFNULL(phylum_id, IF(level.name='phylum', taxnode_id, NULL)),
        IFNULL(subphylum_id, IF(level.name='subphylum', taxnode_id, NULL)),
        IFNULL(class_id, IF(level.name='class', taxnode_id, NULL)),
        IFNULL(subclass_id, IF(level.name='subclass', taxnode_id, NULL)),
        IFNULL(order_id, IF(level.name='order', taxnode_id, NULL)),
        IFNULL(suborder_id, IF(level.name='suborder', taxnode_id, NULL)),
        IFNULL(family_id, IF(level.name='family', taxnode_id, NULL)),
        IFNULL(subfamily_id, IF(level.name='subfamily', taxnode_id, NULL)),
        IFNULL(genus_id, IF(level.name='genus', taxnode_id, NULL)),
        IFNULL(subgenus_id, IF(level.name='subgenus', taxnode_id, NULL)),
        IFNULL(species_id, IF(level.name='species', taxnode_id, NULL)),
        IFNULL(self.molecule_id, IFNULL(inher_molecule_id, self.inher_molecule_id)),
        (CASE 
            WHEN self.taxnode_id = self.tree_id THEN 0
            WHEN hidden_as_unassigned=1 THEN 1
            WHEN self.is_hidden=1 OR self.name IS NULL THEN 0 
            ELSE 1 END),
        CONCAT(
            IFNULL(lineage,''),
            IF(LENGTH(lineage)>0,';',''),
            IF(self.is_hidden=1 AND hidden_as_unassigned=0,'[',''),
            IFNULL(self.name, IF(hidden_as_unassigned=1,'Unassigned','- unnamed -')),
            IF(self.is_hidden=1 AND hidden_as_unassigned=0,']','')
        )
    INTO realm_id, subrealm_id, kingdom_id, subkingdom_id, phylum_id, subphylum_id,
         class_id, subclass_id, order_id, suborder_id, family_id, subfamily_id,
         genus_id, subgenus_id, species_id, inher_molecule_id, use_my_lineage, my_lineage
    FROM taxonomy_node self
    LEFT JOIN taxonomy_level level ON level.id = self.level_id
    WHERE self.taxnode_id = in_taxnode_id;

    -- Update current node's info
    UPDATE taxonomy_node
    SET left_idx=in_left_idx,
        node_depth=in_node_depth,
        realm_id=realm_id,
        subrealm_id=subrealm_id,
        kingdom_id=kingdom_id,
        subkingdom_id=subkingdom_id,
        phylum_id=phylum_id,
        subphylum_id=subphylum_id,
        class_id=class_id,
        subclass_id=subclass_id,
        order_id=order_id,
        suborder_id=suborder_id,
        family_id=family_id,
        subfamily_id=subfamily_id,
        genus_id=genus_id,
        subgenus_id=subgenus_id,
        species_id=species_id,
        inher_molecule_id=inher_molecule_id,
        lineage=my_lineage
    WHERE taxnode_id = in_taxnode_id
    AND (
           left_idx<>in_left_idx OR (left_idx IS NULL AND in_left_idx IS NOT NULL)
        OR node_depth<>in_node_depth OR (node_depth IS NULL AND in_node_depth IS NOT NULL)
        OR (realm_id<>in_realm_id OR (realm_id IS NULL AND in_realm_id IS NOT NULL))
        OR (subrealm_id<>in_subrealm_id OR (subrealm_id IS NULL AND in_subrealm_id IS NOT NULL))
        OR (kingdom_id<>in_kingdom_id OR (kingdom_id IS NULL AND in_kingdom_id IS NOT NULL))
        OR (subkingdom_id<>in_subkingdom_id OR (subkingdom_id IS NULL AND in_subkingdom_id IS NOT NULL))
        OR (phylum_id<>in_phylum_id OR (phylum_id IS NULL AND in_phylum_id IS NOT NULL))
        OR (subphylum_id<>in_subphylum_id OR (subphylum_id IS NULL AND in_subphylum_id IS NOT NULL))
        OR (class_id<>in_class_id OR (class_id IS NULL AND in_class_id IS NOT NULL))
        OR (subclass_id<>in_subclass_id OR (subclass_id IS NULL AND in_subclass_id IS NOT NULL))
        OR (order_id<>in_order_id OR (order_id IS NULL AND in_order_id IS NOT NULL))
        OR (suborder_id<>in_suborder_id OR (suborder_id IS NULL AND in_suborder_id IS NOT NULL))
        OR (family_id<>in_family_id OR (family_id IS NULL AND in_family_id IS NOT NULL))
        OR (subfamily_id<>in_subfamily_id OR (subfamily_id IS NULL AND in_subfamily_id IS NOT NULL))
        OR (genus_id<>in_genus_id OR (genus_id IS NULL AND in_genus_id IS NOT NULL))
        OR (subgenus_id<>in_subgenus_id OR (subgenus_id IS NULL AND in_subgenus_id IS NOT NULL))
        OR (species_id<>in_species_id OR (species_id IS NULL AND in_species_id IS NOT NULL))
        OR (inher_molecule_id<>in_inher_molecule_id OR (inher_molecule_id IS NULL AND in_inher_molecule_id IS NOT NULL))
        OR (lineage<>in_lineage OR (lineage IS NULL AND in_lineage IS NOT NULL))
    );

    IF use_my_lineage=1 THEN
        SET lineage=my_lineage;
    END IF;

    -- Clear children's indexes
    UPDATE taxonomy_node 
    SET left_idx=NULL, right_idx=NULL
    WHERE parent_id = in_taxnode_id AND taxnode_id <> in_taxnode_id;

    DECLARE child_taxnode_id INT;
    DECLARE child_rank VARCHAR(50);
    DECLARE child_is_hidden INT;
    DECLARE child_depth INT;
    SET child_depth = in_node_depth + 1;

    SET out_right_idx = in_left_idx + 1;

    -- Cursor for children
    DECLARE done INT DEFAULT FALSE;
    DECLARE child_cur CURSOR FOR
        SELECT n.taxnode_id, n.is_hidden, rank.name
        FROM taxonomy_node n
        JOIN taxonomy_level rank ON rank.id = n.level_id
        WHERE n.parent_id = in_taxnode_id
          AND n.taxnode_id <> in_taxnode_id
          AND n.left_idx IS NULL
        ORDER BY n.level_id,
                 CASE WHEN n.start_num_sort IS NULL THEN IFNULL(n.name,'ZZZZ') ELSE LEFT(n.name,n.start_num_sort) END,
                 CASE WHEN n.start_num_sort IS NULL THEN NULL ELSE FLOOR(SUBSTRING(n.name,n.start_num_sort+1,50)) END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN child_cur;

    read_loop: LOOP
        FETCH child_cur INTO child_taxnode_id, child_is_hidden, child_rank;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Kid descendant counts
        DECLARE kid_realm_desc_ct INT DEFAULT 0;
        DECLARE kid_subrealm_desc_ct INT DEFAULT 0;
        DECLARE kid_kingdom_desc_ct INT DEFAULT 0;
        DECLARE kid_subkingdom_desc_ct INT DEFAULT 0;
        DECLARE kid_phylum_desc_ct INT DEFAULT 0;
        DECLARE kid_subphylum_desc_ct INT DEFAULT 0;
        DECLARE kid_class_desc_ct INT DEFAULT 0;
        DECLARE kid_subclass_desc_ct INT DEFAULT 0;
        DECLARE kid_order_desc_ct INT DEFAULT 0;
        DECLARE kid_suborder_desc_ct INT DEFAULT 0;
        DECLARE kid_family_desc_ct INT DEFAULT 0;
        DECLARE kid_subfamily_desc_ct INT DEFAULT 0;
        DECLARE kid_genus_desc_ct INT DEFAULT 0;
        DECLARE kid_subgenus_desc_ct INT DEFAULT 0;
        DECLARE kid_species_desc_ct INT DEFAULT 0;

        CALL taxonomy_node_compute_indexes(
            child_taxnode_id, 
            out_right_idx, 
            out_right_idx,
            child_depth,
            realm_id,
            subrealm_id,
            kingdom_id,
            subkingdom_id,
            phylum_id,
            subphylum_id,
            class_id,
            subclass_id,
            order_id,
            suborder_id,
            family_id,
            subfamily_id,
            genus_id,
            subgenus_id,
            species_id,
            kid_realm_desc_ct,
            kid_subrealm_desc_ct,
            kid_kingdom_desc_ct,
            kid_subkingdom_desc_ct,
            kid_phylum_desc_ct,
            kid_subphylum_desc_ct,
            kid_class_desc_ct,
            kid_subclass_desc_ct,
            kid_order_desc_ct,
            kid_suborder_desc_ct,
            kid_family_desc_ct,
            kid_subfamily_desc_ct,
            kid_genus_desc_ct,
            kid_subgenus_desc_ct,
            kid_species_desc_ct,
            inher_molecule_id,
            lineage
        );

        IF child_is_hidden=0 THEN
            SET realm_kid_ct=realm_kid_ct+(CASE WHEN child_rank='realm' THEN 1 ELSE 0 END);
            SET subrealm_kid_ct=subrealm_kid_ct+(CASE WHEN child_rank='subrealm' THEN 1 ELSE 0 END);
            SET kingdom_kid_ct=kingdom_kid_ct+(CASE WHEN child_rank='kingdom' THEN 1 ELSE 0 END);
            SET subkingdom_kid_ct=subkingdom_kid_ct+(CASE WHEN child_rank='subkingdom' THEN 1 ELSE 0 END);
            SET phylum_kid_ct=phylum_kid_ct+(CASE WHEN child_rank='phylum' THEN 1 ELSE 0 END);
            SET subphylum_kid_ct=subphylum_kid_ct+(CASE WHEN child_rank='subphylum' THEN 1 ELSE 0 END);
            SET class_kid_ct=class_kid_ct+(CASE WHEN child_rank='class' THEN 1 ELSE 0 END);
            SET subclass_kid_ct=subclass_kid_ct+(CASE WHEN child_rank='subclass' THEN 1 ELSE 0 END);
            SET order_kid_ct=order_kid_ct+(CASE WHEN child_rank='order' THEN 1 ELSE 0 END);
            SET suborder_kid_ct=suborder_kid_ct+(CASE WHEN child_rank='suborder' THEN 1 ELSE 0 END);
            SET family_kid_ct=family_kid_ct+(CASE WHEN child_rank='family' THEN 1 ELSE 0 END);
            SET subfamily_kid_ct=subfamily_kid_ct+(CASE WHEN child_rank='subfamily' THEN 1 ELSE 0 END);
            SET genus_kid_ct=genus_kid_ct+(CASE WHEN child_rank='genus' THEN 1 ELSE 0 END);
            SET subgenus_kid_ct=subgenus_kid_ct+(CASE WHEN child_rank='subgenus' THEN 1 ELSE 0 END);
            SET species_kid_ct=species_kid_ct+(CASE WHEN child_rank='species' THEN 1 ELSE 0 END);
        END IF;

        SET out_realm_desc_ct=out_realm_desc_ct+kid_realm_desc_ct;
        SET out_subrealm_desc_ct=out_subrealm_desc_ct+kid_subrealm_desc_ct;
        SET out_kingdom_desc_ct=out_kingdom_desc_ct+kid_kingdom_desc_ct;
        SET out_subkingdom_desc_ct=out_subkingdom_desc_ct+kid_subkingdom_desc_ct;
        SET out_phylum_desc_ct=out_phylum_desc_ct+kid_phylum_desc_ct;
        SET out_subphylum_desc_ct=out_subphylum_desc_ct+kid_subphylum_desc_ct;
        SET out_class_desc_ct=out_class_desc_ct+kid_class_desc_ct;
        SET out_subclass_desc_ct=out_subclass_desc_ct+kid_subclass_desc_ct;
        SET out_order_desc_ct=out_order_desc_ct+kid_order_desc_ct;
        SET out_suborder_desc_ct=out_suborder_desc_ct+kid_suborder_desc_ct;
        SET out_family_desc_ct=out_family_desc_ct+kid_family_desc_ct;
        SET out_subfamily_desc_ct=out_subfamily_desc_ct+kid_subfamily_desc_ct;
        SET out_genus_desc_ct=out_genus_desc_ct+kid_genus_desc_ct;
        SET out_subgenus_desc_ct=out_subgenus_desc_ct+kid_subgenus_desc_ct;
        SET out_species_desc_ct=out_species_desc_ct+kid_species_desc_ct;

        SET out_right_idx = out_right_idx+1;

    END LOOP read_loop;

    CLOSE child_cur;

    SET out_realm_desc_ct       = out_realm_desc_ct       + realm_kid_ct;
    SET out_subrealm_desc_ct    = out_subrealm_desc_ct    + subrealm_kid_ct;
    SET out_kingdom_desc_ct     = out_kingdom_desc_ct     + kingdom_kid_ct;
    SET out_subkingdom_desc_ct  = out_subkingdom_desc_ct  + subkingdom_kid_ct;
    SET out_phylum_desc_ct      = out_phylum_desc_ct      + phylum_kid_ct;
    SET out_subphylum_desc_ct   = out_subphylum_desc_ct   + subphylum_kid_ct;
    SET out_class_desc_ct       = out_class_desc_ct       + class_kid_ct;
    SET out_subclass_desc_ct    = out_subclass_desc_ct    + subclass_kid_ct;
    SET out_order_desc_ct       = out_order_desc_ct       + order_kid_ct;
    SET out_suborder_desc_ct    = out_suborder_desc_ct    + suborder_kid_ct;
    SET out_family_desc_ct      = out_family_desc_ct      + family_kid_ct;
    SET out_subfamily_desc_ct   = out_subfamily_desc_ct   + subfamily_kid_ct;
    SET out_genus_desc_ct       = out_genus_desc_ct       + genus_kid_ct;
    SET out_subgenus_desc_ct    = out_subgenus_desc_ct    + subgenus_kid_ct;
    SET out_species_desc_ct     = out_species_desc_ct     + species_kid_ct;

    UPDATE taxonomy_node 
    SET right_idx = out_right_idx,
        realm_desc_ct = out_realm_desc_ct, realm_kid_ct = realm_kid_ct,
        subrealm_desc_ct = out_subrealm_desc_ct, subrealm_kid_ct = subrealm_kid_ct,
        kingdom_desc_ct = out_kingdom_desc_ct, kingdom_kid_ct = kingdom_kid_ct,
        subkingdom_desc_ct = out_subkingdom_desc_ct, subkingdom_kid_ct = subkingdom_kid_ct,
        phylum_desc_ct = out_phylum_desc_ct, phylum_kid_ct = phylum_kid_ct,
        subphylum_desc_ct = out_subphylum_desc_ct, subphylum_kid_ct = subphylum_kid_ct,
        class_desc_ct = out_class_desc_ct, class_kid_ct = class_kid_ct,
        subclass_desc_ct = out_subclass_desc_ct, subclass_kid_ct = subclass_kid_ct,
        order_desc_ct = out_order_desc_ct, order_kid_ct = order_kid_ct,
        suborder_desc_ct = out_suborder_desc_ct, suborder_kid_ct = suborder_kid_ct,
        family_desc_ct = out_family_desc_ct, family_kid_ct = family_kid_ct,
        subfamily_desc_ct = out_subfamily_desc_ct, subfamily_kid_ct = subfamily_kid_ct,
        genus_desc_ct = out_genus_desc_ct, genus_kid_ct = genus_kid_ct,
        subgenus_desc_ct = out_subgenus_desc_ct, subgenus_kid_ct = subgenus_kid_ct,
        species_desc_ct = out_species_desc_ct, species_kid_ct = species_kid_ct,
        taxa_kid_cts = udf_rankCountsToStringWithPurals(
            realm_kid_ct, subrealm_kid_ct,
            kingdom_kid_ct, subkingdom_kid_ct,
            phylum_kid_ct, subphylum_kid_ct,
            class_kid_ct, subclass_kid_ct,
            order_kid_ct, suborder_kid_ct,
            family_kid_ct, subfamily_kid_ct,
            genus_kid_ct, subgenus_kid_ct,
            species_kid_ct
        ),
        taxa_desc_cts = udf_rankCountsToStringWithPurals(
            out_realm_desc_ct, out_subrealm_desc_ct,
            out_kingdom_desc_ct, out_subkingdom_desc_ct,
            out_phylum_desc_ct, out_subphylum_desc_ct,
            out_class_desc_ct, out_subclass_desc_ct,
            out_order_desc_ct, out_suborder_desc_ct,
            out_family_desc_ct, out_subfamily_desc_ct,
            out_genus_desc_ct, out_subgenus_desc_ct,
            out_species_desc_ct
        )
    WHERE taxnode_id = in_taxnode_id;

END$$

DELIMITER ;