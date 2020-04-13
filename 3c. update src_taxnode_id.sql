--
-- SET load_new_msl DEST_TAXNODE_ID & DEST_ICTV_ID
--
--
-- this must happen after 
--  * prev MSL is copied to create new one
--  * load_next_msl is loaded
-- and before we start applying changes
--


update load_next_msl set 
--
-- DEBUG: SELECT src._action, src.change, src._src_taxon_name, src.prev_taxnode_id, dest.lineage, dest.taxnode_id, 
--
	dest_ictv_id = dest.ictv_id
	, dest_taxnode_id = dest.taxnode_id 
from load_next_msl as src
left outer join taxonomy_node dest on
	dest.msl_release_num = src.dest_msl_release_num
	and
	dest.name=src._src_taxon_name
where src.isWrong is NULL
and src._action not in ('new', 'split')
and dest.taxnode_id is not null
and (src.dest_taxnode_id is null or src.dest_taxnode_id <> dest.taxnode_id)


--
-- need to collapse merge nodes - chose taxon with the "oldest" ictv_id (lowest)
--
select src._action, src.change, src.prev_taxnode_id, src._src_lineage, src.dest_taxnode_id, src._dest_lineage 
from load_next_msl src where _action like 'merge%'
select msl_release_num, taxnode_id, ictv_id, lineage from taxonomy_node where name in ('Mink coronavirus 1', 'Ferret coronavirus') and msl_release_num >= 34
order by msl_release_num, left_idx

--
-- when merging into an existing taxon
--
-- take the lowest ICTV_ID amongst all the load_next_msl rows that are merging, and the ICTV_ID of the record we're merging into
--
update load_next_msl set
--select what='merge into existing taxon', load_next_msl._action, load_next_msl.change, load_next_msl._src_lineage, src_ictv=dest_ictv_id, merge_min_ictv_id=mergeMin.min_dest_ictv_id, load_next_msl._dest_lineage, load_next_msl._dest_taxon_name, targ_name=targ.name, targ_id=targ.taxnode_id, targ_ictv=targ.ictv_id,
	dest_taxnode_id = targ.taxnode_id
	,dest_ictv_id = (case when mergeMin.min_dest_ictv_id < targ.ictv_id then min_dest_ictv_id else ictv_id end)
from load_next_msl 
-- get min from merging records
join (
	-- compute the lowest ICTV_ID amongst all load_next_msl rows being merged into the same target.
	select _dest_taxon_name, min_dest_ictv_id = min(dest_ictv_id)
	from load_next_msl
	where isWrong is NULL
	AND _action like 'merge%'
	group by _dest_taxon_name
) as mergeMin on mergeMin._dest_taxon_name = load_next_msl._dest_taxon_name
-- get target record
join taxonomy_node targ on targ.msl_release_num=load_next_msl.dest_msl_release_num and targ.name = load_next_msl._dest_taxon_name
where isWrong is NULL
AND _action like 'merge%'
	

--
-- when merging into an a renamed/created taxon
--
-- take the lowest ICTV_ID amongst all the load_next_msl rows that are merging, and the ICTV_ID of the record we're merging into
--
--update load_next_msl set
--
select what='merge into re-named taxon', load_next_msl._action, load_next_msl.change, load_next_msl._src_lineage, src_ictv=load_next_msl.dest_ictv_id, merge_min_ictv_id=mergeMin.min_dest_ictv_id, load_next_msl._dest_lineage, load_next_msl._dest_taxon_name, targ_name=targ._dest_taxon_name, targ_id=targ.dest_taxnode_id, targ_ictv=targ.dest_ictv_id,
	dest_taxnode_id = targ.dest_taxnode_id
	,dest_ictv_id = (case when mergeMin.min_dest_ictv_id < targ.dest_ictv_id then mergeMin.min_dest_ictv_id else load_next_msl.dest_ictv_id end)
from load_next_msl 
-- get min from merging records
join (
	-- compute the lowest ICTV_ID amongst all load_next_msl rows being merged into the same target.
	select _dest_taxon_name, min_dest_ictv_id = min(dest_ictv_id)
	from load_next_msl
	where isWrong is NULL
	AND _action like 'merge%'
	group by _dest_taxon_name
) as mergeMin on mergeMin._dest_taxon_name = load_next_msl._dest_taxon_name
-- get target record
join load_next_msl targ on targ.dest_msl_release_num=load_next_msl.dest_msl_release_num and targ._dest_taxon_name = load_next_msl._dest_taxon_name and targ._action not like 'merge%'
where load_next_msl.isWrong is NULL
AND load_next_msl._action like 'merge%'




select merge_report='MERGEs handled in step 7d.', d_ictv_id=dest_ictv_id, *
from load_next_msl 
where isWrong is NULL
AND _action like 'merge%'
order by dest_ictv_id

	
