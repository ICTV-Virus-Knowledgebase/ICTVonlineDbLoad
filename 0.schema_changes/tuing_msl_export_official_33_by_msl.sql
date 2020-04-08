select 
	-- basic MSL - one line per species
	--TN.msl_release_num, -- debugging
	[realm]        = isnull([realm].name,'')
	,[subrealm]     = isnull([subrealm].name,'')
	,[kingdom]      = isnull([kingdom].name,'')
	,[subkingdom]   = isnull([subkingdom].name,'')
	,[phylum]       = isnull([phylum].name,'')
	,[subphylum]    = isnull([subphylum].name,'')
	,[class]        = isnull([class].name,'')
	,[subclass]     = isnull([subclass].name,'')
	,[order]        = isnull([order].name,'')
	,[suborder]     = isnull([suborder].name,'')
	,[family]       = isnull([family].name,'')
	,[subfamily]    = isnull([subfamily].name,'')
	,[genus]        = isnull([genus].name,'')
	,[subgenus]     = isnull([subgenus].name,'')
	,[species]      = isnull([species].name,'')
	, type_species = tn.is_ref
	-- add info on most recent change to that taxon
	--,tn.taxnode_id, tn.ictv_id, 
	-- select msl_release_num, ictV_id, name, abbrev from taxonomy_node where abbrev is not null
	/* == MSL32 - move isolate and accession info to tables [virus_isolates]
	,last_ncbi=isnull((
		-- most recent change tag of node or ancestor 
		select top(1) t.genbank_accession_csv
		from taxonomy_node_merge_split tms
		join taxonomy_node t on 
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		where tms.next_ictv_id = tn.ictv_id
		and t.genbank_accession_csv is not null
		order by tn.msl_release_num-t.msl_release_num, abs(tn.left_idx - t.left_idx)
	),'')
	,last_isolates=isnull((
		-- most recent change tag of node or ancestor 
		-- select top(1) rtrim(t.taxnode_id)+','+t.name+','+cast(t.isolate_csv as varchar(max)) -- debug
		select top(1) t.isolate_csv 
		from taxonomy_node_merge_split tms
--		join taxonomy_node_n t on -- get isolates with full Unicode names!
		join taxonomy_node t on -- until move to nvarchar/ntext, some isolates will be missing diacriticals
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		where tms.next_ictv_id = tn.ictv_id
		and t.isolate_csv is not null
		order by tn.msl_release_num-t.msl_release_num, abs(tn.left_idx - t.left_idx)
	),'')
	== */
	-- add info on most recent molecule type designation to that taxon (or it's ancestors)
	,molecule=isnull((
		-- most recent change tag of node or ancestor 
		select top(1) mol.abbrev
		from taxonomy_node_merge_split tms
		join taxonomy_node t on 
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		join taxonomy_node tancestor on
			-- look at ancestors w/in each historic MSL
			tancestor.left_idx <= t.left_idx and tancestor.right_idx >= t.right_idx 
			and tancestor.tree_id = t.tree_id and tancestor.level_id > 100 
		join taxonomy_molecule mol on mol.id = tancestor.inher_molecule_id
		where tms.next_ictv_id = tn.ictv_id
		and mol.abbrev is not null
		order by tn.msl_release_num-tancestor.msl_release_num, tancestor.node_depth desc
	),'')
	-- DEBUG - where did molecule data come from
	/*,molecule_src=isnull((
		-- most recent change tag of node or ancestor 
		select top(1) rtrim(tancestor.msl_release_num)+':'+tancestor.lineage -- mol.abbrev
		from taxonomy_node_merge_split tms
		join taxonomy_node t on 
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		join taxonomy_node tancestor on
			-- look at ancestors w/in each historic MSL
			tancestor.left_idx <= t.left_idx and tancestor.right_idx >= t.right_idx 
			and tancestor.tree_id = t.tree_id and tancestor.level_id > 100 
		join taxonomy_molecule mol on mol.id = tancestor.inher_molecule_id
		where tms.next_ictv_id = tn.ictv_id
		and mol.abbrev is not null
		order by tn.msl_release_num-tancestor.msl_release_num, tancestor.node_depth desc
	),'')
	*/
	-- add info on most recent change to that taxon (or it's ancestors)
	, last_change=(
		select top(1) dx.prev_tags 
		from taxonomy_node_merge_split tms
		join taxonomy_node t on 
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		join taxonomy_node_dx dx on
			-- look at ancestors w/in each historic MSL
			dx.left_idx <= t.left_idx and dx.right_idx >= t.right_idx 
			and dx.tree_id = t.tree_id and dx.level_id > 100 
			and dx.prev_tags is not null and dx.prev_tags <> ''
		where tms.next_ictv_id = tn.ictv_id
		order by tn.msl_release_num-dx.msl_release_num, dx.node_depth desc
	)
	, last_change_msl=(
		-- MSL of most recent change tag of node or ancestor 
		select top(1) dx.msl_release_num 
		from taxonomy_node_merge_split tms
		join taxonomy_node t on 
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		join taxonomy_node_dx dx on
			-- look at ancestors w/in each historic MSL
			dx.left_idx <= t.left_idx and dx.right_idx >= t.right_idx 
			and dx.tree_id = t.tree_id and dx.level_id > 100 
			and dx.prev_tags is not null and dx.prev_tags <> ''
		where tms.next_ictv_id = tn.ictv_id
		order by tn.msl_release_num-dx.msl_release_num, dx.node_depth desc
	)
	, last_change_proposal=isnull((
		-- PROPOSAL of most recent change tag of node or ancestor WITH PROPOSAL
		select top(1) dx.prev_proposal 
		from taxonomy_node_merge_split tms
		join taxonomy_node t on 
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		join taxonomy_node_dx dx on
			-- look at ancestors w/in each historic MSL
			dx.left_idx <= t.left_idx and dx.right_idx >= t.right_idx 
			and dx.tree_id = t.tree_id and dx.level_id > 100 
			and dx.prev_tags is not null and dx.prev_tags <> ''
		where tms.next_ictv_id = tn.ictv_id
		and dx.prev_proposal is not null and dx.prev_proposal <> ''
		and dx.msl_release_num = (
			-- limit to same MSL (but not same ancestory) as last change TAG
			select top(1) dx.msl_release_num 
			from taxonomy_node_merge_split tms
			join taxonomy_node t on 
				-- historic across merge/splits
				t.ictv_id=tms.prev_ictv_id
				 and t.msl_release_num <= tn.msl_release_num
			join taxonomy_node_dx dx on
				-- look at ancestors w/in each historic MSL
				dx.left_idx <= t.left_idx and dx.right_idx >= t.right_idx 
				and dx.tree_id = t.tree_id and dx.level_id > 100 
				and dx.prev_tags is not null and dx.prev_tags <> ''
			where tms.next_ictv_id = tn.ictv_id
			order by tn.msl_release_num-dx.msl_release_num, dx.node_depth desc
		)
		order by tn.msl_release_num-dx.msl_release_num, dx.node_depth desc	
	),'')
	, history_url = '=HYPERLINK("http://ictvonline.org/taxonomy/p/taxonomy-history?taxnode_id='+rtrim(tn.taxnode_id)+'","ICTVonline='+rtrim(tn.taxnode_id)+'")'
	-- these columns are not currently released in the official MSL
	-- ICTV does not OFFICIALLY track abbreviations 
	/*, FYI_last_abbrev=isnull((
		-- most recent change tag of node or ancestor 
		select top(1) tancestor.abbrev_csv
		from taxonomy_node_merge_split tms
		join taxonomy_node t on 
			-- historic across merge/splits
			t.ictv_id=tms.prev_ictv_id
			 and t.msl_release_num <= tn.msl_release_num
		join taxonomy_node tancestor on
			-- look at ancestors w/in each historic MSL
			tancestor.left_idx <= t.left_idx and tancestor.right_idx >= t.right_idx 
			and tancestor.tree_id = t.tree_id and tancestor.level_id > 100 
		where tms.next_ictv_id = tn.ictv_id
		and tancestor.abbrev_csv is not null
		order by tn.msl_release_num-tancestor.msl_release_num, tancestor.node_depth desc
	),'')
	*/
from taxonomy_node tn
left outer join taxonomy_node [tree] on [tree].taxnode_id=tn.tree_id
left outer join taxonomy_node [realm] on [realm].taxnode_id=tn.realm_id
left outer join taxonomy_node [subrealm] on [subrealm].taxnode_id=tn.subrealm_id
left outer join taxonomy_node [kingdom] on [kingdom].taxnode_id=tn.kingdom_id
left outer join taxonomy_node [subkingdom] on [subkingdom].taxnode_id=tn.subkingdom_id
left outer join taxonomy_node [phylum] on [phylum].taxnode_id=tn.phylum_id
left outer join taxonomy_node [subphylum] on [subphylum].taxnode_id=tn.subphylum_id
left outer join taxonomy_node [class] on [class].taxnode_id=tn.class_id
left outer join taxonomy_node [subclass] on [subclass].taxnode_id=tn.subclass_id
left outer join taxonomy_node [order] on [order].taxnode_id=tn.order_id
left outer join taxonomy_node [suborder] on [suborder].taxnode_id=tn.suborder_id
left outer join taxonomy_node [family] on [family].taxnode_id=tn.family_id
left outer join taxonomy_node [subfamily] on [subfamily].taxnode_id=tn.subfamily_id
left outer join taxonomy_node [genus] on [genus].taxnode_id=tn.genus_id
left outer join taxonomy_node [subgenus] on [subgenus].taxnode_id=tn.subgenus_id
left outer join taxonomy_node [species] on [species].taxnode_id=tn.species_id
where tn.is_deleted = 0 and tn.is_hidden = 0 and tn.is_obsolete=0
and tn.msl_release_num = 33
and tn.level_id = 600 /* species */
order by tn.left_idx




