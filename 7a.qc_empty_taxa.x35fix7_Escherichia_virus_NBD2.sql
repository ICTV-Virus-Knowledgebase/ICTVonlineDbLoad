-- --------------------------------------------------------------------------------------------------
--
-- NO KIDS: Duplodnaviria;Heunggongvirae;Uroviricota;Caudoviricetes;Caudovirales;Drexlerviridae;Vilniusvirus

--
-- species"Escherichia virus NBD2", isolate "Escherichia phage vB_EcoS_NBD2" specified in proposal not created in spreadsheet. Will add as sort=1399.5

--
-- --------------------------------------------------------------------------------------------------

-- add action to load_next_msl, for the record
--DEBUG-- DELETE FROM LOAD_NEXT_MSL WHERE SORT=1399.5
--RUN-- insert into load_next_msl (filename, sort, proposal_abbrev, proposal, spreadsheet, change,  _action, rank, srcOrder, SrcFamily, srcSubFamily, species, isType, exemplarRefSeq, exemplarAccessions, Abbrev, exemplarIsolate, prev_taxnode_id, dest_taxnode_id, dest_ictv_id, dest_parent_id)
select 
	src.filename, sort+0.5, proposal_abbrev, proposal, spreadsheet
	, change='new species',  _action='new', rank='species'
	, [Order], Family, SubFamily
	, species='Escherichia virus NBD2'
	, isType=1 -- only species in genus
	, exemplarRefSeq='NC_031050.1', exemplarAccessions='KX130668.1', Abbrev=NULL, exemplarIsolate='Escherichia phage vB_EcoS_NBD2'
	, prev_taxnode_id=prev.taxnode_id
	, dest_taxnode_id=(select max(taxnode_id)+1 from taxonomy_node n where n.msl_release_num = src.dest_msl_release_num)
	, dest_ictv_id=(select max(taxnode_id)+1 from taxonomy_node n where n.msl_release_num = src.dest_msl_release_num)
	, dest_parent_id =destp.taxnode_id
	--, src.*
from load_next_msl src
left outer join taxonomy_node prev on prev.name = srcSubFamily and prev.msl_release_num=dest_msl_release_num-1
left outer join taxonomy_node dest on dest.name = srcSubFamily and dest.msl_release_num=dest_msl_release_num
left outer join taxonomy_node destp on destp.name = _dest_taxon_name and destp.msl_release_num=dest_msl_release_num
where _dest_taxon_name='Vilniusvirus' and sort=1399
and not exists (select * from load_next_msl tst where tst.sort=src.sort+0.5)

-- copied from 4.a.apply_create_actions_RANK_high_to_low.sql (action=NEW/SPLIT section)
--
-- add node to taxonomy_node
-- insert new row
DECLARE @rank varchar(50); SET @RANK='species'
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
		--DEBUG-- DECLARE @rank varchar(50); SET @RANK='species'
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
		from load_next_msl as src
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
		ORDER BY level_id, _dest_taxon_name-- insert new row
		

-- QC check
select report='ancestors', n.parent_id, n.taxnode_id, n.rank, n.name, n.lineage, n.in_change, n.in_filename
from taxonomy_node t
join taxonomy_node_names n on t.left_idx between n.left_idx and n.right_idx and n.tree_id = t.tree_id
where t.name = 'Escherichia virus NBD2'
order by n.level_id 

--COMMIT TRANSACTION
--ROLLBACK TRANSACTION

