USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[membership](
	[membership_id] [int] IDENTITY(1,1) NOT NULL,
	[member_id] [int] NOT NULL,
	[position_id] [int] NOT NULL,
	[inserted_on] [datetime] NOT NULL,
	[is_inactive] [char](1) NOT NULL,
	[start_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[changes] [text] NULL,
	[is_flagged] [char](1) NOT NULL,
 CONSTRAINT [PK_membership] PRIMARY KEY CLUSTERED 
(
	[membership_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[membership] ADD  CONSTRAINT [DF_membership_inserted_on]  DEFAULT (getdate()) FOR [inserted_on]
GO
ALTER TABLE [dbo].[membership] ADD  CONSTRAINT [DF_membership_is_inactive]  DEFAULT ('N') FOR [is_inactive]
GO
ALTER TABLE [dbo].[membership] ADD  CONSTRAINT [DF_membership_start_date]  DEFAULT (getdate()) FOR [start_date]
GO
ALTER TABLE [dbo].[membership] ADD  CONSTRAINT [DF_membership_is_flagged]  DEFAULT ('N') FOR [is_flagged]
GO
ALTER TABLE [dbo].[membership]  WITH CHECK ADD  CONSTRAINT [FK_membership_member] FOREIGN KEY([member_id])
REFERENCES [dbo].[member] ([member_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[membership] CHECK CONSTRAINT [FK_membership_member]
GO
ALTER TABLE [dbo].[membership]  WITH CHECK ADD  CONSTRAINT [FK_membership_position] FOREIGN KEY([position_id])
REFERENCES [dbo].[position] ([position_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[membership] CHECK CONSTRAINT [FK_membership_position]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Y means flagged to become inactive, N means NOT flagged to become inactive. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'membership', @level2type=N'COLUMN',@level2name=N'is_flagged'
GO
