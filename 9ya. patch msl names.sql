print '-- '
print '-- fix up MSL33/34 names'
print '-- '


begin transaction
-- commit transaction
-- ROLLBACK transaction

select report='before', name, taxnode_id, notes, * from taxonomy_node n
where msl_release_num between 30 and 34 and level_id = 100
order by n.left_idx

update taxonomy_node set --select 
	name='2018a', notes='EC 50, Washington, DC, July 2018; Email ratification October 2018 (MSL #33)'
from taxonomy_node 
where msl_release_num in (33) and level_id = 100

update taxonomy_node set --select 
	name='2018b', notes='EC 50, Washington, DC, July 2018; Email ratification February 2019 (MSL #34)'
from taxonomy_node 
where msl_release_num in (34) and level_id = 100


select report='after', name, taxnode_id, notes, * from taxonomy_node n
where msl_release_num between 30 and 34 and level_id = 100
order by n.left_idx


-- commit transaction
-- rollback transaction