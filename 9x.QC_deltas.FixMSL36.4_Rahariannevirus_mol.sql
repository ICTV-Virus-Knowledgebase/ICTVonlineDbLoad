/*
 * molecule type is dsRNA instead of dsDNA!
 */

 select molecule, molecule_id, * from taxonomy_node_names where genus='Rahariannevirus'


update taxonomy_node set molecule_id = 1 where taxnode_id=202011666 and name='Rahariannevirus' and molecule_id <> 1
select * from taxonomy_molecule where name='dsDNA'