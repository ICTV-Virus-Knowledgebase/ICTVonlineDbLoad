-- extract proposal file list by MSL


-- scan for filename issues
select 'taxonoy_node' as table_name, msl_release_num, proposal
	, msl_dir = 'MSL'+case when msl_release_num<10 then '0' else ''end+RTRIM(msl_release_num)
from (
	select msl_release_num, proposal = in_filename  from taxonomy_node_dx 
	union 
	select msl_release_num, proposal = out_filename from taxonomy_node_dx 
) as src
where msl_release_num is not null and (proposal like '%.pdf%' or proposal like '%"%')
group by msl_release_num, proposal

select 'taxonomy_node_delta' as table_name, proposal
from taxonomy_node_delta
where (proposal like '%.pdf%' or proposal like '%"%')


-- create script to move proposals under MSL directories
select 
	msl_release_num
	, script = 'mkdir -p '+msl_dir+'; cp -a "'+proposal+'.pdf" "'+msl_dir+'/'+proposal+'.pdf"'
from (
	select msl_release_num, proposal = REPLACE(REPLACE(proposal, '.pdf',''),'"','')
		, msl_dir = 'MSL'+case when msl_release_num<10 then '0' else ''end+RTRIM(msl_release_num)
	from (
		select msl_release_num, proposal = in_filename  from taxonomy_node_dx 
		union 
		select msl_release_num, proposal = out_filename from taxonomy_node_dx 
	) as src
	where msl_release_num is not null and proposal is not null
	group by msl_release_num, proposal
) as ssrc
order by msl_release_num

