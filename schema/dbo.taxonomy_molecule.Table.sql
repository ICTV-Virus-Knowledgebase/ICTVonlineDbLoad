USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[taxonomy_molecule](
	[id] [int] NOT NULL,
	[abbrev] [varchar](50) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[balt_group] [int] NULL,
	[balt_roman] [varchar](5) NULL,
	[description] [text] NULL,
 CONSTRAINT [pk_taxonomy_molecule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
