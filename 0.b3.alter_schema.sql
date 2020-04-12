/*
 * ALTER SCHEMA
 *
  */

--
-- taxonomy_node ADD _numKids (computed)
--
-- convenience column 
alter table taxonomy_node add [_numKids]  AS ([right_idx]-[left_idx]-1)/2 PERSISTED