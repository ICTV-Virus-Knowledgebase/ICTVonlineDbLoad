USE [ICTVonline39]
GO
/****** Object:  Table [dbo].[taxonomy_node_merge_split]    Script Date: 8/20/2024 4:10:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[taxonomy_node_merge_split](
	[prev_ictv_id] [int] NOT NULL,
	[next_ictv_id] [int] NOT NULL,
	[is_merged] [int] NOT NULL,
	[is_split] [int] NOT NULL,
	[dist] [int] NOT NULL,
	[rev_count] [int] NOT NULL,
 CONSTRAINT [PK_taxonomy_node_merge_split] PRIMARY KEY CLUSTERED 
(
	[prev_ictv_id] ASC,
	[next_ictv_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[taxonomy_node_merge_split]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_node_merge_split_taxonomy_node1] FOREIGN KEY([next_ictv_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[taxonomy_node_merge_split] CHECK CONSTRAINT [FK_taxonomy_node_merge_split_taxonomy_node1]
GO
