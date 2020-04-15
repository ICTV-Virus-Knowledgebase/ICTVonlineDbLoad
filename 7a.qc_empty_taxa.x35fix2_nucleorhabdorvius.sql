-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Riboviria;Orthornavirae;Negarnaviricota;Haploviricotina;Monjiviricetes;Mononegavirales;Rhabdoviridae;Nucleorhabdovirus
--
-- split, code didn't remove orignal name
--
-- --------------------------------------------------------------------------------------------------

--select sort, * from load_next_msl where dest_taxnode_id = 201901741 or _src_taxon_name = 'Nucleorhabdovirus'
delete from taxonomy_node
-- select _numKids, * from taxonomy_node 
where msl_release_num=35 and name='Nucleorhabdovirus'  and _numKids=0
