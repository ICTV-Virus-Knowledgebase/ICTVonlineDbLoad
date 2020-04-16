--
-- no root for ictv_id: Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Caudovirales;Autographiviridae
--
-- this was a promote, and was hand-coded, so messed up the ictv_id
--
select * from load_next_msl where _dest_taxon_name = 'autographiviridae'
select * from taxonomy_node where taxnode_id = 201850541

update taxonomy_node set ictv_id=20090674 /* ictv_id from MSL34 Autographivirinae */
where taxnode_id=201908192

update load_next_msl set dest_ictv_id=20090674 where _dest_taxon_name = 'Autographiviridae' and _action ='promote'