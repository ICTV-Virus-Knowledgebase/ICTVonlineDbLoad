-- ---------------------------------------------------------------------------------------------------------------
--
-- accents 
--
-- ---------------------------------------------------------------------------------------------------------------
-- accents
--
-- check accents
--
select title, msl_release_num, status_msg, count(*) as [count]
from (
	select 'accent_check:' as title 
		, msl_release_num, taxnode_id, name
		, status_msg = case 
			when name like 'Jun_n %virus'  or name like 'Amapar_ %virus' then case when name like '%í%' then 'OK: í' else 'ERROR: í missing' end
			when name like 'Sabi%virus%' or name like 'Paran%virus%' then case when name like '%á%' then 'OK: á' else 'ERROR: á missing' end
			when name like 'Kalancho%virus%' then case when name like '%ë%' then 'OK: ë' else 'ERROR: ë missing' end
			when isolate_csv like 'M_ji_ng %'  then case when isolate_csv like N'%ā%' then N'OK: ā' else N'ERROR: ā missing' end
			when isolate_csv like 'X_nch_ng %' then case when isolate_csv like N'%ī%' then N'OK: ī' else N'ERROR: ī missing' end
			when isolate_csv like 'L_sh_ %'    then case when isolate_csv like N'%ĭ%ì%' then N'OK: ĭ & ì ' else N'ERROR: ĭ and/or ì missing' end
			when isolate_csv like 'T_ch_ng %'  then case when isolate_csv like N'%ǎ%' then N'OK: ǎ' else N'ERROR: ǎ missing' end
			when isolate_csv like 'W_nzh_u %'  then case when isolate_csv like N'%ē%ō%' then N'OK: ē & ō' else N'ERROR: ē and/or ō missing' end
			when isolate_csv like 'S_nxi %'	then case when isolate_csv like N'%ā%' then N'OK: ā' else N'ERROR: ā missing' end
			else 'error: unknown target'
			end		
	from taxonomy_node
	where msl_release_num in (35)--(@msl) --, @msl-1)
	and (
		-- taxon names
		name like 'Jun_n %virus'  or name like 'Amapar_ %virus' or name like '%í%'
		or name like 'Sabi%virus%' or name like 'Paran%virus%' or name like '%á%'
		or name like 'Kalancho%virus%' or name like '%ë%'
		-- isolate names
		or isolate_csv like 'M_ji_ng %'
		or isolate_csv like 'X_nch_ng %'
		or isolate_csv like 'L_sh_ %'
		or isolate_csv like 'T_ch_ng %'
		or isolate_csv like 'W_nzh_u %'
		or isolate_csv like 'S_nxi %'
		or isolate_csv like 'W_nzh_u %'
	)
) as src 
group by title, msl_release_num, status_msg
order by msl_release_num desc


select 'accent_check NAME:' as details
	, msl_release_num, taxnode_id, name
	, [status] = case 
		when name like 'Jun%n%virus%' or name like 'Amapar%virus%' then case when name like '%í%' then 'OK: í' else 'ERROR: í missing' end
		when name like 'Sabi%virus%' or name like 'Paran%virus%' then case when name like '%á%' then 'OK: á' else 'ERROR: á missing' end
		when name like 'Kalancho%virus%' then case when name like '%ë%' then 'OK: ë' else 'ERROR: ë missing' end
		else 'error: unknown target'
		end		
from taxonomy_node 
where msl_release_num in (@msl, @msl-1)
and (
	name like 'Jun%n%virus%' or name like 'Amapar%virus%' or name like '%í%'
	or name like 'Sabi%virus%' or name like 'Paran%virus%' or name like '%á%'
	or name like 'Kalancho%virus%' or name like '%ë%')
order by msl_release_num desc

-- declare @msl int; set @msl=(select MAX(msl_release_num) from taxonomy_node)
select 'accent_check ISOLATE:' as details
	, msl_release_num, taxnode_id, name, isolate_csv
	, [status] = case 
		when isolate_csv like 'M_ji_ng %'  then case when isolate_csv like N'%ā%' then N'OK: ā' else N'ERROR: ā missing' end
		when isolate_csv like 'X_nch_ng %' then case when isolate_csv like N'%ī%' then N'OK: ī' else N'ERROR: ī missing' end
		when isolate_csv like 'L_sh_ %'    then case when isolate_csv like N'%ĭ%ì%' then N'OK: ĭ & ì ' else N'ERROR: ĭ and/or ì missing' end
		when isolate_csv like 'T_ch_ng %'  then case when isolate_csv like N'%ǎ%' then N'OK: ǎ' else N'ERROR: ǎ missing' end
		when isolate_csv like 'W_nzh_u %'  then case when isolate_csv like N'%ē%ō%' then N'OK: ē & ō' else N'ERROR: ē and/or ō missing' end
		when isolate_csv like 'S_nxi %'	then case when isolate_csv like N'%ā%' then N'OK: ā' else N'ERROR: ā missing' end
		else 'error: unknown target'
		end		
from taxonomy_node 
where msl_release_num in (@msl, @msl-1)
and (
	   isolate_csv like 'M_ji_ng %'
	or isolate_csv like 'X_nch_ng %'
	or isolate_csv like 'L_sh_ %'
	or isolate_csv like 'T_ch_ng %'
	or isolate_csv like 'W_nzh_u %'
	or isolate_csv like 'S_nxi %'
	or isolate_csv like 'W_nzh_u %'
)
order by msl_release_num desc


--
-- accent details over time
--
select name, count=count(*), min_msl=min(msl_release_num), max_msl=max(msl_release_num) from taxonomy_node where  name like 'Jun_n %virus' group by name order by min(msl_release_num)
select name, count=count(*), min_msl=min(msl_release_num), max_msl=max(msl_release_num)  from taxonomy_node where   name like 'Amapar_ %virus' group by name order by min(msl_release_num)
select name, count=count(*), min_msl=min(msl_release_num), max_msl=max(msl_release_num)  from taxonomy_node where   name like 'Kalancho%virus%' group by name order by min(msl_release_num)

