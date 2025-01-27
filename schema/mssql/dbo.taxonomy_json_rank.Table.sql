USE [ICTVonline]
GO
/****** Object:  Table [dbo].[taxonomy_json_rank]    Script Date: 8/20/2024 4:10:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[taxonomy_json_rank](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[level_id] [int] NOT NULL,
	[rank_index] [int] NOT NULL,
	[rank_name] [varchar](50) NOT NULL,
	[tree_id] [int] NOT NULL,
 CONSTRAINT [PK_taxonomy_json_rank] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_taxonomy_json_rank] UNIQUE NONCLUSTERED 
(
	[level_id] ASC,
	[tree_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_taxonomy_json_rank_rank_tree] UNIQUE NONCLUSTERED 
(
	[rank_index] ASC,
	[tree_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[taxonomy_json_rank]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_json_rank_taxonomy_level] FOREIGN KEY([level_id])
REFERENCES [dbo].[taxonomy_level] ([id])
GO
ALTER TABLE [dbo].[taxonomy_json_rank] CHECK CONSTRAINT [FK_taxonomy_json_rank_taxonomy_level]
GO
ALTER TABLE [dbo].[taxonomy_json_rank]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_json_rank_tree_id] FOREIGN KEY([tree_id])
REFERENCES [dbo].[taxonomy_node] ([taxnode_id])
GO
ALTER TABLE [dbo].[taxonomy_json_rank] CHECK CONSTRAINT [FK_taxonomy_json_rank_tree_id]
GO
