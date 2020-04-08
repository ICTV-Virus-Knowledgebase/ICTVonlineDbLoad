print '-- '
print '-- fix up out_target problems from Riboviria'
print '-- '


begin transaction
-- commit transaction
-- ROLLBACK transaction

print '-- '
print '-- fix up out_target for taxa we moved at a higher rank'
print '-- '

-- ===========================================================================
-- update out_target in prev MSL for things whose lineage has changed at a higher rank
-- ===========================================================================

select [report_before: taxonomy_node.out_target <> nn.lineage]='BEFORE: '+taxonomy_node.out_target+' <> '+nn.lineage
	,taxonomy_node.taxnode_id, taxonomy_node.ictv_id, taxonomy_node.lineage, taxonomy_node.out_change, taxonomy_node.out_target
	,'>>>'
	,ld._src_lineage, ld._action, ld._dest_lineage
	,'>>>'
	,nn.taxnode_id, nn.lineage,
	-- update taxonomy_node set
	out_target = nn.lineage
from taxonomy_node
join load_next_msl_34a ld on  taxonomy_node.taxnode_id=ld.prev_taxnode_id
join taxonomy_node nn on nn.taxnode_id=ld.dest_taxnode_id
where taxonomy_node.out_target <> nn.lineage

select report='BEFORE: should be a new, then move next MSL', * from taxonomy_node_delta
where 20186210 in (prev_taxid, new_taxid)

print '--'
print '-- update out_target with nn.lineage'
print '--'
update taxonomy_node set
	out_target = nn.lineage
from taxonomy_node
join load_next_msl_34a ld on  taxonomy_node.taxnode_id=ld.prev_taxnode_id
join taxonomy_node nn on nn.taxnode_id=ld.dest_taxnode_id
where taxonomy_node.out_target <> nn.lineage


-- MSL34 2m30s -- inside tx
exec rebuild_delta_nodes NULL
exec rebuild_node_merge_split

select report='AFTER rebuild: should be a new, then move next MSL', * from taxonomy_node_delta
where 20186210 in (prev_taxid, new_taxid)
-- commit transaction
-- rollback transaction