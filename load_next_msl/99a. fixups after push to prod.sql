--use ictvonline 

-- ======================
-- MSL30 -- 
-- ======================

--
-- clean up quoted proposal filenames! ARG - shoudln't get this far!!!!
--
select 'quoted proposal name' as problem 
	, msl_release_num, lineage, in_filename, in_change, out_filename, out_change
from taxonomy_node_n
where in_filename like '"%"'
or out_filename like '"%"'
	
update taxonomy_node set
	in_filename = REPLACE(in_filename,'"','')
where in_filename like '"%"'

update taxonomy_node set
	out_filename = REPLACE(out_filename,'"','')
where out_filename like '"%"'

update taxonomy_node_delta set
	proposal = REPLACE(proposal,'"','')
where proposal like '"%"'

update taxonomy_node set
	-- select name, isolate_csv,
	isolate_csv = 'Sudan virus/H.sapiens-tc/UGA/2000/Gulu-808892'
from taxonomy_node
where name = 'Sudan ebolavirus'
and msl_release_num = 30
and isolate_csv not like 'Sudan virus/H.sapiens-tc/UGA/2000/Gulu-808892'

update taxonomy_node set
	-- select name, isolate_csv,
	isolate_csv = 'Ebola virus/H.sapiens-tc/COD/1976/Yambuku-Mayinga'
from taxonomy_node
where name = 'Zaire ebolavirus'
and msl_release_num = 30
and isolate_csv not like 'Ebola virus/H.sapiens-tc/COD/1976/Yambuku-Mayinga'



/*
 -- somehow both quotes and .pdf go through in proposal names again in 2014 /MSL29
 -- Looks like cleanup step was after delta nodes were created, so delta nodes got un-clean proposal names
 -- also, 2 proposal names had quotes around them, which foiled the %.pdf cleanup pattern. Needed a %.pdf%, 
 -- plus quote removal.
--
-- fix PDF name
--

--
-- primary copy
--
update taxonomy_node set 
--select n.in_filename, n.out_filename, n.filename,
	in_filename= case
		when in_filename like '"%.pdf"'  then replace(replace(in_filename, '.pdf', ''),'"','')
		when in_filename like '%.pdf%'  then replace(in_filename, '.pdf', '')
		when in_filename like '"%"' then replace(in_filename, '"','') 
		else in_filename end
	, out_filename= case
		when out_filename like '"%.pdf"'  then replace(replace(out_filename, '.pdf', ''),'"','')
		when out_filename like '%.pdf%'  then replace(out_filename, '.pdf', '')
		when out_filename like '"%"' then replace(out_filename, '"','') 
		else out_filename end
	, filename= case 
		when n.filename like '"%.pdf"'  then replace(replace(filename, '.pdf', ''),'"','')
		when n.filename like '%.pdf%'  then replace(filename, '.pdf', '')
		when n.filename like '"%"' then replace(filename, '"','') 
		else filename end
from taxonomy_node n
where 
--tree_id = 20130000 and 
(
	n.in_filename like '%.pdf%' or n.in_filename like '"%"'
	or
	n.out_filename like  '%.pdf%'  or n.out_filename like '"%"'
	or
	n.filename like  '%.pdf%' or n.filename like '"%"'
)

-- 
-- derived copies
--
update taxonomy_node_delta set
--select d.proposal,
	proposal=replace(replace(proposal, '.pdf', ''), '"','')
from taxonomy_node_delta as d
where d.proposal like '%.pdf%' or d.proposal like '%"%'


-- correct data entry error (proposal is correct)
-- move 'yellow tailflower mild mottle virus', 'tomato mottle mosaic virus'
-- from 'Tobravirus' to 'Tobamovirus'
-- per Dr Steve Wylie,  s.wylie@murdoch.edu.au, email 2015-03-04
update taxonomy_node set
 -- select parent_id, name, in_target,
 parent_id = (select p.taxnode_id from taxonomy_node p where  p.name='Tobamovirus' and p.msl_release_num=n.msl_release_num)
 , in_target= replace(in_target, ';Tobravirus;', ';Tobamovirus;')
from taxonomy_node n
where n.name in ('yellow tailflower mild mottle virus', 'tomato mottle mosaic virus')
and (
	in_target not like '%;Tobamovirus;%' 
	or
	parent_id <> (select p.taxnode_id from taxonomy_node p where  p.name='Tobamovirus' and p.msl_release_num=n.msl_release_num)
)
and n.msl_release_num in (29)

-- correct errors/typos (proposal is also flawed)
-- issues with the new family Sphaerolipoviridae, which need correction:
-- 1) Virus names ph1, sh1, snj1, p23-77 and in93 should be written with
-- capital letters (i.e., PH1, SH1, SNJ1, P23-77 and IN93).
-- 
--2) In genus Gammasphaerolipovirus, "phagein in93" should be corrected to "phage IN93".
-- per Mart Krupovic" <mart.krupovic@pasteur.fr> Date: March 8, 2015 at 9:56:24 AM PDT
update taxonomy_node set
-- select parent_id, name, in_target,
 name = case 
	when name like '%phagein in%' then replace(name, 'phagein in93', 'phage IN93')
	when name like '%ph1' then replace(name, 'ph1', 'PH1')
	when name like '%sh1' then replace(name, 'sh1', 'SH1')
	when name like '%snj1' then replace(name, 'snj1', 'SNJ1')
	when name like '%p23-77' then replace(name, 'p23-77', 'P23-77')
	end
 , in_target = case 
	when in_target like '%phagein in93' then replace(in_target, 'phagein in93', 'phage IN93')
	when in_target like '%ph1' then replace(in_target, 'ph1', 'PH1')
	when in_target like '%sh1' then replace(in_target, 'sh1', 'SH1')
	when in_target like '%snj1' then replace(in_target, 'snj1', 'SNJ1')
	when in_target like '%p23-77' then replace(in_target, 'p23-77', 'P23-77')
	end
from taxonomy_node n
where n.family_id = (select f.taxnode_id from taxonomy_node f where f.name= 'Sphaerolipoviridae' and f.msl_release_num=29)
and (
	n.name like '%phagein%'
or	n.name  COLLATE Latin1_General_CS_AS like '%ph1' -- CS = Case Sensitive
or	n.name  COLLATE Latin1_General_CS_AS like '%sh1' -- CS = Case Sensitive
or	n.name  COLLATE Latin1_General_CS_AS like '%snj1'-- CS = Case Sensitive
or	n.name  COLLATE Latin1_General_CS_AS like '%p23-77'-- CS = Case Sensitive
)
and n.msl_release_num in (29)


-- ***********************************************
-- Fix transient loss of type status
--
-- Mike's historical load didn't match cleanly with
-- Andy Ball's final MSL, leading to several species
-- that WERE type historically, weren't in Andy's MSL, 
-- then were corrected the next year (w/o proposal). 
--
-- This finds all these, and then makes them type. 
--
-- ***********************************************
begin transaction
-- 146 rows
select 'before' as title, msl_release_num, prev_tags, prev_proposal, taxnode_id, next_proposal, next_tags,  lineage, left_idx 
into #wrong_ref_list
from taxonomy_node_dx
where prev_tags like '%removed as type%' 
and next_tags like '%assigned as type%'

select * 
from #wrong_ref_list
order by msl_release_num, left_idx

-- update the nodes themselves
update taxonomy_node set
--select is_ref,
	is_ref=1 
from taxonomy_node
where taxnode_id in (select taxnode_id from #wrong_ref_list)

-- correct previous deltas (could just re-build deltas...)
update taxonomy_node_delta set
--select is_now_type,  tag_csv,
	is_now_type = 0 
from taxonomy_node_delta
where new_taxid in (select taxnode_id from #wrong_ref_list)

-- correct next deltas (could just re-build deltas...)
update taxonomy_node_delta set
-- select is_now_type, tag_csv,
	is_now_type = 0 
from taxonomy_node_delta
where prev_taxid in (select taxnode_id from #wrong_ref_list)

-- QC 
select 'after' as title, msl_release_num, prev_tags, prev_proposal, taxnode_id, next_proposal, next_tags,  lineage, left_idx 
--into #wrong_ref_list
from taxonomy_node_dx
where prev_tags like '%removed as type%' 
and next_tags like '%assigned as type%'

drop table #wrong_ref_list
--rollback transaction
commit transaction
-- annomolies
--
--Unassigned;Totiviridae;Unassigned;Totivirus;Saccharomyces cerevisiae virus L-A
--http://ictvonline.org/taxonomyHistory.asp?taxnode_id=20143803
-- renamed with (L1) in 'ICTV 8th Report', but we didn't accept name change
--

-- ***********************************************
-- 2013.001a-oB.U.v4.Sphaerolipoviridae.pdf (has caps)
-- vs 
-- 2013.001a-oB.U.v5.Sphaerolipoviridae.pdf (lacks caps)
-- 
-- Names with caps were ratified, and are the official ones.
-- per Andrew King <amqking@gmail.com>
-- ***********************************************
update taxonomy_node set
	--select taxnode_id, msl_release_num,in_filename,notes,
	in_filename= case when in_filename like '2013%.v5.%sphaer%'then replace(in_filename,'.v5.', '.v4.') end
	, notes = '[in_filename] Switch proposal from v5 (lacks caps) to v4 (has caps, ratified version) of the MSL29 Sphaerolipidae proposal [Mart Krupovic <mart.krupovic@pasteur.fr>]; '
from taxonomy_node
where 
in_filename like '2013%.v5.%sphaer%'

update taxonomy_node_delta set
	--select prev_taxid, new_taxid, proposal,
	proposal= case when proposal like '2013%.v5.%sphaer%'then replace(proposal,'.v5.', '.v4.') end
from taxonomy_node_delta
where 
proposal like '2013%.v5.%sphaer%'

-- QC
select taxnode_id, msl_release_num,
	prev_proposal= case when prev_proposal like '2013%sphaer%'then right(left(prev_proposal,len('2013.001a-oB.U.v4')),2) end,
	in_filename= case when in_filename like '2013%sphaer%' then right(left(in_filename,len('2013.001a-oB.U.v4')),2) end ,
	lineage,prev_proposal,in_filename
from taxonomy_node_dx
where 
in_filename like '2013%.v%.%sphaer%'
or prev_proposal like '2013%.v%.%sphaer%'

*/