--
-- summarize status by rank and action
--

-- summarize change types by action
select count(*) tot from load_next_msl

select filename, _action
	, count(*)  as tot
	, count(prev_taxnode_id) as prev_taxnode_id
	, count(dest_taxnode_id) as dest_taxnode_id
	, count(dest_ictv_id) as dest_ictv_id
	, sum(isDone) as done
	, count(isWrong) as isWrong
from  load_next_msl msl
group by filename, _action
order by filename, _action 


-- summarize change types by rank
select filename, _action, lvl.id, _dest_taxon_rank
	, count(*)  as tot
	, count(prev_taxnode_id) as prev_tax_id
	, count(dest_taxnode_id) as dest_taxnode_id
	, count(dest_ictv_id) as dest_ictv_id
	, sum(isDone) as done
	, count(isWrong) as isWrong
from  load_next_msl msl
left outer join taxonomy_level lvl on lvl.name =msl._dest_taxon_rank
group by filename, _action, _dest_taxon_rank, lvl.id
order by filename, lvl.id , _action 

-- find things that should be linked, but aren't
select ERROR='ERROR: should be linked to prev, but is NOT', _action, _dest_taxon_rank, *
from load_next_msl msl 
where left(_action,4) in ('move', 'rena', 'merg') 
and prev_taxnode_id is NULL


/*
 * debugginged for MSL34

-- history for 'Negarnaviricota;Polyploviricotina;Ellioviricetes;Bunyavirales;Peribunyaviridae;Tospovirus
-- web page doesn't display the change in  MSL31 
select   msl_release_num,left_idx,taxnode_id, ictv_id, lineage from taxonomy_node_x
where target_taxnode_id = 20180178 --target_name in ('Orthotospovirus')
order by msl_release_num, left_idx
-- change links definitely broken MSL30->MSL31
select * from taxonomy_node_dx 
where ictv_id = 19900109
order by msl_release_num

*/