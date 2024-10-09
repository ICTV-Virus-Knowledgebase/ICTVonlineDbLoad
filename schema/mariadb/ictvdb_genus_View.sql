CREATE VIEW `ictvdb_genus` AS
SELECT * 
FROM `ictvdb_index`
WHERE CHAR_LENGTH(`ictv_code`) = 12; -- genus ##.###.#.##.
