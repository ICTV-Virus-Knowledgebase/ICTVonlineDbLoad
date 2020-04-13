--
-- QC : do any of these action='new' taxa exist already?
--

--
-- QUERY bad taxa
--
select report='TAXON ALREADY EXISTS in MSL'+rtrim(tn.msl_release_num)
	, msl.filename
	-- load_next_msl fields
	,sort, proposal, change, _dest_lineage, _dest_taxon_name
	-- taxonomy_node fields
	, tn.taxnode_id,ictv_id, tn.lineage,  tn.is_ref,  tn.in_filename, tn. in_change
	, isWrong
	--
	-- !!  MARK BAD TAXA !!
	--
    -- UPDATE load_next_msl set isWrong = 'taxon already exists: taxnode_id='+rtrim(tn.taxnode_id)+', ictv_id='+rtrim(tn.ictv_id)+', lineage='+tn.lineage 
	--
from load_next_msl msl
-- prev MSL in taxnomy_node
join taxonomy_node tn  on tn.msl_release_num in( msl.dest_msl_release_num-1) and tn.name = msl._dest_taxon_name
where  msl._action = 'new'
--
-- skip this part to get a report of bads already set to isWrong=[message]
--
AND isWrong is NULL



--
-- FIXES 
--

--
-- MSL35.1469
-- 
/*
sort=1469; 2019.103B.zip; [Create new; assign as type species]  taxon already exists: taxnode_id=201850587, ictv_id=20094401, lineage=Caudovirales;Podoviridae;Autographivirinae;Prochlorococcus virus PSSP7
o	Elliot: In the line before this, 1468, the species Prochlorococcus virus PSSP7 is abolished. But since sort 1469 creates it again in the new genus Tiamatvirus, this is really just a move. So I would delete sort line 1468, and change 1469 to a move. 
*/

-- "remove" the "abolish" by setting isWrong='message'
select sort, isWrong, proposal, spreadsheet, _src_lineage, _src_taxon_rank, change, _dest_lineage, rank,
--
-- update load_next_msl set
--
	isWrong = 'Elliot: In the line before this, 1468, the species Prochlorococcus virus PSSP7 is abolished. But since sort 1469 creates it again in the new genus Tiamatvirus, this is really just a move. So I would delete sort line 1468, and change 1469 to a move.'
from load_next_msl
where isWrong is null and sort=1468

-- show two error rows
select rpt='look at both rows to cut-paste combined correction row below', * from load_next_msl where sort in (1468, 1469)

--
-- replace with a MOVE, inserted by hand.
--
insert into load_next_msl (
		[filename]			
	  , [sort]				
      ,[isWrong]			
      ,[proposal_abbrev]	
      ,[proposal]			
      ,[spreadsheet]		
      ,[srcOrder]		
      ,[srcFamily]			
      ,[srcSubfamily]		
      ,[srcSpecies]			
      ,[order]				
      ,[family]				
      ,[genus]				
      ,[species]			
      ,[isType]				
      ,[exemplarAccessions]	
      ,[exemplarName]		
      ,[isComplete]			
      ,[molecule]			
      ,[change]				
      ,[rank]				
      ,[_action]			
      ,[prev_taxnode_id]	
      ,[dest_msl_release_num]
      ,[isDone]				
)
select
		[filename]			= rm.[filename]
	  , [sort]				= rm.sort+0.5  -- half way between two wrong ones!
      ,[isWrong]			= NULL
      ,[proposal_abbrev]	= '2019.103B'
      ,[proposal]			= '2019.103B.zip'
      ,[spreadsheet]		= '2019.103B.Autographiviridae_1fam9subfam132gen_2020template.xlsx'
      ,[srcOrder]			= 'Caudovirales'
      ,[srcFamily]			= 'Podoviridae'
      ,[srcSubfamily]		= 'Autographivirinae'
      ,[srcSpecies]			= 'Prochlorococcus virus PSSP7'
      ,[order]				= 'Caudovirales'
      ,[family]				= 'Autographiviridae'
      ,[genus]				= 'Tiamatvirus'
      ,[species]			= 'Prochlorococcus virus PSSP7'
      ,[isType]				= 1
      ,[exemplarAccessions]	= 'AY939843'
      ,[exemplarName]		= 'Prochlorococcus phage P-SSP7'
      ,[isComplete]			= 'CG'
      ,[molecule]			= 'dsDNA'
      ,[change]				= 'move genus; assign as type species'
      ,[rank]				= 'species'
      ,[_action]			= 'move'
      ,[prev_taxnode_id]	= rm.[prev_taxnode_id]
      ,[dest_msl_release_num] = 35
      ,[isDone]				= 0
from load_next_msl rm
where rm.sort=1468 -- base on abolish
and not exists (select * from load_nexT_msl where sort=rm.sort+0.5) -- don't re-insert