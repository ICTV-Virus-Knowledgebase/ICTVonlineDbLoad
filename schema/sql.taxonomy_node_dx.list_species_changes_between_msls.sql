--
-- MSL36 - MSL37 
-- 
-- species names and changes 
--

select
	[OLD_MSL]=ps.msl_release_num, [OLD_lineage]= dx.prev_lineage, [OLD_species]=ps.name  
	, [changes]=dx.prev_tags
	, [NEW_species]= dx.name, [NEW_lineage]= dx.lineage, [NEW_MSL]=dx.msl_release_num
	--, * 
from taxonomy_node_dx dx
left outer join  taxonomy_node ps on ps.taxnode_id = dx.prev_id
where dx.msl_release_num=37
and dx.level_id = 600 -- species
order by dx.left_idx