
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[taxonomy_genome_coverage](
	[genome_coverage] [nvarchar](50) NOT NULL,
	[name] [nvarchar](50) NULL,
	[priority] [int] NULL,
 CONSTRAINT [PK_taxonomy_genome_coverage] PRIMARY KEY CLUSTERED 
(
	[genome_coverage] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

