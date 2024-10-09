CREATE VIEW `ictvdb_order` AS
SELECT * 
FROM `ictvdb_index`
WHERE LENGTH(`ictv_code`) = 3; -- order ##
