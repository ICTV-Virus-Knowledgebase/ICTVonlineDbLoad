-- -----------------------------------------------------------------------------
--
-- QUERY for duplicate names
--
-- -----------------------------------------------------------------------------

declare @msl int; set @msl=(select MAX(msl_release_num) from taxonomy_node)
select 'TARGET MSL: ',@msl

select 'just this MSL' as scope, msl_release_num, name, count=COUNT(name)
	, [duplicate taxon names] = (case when name = 'unassigned' and min(level_id)=500 and max(level_id)=500 then 'OK - Unassigned genera permitted' else 'PROBLEM!' end)
	, MIN(lineage) as min_lineage, MAX(lineage) as max_lineage
from taxonomy_node
where msl_release_num = @msl
group by msl_release_num, name
having COUNT(name) > 1



select 
	'all MSL' as scope, msl_release_num, name, COUNT(name) as [count]
	, [duplicate taxon names]  =(case when name = 'unassigned' and min(level_id)=500 and max(level_id)=500 then 'OK - Unassigned genera permitted' else 'PROBLEM!' end)
	, MIN(lineage) as min_lineage, MAX(lineage) as max_lineage
from taxonomy_node
where
	 msl_release_num is not null 
	 and is_deleted=0
	and (notes is null or notes not like '%known duplicate taxon name%')
group by msl_release_num, name
having COUNT(name) > 1 and name <> 'unassigned'
and not (
	-- MSL 1-13 had genera whose name matched one of their species
	((COUNT(name)=2 and MAX(lineage) like MIN(lineage)+';%') and max(msl_releasE_num)>14)
	-- MSL10-15 had genera named 'Unnamed genus'
	or (name = 'Unnamed genus' and max(msl_release_num) < 16)
	-- MSL 22 - "Chayote mosaic virus" created in two separate genera (Geminiviridae>Begomovirus & Tymovirus). 
	-- The next year, the Geminivridae folks renamed their version “Chayote yellow mosaic virus”
	or (name = 'Chayote mosaic virus' and max(msl_release_num) =22)
)
order by msl_release_num

-- peek
-- select * from taxonomy_node where msl_release_num = 31 order by left_idx
-- 
select 
	title='detail taxa duplication report:' 
	,prev_tags, prev_proposal, msl=msl_release_num, lin=left(lineage, len(lineage)-len(name)),name, next_proposal, next_tags, next_lineage, notes
	, * 
from taxonomy_node_dx as dx where 
msl_release_num is not null
and name in (
--	'Lipid phage PM2', 'Polyomavirus'
--	'Unnamed genus'
--	'Dermacentor mivirus'
	'NO_MATCHES'
) 
order by dx.name, dx.taxnode_id

--  record for postarity
/*update taxonomy_node set
	-- select * ,
	notes = isnull(notes+'; ','')+'Known duplicate taxon name: MSL 22 - [Chayote mosaic virus] created in two separate genera (Geminiviridae>Begomovirus & Tymovirus).'
	+' The next year, the Geminivridae folks renamed their version [Chayote yellow mosaic virus]'
from taxonomy_node where 
name = 	'Chayote mosaic virus' and msl_release_num = 22
and (notes is null or not notes like '%known duplicate taxon%')

*/

-- -----------------------------------------------------------------------------
-- 
-- QUERY for duplicate *lineages*
-- 
-- 
-- -----------------------------------------------------------------------------


select 
	[query duplicate lineage] = 'Found duplicates!' 
	+ (case when msl_release_num = (select max(msl_release_num) from taxonomy_node) then '    !!NEW!!' else ''  end)
	, msl_release_num, lineage, count(*)
from taxonomy_node
where msl_release_num is not null
AND is_deleted = 0 AND is_hidden = 0 AND is_obsolete =0
group by msl_release_num, lineage
having count(*) > 1 or  lineage is null
order by msl_release_num desc

-- -----------------------------------------------------------------------------
--
-- QUERY for names with ';'
-- 
-- there should not be any!
--
-- -----------------------------------------------------------------------------

select 'problem:' as [names with embedded ;]
	, msl_release_num, in_change, COUNT(*) as [count]
from taxonomy_node
where name like '%;%'
group by msl_release_num, in_change
order by msl_release_num, in_change


