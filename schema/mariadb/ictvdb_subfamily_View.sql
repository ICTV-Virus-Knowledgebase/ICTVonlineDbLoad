CREATE VIEW `ictvdb_subfamily` AS
SELECT * 
FROM `ictvdb_index`
WHERE LENGTH(`ictv_code`) = 9; -- subfamily ##.###.#.
