CREATE VIEW `ictvdb_family` AS
SELECT * 
FROM `ictvdb_index`
WHERE CHAR_LENGTH(`ictv_code`) = 7; -- family ##.###.