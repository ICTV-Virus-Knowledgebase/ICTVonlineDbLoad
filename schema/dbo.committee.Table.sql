USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[committee]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[committee](
	[committee_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[type] [varchar](50) NOT NULL,
	[parent_id] [int] NULL,
	[left_idx] [int] NULL,
	[right_idx] [int] NULL,
	[node_depth] [int] NULL,
	[url] [varchar](500) NULL,
	[display_name]  AS (([name]+' ')+[type]),
	[comment] [text] NULL,
	[needs_positions] [char](1) NOT NULL,
	[active] [char](1) NOT NULL,
 CONSTRAINT [PK_committee] PRIMARY KEY CLUSTERED 
(
	[committee_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_committee] UNIQUE NONCLUSTERED 
(
	[name] ASC,
	[type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[committee] ADD  CONSTRAINT [DF_committee_needs_positions]  DEFAULT ('Y') FOR [needs_positions]
GO
ALTER TABLE [dbo].[committee] ADD  CONSTRAINT [DF_committee_active]  DEFAULT ('Y') FOR [active]
GO
ALTER TABLE [dbo].[committee]  WITH CHECK ADD  CONSTRAINT [FK_committee_committee] FOREIGN KEY([parent_id])
REFERENCES [dbo].[committee] ([committee_id])
GO
ALTER TABLE [dbo].[committee] CHECK CONSTRAINT [FK_committee_committee]
GO
ALTER TABLE [dbo].[committee]  WITH CHECK ADD  CONSTRAINT [FK_committee_committee_type_cv] FOREIGN KEY([type])
REFERENCES [dbo].[committee_type_cv] ([type])
GO
ALTER TABLE [dbo].[committee] CHECK CONSTRAINT [FK_committee_committee_type_cv]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Y means flagged to add positions, N means positions already created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'committee', @level2type=N'COLUMN',@level2name=N'needs_positions'
GO
