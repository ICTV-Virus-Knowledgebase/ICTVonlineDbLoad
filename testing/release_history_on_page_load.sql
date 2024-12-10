USE ICTVonline39;

-------------------------------------------------------------------------------------------
-- Query runs when first opening the Release History page.
-------------------------------------------------------------------------------------------

SELECT 
    msl_release_num, 
    notes, 
    tree_id, 
    year, 
    realms, 
    subrealms, 
    kingdoms, 
    subkingdoms, 
    phyla, 
    subphyla, 
    classes, 
    subclasses, 
    orders, 
    suborders, 
    families, 
    subfamilies, 
    genera, 
    subgenera, 
    species
FROM view_taxa_level_counts_by_release
order by msl_release_num DESC;