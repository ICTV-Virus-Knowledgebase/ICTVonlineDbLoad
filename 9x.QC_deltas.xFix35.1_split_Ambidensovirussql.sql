--
-- delta issues: 
-- 
-- 34	ERROR DETAIL: MSL34 tax DISappears with out a delta record
-- taxnode_id	ictv_id		rank	taxon			lineage
-- 201854208	19750053	genus	Ambidensovirus	Parvoviridae;Densovirinae;Ambidensovirus
--

begin transaction 

select * from taxonomy_node_delta where prev_taxid=201854208

select * from taxonomy_node 
where 
	(in_change like '%Ambidensovirus%' and msl_release_num= 35)
or
	taxnode_id = 201854208
or 
	name in ('Aquambidensovirus','Scindoambidensovirus','Protoambidensovirus','Hemiambidensovirus','Pefuambidensovirus','Blattambidensovirus')
order by msl_release_num, left_idx

select taxnode_id, level_id, lineage, in_change, in_target in_filename, in_notes, updateWith='>>>>>',
--RUN-- update dest set
	in_change='split', in_target='Ambidensovirus'
from taxonomy_node dest
where msl_release_num=35 and in_change='new'
and name in ('Aquambidensovirus','Scindoambidensovirus','Protoambidensovirus','Hemiambidensovirus','Pefuambidensovirus','Blattambidensovirus')

--commit transaction 
--rollback transaction 

EXEC [dbo].[rebuild_delta_nodes] NULL -- hits latest MSL automatically.