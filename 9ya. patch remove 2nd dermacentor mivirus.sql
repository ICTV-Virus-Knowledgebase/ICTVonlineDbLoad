begin transaction

select 'before', idx=n.left_idx
	,flag=(case when n.name like 'Dermacentor mivirus' then '****' else'' end)
	,l=n.lineage, * from taxonomy_node n
join taxonomy_node t on t.name='Mivirus' and n.left_idx between t.left_idx and t.right_idx and t.tree_id = n.tree_id
order by n.left_idx

delete  --select * 
from taxonomy_node 
where name like 'Dermacentor mivirus'
and	isolate_csv like '%tick virus 5%'

delete  --select * 
from load_next_msl_33
where _dest_taxon_name like 'Dermacentor mivirus'
and	exemplarName like '%tick virus 5%'

select 'after', idx=n.left_idx
	,flag=(case when n.name like 'Dermacentor mivirus' then '****' else'' end)
	,l=n.lineage, * from taxonomy_node n
join taxonomy_node t on t.name='Mivirus' and n.left_idx between t.left_idx and t.right_idx and t.tree_id = n.tree_id
order by n.left_idx

-- commit transaction
-- rollback transaction