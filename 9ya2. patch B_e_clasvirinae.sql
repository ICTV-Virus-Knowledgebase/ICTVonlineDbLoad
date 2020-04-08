print '-- '
print '-- fix up out_target problems from Riboviria & Bclasvirinae/Beclasvirinae'
print '-- '


begin transaction
-- commit transaction
-- ROLLBACK transaction

print '-- '
print '-- fix up typo Beclasvirinae instead of Bclasvirinae: species Mycobacterium virus TA17a'
print '-- '

select report='before', t='taxonomy_node', taxnode_id, name, out_change, out_target,  notes, * 
from taxonomy_node n
where msl_release_num between 30 and 35 and name='Mycobacterium virus TA17a' and out_target like '%Beclasvirinae%'
order by  msl_release_num desc, n.left_idx

select report='before', t='load_next_msl_34a', * 
from load_next_msl_34a ld
where ld.subfamily like '%Beclasvirinae%'



print '--'
print '-- update taxonomy_node'
print '--'
update taxonomy_node set --select report='update', t='taxonomy_node', taxnode_id, name, out_change, out_target,  notes,
	out_target= replace(out_target, 'Beclasvirinae','Bclasvirinae' )
from taxonomy_node 
where msl_release_num in (33) and out_target like '%Beclasvirinae%'

print '--'
print '-- update load_next_msl_34a'
print '--'
update load_next_msl_34a set --select report='update', t='load_next_msl_34a', subfamily, _dest_lineage,
	subfamily = 'Bclasvirinae'
from load_next_msl_34a ld
where ld.subfamily like 'Beclasvirinae'


print '-- '
print '-- fix up typo Beclasvirinae instead of Bclasvirinae: species Mycobacterium virus TA17a'
print '-- '

select report='AFTER', t='taxonomy_node', taxnode_id, name, out_change, out_target,  notes, * 
from taxonomy_node n
where   msl_release_num between 30 and 35 and name='Mycobacterium virus TA17a' --and out_target like '%Beclasvirinae%'
order by  msl_release_num desc, n.left_idx

select report='AFTER', t='load_next_msl_34a', * 
from load_next_msl_34a ld
where ld.subfamily like '%B%clasvirinae%'


-- commit transaction
-- rollback transaction