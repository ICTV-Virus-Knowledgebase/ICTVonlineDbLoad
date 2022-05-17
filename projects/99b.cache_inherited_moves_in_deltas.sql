--
-- taxonomy_node_delta
-- 
-- AN INVESTIGATION
-- 
-- find proposal/delta responsible for "inherited" move
--

select 
	-- PREV NODE
	p.level_id, p.lineage, p.out_change, p.out_filename
	, S1='>>>'
	-- PREV NODE ANCESTOR
	,pp.level_id, pp.lineage, pp.out_change, pp.out_filename
	, S1='>>>'
	-- DELTA NODE
	, d.prev_taxid, d.new_taxid, d.proposal,d.is_moved, d.tag_csv
	, S2='>>>'
	-- NEW NODE
	,n.level_id, n.lineage, n.out_change, n.out_filename
from taxonomy_node_delta d
left outer join taxonomy_node p on p.taxnode_id = d.prev_taxid
left outer join taxonomy_node pp on pp.tree_id = p.tree_id and p.left_idx between pp.left_idx and pp.right_idx
left outer join taxonomy_node n on n.taxnode_id = d.new_taxid

where d.proposal is null and d.is_moved = 1
and prev_taxid > 20200000
order by d.prev_taxid, d.new_taxid, p.left_idx, pp.left_idx
