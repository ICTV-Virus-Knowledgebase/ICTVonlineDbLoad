USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[taxonomy_level]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[taxonomy_level](
	[id] [int] NOT NULL,
	[parent_id] [int] NULL,
	[name] [varchar](255) NOT NULL,
	[plural] [varchar](50) NULL,
	[suffix] [varchar](50) NULL,
	[suffix_viroid] [varchar](50) NULL,
	[suffix_nuc_acid] [varchar](50) NULL,
	[notes] [text] NULL,
 CONSTRAINT [pk_taxonomy_level] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[taxonomy_level]  WITH CHECK ADD  CONSTRAINT [FK_taxonomy_level_taxonomy_level] FOREIGN KEY([parent_id])
REFERENCES [dbo].[taxonomy_level] ([id])
GO
ALTER TABLE [dbo].[taxonomy_level] CHECK CONSTRAINT [FK_taxonomy_level_taxonomy_level]
GO
