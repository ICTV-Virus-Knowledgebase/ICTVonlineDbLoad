GO

/****** Object:  Table [dbo].[taxonomy_host_source]    Script Date: 7/23/2024 8:34:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[taxonomy_host_source](
	[host_source] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_taxonomy_host_source] PRIMARY KEY CLUSTERED 
(
	[host_source] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

