USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[position](
	[position_id] [int] IDENTITY(1,1) NOT NULL,
	[committee_id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[display_order] [int] NULL,
	[is_singular] [char](1) NULL,
 CONSTRAINT [PK_position] PRIMARY KEY CLUSTERED 
(
	[position_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_position] UNIQUE NONCLUSTERED 
(
	[committee_id] ASC,
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[position]  WITH CHECK ADD  CONSTRAINT [FK_position_committee] FOREIGN KEY([committee_id])
REFERENCES [dbo].[committee] ([committee_id])
GO
ALTER TABLE [dbo].[position] CHECK CONSTRAINT [FK_position_committee]
GO
