-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Monodnaviria;Shotokuvirae;Cossaviricota;Quintoviricetes;Piccovirales;Parvoviridae;Densovirinae;Ambidensovirus
--
-- split, code didn't remove orignal name
--
-- --------------------------------------------------------------------------------------------------

-- select sort, _src_taxon_name, isWRong, _action, _dest_parent_name, _dest_taxon_name, * from load_next_msl where dest_taxnode_id = 201901741 or _src_taxon_name = 'Ambidensovirus'
delete from taxonomy_node
-- select _numKids, * from taxonomy_node 
where msl_release_num=35 and name='Ambidensovirus' and _numKids=0