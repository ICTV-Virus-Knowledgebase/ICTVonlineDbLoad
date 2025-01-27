USE [ICTVonline39lmims]
GO
/****** Object:  View [dbo].[virus_isolates]    Script Date: 10/8/2024 4:19:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  VIEW [dbo].[virus_isolates]
AS
/*

-- TEST
SELECT * FROM [virus_isolates]

*/
/* 
--
-- VMR based version (original; pre 2024-July)
--
SELECT     
	 vmr.species,
	 -- exemplar (E record)
	 vmr.exemplar, vmr.exemplar_isolate, vmr.exemplar_genbank_accession, vmr.exemplar_refseq_accession, 
	 vmr.exemplar_seq_complete, 
	 -- isolate (A record)
	 vmr.isolate_csv, vmr.isolate_genbank_accession_csv, vmr.isolate_refseq_accession, vmr.isolate_seq_complete_csv, 
                   vmr.alternative_name_csv,
	 -- VMR metadata
	 vmr.abbrev_csv, vmr.isolate_abbrev,
	 vmr.sort_species, vmr.sort, vmr.taxnode_id,
	 vmr.host, vmr.molecule, 
 	 -- taxonomy_node metadata
     tn.realm,
	 tn.subrealm, 
	 tn.kingdom, 
	 tn.subkingdom, tn.phylum, tn.subphylum, tn.class, tn.subclass, tn.[order], tn.suborder, 
     tn.family, tn.subfamily, tn.genus, tn.subgenus,
	 tn.left_idx,
     -- QC fields that compare to taxonomy_node for molecule and genome_coverage
	 qc_status =
		 (case when  vmr.molecule<> tn.inher_molecule then 'ERROR:molecule ' else '' end) +
		 (case when  tn.genome_coverage_name <> '' and tn.genome_coverage_name <>  isnull(vmr.exemplar_seq_complete, vmr.isolate_seq_complete_csv) then 'ERROR:genome_coverage ' else '' end),
	  qc_taxon_inher_molecule=tn.inher_molecule,
	  qc_taxon_genome_coverage = tn.genome_coverage_name,
	  qc_taxon_change = vmr.change,
	  qc_taxon_proposal = vmr.change_proposal
FROM         dbo.vmr vmr
LEFT OUTER JOIN dbo.taxonomy_node_names tn
     ON vmr.taxnode_id  =tn.taxnode_id
	*/
--
-- [SPECIES_ISOLATES]  based version (new 2024-July)
--
SELECT 
	[species] = si.species_name 
	 , exemplar = si.isolate_type -- A/E
	 -- exemplar (E record)
	 , exemplar_isolate =           (case when isolate_type='E' then si.isolate_designation end)
	 , exemplar_genbank_accession = (case when isolate_type='E' then si.genbank_accessions  end)
	 , exemplar_refseq_accession =  (case when isolate_type='E' then si.refseq_accessions   end)
	 , exemplar_seq_complete =      (case when isolate_type='E' then si.genome_coverage     end)
	 -- isolate (A record)
	 , isolate_csv =                 (case when isolate_type='A' then si.isolate_designation end)
	 , isolate_genbank_accession_csv=(case when isolate_type='A' then si.genbank_accessions  end)
	 , isolate_refseq_accession =    (case when isolate_type='A' then si.refseq_accessions   end)
	 , isolate_seq_complete_csv =    (case when isolate_type='A' then si.genome_coverage     end)
     , alternative_name_csv =        si.isolate_names
	 -- VMR metadata
	 , abbrev_csv = si.isolate_abbrevs
	 , isolate_abbrev = NULL
	 , sort_species= si.species_sort
	 , sort = si.isolate_sort
	 , taxnode_id = si.taxnode_id
	 , host = si.host_source
	 , molecule = si.molecule
 	 -- taxonomy_node metadata
     , tn.realm
	 , tn.subrealm
	 , tn.kingdom
	 , tn.subkingdom, tn.phylum, tn.subphylum, tn.class, tn.subclass, tn.[order], tn.suborder
     , tn.family, tn.subfamily, tn.genus, tn.subgenus
	 , tn.left_idx
     -- QC fields that compare to taxonomy_node for molecule and genome_coverage
	 , qc_status =
		 (case when  si.molecule<> tn.inher_molecule then 'ERROR:molecule ' else '' end)
		 -- +
		 -- (case when  tn.genome_coverage_name <> '' and tn.genome_coverage_name <>  isnull(vmr.exemplar_seq_complete, vmr.isolate_seq_complete_csv) then 'ERROR:genome_coverage ' else '' end),
	  , qc_taxon_inher_molecule=tn.inher_molecule
	  --, qc_taxon_genome_coverage = tn.genome_coverage_name,
	  , qc_taxon_change = si.update_change
	  , qc_taxon_proposal = si.update_change_proposal
FROM [species_isolates]    si
JOIN [taxonomy_node_names] tn ON tn.taxnode_id = si.taxnode_id
WHERE si.species_name <> 'abolished'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vmr"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 166
               Right = 341
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "taxonomy_node_names"
            Begin Extent = 
               Top = 168
               Left = 38
               Bottom = 419
               Right = 339
            End
            DisplayFlags = 280
            TopColumn = 80
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'virus_isolates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'virus_isolates'
GO
