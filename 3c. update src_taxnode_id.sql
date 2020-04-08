--
-- set load_new_msl.prev_taxnode_id and dest_taxnode_id, dest_ictv_id
--


update load_next_msl set 
--select 	dest._action, dest.change, n.lineage, n.taxnode_id, dest._src_taxon_name, dest._action, dest.*,
	prev_taxnode_id = n.taxnode_id
	, dest_ictv_id = n.ictv_id
	, dest_taxnode_id = 
	(case 
		when dest._action not in ('new','split','abolish') 
		then n.taxnode_id+(201850000 - 20180000) -- jump from 10k spacing to 100k spacing,plus 50k for 2nd MSL release in that year
		else dest.dest_taxnode_id 
		end)
from load_next_msl as dest
left outer join taxonomy_node n on
	n.msl_release_num = (dest.dest_msl_release_num-1)
	and
	n.name=dest._src_taxon_name
where isWrong is NULL
and dest._action not in ('new', 'split')
and n.taxnode_id is not null
and (dest.prev_taxnode_id is null or dest.prev_taxnode_id <> n.taxnode_id)

--
-- need to collapse merge nodes - chose taxon with the "oldest" ictv_id (lowest)
--

update load_next_msl set
--select *,
	dest_taxnode_id = (select top 1 dest_taxnode_id from load_next_msl src where src._dest_taxon_name = load_next_msl._dest_taxon_name order by dest_ictv_id ASC)
	,dest_ictv_id =   (select top 1 dest_ictv_id    from load_next_msl src where src._dest_taxon_name = load_next_msl._dest_taxon_name order by dest_ictv_id ASC)
from load_next_msl 
where isWrong is NULL
AND _action like 'merge%'
	

select merge_report='MERGEs handled in step 7d.', d_ictv_id=dest_ictv_id, *
from load_next_msl 
where isWrong is NULL
AND _action like 'merge%'
order by dest_ictv_id

	