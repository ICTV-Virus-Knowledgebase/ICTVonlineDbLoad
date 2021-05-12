/*
* QC: taxonomy_node.name for suffixes
*/

/* 
 * legal suffixes defined here
 */
SELECT 'legal suffices in suffix_ columns:', *
  FROM [ICTVonline36].[dbo].[taxonomy_level]

/*
 * QC taxonomy_node.name suffixes
 */
select n.msl_release_num, n.[rank], n.name 
	, which = (case 
		when n.name like '%'+l.suffix then 'suffix'
		when n.name like '%'+l.suffix_viroid then 'suffix_viroid'
		when n.name like '%'+l.suffix_nuc_acid then 'suffix_nuc_acid'
		else 'ERROR'
		end)
from taxonomy_node_names n
join taxonomy_level l on l.id = n.level_id
where 
-- how far back do we want to go? 
msl_release_num is not null
-- no convention for species, outside of viroids
and level_id < (select id from taxonomy_level where name='species')
and not (
	-- 
	-- modern suffixes come from the table, add some plurals, etc
	--
	n.name like '%'+l.suffix
	or --'Influenzavirus A'
	n.name like '%'+l.suffix+' _'
	or --'Mu-like viruses'
	n.name like '%'+l.suffix+'es'
	or
	n.name like '%'+l.suffix_viroid
	or 
	n.name like '%'+l.suffix_nuc_acid
	-- 
	-- historical suffixes
	--
	or -- 'T5-like phages' < MSL23
	(n.msl_release_num < 23 and n.rank in ('genus','family') and (n.name like '% phages' or n.name like '% phage' or n.name like '% phage %'))
	or -- 'Viroids' < MSL17
	(n.msl_release_num < 17 and n.rank in ('genus','family') and (n.name like 'viroids'))
	or -- 'Unnamed genus' < MSL17
	(n.msl_release_num < 17 and n.rank in ('genus') and (n.name like 'Unnamed genus' or n.name like 'Unnamed genus _'))
	or -- 'Influenza virus A and B' < MSL15
	(n.msl_release_num < 15 and n.rank in ('genus') and (n.name like 'Influenza virus A and B'))
	or -- 'Hepatitis virus C group' < MSL14
	(n.msl_release_num < 16 and n.rank in ('genus','family') and (n.name like '% group' or n.name like '% subgroup %' or n.name like '% group %'))
	or -- '% family' < MSL14
	(n.msl_release_num < 14 and n.rank in ('genus') and (n.name like '% subgenus'))
	or -- '% family' < MSL12
	(n.msl_release_num < 12 and n.rank in ('family') and (n.name like '% family'))
)
order by msl_release_num desc, left_idx

