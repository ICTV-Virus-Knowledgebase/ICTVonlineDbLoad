CREATE VIEW `ictvdb_species` AS
SELECT * 
FROM `ictvdb_index`
WHERE LENGTH(`ictv_code`) = 16; -- species ##.###.#.##.###.
