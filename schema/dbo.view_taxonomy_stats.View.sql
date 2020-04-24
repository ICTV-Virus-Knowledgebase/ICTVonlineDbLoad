USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Taxa counts per MSL - used by index.asp and taxInfo.asp*/
CREATE VIEW [dbo].[view_taxonomy_stats]
AS
SELECT     (SELECT     notes
                       FROM          dbo.taxonomy_node AS t
                       WHERE      (level_id = 100) AND (taxnode_id = n.tree_id)) AS notes, n.msl_release_num,
                          (SELECT     name
                            FROM          dbo.taxonomy_node AS t
                            WHERE      (level_id = 100) AND (taxnode_id = n.tree_id)) AS year, COUNT(order_level.id) AS orders, COUNT(family_level.id) AS families, COUNT(subfamily_level.id) 
                      AS subfamilies, COUNT(genus_level.id) AS genera, COUNT(species_level.id) AS species
FROM         dbo.taxonomy_node AS n LEFT OUTER JOIN
                      dbo.taxonomy_level AS order_level ON order_level.id = n.level_id AND order_level.id = 200 LEFT OUTER JOIN
                      dbo.taxonomy_level AS family_level ON family_level.id = n.level_id AND family_level.id = 300 LEFT OUTER JOIN
                      dbo.taxonomy_level AS subfamily_level ON subfamily_level.id = n.level_id AND subfamily_level.id = 400 LEFT OUTER JOIN
                      dbo.taxonomy_level AS genus_level ON genus_level.id = n.level_id AND genus_level.id = 500 LEFT OUTER JOIN
                      dbo.taxonomy_level AS species_level ON species_level.id = n.level_id AND species_level.id = 600
WHERE     (n.is_hidden = 0) AND (n.msl_release_num IS NOT NULL) AND (n.name NOT LIKE 'unassigned') AND (n.tree_id > 10090000)
GROUP BY n.tree_id, n.msl_release_num
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
         Begin Table = "n"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "order_level"
            Begin Extent = 
               Top = 6
               Left = 292
               Bottom = 125
               Right = 468
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "family_level"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "subfamily_level"
            Begin Extent = 
               Top = 126
               Left = 252
               Bottom = 245
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "genus_level"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "species_level"
            Begin Extent = 
               Top = 246
               Left = 252
               Bottom = 365
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 0
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
      Begin ColumnWidths = 12
         Column = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_taxonomy_stats'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 3045
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_taxonomy_stats'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_taxonomy_stats'
GO
