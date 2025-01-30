CALL populateTaxonomyJsonForAllReleases();

-- set auto increment column to the value of the last isolate_id + 1
-- Now compute the next ID in a user variable
SET @autoIncVal := (
  SELECT COALESCE(MAX(id), 0) + 1
  FROM taxonomy_json
);

-- Build a dynamic ALTER TABLE statement that uses the literal value
SET @sql = CONCAT('ALTER TABLE taxonomy_json AUTO_INCREMENT = ', @autoIncVal);

-- Prepare and execute
PREPARE st FROM @sql;
EXECUTE st;
DEALLOCATE PREPARE st;