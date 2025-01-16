-- taxonomy_node computed columns
ALTER TABLE `taxonomy_node`
  ADD COLUMN `cleaned_name` VARCHAR(100)
    GENERATED ALWAYS AS (
      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      REPLACE(REPLACE(`name`, 'í', 'i'), 'é', 'e'), 'ó', 'o'), 'ú', 'u'), 'á', 'a'),
      'ì', 'i'), 'è', 'e'), 'ò', 'o'), 'ù', 'u'), 'à', 'a'), 'î', 'i'), 'ê', 'e'),
      'ô', 'o'), 'û', 'u'), 'â', 'a'), 'ü', 'u'), 'ö', 'o'), 'ï', 'i'), 'ë', 'e'),
      'ä', 'a'), 'ç', 'c'), 'ñ', 'n'), '‘', ''''), '’', ''''), '`', ' '), '  ', ' '),
      'ā', 'a'), 'ī', 'i'), 'ĭ', 'i'), 'ǎ', 'a'), 'ē', 'e'), 'ō', 'o')
    ) PERSISTENT,
  ADD COLUMN `cleaned_problem` VARCHAR(100)
    GENERATED ALWAYS AS (
      CASE 
        WHEN INSTR(`name`, 'í') > 0 THEN 'í (accented i)'
        WHEN INSTR(`name`, 'é') > 0 THEN 'é (accented e)'
        WHEN INSTR(`name`, 'ó') > 0 THEN 'ó (accented o)'
        WHEN INSTR(`name`, 'ú') > 0 THEN 'ú (accented u)'
        WHEN INSTR(`name`, 'á') > 0 THEN 'á (accented a)'
        WHEN INSTR(`name`, 'ì') > 0 THEN 'ì (accented i)'
        WHEN INSTR(`name`, 'è') > 0 THEN 'è (accented e)'
        WHEN INSTR(`name`, 'ò') > 0 THEN 'ò (accented o)'
        WHEN INSTR(`name`, 'ù') > 0 THEN 'ù (accented u)'
        WHEN INSTR(`name`, 'à') > 0 THEN 'à (accented a)'
        WHEN INSTR(`name`, 'î') > 0 THEN 'î (accented i)'
        WHEN INSTR(`name`, 'ê') > 0 THEN 'ê (accented e)'
        WHEN INSTR(`name`, 'ô') > 0 THEN 'ô (accented o)'
        WHEN INSTR(`name`, 'û') > 0 THEN 'û (accented u)'
        WHEN INSTR(`name`, 'â') > 0 THEN 'â (accented a)'
        WHEN INSTR(`name`, 'ü') > 0 THEN 'ü (accented u)'
        WHEN INSTR(`name`, 'ö') > 0 THEN 'ö (accented o)'
        WHEN INSTR(`name`, 'ï') > 0 THEN 'ï (accented i)'
        WHEN INSTR(`name`, 'ë') > 0 THEN 'ë (accented e)'
        WHEN INSTR(`name`, 'ä') > 0 THEN 'ä (accented a)'
        WHEN INSTR(`name`, 'ç') > 0 THEN 'ç (accented c)'
        WHEN INSTR(`name`, 'ñ') > 0 THEN 'ñ (accented n)'
        WHEN INSTR(`name`, '‘') > 0 THEN '‘ (Microsoft curvy open single-quote)'
        WHEN INSTR(`name`, '’') > 0 THEN '’ (Microsoft curvy close single-quote)'
        WHEN INSTR(`name`, '`') > 0 THEN '` (ASCII back-quote)'
        WHEN INSTR(`name`, '  ') > 0 THEN '(double space)'
        WHEN INSTR(`name`, 'ā') > 0 THEN 'a-macron'
        WHEN INSTR(`name`, 'ī') > 0 THEN 'i-macron'
        WHEN INSTR(`name`, 'ĭ') > 0 THEN 'i-breve'
        WHEN INSTR(`name`, 'ǎ') > 0 THEN 'a-caron'
        WHEN INSTR(`name`, 'ē') > 0 THEN 'e-macron'
        WHEN INSTR(`name`, 'ō') > 0 THEN 'o-macron'
    END
    ) PERSISTENT,
  ADD COLUMN `flags` VARCHAR(255)
    GENERATED ALWAYS AS (
      CONCAT(
        CASE WHEN `tree_id` = `taxnode_id` THEN 'root;' ELSE '' END,
        CASE WHEN `is_hidden` = 1 THEN 'hidden;' ELSE '' END,
        CASE WHEN `is_deleted` = 1 THEN 'deleted;' ELSE '' END,
        CASE WHEN `is_deleted_next_year` = 1 THEN 'removed_next_year;' ELSE '' END,
        CASE WHEN `is_typo` = 1 THEN 'typo;' ELSE '' END,
        CASE WHEN `is_renamed_next_year` = 1 THEN 'renamed_next_year;' ELSE '' END,
        CASE WHEN `is_obsolete` = 1 THEN 'obsolete;' ELSE '' END
      )
    ) PERSISTENT,
  ADD COLUMN `_numKids` INT
    GENERATED ALWAYS AS (
      ((`right_idx` - `left_idx`) - 1) / 2
    ) PERSISTENT,
  ADD COLUMN `_out_target_parent` VARCHAR(255)
    GENERATED ALWAYS AS (
      RTRIM(LTRIM(REVERSE(SUBSTRING(REPLACE(REVERSE(`out_target`), ';', REPEAT(' ', 1000)), 500, 1500))))
    ) PERSISTENT,
  ADD COLUMN `_out_target_name` VARCHAR(255)
    GENERATED ALWAYS AS (
      RTRIM(LTRIM(REVERSE(SUBSTRING(REPLACE(REVERSE(`out_target`), ';', REPEAT(' ', 1000)), 0, 500))))
    ) PERSISTENT;