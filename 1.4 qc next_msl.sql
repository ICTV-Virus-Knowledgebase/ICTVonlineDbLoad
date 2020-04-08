-- ******************************************************************************
-- QC scans on [load_next_msl]
-- ******************************************************************************

-- 
select title='test 1.4.1 stats', src_level, dest_level, dest_in_change, src_out_change,  count(*) 
from load_next_msl
left outer join taxonomy_level as sl on sl.name = src_level
group by sl.id, src_level, dest_in_change, src_out_change, dest_level
order by sl.id, dest_level 

--
-- set dest_tree_id based on dest_taxnode_id for root node/*
--
/* not needed when IDs assigned in excel 
update [load_next_msl] set
	-- SELECT title='test 1.4.2', [dest_tree_id], 
	[dest_tree_id] = (select min(dest_taxnode_id) from [load_next_msl])
from [load_next_msl] 
where [dest_tree_id] is null 

select  title='test 1.4.2 check for null dest_tree_id',dest_tree_id, count(*) from [load_next_msl] group by dest_tree_id 
*/

-- check dest_tree_id
select 
	title='test 1.4.3',
	message=case 
		when count(*)<>(select count(*) from load_next_msl) then 'ERROR: inconsistent dest_tree_id' 
		when dest_tree_id is NULL then 'ERROR: dest_tree_id is NULL' 
		when dest_tree_id ='' then 'ERROR: dest_tree_id is EMPTY' 
		when (select count(*) from taxonomy_node where tree_id=dest_tree_id and level_id=100)>0 then 'ERROR: dest_tree_id ALREADY EXISTS in taxonomy_node' 
		else 'OK - dest_tree_id' end,
	dest_tree_id,
	ct=count(*),
	total_ct=(select count(*) from load_next_msl)
from load_next_msl
group by dest_tree_id
--if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.3; rows found', 18, 1) else print('PASS')

-- dest_taxnode_id	
select 
	title='test 1.4.4',
	message=case 
		when count(*)>1 then 'ERROR: dest_ictv_id used more than once'
		when dest_taxnode_id is null then 'ERROR: dest_ictv_id is NULL'
		when dest_taxnode_id = '' then 'ERROR: dest_ictv_id is EMPTY'
		else 'huh? QC internal error' end,
	dest_taxnode_id
from load_next_msl
group by dest_taxnode_id
having dest_taxnode_id is null or count(*) > 1
if @@ROWCOUNT > 0  raiserror('ERROR test 1.445; rows found', 18, 1) else print('PASS')

-- ------------------------------------------------------------------
-- verb warnings
-- ------------------------------------------------------------------

--
-- check for fields missing reuqired by certain verbs
--

-- is_type for new_type
select distinct dest_in_change, srC_out_change from load_next_msl
select 
	title='test 1.4.5',
	err_message='ERROR: new_type taxon missing is_type', 
	src_lineage, src_is_type, dest_in_change, src_out_change, dest_target, dest_level, dest_is_type
from load_next_msl 
where (dest_is_type is null or dest_is_type=0) and (dest_in_change like '%_type' or src_out_change like '%_type')
if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.5; rows found', 18, 1) else print('PASS')

-- convert new_type to new
update [load_next_msl] set
-- select title='test 1.4.5b', *,
	dest_in_change = 'new'
	, corrected = isnull(corrected+'; ','')+'dest_in_change: new_type>>new'
from [load_next_msl] where dest_in_change = 'new_type'

select 
	title='test 1.4.5c',
	err_message='ERROR: new taxon missing dest_level', 
	dest_target, dest_level
from load_next_msl 
where dest_level is null and (dest_in_change in ( 'new', 'split') or src_out_change = 'promote')
if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.5c; rows found', 18, 1 ) else print('PASS')

update [load_nexT_msl] set
	-- select title='test 1.4.24', src_taxnode_id, dest_level, dest_target,
	dest_level = case (len(dest_target)-len(replace(dest_target,';','')))
		when 0 then (case when src_level='tree' 
			then 100 -- tree 
			else 200  -- order
			end) 
		when 1 then 300 -- family
		when 2 then 400 -- sub-family
		when 3 then 500 -- genus
		when 4 then 600 -- species
	end
	, corrected =  isnull(corrected+'; ','')+'set dest_level'
from [load_next_msl] 
where dest_target is not null AND (dest_level ='' or dest_level is null)
and dest_in_change in ('new', 'split') or src_out_change in ('promote')

-- check for rename with dest_lineage != src_lineage 
select
	title='test 1.4.6',
	message=case 
		when dest_target like '%;%' and src_parent_lineage<>dest_parent_lineage
		then 'WARNING: rename destination is a lineage - perhaps this should be move_rename?'
		else 'INFO: full lineage not needed for a rename' end,
	src_lineage, src_out_change, dest_target
from load_next_msl
where src_out_change = 'rename' and dest_target like '%;%'

-- fix update verb, where needed
update load_next_msl set 
	-- select 	title='test 1.4.7', src_out_change, src_lineage, dest_target,
	src_out_change='move_rename'
	, corrected =  isnull(corrected+'; ','')+'out_change:rename>>move_rename'
from load_next_msl
where 
src_out_change = 'rename' 
AND dest_target like '%;%' 
-- check for different lineage
AND src_parent_lineage<>dest_parent_lineage

--
-- fix dest_target to strip lineage
--
--
/*
-- 20180301 why do we want to do this? 
update load_next_msl set 
	-- select title='test 1.4.8', src_out_change, src_lineage, dest_target,
	dest_target=LTRIM(right(replace(dest_target,';',space(200)),200))
	, corrected =  isnull(corrected+'; ','')+'dest_target: strip lineage (rename & src_parent=dest_parent)'
from load_next_msl
where 
src_out_change = 'rename' 
AND dest_target like '%;%' 
-- check for different lineage
AND src_parent_lineage=dest_parent_lineage
*/

select
	title='test 1.4.9',
	message=case 
		when ref_filename is null then 'ERROR: change of type status without a proposal filename'
		else 'huh? QC internal error' end,
	src_lineage, src_is_type, dest_is_type, src_out_change, dest_in_change, dest_target,  ref_filename
from load_next_msl
where src_is_type <> dest_is_type and ref_filename is null
if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.9; rows found', 18, 1 ) else print('PASS')


-- ******************************************************************************
-- load cleanups
-- ******************************************************************************


/* -- dont need when built from delta load


-- added dest_taxnode_id unique index (ok once nulls gone)
/****** Object:  Index [IX_load_next_msl-dest_taxnode_id]    Script Date: 05/14/2016 12:29:09 ******/
ALTER TABLE [dbo].[load_next_msl] ADD  CONSTRAINT [IX_load_next_msl-dest_taxnode_id] UNIQUE NONCLUSTERED 
(
	[dest_taxnode_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
*/
-- report  proposal names w/o known extensions
--update load_next_msl set
select title='test 1.4.10', 'ERROR: missing file extension', ref_filename
from load_next_msl
where ref_filename <> '' and not( ref_filename like '%.pdf' or ref_filename like '%.zip')
if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.10; rows found', 18, 1 ) else print('PASS')


-- check for ";" or "," in proposal names - indicates a list!
select title='test 1.4.11', 'ERROR: quotes in filename',  ref_filename 
from load_next_msl 
where ref_filename like '%;%'  or ref_filename like '% %' or ref_filename like '%MISSING%'
if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.11; rows found', 18, 1 ) else print('PASS')

-- check line count - should be last (excel row -1) 
select title='test 1.4.12','Number of rows of data: ', COUNT(*), ' (check vs Excel file!)' from [load_next_msl]

-- check accents came over ok
select title='test 1.4.13',src_name, dest_target, src_isolates, dest_isolates 
from load_next_msl 
where 
	src_name like '%í%' or dest_target like '%í%' or src_name like 'Jun%n virus' -- Junín virus
or  src_name like '%Kalancho%'  -- Kalanchoë mosaic virus
or  src_name like '%Paran% virus' -- Paraná virus
or  dest_isolates like 'X%nch%ng mosquito virus' -- Xincheng anphevirus / Xīnchéng mosquito virus
or  dest_isolates like N'ī' or src_isolates like  N'ī'

-- correct accents -- if needed
update load_next_msl set 
-- select title='test 1.4.14', src_name, dest_target,
	src_name=REPLACE(REPLACE(REPLACE(src_name,'+¡','í'),'+½','ë'),'+í','á')
	,dest_target=REPLACE(REPLACE(REPLACE(dest_target,'+¡','í'),'+½','ë'),'+í','á')
from load_next_msl 
where src_name like '%+%' or src_name like '%+½%' or src_name like '%+í%'
or    dest_target like '%+%' or dest_target like '%+½%' or dest_target like '%+í%'

-- correct smart quotes
update load_next_msl set -- select title='test 1.4.15',src_isolates, dest_isolates, 
		src_isolates=REPLACE(REPLACE(replace(src_isolates,'“', '"'),'”','"'),'‘','''')
		, dest_isolates=REPLACE(REPLACE(replace(dest_isolates,'“', '"'),'”','"'),'‘','''')
from	load_next_msl 
where	src_isolates like '%“%' or src_isolates like '%”%' or src_isolates like '%‘%'
or		dest_isolates like '%“%' or dest_isolates like '%”%' or dest_isolates like  '%‘%'
		

-- correct vagrant spaces
select title='test 1.4.16', message='WARNING: records with spaces in dest_target adjacent to a semi-colon or beginning or end of line (fixing)'
	, dest_target
	, dest_target_highlight=case 
		when dest_target like '%; %' or dest_target like '% ;%' then replace(replace(ltrim(rtrim(dest_target)),'; ',';[ ]'),' ;','[ ];')
		when  dest_target like ' %'  then '[ ]'+ltrim(dest_target)
		when dest_target like '% ' then rtrim(dest_target)+'[ ]'
		when dest_target like '%   %' then replace(dest_target,'   ','[ | | ]')
		when dest_target like '%  %' then replace(dest_target,'  ','[ | ]')
	end
from load_next_msl
where dest_target like '%; %' or dest_target like '% ;%' or dest_target like ' %' or dest_target like '% ' or dest_target like '%  %'
if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.16; vagrent spaces found', 18, 1 ) else print('PASS')


update load_next_msl set -- select title='test 1.4.17',
	dest_target=replace(replace(replace(replace(ltrim(rtrim(dest_target)),'; ',';'),' ;',';'),'  ',' '),'  ',' ')
	, corrected =  isnull(corrected+'; ','')+'dest_target: removed spaces:'+
	case 
		when dest_target like '%; %' or dest_target like '% ;%' then replace(replace(ltrim(rtrim(dest_target)),'; ',';[ ]'),' ;','[ ];')
		when dest_target like ' %'  then '[ ]'+ltrim(dest_target)
		when dest_target like '% ' then rtrim(dest_target)+'[ ]'
		when dest_target like '%   %' then replace(dest_target,'   ','[ | | ]')
		when dest_target like '%  %' then replace(dest_target,'  ','[ | ]')
	end
from load_next_msl
where dest_target like '%; %' or dest_target like '% ;%' or dest_target like ' %' or dest_target like '% ' or dest_target like '%  %'

-- correct vagrant spaces
select title='test 1.4.18', message='WARNING: records ending in as semi-colon (fixing)', dest_target
from load_next_msl
where rtrim(dest_target) like '%;' 
update load_next_msl set -- select title='test 1.4.19',
	dest_target=left(rtrim(dest_target),len(rtrim(dest_target))-1)
from load_next_msl
where rtrim(dest_target) like '%;' 

-- **********************************************************
-- stats
-- **********************************************************
select title='test 1.4.19', dest_in_change, src_out_change, taxa_ct=count(*)
from load_next_msl 
group by dest_in_change, src_out_change
union all
select title='test 1.4.20', dest_in_change, src_out_change, taxa_ct=count(*)
from (
	select 
		dest_in_change = case when dest_in_change is null then null else '%' end
		,src_out_change = case when srC_out_change IS null then null else '%' end
		,dest_taxnode_id
	from load_next_msl 
	where ISNULL(dest_in_change, src_out_change) is not null
) as src
group by dest_in_change, src_out_change
order by dest_in_change desc, src_out_change desc

-- **********************************************************
-- checking for MISSING internal nodes 
-- >>> 20180302 this is addressed below better <<<
--
-- 20180228 not sure when and how these need to be fixed!!!!!
-- two classes
--  * dest_parent_lineage LIKE '%;Unassigned'
--      genus, subfamily, 
--  * everything else
-- **********************************************************
select 
	title='test 1.4.21'
	,error = 'missing parent node assumed by some taxa'
	,src.src_lineage, src.dest_target, src.dest_parent_lineage, p.dest_target, sp.src_lineage, src.src_out_change, src.dest_in_change, src.dest_taxnode_id, src.dest_parent_id
from [load_nexT_msl] AS src
left outer join [load_next_msl] as p 
	ON (P.dest_target = src.dest_parent_lineage or P.dest_target = src.dest_parent_name)
left outer join [load_next_msl] as sp
	ON SP.src_lineage = src.dest_parent_lineage 
where src.dest_target like '%;%'
and (p.dest_target is null and sp.src_lineage is null)
if @@ROWCOUNT > 0  raiserror('ERROR test 1.4.21; rows found', 18, 1 ) else print('PASS')


select * from [load_next_msl] where dest_target like '%Ophiovirus%'
select * from [load_next_msl] where srC_lineage like 'Unassigned;Aspiviridae;Unassigned;Ophiovirus' or srC_lineage like '%Ophiovirus%'



-- -----------------------------------------------------------------------------
--
-- figure out parents in advance
-- 
-- In order to fill in missing Unassigned implicit taxa, one must turn off the RAISEERROR
-- and run this block many times. 
-- -----------------------------------------------------------------------------
--
-- add src_parent_lineage computed column
/*
ALTER TABLE [dbo].[load_next_msl] ADD  
	[src_parent_lineage]  AS (case when [src_lineage] like '%;%' then reverse(ltrim(replace(substring(replace(reverse([src_lineage]),';',space((200))),(200),(5000)),space((200)),';')))  end) PERSISTED
GO
ALTER TABLE [load_next_msl] ADD
	[dest_parent_id] int
	GO

CREATE NONCLUSTERED INDEX [IX_load_next_msl-dest_parent_id] ON dbo.load_next_msl
	(
	[dest_parent_id]
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- *[BLOCK]* BEGIN CREATE implicit [Unassigned]
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	update load_next_msl set 
	-- select load_next_msl.src_taxnode_id, load_next_msl.src_lineage, load_next_msl.src_level, load_next_msl.src_out_change, load_next_msl.dest_in_change, load_next_msl.dest_level, load_nexT_msl.dest_target, load_next_msl.dest_taxnode_id, load_next_msl.dest_parent_id, '>>p>>',p.*,'>>pn>>',pn.*, '>>pss>>',pss.*, '>>psd>>',psd.*, '>>pds>>',pds.*, '>>tree>>',tree.*,
	dest_parent_id=isnull(isnull(isnull(p.dest_taxnode_id, isnull(pn.dest_taxnode_id,pss.dest_taxnode_id)),isnull(psd.dest_taxnode_id, pds.dest_taxnode_id)),tree.dest_taxnode_id)
/*
		 src.dest_taxnode_id, src.src_lineage, src.dest_target
		, p_dd = p.dest_taxnode_id -- load_next_msl
		--	, p.src_lineage, p.dest_target
		, p_ss = pss.dest_taxnode_id -- load_next_msl
		--	, pss.src_lineage, pss.dest_target
		, p_sd = psd.dest_taxnode_id -- load_next_msl
		, p_ds = pds.dest_taxnode_id
		, tree = tree.dest_taxnode_id
	--	, src.*
	--	into #id_match
*/	from load_next_msl
	-- parent (lineage)
	left outer join load_next_msl as p ON		p.dest_target=load_next_msl.dest_parent_lineage
	-- parent name match for renames where dest_target has lineage stripped
	left outer join load_next_msl as pn ON		pn.dest_name=load_next_msl.dest_parent_name and load_next_msl.dest_parent_name <> 'Unassigned'
	left outer join load_next_msl as pss ON		pss.src_lineage=load_next_msl.src_parent_lineage and load_next_msl.src_out_change is null
	left outer join load_next_msl as psd ON		psd.src_lineage=load_next_msl.dest_parent_lineage
	left outer join load_next_msl as pds ON 	pds.dest_parent_lineage=load_next_msl.src_parent_lineage
	left outer join load_next_msl as tree on	tree.src_level='tree' and (load_next_msl.src_level in ('tree','order') or load_next_msl.dest_level=200)
	where (load_next_msl.dest_parent_id is null and (load_next_msl.src_out_change != 'abolish' or load_next_msl.src_out_change is null))
	or  load_next_msl.dest_name in ( 'Aspiviridae','Ophiovirus','Blueberry mosaic associated ophiovirus') 
		/*where 
			  p.dest_taxnode_id  is null
			and  pss.dest_taxnode_id is null
			and  psd.dest_taxnode_id is null
			and  pds.dest_taxnode_id is null*/
		--where src.dest_taxnode_id in (20161660,20161658,20164759,20161697,20161668)
	-- check for missing
	select title='2.1', problem='Missing load_next_msl.dest_parent_id', *
	from load_next_msl
	where dest_parent_id is null and (load_next_msl.src_out_change != 'abolish' or load_next_msl.src_out_change is null)
	--if @@ROWCOUNT > 0  raiserror('ERROR test 2.1; rows found', 18, 1 ) else print('PASS')

	-- insert one missing Unassigned Genus or SubFamily
	--
	-- data entry often referes to Unassigned taxa implicitly, which must be created. 
	-- only create one at a time, as we assign dest_taxnode_id based on current max. 
	-- also, must re-run the update above to assign the dest_parent_id after each one. 
	insert into [load_next_msl] 
			select TOP 1 
			-- select orig = [dest_target], 
		   [src_tree_id]
		  ,[src_msl_release_num]
		  ,[src_left_idx]=NULL
		  ,[src_taxnode_id]=NULL
		  ,[src_ictv_id]=NULL
		  ,[src_is_hidden]=NULL
		  ,[src_lineage]=NULL
		  ,[src_level]=NULL
		  ,[src_name]=NULL
		  ,[src_is_type]=NULL
		  ,[src_isolates]=NULL
		  ,[src_ncbi_accessions]=NULL
		  ,[src_abbrevs]=NULL
		  ,[src_molecule]=NULL
		  ,[dest_in_change]='new'
		  ,[src_out_change]=NULL
		  ,[dest_target]=[dest_parent_lineage]
		  ,[orig_ref_filename]
		  ,[ref_filename]
		  ,[ref_notes]
		  ,[ref_problems]
		  ,[dest_level]=(select parent_id from taxonomy_level where dest_level=id)
		  ,[dest_is_type]=0
		  ,[dest_is_hidden]=(select (case when name='genus' then 1 else 0 end) from taxonomy_level where dest_level=id)
		  ,[dest_isolates]=NULL
		  ,[dest_ncbi_accessions]=NULL
		  ,[dest_abbrevs]=NULL
		  ,[dest_molecule]=NULL
		  ,[dest_msl_release_num]
		  ,[dest_tree_id]
		  ,[dest_taxnode_id]=(select max(dest_taxnode_id)+1 from [load_next_msl])
		  ,[edit_comments]=NULL
		  ,[corrected]='2.1 Unassigned taxon created implicitly'
		  ,[dest_parent_id]=NULL
	 FROM [dbo].[load_next_msl] as src
	 WHERE [dest_parent_id] is NULL and  (src.src_out_change != 'abolish' or src.src_out_change is null)
	 and not exists(select * from [load_next_msl] where dest_target = src.[dest_parent_lineage])
	 and ([dest_parent_name] = 'Unassigned'  -- might want to remove this constraint in some case
		or dest_parent_lineage in ('Unassigned;Bacilladnaviridae', 'Unassigned;Aspiviridae;Unassigned;Ophiovirus')
		)

	-- list inserted implicit Unassigned taxa
	select top 20 *
	from  [load_next_msl] 
	--where dest_taxnode_id is NULL
	order by dest_taxnode_id desc
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- *[BLOCK]* ENDimplicit [Unassigned]
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

select * from load_next_msl where dest_target like '%Simiispumavirus%' or src_lineage like '%Simiispumavirus%'



--delete from [load_next_msl]  where dest_taxnode_id > 20176013 -- debug


--
-- MSL32: rename family: Unassigned;Ophioviridae;Unassigned;Ophiovirus >> Unassigned;Aspiviridae;Unassigned;Ophiovirus
-- CHECK if it worked out 
--
select 'MSL32: rename family: check:', * 
from [load_next_msl]
where dest_target like '%Aspiviridae%'
or src_lineage like '%Ophioviridae%'
order by isnull(dest_target, src_lineage)


