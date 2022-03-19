--
-- QC empty taxa & in-appropriate rank changes
--

-- --------------------------------------------------------------------------------------
-- 
PRINT '#QC SCAN for orphan "Unassigned" (QC may miss some things)'
-- Ex: MSL30, Tymovirales > Betaflexiviridae > [Unassigned] > Unassigned : has no kids
--
-- --------------------------------------------------------------------------------------
select
	report='scan for non-species nodes with no children'
	, p.msl_release_num, p.taxnode_id, p.ictv_id, p.rank, p.is_hidden, p.lineage,p.notes, _numKids
from taxonomy_node_names as p
where p.msl_release_num is not null
and p.level_id < 600
and p.is_deleted = 0
and not (
	-- Elliot: prior to 1999, species were not recognized. So higher-level taxa were established that did not formally contain species. 
	-- Many times they were populated with "viruses" and that is what was listed in the database. 
	-- But occasionally, no virus was designated that would have been assigned to the higher-level taxon. Hence these two taxa with no species/virus
	--p.lineage in ('')--('Unassigned;Poxviridae;Unassigned;Entomopoxvirus','Unassigned;Hepadnaviridae')
	p.notes like '%known empty taxon!%' and p.notes is not null
)
and _numKids = 0 
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7; empty taxa found', 18, 1) else print('PASS - no empty taxa')


-- 
-- MSL37 fix:  Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Mesyanzhinovviridae;Rabinowitzvirinae;Yuavirus missing Keylargovirus JL001
-- 
select * from taxonomy_node where msl_release_num in (36,37) and ( name like 'keylargovirus%' or name like 'Alphaproteobacteria virus phiJl001')
select * from load_next_msl where species like 'keylargovirus%'
update taxonomy_node set -- select *, 
	parent_id= (select taxnode_id from taxonomy_node where msl_release_num=37 and name='Keylargovirus')
from taxonomy_node where name='Keylargovirus JL001'  and lineage = 'Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Mesyanzhinovviridae;Rabinowitzvirinae;Yuavirus;Keylargovirus JL001'
update taxonomy_node set -- select *, 
	out_target = (select lineage from taxonomy_node where msl_release_num=37 and name='Keylargovirus JL001')
from taxonomy_node where  msl_release_num=36 and name='Alphaproteobacteria virus phiJl001'
update load_next_msl_isok set -- select *,
	change='move', _action='move'
	, dest_parent_id = (select taxnode_id  from taxonomy_node n where n.msl_release_num=dest_msl_release_num and name = _dest_parent_name)
from load_next_msl_isok
where species = 'Keylargovirus JL001' and _action <> 'move'

-- ===================================================================================================================================
-- === MORE QC
-- ===================================================================================================================================

PRINT '#QC Checking for inapproapriate RANK changes'
select 
	report='inappropriate rank change:'
	,_src_taxon_rank, _action, _dest_taxon_rank
	,  * 
from load_next_msl 
where _src_taxon_rank <> _dest_taxon_rank
and (_action not in ('new','promote','demote') or _action is null) 
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a; taxa change level badly', 18, 1) else print('PASS - no bad level changes')



-- -------------------------------------------------------------------
PRINT '#QC: lowercase unassigned'
-- -------------------------------------------------------------------

select ascii(name), name, 
	-- UPDATE taxonomy_node SET
	name = 'Unassigned' 
from taxonomy_node
where name = 'unassigned' and ascii(name)=117 -- lowercase U
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a; lower-case unassigned (obsolete)', 18, 1) else print('PASS - no lower-case unassigned nodes')

-- -------------------------------------------------------------------
PRINT '#QC: The Unassigned designation when used for genera is sometimes upper, sometimes lower case'
-- -------------------------------------------------------------------
select *,
	-- UPDATE taxonomy_node SET
	name = NULL
from taxonomy_node 
where taxnode_id in (
	select	-- select *,
		taxnode_id
	from taxonomy_node 
	where level_id=400 -- subfamily
	and is_hidden = 1 and name = 'unassigned'
)
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a; genus with Unasssigned name (obsolete)', 18, 1) else print('PASS - no genera with name=unassigned ')

-- -------------------------------------------------------------------
PRINT '#QC: CTRL-ENTER in genbank_accession_csv'
-- 1.	See extra line 2974 of your spreadsheet. 
-- CTRL-ENTER introduced in MSL30. Fixes 2 rows.
-- -------------------------------------------------------------------
select genbank_accession_csv, replace(genbank_accession_csv, char(10), ' '),
	-- UPDATE taxonomy_node SET
	genbank_accession_csv=replace(genbank_accession_csv, char(10), ', ')
from taxonomy_node 
where genbank_accession_csv like '%'+char(10)+'%' 
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a; CTRL-ENTERs in genbank_accession_csv ', 18, 1) else print('PASS - no CTRL-ENTERs found ')





-- -------------------------------------------------------------------
PRINT '#QC:  quoted proposal filenames! '
-- -------------------------------------------------------------------
select 'quoted proposal name' as problem 
	, msl_release_num, lineage, in_filename, in_change, out_filename, out_change
from taxonomy_node n
where in_filename like '"%"'
or out_filename like '"%"'
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a;  quoted proposal filenames ', 18, 1) else print('PASS - no  quoted proposal filenames ')
	
/*
update taxonomy_node set
	in_filename = REPLACE(in_filename,'"','')
where in_filename like '"%"'

update taxonomy_node set
	out_filename = REPLACE(out_filename,'"','')
where out_filename like '"%"'

update taxonomy_node_delta set
	proposal = REPLACE(proposal,'"','')
where proposal like '"%"'
*/

--
PRINT '#QC: check for bogus filenames - should end with .zip or .pdfa'
-- 
select taxnode_id, in_filename, lineage,'>>SET>>',
-- update taxonomy_node set NEED TO CUSTOMIZE FIX
	in_filename = replace(in_filename,';','.pdf;')
from taxonomy_node 
where 
(in_filename is not null and in_filename not like '%.pdf'  and in_filename not like '%.zip')
or
(in_filename like '%;%' and in_filename not like '%%.pdf;%'  and in_filename not like '%.zip;%')
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a;  in_filename mising .pdf and .zip ', 18, 1) else print('PASS - no   in_filename mising .pdf and .zip ')
	

select taxnode_id, out_filename, lineage, '>>SET>>',
-- update taxonomy_node set NEED TO CUSTOMIZE FIX
	out_filename = replace(out_filename,';','.pdf;')
from taxonomy_node 
where 
(out_filename is not null and out_filename not like '%.pdf'  and out_filename not like '%.zip')
or
(out_filename like '%;%' and out_filename not like '%%.pdf;%'  and out_filename not like '%.zip;%')
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a;  out_filename mising .pdf and .zip ', 18, 1) else print('PASS - no   out_filename mising .pdf and .zip ')



select *, '>>SET>>',
-- update taxonomy_node set NEED TO CUSTOMIZE FIX
	proposal = replace(proposal,';','.pdf;')
from taxonomy_node_delta
where 
(proposal is not null and proposal not like '%.pdf'  and proposal not like '%.zip')
or
(proposal like '%;%' and proposal not like '%%.pdf;%'  and proposal not like '%.zip;%')
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a;  delta.proposal mising .pdf and .zip ', 18, 1) else print('PASS - no delta.proposal mising .pdf and .zip ')


--
PRINT '#QC: check for bogus filenames lists - no spaces around ;'
-- 
select taxnode_id, in_filename, lineage,'>>SET>>',
-- update taxonomy_node set 
	in_filename = replace(replace(in_filename,' ;',';'),'; ',';')
from taxonomy_node 
where 
in_filename like '% ;%' 
or 
in_filename like '%; %'
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a;  in_filename has whitespace around ; ', 18, 1) else print('PASS - no  in_filename has whitespace around ')
	

select taxnode_id, out_filename, lineage,'>>SET>>',
-- update taxonomy_node set 
	out_filename = replace(replace(out_filename,' ;',';'),'; ',';')
from taxonomy_node 
where 
out_filename like '% ;%' 
or 
out_filename like '%; %'
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a;  out_filename has whitespace around ; ', 18, 1) else print('PASS - no  out_filename has whitespace around ')
	
select *, '>>SET>>',
-- update taxonomy_node_delta set 
	proposal =  replace(replace(proposal,' ;',';'),'; ',';')
from taxonomy_node_delta
where 
proposal like '% ;%'   
or
proposal like '%; %'
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7a;  delta.proposal mising .pdf and .zip ', 18, 1) else print('PASS - no delta.proposal mising .pdf and .zip ')


