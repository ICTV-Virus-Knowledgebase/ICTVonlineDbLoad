/* --------------------------------------------------
 *
 * apply changes [load_next_msl] => [taxonomy_node]
 * ACTIONS: NEW, SPLIT, MOVE, RENAME 
 * ORDER: high to low rank
 *
 * 20220309 add load_next_msl_isOk 
 * 20220309 rework to use load_next_msl._dest_rank=@rank and ignore user-entered load_next_msl.rank
 * ---------------------------------------------------*/
-- MSL37 - schema upgrade (needs to be added to 0.b2.create_table-load_next_msl.sql)
--
-- add columns to track merges
-- change sort to varchar instead of int
--
ALTER table load_next_msl add  merged_left_sort nvarchar(50) NULL;
ALTER table load_next_msl add  merged_right_sort nvarchar(50) NULL;
ALTER table load_next_msl add  merged_reason nvarchar(50) NULL;
ALTER table load_next_msl add  sort_str nvarchar(50) NULL;
GO
UPDATE load_next_msl SET sort_str = convert(varchar(50),sort,128)
ALTER table load_next_msl drop column sort;
EXEC sp_rename 'dbo.load_next_msl.sort_str', 'sort', 'COLUMN'; 
ALTER TABLE load_next_msl ALTER COLUMN sort NVARCHAR(50) NOT NULL;
GO
ALTER TABLE load_next_msl ADD CONSTRAINT AK_sort_uniq UNIQUE (sort);
GO
ALTER TABLE load_next_msl ALTER COLUMN isDone NVARCHAR(1000) NULL;
go
drop view load_next_msl_isOk
GO
CREATE OR ALTER VIEW load_next_msl_isOk as select * from load_next_msl where isWrong is null
GO
BEGIN TRANSACTION
-- COMMIT TRANSACTION

-- rollback transaction

/* ==================================================================================
 * ==================================================================================
 * FIXES/DEBUG MSL37
 * ==================================================================================
 * ==================================================================================
 */
-- remove blank/NOP rows
select * from load_next_msl where _src_taxon_name is null and _dest_taxon_name is null 
delete from load_next_msl where _src_taxon_name is null and _dest_taxon_name is null 

-- if action='abolish' clear destTaxa (people often put the genus when abolishing a species???!?!?)
select * from load_next_msl where _action='abolish' and _dest_taxon_name is not null
update load_next_msl set realm=NULL, subrealm=NULL, kingdom=NULL, subkingdom=NULL, phylum=NULL, subphylum=NULL, [class]=NULL, subclass=NULL, [order]=NULL, suborder=NULL, family=NULL, subfamily=NULL, genus=NULL, subgenus=NULL, species=NULL where _action='abolish' and _dest_taxon_name is not null

--typo do not rename Stanholtvirus into Squirtyvirus
update load_next_msl set genus='Stanholtvirus' --select * 
from load_next_msl where srcGenus = 'Stanholtvirus' and genus='Squirtyvirus' and isWrong is null and not proposal like '%;%'

--
-- duplicates and danglers (logic might only work for "new" - need to think more)
-- 
select * from (
	select sort, _dest_taxon_rank,_action, proposal, _dest_taxon_name,
		isDone = (select count(*) from taxonomy_node n where n.msl_release_num = ld.dest_msl_release_num and n.name =ld._dest_taxon_name)
	from load_next_msl_isOk ld
	--where _action = 'new'
) sr where  isDone <> 1
order by isDone

select * from taxonomy_node where msl_release_num=37 and name in ('Pbunavirus PA01','Chivirus BSPM4')
select [report]='list multiple modifications of the same dest_taxon_name'
	, sort, proposal, _src_lineage,  _src_taxon_name, _action, _dest_taxon_rank,_dest_taxon_name, _dest_lineage 
from load_next_msl_isOk 
where isWrong is null
and _dest_taxon_name in 
	(select _dest_taxon_name from load_next_msl_isOk where isWrong is null group by _dest_taxon_name having count(*) > 1)
order by _src_taxon_name, _dest_taxon_name

--
-- REPORT: taxa modified twice
--    CHAINs: A->B->C  (consistent, two proposals)
--    DUPS: A->B, A->B (consistent, two proposals)
--    CONFLICT: A->B, C->B (inconsistent)
--
select  report='ERROR: _dest_taxon_name with multiple actions',
	one._dest_taxon_name, one.sort, one.proposal, one._src_lineage, one._action, one._src_taxon_rank, one._dest_lineage, 
	[<< STATUS >>]=(case 
		when one._dest_lineage = two._src_lineage then '     = chain =' 
		when isnull(one._src_lineage,'NULL') = isnull(two._src_lineage,'NULL') and one._dest_lineage = two._dest_lineage then '    = DUP = '
		else '<< CONFLICT >>' 
		end),
	two._src_lineage, two._action, _taxon_rank=ISNULL(two._src_taxon_rank,two._dest_taxon_rank), two._dest_lineage, two.sort, two.proposal
from load_next_msl_isOk one
left outer join load_next_msl_isOk two 
on --one._dest_lineage = two._src_lineage and 
one._dest_taxon_name = two._dest_taxon_name
and one.sort < two.sort
where one._dest_taxon_name in 
	-- taxa that appear twice as the _dest_taxon_name
	(select _dest_taxon_name from load_next_msl_isOk group by _dest_taxon_name having count(*) > 1)
and one._dest_taxon_name is not null and two._dest_taxon_name is not null
order by one._dest_taxon_name

select report='ERROR: _src_taxon_name with multiple actions',
  one._src_taxon_name, one.sort, one.proposal, one._src_lineage, one._action, one._src_taxon_rank, one._dest_lineage, 
	[<< STATUS >>]=(case 
		when one._dest_lineage = two._src_lineage then '     = chain =' 
		when isnull(one._src_lineage,'NULL') = isnull(two._src_lineage,'NULL') and one._dest_lineage = two._dest_lineage then '    = DUP = '
		else '<< CONFLICT >>' 
		end),
	two._src_lineage, two._action, _taxon_rank=ISNULL(two._src_taxon_rank,two._dest_taxon_rank), two._dest_lineage, two.sort, two.proposal
from load_next_msl_isOk one
left outer join load_next_msl_isOk two 
on --one._dest_lineage = two._src_lineage and 
one._src_taxon_name = two._src_taxon_name
and one.sort < two.sort
where one._src_taxon_name in 
	-- N=27 taxa that appear twice as the _src_taxon_name
	(select _src_taxon_name from load_next_msl_isOk where _src_taxon_name is not null group by _src_taxon_name having count(*) > 1)
and one._src_taxon_name is not null and two._src_taxon_name is not null
order by one._src_taxon_name, one.proposal_abbrev

-- past cases of two-proposals-in-one-MSL
select title='past cases of two-proposals-in-one-MSL', msl_release_num, lineage, in_filename, out_filename  
from taxonomy_node 
where in_filename like '%;%' or out_filename like '%;%'

/* -- delete inserts below if it all goes wrong.
delete -- select *
	from load_next_msl where rtrim([sort]) <> rtrim(cast([sort] as int)) 
	order by _dest_taxon_name --dest_parent_id = 202100838 or proposal like '%;%'
update load_next_msl set isWrong=NULL from load_next_msl where isWrong in ('chained_left', 'chained_right')
*/ 

-- ---------------------------------------------------------------------------------------
--
-- ADD missing record
-- 
-- ---------------------------------------------------------------------------------------

-- INSERT move genus = 'Nevevirus'
insert into load_next_msl_isok (
	filename
	,sort
	,proposal_abbrev
	,proposal
	,srcRealm
	,srcKingdom
	,srcPhylum
	,srcClass
	,srcOrder
	,srcFamily
	,srcGenus
	,Realm
	,Kingdom
	,Phylum
	,Class
	,Genus
	,rank
	,change
	,_action
	,comments
	)
select
	filename='4a.apply_create'
	, sort = 'step4a.1'
	, proposal_abbrev = 'email'
	, proposal = 'Evelien.Adriaenssens@quadram.ac.uk'
		-- src
	,srcRealm = 'Duplodnaviria'
	,srckingdom = 'Heunggongvirae'
	,srcphylum = 'Uroviricota'
	,srcclass = 'Caudoviricetes'
	,srcOrder = 'Caudovirales'
	,srcFamily ='Siphoviridae'
	,srcgenus = 'Nevevirus'
	-- dest
	,realm = 'Duplodnaviria'
	,kingdom = 'Heunggongvirae'
	,phylum = 'Uroviricota'
	,class = 'Caudoviricetes'
	,genus = 'Nevevirus'
	-- meta
	,rank = 'genus'
	,change ='move'
	,_action = 'move'
	,comments = '2021.010B.A.v1.Binomial_names.zip should have moved this'
where not exists (select * from load_next_msl_isok where sort = 'step4a.1')

-- add late-breaking proposal justifying this
update load_next_msl_isok set
--select *,
	filename='load_next_msl.37v1.txt'
	,proposal_abbrev='2021.097B'
	, proposal='2021.097B.R.error_correction_Caudoviricetes.zip'
	, spreadsheet='2021.097B.R.error_correction_Caudoviricetes.xlsx'
from load_next_msl_isOk
where _action = 'move' and genus='Nevevirus' and proposal_abbrev<>'2021.097B'
-- add late-breaking proposal justifying this
update taxonomy_node set
-- select *, 
	out_filename=ld.proposal
from taxonomy_node 
join load_next_msl_isOk ld on taxonomy_node.taxnode_id = ld.prev_taxnode_id
where ld._action = 'move' and ld.genus='Nevevirus' and out_filename<>ld.proposal 

-- UPDATE create genusin (  'Refugevirus',  'Pharaohvirus')
update load_next_msl_isok set
	-- select *,
	[class] = 'Caudoviricetes'
	,[order]=NULL
	, [family] = NULL
	, dest_parent_id = (select taxnode_id from taxonomy_node n where name = 'Caudoviricetes' and n.msl_release_num = load_next_msl_isok.dest_msl_release_num)
from load_next_msl_isok
where
	genus in ( 'Refugevirus',  'Pharaohvirus')
and _dest_taxon_rank = 'genus'
and proposal_abbrev='2021.064B'
and ([family] is not null or [order] is not null or [class] is null )

-- add late-breaking proposal justifying this
update load_next_msl_isok set
--select *,
	filename='load_next_msl.37v1.txt'
	,proposal_abbrev='2021.064B;2021.097B'
	, proposal='2021.064B.A.v1.Pharaohvirus_Refugevirus.zip;2021.097B.R.error_correction_Caudoviricetes.zip'
	, spreadsheet='2021.064B.A.v1.Pharaohvirus_Refugevirus.xlsx;2021.097B.R.error_correction_Caudoviricetes.xlsx'
from load_next_msl_isOk
where _action = 'new' and _dest_taxon_rank='genus' and genus in ( 'Refugevirus',  'Pharaohvirus') and proposal_abbrev<>'2021.097B'
-- add late-breaking proposal justifying this
update taxonomy_node set
-- select 'taxonomy_node>>',taxonomy_node.*,'load_next_msl_isok>>>', ld.*, 'change>>>>', 
	in_filename=ld.proposal, in_notes=ld.spreadsheet
from taxonomy_node 
join load_next_msl_isOk ld on taxonomy_node.taxnode_id = ld.dest_taxnode_id
where ld._action = 'new' and ld._dest_taxon_rank='genus' and ld.genus in ( 'Refugevirus',  'Pharaohvirus') and in_filename<>ld.proposal 

-- debug: remove new nodes so we can re-insert them.
--select taxnode_id, lineage,_numKids -- delete
--from taxonomy_node where taxnode_id in (select dest_taxnode_id from load_next_msl_isok where genus in ( 'Refugevirus',  'Pharaohvirus') and _dest_taxon_rank = 'genus' and proposal_abbrev='2021.064B')
--from taxonomy_node where parent_id in (select dest_taxnode_id from load_next_msl_isok where genus in ( 'Refugevirus',  'Pharaohvirus') and _dest_taxon_rank = 'genus' and proposal_abbrev='2021.064B')
--update load_next_msl_isok set isDone = NULL  from load_next_msl_isok where genus in ( 'Refugevirus',  'Pharaohvirus') and _dest_taxon_rank in ( 'genus' , 'species' ) and proposal_abbrev='2021.064B'

-- INSERT abolish srcSpecies ='Cronobacter virus PhiCS01'
insert into load_next_msl (
	filename
	, sort
	, proposal_abbrev
	, proposal
	, spreadsheet
	,srcRealm
	,srcKingdom
	,srcPhylum
	,srcClass
	,srcFamily
	,srcGenus
	,srcSpecies
	-- meta
	,change
	,[rank]
	,_action
)
select
	filename='4a.apply_create'
	, sort = 'step4a.4'
	, proposal_abbrev
	, proposal
	, spreadsheet
	,srcRealm
	,srcKingdom
	,srcPhylum
	,srcClass
	,srcFamily
	,srcGenus
	,srcSpecies ='Cronobacter virus PhiCS01'
	-- meta
	,change
	,[rank] = 'species'
	,_action
 -- select *
 from load_next_msl 
 where _action = 'abolish' and srcGenus='Gyeonggidovirus' and _src_taxon_rank='genus'
 and not exists (select * from load_next_msl where srcSpecies = 'Cronobacter virus PhiCS01')

 select * from load_next_msl_isok where srcGenus = 'Nevevirus'
 select * from load_next_msl_isok where srcGenus = 'Alphaguttavirus'
 select * from load_next_msl_isok where srcGenus = 'Giessenvirus'
 select * from taxonomy_node where name like '%C1302' and msl_release_num = 37
  select * from taxonomy_node where name in ('Pharaohvirus','Refugevirus', 'Nevevirus') and msl_release_num = 37
    select * from load_next_msl where genus in ('Pharaohvirus','Refugevirus', 'Nevevirus') and _dest_taxon_rank = 'genus'

select * from taxonomy_node_names where msl_release_num=37 and 202100713 in (taxnode_id, parent_id) order by left_idx
select * from taxonomy_node_names where msl_release_num=37 and name = 'Pharaohvirus'

--delete from taxonomy_node where parent_id in ( 202112877,202112880) -- 'Pharaohvirus','Refugevirus'
--delete from taxonomy_node where taxnode_id in ( 202112877,202112880) -- 'Pharaohvirus','Refugevirus'

-- ---------------------------------------------------------------------------------------
--
-- MERGE chain/dup records
-- 
-- ---------------------------------------------------------------------------------------

-- 
-- records with same _dest_taxon_name
--- 
--select 'load_next_msl', count(*) from load_next_msl
insert into load_next_msl (
	filename
	,sort
	,merged_left_sort
	,merged_right_sort
	,merged_reason
	,proposal_abbrev
	,proposal
	,spreadsheet
	,srcRealm
	,srcSubRealm
	,srcKingdom
	,srcSubKingdom
	,srcPhylum
	,srcSubPhylum
	,srcClass
	,srcSubClass
	,srcOrder
	,srcSubOrder
	,srcFamily
	,srcSubfamily
	,srcGenus
	,srcSubGenus
	,srcSpecies
	,Realm
	,SubRealm
	,Kingdom
	,SubKingdom
	,Phylum
	,SubPhylum
	,Class
	,SubClass
	,[Order]
	,SubOrder
	,Family
	,Subfamily
	,Genus
	,SubGenus
	,Species
	,exemplarAccessions
	,exemplarName
	,exemplarIsolate
	,isComplete
	,hostSource
	,molecule
	,rank
	,change
	,comments
	,prev_taxnode_id
	,dest_taxnode_id
	,dest_ictv_id
	,dest_parent_id
	,dest_level_id
	,isDone
	)
select  
	-- one.isWrong, two.isWrong, one.[sort], two.[sort],-- debug
	filename = one.filename --+';'+two.filename -- filename is the same
	,sort = one.sort+'.'+two.sort
	,merged_left_sort = one.sort
	,merged_right_sort = two.sort
	,merge_reason =     (case 
							when isnull(one._dest_lineage,'NULL') = isnull(two._src_lineage,'NULL') then  'chained'
							when isnull(one._src_lineage,'NULL') = isnull(two._src_lineage,'NULL')
							and  isnull(one._dest_lineage,'NULL') = isnull(two._dest_lineage,'NULL') then 'duplicate'
							else 'error'
							end)
	,proposal_abbrev =	(case when one.proposal_abbrev=two.proposal_abbrev then one.proposal_abbrev else one.proposal_abbrev+';'+two.proposal_abbrev end)
	,proposal=			(case when one.proposal		  =two.proposal		   then one.proposal        else one.proposal+';'+two.proposal end)
	,spreadsheet=       (case when one.spreadsheet    =two.spreadsheet	   then one.spreadsheet     else one.spreadsheet+';'+two.spreadsheet end)
	,one.srcRealm
	,one.srcSubRealm
	,one.srcKingdom
	,one.srcSubKingdom
	,one.srcPhylum
	,one.srcSubPhylum
	,one.srcClass
	,one.srcSubClass
	,one.srcOrder
	,one.srcSubOrder
	,one.srcFamily
	,one.srcSubfamily
	,one.srcGenus
	,one.srcSubGenus
	,one.srcSpecies
	,two.realm
	,two.SubRealm
	,two.Kingdom
	,two.SubKingdom
	,two.Phylum
	,two.SubPhylum
	,two.[Class]
	,two.SubClass
	,two.[Order]
	,two.SubOrder
	,two.Family
	,two.Subfamily
	,two.Genus
	,two.SubGenus
	,two.Species
	,exemplarAccessions = isnull(one.exemplarAccessions,two.exemplarAccessions)
	,exemplarName		= isnull(one.exemplarName,two.exemplarName)
	,exemplarIsolate	= isnull(one.exemplarIsolate,two.exemplarIsolate)
	,isComplete			= isnull(two.isComplete,one.isComplete)
	,hostSource			= isnull(two.hostSource,one.hostSource)
	,molecule			= isnull(two.molecule,one.molecule)
	,rank =				one._dest_taxon_rank+(case when one.rank=two._dest_taxon_rank then '' else ';'+two._dest_taxon_rank end)
	,change =			one.change+(case when one.change=two.change then '' else ';'+two.change end)
	,comments			= one.comments+isnull(';'+two.comments,'')
	,one.prev_taxnode_id
	,two.dest_taxnode_id
	,two.dest_ictv_id
	,two.dest_parent_id
	,two.dest_level_id
	,two.isDone
from load_next_msl_isOk one
left outer join load_next_msl_isOk two 
on --one._dest_lineage = two._src_lineage and 
one._dest_taxon_name = two._dest_taxon_name
and one.sort < two.sort
where one._dest_taxon_name in 
	-- taxa that appear twice as the _dest_taxon_name
	(select _dest_taxon_name from load_next_msl_isOk group by _dest_taxon_name having count(*) > 1)
and one._dest_taxon_name is not null and two._dest_taxon_name is not null
and (
	-- chain: two consecutive, consistent changes to same taxon
	one._dest_lineage = two._src_lineage
	-- duplicate: two identical changes to same taxon - merge
	or (
		one.sort <> two.sort
		and 
		one._src_lineage = two._src_lineage
		and
		one._dest_lineage = two._dest_lineage
	)
)
-- only merge primary records, never one that is already merged
and one.sort not like '%.%' and two.sort not like '%.%'
-- don't insert this chain/merge more than once
and not exists (select * from load_next_msl_isOk m where sort=one.sort+'.'+two.sort)
order by one._dest_taxon_name

-- 
-- records with same _src_taxon_name
--- 
--select 'load_next_msl', count(*) from load_next_msl
insert into load_next_msl (
	filename
	,sort
	,merged_left_sort
	,merged_right_sort
	,merged_reason
	,proposal_abbrev
	,proposal
	,spreadsheet
	,srcRealm
	,srcSubRealm
	,srcKingdom
	,srcSubKingdom
	,srcPhylum
	,srcSubPhylum
	,srcClass
	,srcSubClass
	,srcOrder
	,srcSubOrder
	,srcFamily
	,srcSubfamily
	,srcGenus
	,srcSubGenus
	,srcSpecies
	,Realm
	,SubRealm
	,Kingdom
	,SubKingdom
	,Phylum
	,SubPhylum
	,Class
	,SubClass
	,[Order]
	,SubOrder
	,Family
	,Subfamily
	,Genus
	,SubGenus
	,Species
	,exemplarAccessions
	,exemplarName
	,exemplarIsolate
	,isComplete
	,hostSource
	,molecule
	,rank
	,change
	,comments
	,prev_taxnode_id
	,dest_taxnode_id
	,dest_ictv_id
	,dest_parent_id
	,dest_level_id
	,isDone
	)
select  
	-- one.isWrong, two.isWrong, one.[sort], two.[sort],-- debug
	filename = one.filename --+';'+two.filename -- filename is the same
	,sort = one.sort+'.'+two.sort
	,merged_left_sort = one.sort
	,merged_right_sort = two.sort
	,merge_reason =     (case 
							when isnull(one._dest_lineage,'NULL') = isnull(two._src_lineage,'NULL') then  'chained'
							when isnull(one._src_lineage,'NULL') = isnull(two._src_lineage,'NULL')
							and  isnull(one._dest_lineage,'NULL') = isnull(two._dest_lineage,'NULL') then 'duplicate'
							else 'error'
							end)
	,proposal_abbrev =	(case when one.proposal_abbrev=two.proposal_abbrev then one.proposal_abbrev else one.proposal_abbrev+';'+two.proposal_abbrev end)
	,proposal=			(case when one.proposal		  =two.proposal		   then one.proposal        else one.proposal+';'+two.proposal end)
	,spreadsheet=       (case when one.spreadsheet    =two.spreadsheet	   then one.spreadsheet     else one.spreadsheet+';'+two.spreadsheet end)
	,one.srcRealm
	,one.srcSubRealm
	,one.srcKingdom
	,one.srcSubKingdom
	,one.srcPhylum
	,one.srcSubPhylum
	,one.srcClass
	,one.srcSubClass
	,one.srcOrder
	,one.srcSubOrder
	,one.srcFamily
	,one.srcSubfamily
	,one.srcGenus
	,one.srcSubGenus
	,one.srcSpecies
	,two.realm
	,two.SubRealm
	,two.Kingdom
	,two.SubKingdom
	,two.Phylum
	,two.SubPhylum
	,two.[Class]
	,two.SubClass
	,two.[Order]
	,two.SubOrder
	,two.Family
	,two.Subfamily
	,two.Genus
	,two.SubGenus
	,two.Species
	,exemplarAccessions = isnull(one.exemplarAccessions,two.exemplarAccessions)
	,exemplarName		= isnull(one.exemplarName,two.exemplarName)
	,exemplarIsolate	= isnull(one.exemplarIsolate,two.exemplarIsolate)
	,isComplete			= isnull(two.isComplete,one.isComplete)
	,hostSource			= isnull(two.hostSource,one.hostSource)
	,molecule			= isnull(two.molecule,one.molecule)
	,rank =				one._dest_taxon_rank+(case when one.rank=two._dest_taxon_rank then '' else ';'+two._dest_taxon_rank end)
	,change =			one.change+(case when one.change=two.change then '' else ';'+two.change end)
	,comments			= one.comments+isnull(';'+two.comments,'')
	,one.prev_taxnode_id
	,two.dest_taxnode_id
	,two.dest_ictv_id
	,two.dest_parent_id
	,two.dest_level_id
	,two.isDone
from load_next_msl_isOk one
left outer join load_next_msl_isOk two 
on 
one._src_taxon_name = two._src_taxon_name
and one.sort < two.sort
where one._src_taxon_name in 
	-- taxa that appear twice as the _dest_taxon_name
	(select _src_taxon_name from load_next_msl_isOk where _src_taxon_name is not null group by _src_taxon_name having count(*) > 1)
and one._src_taxon_name is not null and two._src_taxon_name is not null
and (
	-- chain: two consecutive, consistent changes to same taxon
	one._dest_lineage = two._src_lineage
	-- duplicate: two identical changes to same taxon - merge
	or (
		one.sort <> two.sort
		and 
		one._src_lineage = two._src_lineage
		and
		one._dest_lineage = two._dest_lineage
	)
)
-- only merge primary records, never one that is already merged
and one.sort not like '%.%' and two.sort not like '%.%'
-- don't insert this chain/merge more than once
and not exists (select * from load_next_msl_isOk m where sort=one.sort+'.'+two.sort)
order by one._src_taxon_name

--
-- mark the originals with isWrong='chained|duplicate'
--
update load_next_msl_isOk set 
--select report='mark left', left_sort=load_next_msl_isOk.sort, merged_sort=merged.sort, right_sort=two.sort,  left_wrong=load_next_msl_isOk.isWrong, merged_wrong=merged.isWrong, right_wrong=two.isWrong,merged.merged_reason,  *,
	isWrong = merged.merged_reason+'_left'
		+' merged with '+two.proposal_abbrev+':'+rtrim(two.sort)
from load_next_msl_isOk
join load_next_msl_isOk merged on merged.merged_left_sort = load_next_msl_isOk.sort
join load_next_msl two         on merged.merged_right_sort = two.sort


update load_next_msl_isOk set 
--select report='mark left', left_sort=two.sort, merged_sort=merged.sort, right_sort=load_next_msl_isOk.sort,  left_wrong=two.isWrong, merged_wrong=merged.isWrong, right_wrong=load_next_msl_isOk.isWrong, merged.merged_reason, *,
	isWrong = merged.merged_reason+'_right'
		+' merged with '+two.proposal_abbrev+':'+rtrim(two.sort)
from load_next_msl_isOk 
join load_next_msl_isOk merged on merged.merged_right_sort = load_next_msl_isOk.sort
join load_next_msl two		   on merged.merged_left_sort = two.sort

/* 
 * chaining doesn't always get _action right
 */
 update load_next_msl_isok set -- select *,
	_action = 'move' 
from load_next_msl_isok
where _src_taxon_name='Giessenvirus' and _dest_taxon_name = 'Hungariovirus'
and _action is null

select report='ERROR: load_next_msl_isOk _action=NULL errors', * from load_next_msl_isOk where _action is null

/* ====
 * fix conflicts, one by one
 * ==== */

update load_next_msl_isOk set -- select *, 
isWrong='already exists, created by rename in 2021.010B' from load_next_msl_isOk where _action='new' and _dest_taxon_name='Chivirus BSPM4'

update load_next_msl_isOk set -- select *, 
isWrong='same genus creatd in two families: 2021.076B, 2021.082B; remove' from load_next_msl_isOk where genus = 'Glaucusvirus'

update load_next_msl_isOk set -- select *, 
isWrong='incorrect move; correct in 2021.001A' from load_next_msl_isOk where _dest_lineage='Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Haloferacalesvirus'

update load_next_msl_isOk set -- select *, 
isWrong='duplicate rename; also in 2021.001A' from load_next_msl_isOk where proposal_abbrev ='2021.010B' and _dest_lineage='Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Haloferacalesvirus;Haloferacalesvirus HF1'

update load_next_msl_isOk set -- select *, 
isWrong='incorrect move; correct in 2021.001A' from load_next_msl_isOk where proposal_abbrev ='2021.001B' and _dest_lineage='Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Myohalovirus'

update load_next_msl_isOk set -- select *, 
isWrong='duplicate rename; also in 2021.001A' from load_next_msl_isOk where proposal_abbrev ='2021.010B' and _dest_lineage='Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Myohalovirus;Myohalovirus PhiCh1'

update load_next_msl_isOk set -- select *, 
isWrong='duplicate rename; also in 2021.001A' from load_next_msl_isOk where proposal_abbrev ='2021.010B' and _dest_lineage='Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Myohalovirus;Myohalovirus phiH'

update load_next_msl_isOk set -- select *, 
isWrong='duplicates rename in 2021.010B' from load_next_msl_isOk where proposal_abbrev ='2021.061B' and _dest_taxon_name='Pbunavirus BrSP1'
update load_next_msl_isOk set -- select *,
isComplete='CG', hostSource='bacteria', molecule='dsDNA'
from load_next_msl_isOk where proposal_abbrev ='2021.010B' and _dest_taxon_name='Pbunavirus BrSP1'

update load_next_msl_isOk set -- select *, 
isWrong='duplicates rename in 2021.010B' from load_next_msl_isOk where proposal_abbrev ='2021.061B' and _dest_taxon_name='Pbunavirus EPa61'
update load_next_msl_isOk set -- select *,
isComplete='CG', hostSource='bacteria', molecule='dsDNA'
from load_next_msl_isOk where proposal_abbrev ='2021.010B' and _dest_taxon_name='Pbunavirus EPa61'

update load_next_msl_isOk set -- select *, 
isWrong='duplicates rename in 2021.010B' from load_next_msl_isOk where proposal_abbrev ='2021.061B' and _dest_taxon_name='Pbunavirus PA01'
update load_next_msl_isOk set -- select *,
isComplete='CG', hostSource='bacteria', molecule='dsDNA'
from load_next_msl_isOk where proposal_abbrev ='2021.010B' and _dest_taxon_name='Pbunavirus PA01'

update load_next_msl_isOk set -- select *, 
isWrong='duplicates rename in 2021.010B' from load_next_msl_isOk where proposal_abbrev ='2021.061B' and _dest_taxon_name='Pbunavirus R12'
update load_next_msl_isOk set -- select *,
isComplete='CG', hostSource='bacteria', molecule='dsDNA'
from load_next_msl_isOk where proposal_abbrev ='2021.010B' and _dest_taxon_name='Pbunavirus R12'

update load_next_msl_isOk set -- select *, 
isWrong='duplicate move; correct in 2021.080B' from load_next_msl_isOk where proposal_abbrev ='2021.001B' and _dest_taxon_name='Phapecoctavirus'

update load_next_msl_isOk set -- select *, 
isWrong='incorrect genus move; correct in 2021.001A' from load_next_msl_isOk where proposal_abbrev ='2021.001B' and _dest_taxon_name='Psimunavirus'

-- remove one, of two, duplicate lines
update load_next_msl_isOk set -- select *, 
isWrong='duplicate move_genus; remove one' from load_next_msl_isOk where proposal_abbrev ='2021.001B' and _dest_taxon_name='rerduovirus' and 
	sort = (select max(sort) from load_next_msl_isOk where proposal_abbrev ='2021.001B' and _dest_taxon_name='rerduovirus' and isWrong is null group by _dest_taxon_name having count(*)>1)

update load_next_msl_isOk set -- select *, 
isWrong='incorrect genus move; correct in 2021.015B' from load_next_msl_isOk where proposal_abbrev ='2021.001B' and _dest_taxon_name='Yonseivirus'

update load_next_msl_isOk set -- select *, 
isWrong='incorrect subfamily move; correct as promotion in 2021.063B' from load_next_msl_isOk 
where proposal_abbrev ='2021.001B' and _action='move' and _dest_taxon_rank='subfamily' and  _dest_lineage='Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae'

--
-- fix errors found with duplicate _src_taxon_name, where one record needs to be surpressed.
-- 
-- N=27 taxa that appear twice as the _src_taxon_name
update load_next_msl_isOK set
-- compare duplicate set vs the set we're updating
--select * from (select _src_taxon_name from load_next_msl_isOk where _src_taxon_name is not null group by _src_taxon_name having count(*) > 1) src where src._src_taxon_name not in (
	-- query set we're updating
	--select load_next_msl_isOK._src_taxon_name, load_next_msl_isOK._action, load_next_msl_isOK._dest_taxon_name, load_next_msl_isOK._dest_taxon_rank, load_next_msl_isOK._src_lineage, load_next_msl_isOK._dest_lineage, load_next_msl_isOK.proposal, load_next_msl_isOK.sort ,
		isWrong = 'incorrect; correct change ('+two._action+') found in '--+two.proposal
	from load_next_msl_isOK
	join  load_next_msl_isOk two on load_next_msl_isOK._src_taxon_name =two._src_taxon_name and load_next_msl_isOk.sort <> two.sort
	where load_next_msl_isOk._src_taxon_name in (select _src_taxon_name from load_next_msl_isOk where _src_taxon_name is not null group by _src_taxon_name having count(*) > 1)
	and load_next_msl_isOk._dest_lineage in (
		-- _dest_lineage to be removed
		'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Kisquinquevirus;Kisquinquevirus AP3',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Tigrvirus;Tigrvirus KL3',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Tigrvirus;Tigrvirus E122',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Felsduovirus;Felsduovirus wv5004651',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Xuanwuvirus;Xuanwuvirus gv5004652',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Giessenvirus;Giessenvirus C1302',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Seongnamvirus;Seongnamvirus ev015',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Seongnamvirus;Seongnamvirus ev040',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Seongnamvirus;Seongnamvirus ev129',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Seongnamvirus;Seongnamvirus ev239',		'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Myohalovirus;Myohalovirus chaoS9',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Haloferacalesvirus;Haloferacalesvirus hv5',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Haloferacalesvirus;Haloferacalesvirus hv7',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Haloferacalesvirus;Haloferacalesvirus hv8',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Haloferacalesvirus;Haloferacalesvirus HF2',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Felsduovirus;Felsduovirus 4LV2017',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Felsduovirus;Felsduovirus ST13OXA48phi121',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Felsduovirus;Felsduovirus ST15OXA48phi141',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Felsduovirus;Felsduovirus ST437OXA245phi41',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Felsduovirus;Felsduovirus ST512KPC3phi132',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Fromanvirus;Fromanvirus arturo',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Fromanvirus;Fromanvirus backyardigan',	'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Fromanvirus;Fromanvirus benedict',		'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Pseudomonas virus 119X','Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Peduovirinae;Aresaunavirus;Aresaunavirus RSY1'
	)
--) -- used for set comparison
--order by load_next_msl_isOK._src_taxon_name, load_next_msl_isOK.proposal_abbrev

-- query
--select * from taxonomy_node where name='Pseudomonas virus BrSP1'
--select * from load_next_msl where _src_taxon_name = 'Peduovirinae'
select report='stats on nodes',
	msl_release_num, tot=count(*), in_action=count(in_change), out_action=count(out_change), min_id=min(taxnode_id), max_id=max(taxnode_id)
from taxonomy_node 
where msl_release_num in (36, 37) 
group by msl_release_num
/*
 * ###########################################################################################################################################
 * ###########################################################################################################################################
 * ========================================================================================
 * Actual work
 * ========================================================================================
 * ###########################################################################################################################################
 * ###########################################################################################################################################
 */

/*
 * what to expect 
 */
 select 'todo', _action, tot= count(*), done=count(isDone)
 from load_next_msl_isOk 
 where isWrong is null
 group by _action 

 select report='load_next_msl_isOk _action=NULL errors', * from load_next_msl_isOk where _action is null

 -- 
 -- data fixes (splits with same name were not exempted from getting new taxnode/ictv ids)
 --
 select * from load_next_msl where sort in ('272','3955','302','3722')
 select 'splits with original name'='ERROR', sort,_src_lineage, _dest_taxon_rank, _action, _dest_lineage, dest_taxnode_id, dest_ictv_id, taxnode_id, ictv_id, lineage
 -- update load_next_msl_isOk set dest_taxnode_id=dest.taxnode_id, dest_ictv_id=dest.ictv_id
 from load_next_msl_isOk
 join taxonomy_node dest on dest.msl_release_num=dest_msl_release_num and dest.name = _dest_taxon_name 
 where isWrong is null 
 and _action='split' and _src_taxon_name = _dest_taxon_name
 and (dest_taxnode_id<>dest.taxnode_id OR  dest_ictv_id<>dest.ictv_id)


-- =======================================================================================
-- ITERATE over RANKS (top to bottom)
-- set 
-- =======================================================================================


DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl_isOk)
DECLARE @tree_id int; SET @tree_id=(select tree_id from taxonomy_toc where msl_release_num=@msl)


PRINT 'set tree_id '+rtrim(@tree_id)+' and msl_release_num '+rtrim(@msl)

-- cursor to assign IDs?

SET NOCOUNT ON
DECLARE @level_id int
DECLARE @rank varchar(50)
DECLARE @msg nvarchar(200)
DECLARE @count int

DECLARE UP_CURSOR CURSOR FOR
SELECT id, name FROM taxonomy_level WHERE id>100/*tree*/ ORDER BY id -- FOR UPDATE OF dest_taxnode_id, dest_ictv_id
OPEN UP_CURSOR
FETCH NEXT FROM UP_CURSOR INTO @level_id, @rank

WHILE(@@FETCH_STATUS=0)
BEGIN
	-- do update 
	--UPDATE load_next_msl_isOk SET dest_taxnode_id = @next_taxnode_id, dest_ictv_id = @next_taxnode_id WHERE CURRENT OF UP_CURSOR

	PRINT '-- ##############################################################################'
	PRINT '-- ## '+@rank+' ('+rtrim(@level_id)+')'
	PRINT '-- ##############################################################################'
	-- DEBUG:
	-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='class';
	print '-- -----------------------------------------------------------------------------'
	PRINT '-- RENAME @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*) 
	FROM load_next_msl_isOk where _action='rename' AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No actions for rank '+@rank
	END ELSE BEGIN
		SELECT step='starting', action='RENAME', rank=@rank 
		-- debug promote
		select t='taxonomy_node', taxnode_id, msl_release_num, level_id, name, out_change, out_target, out_filename from taxonomy_node where taxnode_id in (202000225,202004872,202004918)  order by msl_release_num, level_id

		-- debug
		SELECT 'DEBUG'='RENAME', src.sort, n.taxnode_id, n.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name,'>>>',N.*
		FROM TAXONOMY_NODE n
		join taxonomy_node P on n.left_idx between p.left_idx and p.right_idx and p.tree_id = n.tree_id
		JOIN load_next_msl_isOk src on src.dest_taxnode_id = p.taxnode_id
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE src._action='rename'	
		and p.level_id = @level_id
		order by n.left_idx

		-- change current name
		UPDATE taxonomy_node SET 
			name=src._dest_taxon_name
			,is_ref = isnull(src.isType,taxonomy_node.is_ref)
			-- metadata 
			,genbank_accession_csv	= isnull(src.exemplarAccessions,genbank_accession_csv)
			,abbrev_csv				= isnull(src.abbrev, abbrev_csv)
			,isolate_csv			= isnull(src.exemplarIsolate, isolate_csv)
			,molecule_id			= isnull(destMol.id, molecule_id)
		--SELECT taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name
		FROM taxonomy_node 
		JOIN load_next_msl_isOk src on src.dest_taxnode_id = taxonomy_node.taxnode_id
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE src._action='rename'	
		and level_id = @level_id

		-- update prev msl
		UPDATE taxonomy_node SET 
		--SELECT taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name,
			out_change = _action
			, out_target = src._dest_taxon_name
			, out_filename = proposal
			, out_notes = spreadsheet
		FROM taxonomy_node 
		JOIN load_next_msl_isOk src on src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src._action='rename'	
		and level_id = @level_id

		-- record completion
		UPDATE load_next_msl_isOk 
		SET isDONE=ISNULL(isDONE+'; ','')+'4.a.apply_create_action['+rtrim(sort)+']s: RENAME dest_rank='+@rank+'; _action='+src._action
		FROM load_next_msl_isOk src 
		JOIN taxonomy_node on src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src._action='rename'	
		and level_id = @level_id
	END 

	-- DEBUG:
	select _dest_taxon_rank ,_action, ct=count(*) from load_next_msl_isOk where isWrong is null AND  _action in ('new','split') group by _dest_taxon_rank ,_action
	-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='subgenus';
	print '-- -----------------------------------------------------------------------------'
	PRINT '-- NEW/SPLIT @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*)
	FROM load_next_msl_isOk where  _action in ('new') AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No actions for rank '+@rank
	END ELSE BEGIN
		SELECT step='starting', action='NEW/SPLIT', rank=@rank 
		-- debug promote
		select t='taxonomy_node', taxnode_id, msl_release_num, level_id, name, out_change, out_target, out_filename from taxonomy_node where taxnode_id in (202000225,202004872,202004918)  order by msl_release_num, level_id

		-- NEW/SPLIT: insert new row

		INSERT INTO taxonomy_node (
			taxnode_id
			,tree_id
			,parent_id
			,name
			,level_id
			,is_ref
			,ictv_id
			,msl_release_num
			, in_change, in_filename, in_notes, in_target
			--out_change, out_filename, out_notes
			,genbank_accession_csv 
			,abbrev_csv
			,isolate_csv
			,molecule_id
		) 
		select 
			--src.src_out_change, -- debug
			taxnode_id = src.dest_taxnode_id
			, tree_id = (select tree_id from taxonomy_toc where msl_release_num = src.dest_msl_release_num)
			-- parent nodes already inserted into taxonomy_node
			, parent_id = src.dest_parent_id
			-- assume it's a lineage, and get what's after the last semi-colon
			, name = _dest_taxon_name
			,level_id = rank.id
			,is_ref = isnull(src.isType,0)
			,ictv_id = src.dest_ictv_id
			,msl_release_num = src.dest_msl_release_num
			-- change linker
			,in_change = src._action
			,in_filename = src.proposal
			,in_notes = src.spreadsheet
			,in_target = src._src_taxon_name
			-- metadata 
			,genbank_accession_csv = src.exemplarAccessions
			,abbrev_csv=src.abbrev
			,isolate_csv=src.exemplarIsolate
			,molecule_id=destMol.id
		from load_next_msl_isOk as src
		-- parent
		left outer join taxonomy_level rank on rank.name = src._dest_taxon_rank
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE (
			(_action like 'new')-- or src.src_out_change in ('promote')) )
			or
			(_action like 'split' AND _src_taxon_name <> _dest_taxon_name)
		) 
		AND _dest_taxon_rank = @rank

		AND
			-- reentrant: skip ones already inserted
			(src.dest_taxnode_id NOT in (select n.taxnode_id from taxonomy_node as n where n.msl_release_num = src.dest_msl_release_num))
		ORDER BY level_id, _dest_taxon_name


		-- SPLIT (only) where name is same - just set in_*
		 
		update taxonomy_node set
			--DEBUG-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='class'; select taxnode_id, 
			-- change linker
			in_change = src._action
			,in_filename = src.proposal
			,in_notes = src.spreadsheet
			,in_target = src._src_taxon_name
			-- metadata 
			,genbank_accession_csv = src.exemplarAccessions
			,abbrev_csv=src.abbrev
			,isolate_csv=src.exemplarIsolate
			,molecule_id=destMol.id			
		from taxonomy_node 
		join load_next_msl_isOk as src on taxonomy_node.taxnode_id = src.dest_taxnode_id
		left outer join taxonomy_level rank on rank.name = src._dest_taxon_rank
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		WHERE (
			(_action like 'split' AND _src_taxon_name = _dest_taxon_name)
		) 
		AND _dest_taxon_rank = @rank
		AND
			-- reentrant: skip ones already inserted
			taxonomy_node.in_change is null 


		print '-- NEW/SPLIT: record completion in load_next_msl.isDONE'
		-- DEBUG DECLARE @rank varchar(100); SET @rank='kingdom'
		UPDATE load_next_msl_isOk SET 
		-- DEBUG DECLARE @rank varchar(100); SET @rank='realm'; select src.*,
			isDONE=ISNULL(isDONE+'; ','')+'4.a.apply_create_actions['+rtrim(sort)+']: NEW/SPLIT, dest_rank='+@rank+'; _action='+src._action
		FROM load_next_msl_isOk src 
		JOIN taxonomy_node on src.dest_taxnode_id = taxonomy_node.taxnode_id
		WHERE  src._action in ('new', 'split')	
		AND _dest_taxon_rank = @rank
		AND
			-- check inserted
			(src.dest_taxnode_id in (select n.taxnode_id from taxonomy_node as n where n.msl_release_num = src.dest_msl_release_num))
	END
	
	-- DEBUG:
	-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='species';
	print '-- -----------------------------------------------------------------------------'
	PRINT '-- MOVE (+rename+promote+demote) @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*) 
	FROM load_next_msl_isOk where _action in ('move','demote','promote') AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No MOVE actions for rank '+@rank
	END ELSE BEGIN
		SELECT step='starting', action='MOVE (+rename+promote+demote)', rank=@rank 
		-- debug promote
		select t='taxonomy_node', taxnode_id, msl_release_num, level_id, name, out_change, out_target, out_filename from taxonomy_node where taxnode_id in (202000225,202004872,202004918)  order by msl_release_num, level_id

		SELECT * FROM load_next_msl_isOk where _action in ('move','demote','promote') AND _dest_taxon_rank = @rank
		-- DEBUG
		select t='load_next_msl_ok: before', * from load_next_msl_isOk where _action='promote'
		select t='taxonomy_node: before', taxnode_id, msl_release_num, level_id, name, out_change, out_target, out_filename
		 from taxonomy_node where taxnode_id in (202100225,202104872,202104918, 202000225,202004872,202004918,202107120,202007120)
		 order by msl_release_num, level_id
		

		print '-- change current name and parent '
		UPDATE taxonomy_node SET 
		--SELECT 'cur_msl',taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name,
			parent_id=src.dest_parent_id
			, name=src._dest_taxon_name
			,is_ref = isnull(src.isType,taxonomy_node.is_ref)
			-- metadata 
			,genbank_accession_csv = src.exemplarAccessions
			,abbrev_csv=src.abbrev
			,isolate_csv=src.exemplarIsolate
			,molecule_id=destMol.id
			,level_id=destRank.id
			--,level_id -- debug
		FROM taxonomy_node 
		JOIN load_next_msl_isOk src on src.dest_taxnode_id = taxonomy_node.taxnode_id
		left outer join taxonomy_molecule destMol on destMol.abbrev=src.molecule
		left outer join taxonomy_level destRank on destRank.name = src._dest_taxon_rank
		WHERE src._action in ('move','demote','promote')
		and destRank.id = @level_id

		print '-- update prev msl'
		-- SELECT 'prev_msl',-- 
		UPDATE taxonomy_node SET 
		--SELECT 'prev_msl',sort, taxonomy_node.taxnode_id, taxonomy_node.lineage, _action, _dest_taxon_rank, new_name=src._dest_taxon_name, [update]='>>>>',
			out_change = _action
			, out_target = dest.lineage
			, out_filename = proposal
			, out_notes = spreadsheet
		FROM taxonomy_node 
		JOIN load_next_msl_isOk src on src.prev_taxnode_id = taxonomy_node.taxnode_id
		JOIN taxonomy_node dest on dest.taxnode_id = src.dest_taxnodE_id
		left outer join taxonomy_level destRank on destRank.name = src._dest_taxon_rank
		WHERE src._action in ('move','demote','promote')	
		and destRank.id = @level_id
		--and taxonomy_node.out_change is null
	

		print '-- record completion'
		UPDATE load_next_msl_isOk SET 
		-- 	DECLARE @rank varchar(20); SET @rank='family'; DECLARE @level_id int; SET @level_id=300 ; SELECT taxnode_id, name, level_id, _dest_taxon_rank, out_change, out_target,
			 isDONE=ISNULL(isDONE+'; ','')+'4.a.apply_create_actions['+rtrim(sort)+']: MOVE (+rename+promote+demote) src_rank='+_src_taxon_rank+', dest_rank='+@rank+'; _action='+src._action
		FROM load_next_msl_isOk src 
		JOIN taxonomy_node on src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src._action in ('move','demote','promote')
		and _dest_taxon_rank = @rank
		--and 1 = 0 -- DEBUG

		/*-- DEBUG
		select t='load_next_msl_ok: after', * from load_next_msl_isOk where _action='promote'
		select t='taxonomy_node: after', taxnode_id, msl_release_num, level_id, name, out_change, out_target, out_filename
		from taxonomy_node where taxnode_id in (202100225,202104872,202104918, 202000225,202004872,202004918,202107120,202007120)
		order by msl_release_num, level_id
		*/
	ENd
	
	-- DEBUG:
	-- DECLARE @count int; DECLARE @rank varchar(50); DECLARE @level_id int; DECLARE @msg varchar(500); SELECT @rank=name, @level_id=id FROM taxonomy_level WHERE name='species';

	print '-- -----------------------------------------------------------------------------'
	PRINT '-- MERGE @ '+@rank
	print '-- -----------------------------------------------------------------------------'

	SELECT @count=count(*) 
	FROM load_next_msl_isOk where _action='merge' AND _dest_taxon_rank = @rank
	if @count = 0 BEGIN
		PRINT 'SKIP: No actions for rank '+@rank
	END ELSE BEGIN
		SELECT step='starting', action='MERGE', rank=@rank 
		-- debug promote
		select t='taxonomy_node', taxnode_id, msl_release_num, level_id, name, out_change, out_target, out_filename from taxonomy_node where taxnode_id in (202000225,202004872,202004918)  order by msl_release_num, level_id

		-- when MSL created, included this taxon, so remove the copy in the current MSL
		-- (since it will be merged and no longer exist)

		-- first, move any children to the MERGE target
		UPDATE taxonomy_node SET 
			parent_id = dest_parent.taxnode_id
		FROM taxonomy_node 
		JOIN taxonomy_node src_parent on src_parent.taxnode_id = taxonomy_node.parent_id  and src_parent._numKids > 0
		JOIN load_next_msl_isOk src on src_parent.taxnode_id=src.dest_taxnode_id 
		JOIN taxonomy_node dest_parent on dest_parent.msl_release_num = src.dest_msl_release_num and dest_parent.name = src._dest_taxon_name
		where src._action='merge'
		and src_parent.level_id = (select id from taxonomy_level where name ='genus')

		-- then delete the MERGE source from this MSL
		DELETE FROM taxonomy_node 
		--SELECT a='DELETE',_action, taxonomy_node.taxnode_id, taxonomy_node.lineage, src._src_taxon_name, new_name=src._dest_taxon_name, prev_taxnode_id=src.prev_taxnode_id, isWrong
		FROM taxonomy_node 
		JOIN load_next_msl_isOk src on  msl_release_num = src.dest_msl_releasE_num AND src._src_taxon_name = taxonomy_node.name 
		WHERE src._action='merge'	
		and level_id = @level_id


		-- set "OUT" change fields on prev MSL
		UPDATE taxonomy_node SET 
		--SELECT taxonomy_node.taxnode_id, taxonomy_node.lineage, '|'+_action+'|', _dest_taxon_rank, new_name=src._dest_taxon_name,
			out_change = _action
			, out_target = src._dest_taxon_name
			, out_filename = proposal
			, out_notes = spreadsheet
		FROM taxonomy_node 
		JOIN load_next_msl_isOk src on src.prev_taxnode_id = taxonomy_node.taxnode_id
		where src._action='merge'	
		and level_id = @level_id
		AND (
			out_target is null or out_target <> src._dest_taxon_name
		)

		-- record completion
		UPDATE load_next_msl_isOk SET 
		--SELECT _action, _src_lineage, _dest_taxon_rank, _dest_lineage, 	
			isDONE=ISNULL(isDONE+'; ','')+'4.a.apply_create_actions['+rtrim(sort)+']: MERGE, dest_rank='+@rank+'; _action='+src._action
		FROM load_next_msl_isOk src 
		JOIN taxonomy_node on src.prev_taxnode_id = taxonomy_node.taxnode_id
		WHERE src._action='merge'	
		and level_id = @level_id
		and isDONE is null
	END 


	FETCH NEXT FROM UP_CURSOR INTO @level_id, @rank
END

CLOSE UP_CURSOR
DEALLOCATE UP_CURSOR

SET NOCOUNT OFF

--
-- report on changes implemented
--

--
-- summary counts
--
--DEBUG-- DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl_isOk)

select 
	report='counts by [ACTION]'
	, action=act.change, prevMSL=prev.ct, load_next_msl_isOk=new.ct, nextMSL=dest.ct
	, (case when  isnull(prev.ct,0)+isnull(dest.ct,0) = isnull(new.ct,0) then 'OK' else 'ERROR' end )
from (select change from taxonomy_change_in union select change from taxonomy_change_out) as act
left outer join (
	-- load_next_msl
	select change=_action, ct=count(*), title='load_next_msl_isOk', col='_action',  msl=dest_msl_release_num
	from load_next_msl_isOk 
	group by dest_msl_release_num, _action 
) as new on new.change = act.change
left outer join (
	-- prev-MSL: out_change
	select  change=out_change, ct=count(*),title='prevMSL.out_action', col='out_change', msl_release_num
	from taxonomy_node_names where msl_release_num=(@msl-1) and out_change is not null
	group by msl_release_num, out_change
) as prev on prev.change = act.change
left outer join (
	-- MSL: in_change DECLARE @msl int; SET @msl=(select distinct dest_msl_release_num from load_next_msl_isOk)
	select change=in_change, ct=count(*), title='currMSL.in_action ', col='in_change=',  msl_release_num
	from taxonomy_node_names where msl_release_num=@msl and in_change is not null
	group by msl_release_num, in_change
) as dest on dest.change = act.change
order by action

-- QC
-- compare load_next_msl with taxonomy_node.in_action
-- declare @msl int; SET @msl = 37
select src.* , lvl.id
from (
	select r='QC: load_next_msl_isOk._action=new', _action, _dest_taxon_rank, ct=count(*), doneCt=count(isDone) from load_next_msl_isOk where  _action = 'new' group by _action, _dest_taxon_rank
	union all
	select r='QC: tax_node.MSL'+rtrim(@msl)+'.in_change=new ***', in_change, rank, ct=count(*), isDONE=0 from taxonomy_node_names where msl_release_num = @msl and in_change in ('new') group by in_change, rank
) as src
join taxonomy_level lvl on lvl.name = src._dest_taxon_rank
order by lvl.id, _action,r

/*
--
-- taxonomy_node remove things marked isWrong in load_next_msl
--
-- declare @msl int; SET @msl = 37
select n.taxnode_id, n.lineage, l.*
from taxonomy_node_names n
left outer join load_next_msl l on l.dest_taxnode_id = n.taxnode_id
where n.msl_release_num = @msl and n.in_change='new' and n.[rank]='species'
order by n.lineage, l.isWrong
*/


-- mark the originals as isWrong
/* DEBUG MSL36
select 'after',taxnode_id, lineage, _numKids,* from taxonomy_node where taxnode_id in (202112935,202114000) or name in ('Doupovirus australiaense','Doupovirus')
order by msl_release_num, left_idx
select * from load_next_msl where dest_taxnode_id = 202114000 or _dest_taxon_name in ('Doupovirus australiaense','Doupovirus')
*/


-- MSL37 - missing promote
select * from load_next_msl_isOk where _action='promote'
select t='taxonomy_node', taxnode_id, msl_release_num, level_id, name, out_change, out_target, out_filename
 from taxonomy_node where taxnode_id in (202100225,202104872,202104918, 202000225,202004872,202004918,202107120,202007120)
 order by msl_release_num, level_id
 /* MSL37 need this fix?
select rank, 
	--update load_next_msl_isOk set 
	rank='subfamily', isdone=null  
from load_next_msl_isOk where sort=3880
*/

select sort, proposal, _src_taxon_rank, _src_lineage, _action, _dest_taxon_rank, _dest_lineage, isDone from load_next_msl where sort in ('3880','98')

select sort, proposal, _src_taxon_rank, _src_lineage, _action, _dest_taxon_rank, _dest_lineage, isDone from load_next_msl where subfamily='Peduovirinae'
select sort, proposal, _src_taxon_rank, _src_lineage, _action, _dest_taxon_rank, _dest_lineage, isDone from load_next_msl where family='Peduoviridae'


select report='src_taxon multiply modified'
	, _src_taxon_name,  ct=count(*)
	, _action1=min(_action), _action2=max(_action)
	, proposal1=min(proposal), proposal2=max(proposal)
	, sort1=min(sort), sort2=max(sort)
from load_next_msl_isok 
where _src_taxon_name is not null
group by _src_taxon_name 
having count(*)>1




--rollback transaction
--commit transaction
