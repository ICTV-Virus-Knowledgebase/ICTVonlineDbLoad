-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Cressdnaviricota;Arfiviricetes;Recrevirales

--
-- sort=439 new family Redondoviridae placed that family in root instead of in Recrevirales, as proposal had specified. 
--
-- --------------------------------------------------------------------------------------------------
BEGIN TRANSACTION 

select 
	report='details on selected sort IDs',
	sort, _src_taxon_name, isWrong=left(isWRong,20), action=_action, _dest_parent_name, dest_taxon_name=_dest_taxon_name, dest_taxnode_id, _dest_lineage
	, in_change, in_filename, in_notes, in_target
	, dest._numKids 
from load_next_msl src
left outer join taxonomy_node_names dest on dest.taxnode_id = src.dest_taxnode_id
where sort in (439) 
order by dest_taxon_name, action


--
-- update load to add missing parent taxa
--
update load_next_msl set
	phylum='Cressdnaviricota', class='Arfiviricetes', [order]='Recrevirales'
from load_next_msl
where sort in (439) 
and [order] is null 


-- 
-- reparent Redondoviridae into Recrevirales
--
select dest.taxnode_id, dest.parent_id, dest.level_id, dest.lineage, dest.in_target, ssep='>>', correct._dest_parent_name, correct._dest_lineage,
--RUN-- update dest set 	
	parent_id = p.taxnode_id
from taxonomy_node dest
join load_nexT_msl correct on correct.sort=439  and dest.taxnode_id = correct.dest_taxnode_id
join taxonomy_node p on p.msl_release_num = dest.msl_release_num and p.name = correct._dest_parent_name
where dest.parent_id <> p.taxnode_id
--END-RUN -- skip order during  update

--
--
-- update in_target
--
select dest.taxnode_id, dest.parent_id, dest.level_id, dest.lineage, dest.in_target, ssep='>>', correct._dest_parent_name, correct._dest_lineage,
--RUN-- update dest set 	
	in_target = dest.lineage 
from taxonomy_node dest
join load_nexT_msl correct on correct.sort=439  and dest.taxnode_id = correct.dest_taxnode_id
where dest.in_target <> dest.lineage or dest.in_target is null

-- COMMIT transaction
-- ROLLBACK transaction