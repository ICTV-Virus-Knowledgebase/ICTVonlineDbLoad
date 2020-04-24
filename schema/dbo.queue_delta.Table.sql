USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[queue_delta](
	[prev_taxid] [int] NULL,
	[new_taxid] [int] NULL,
	[proposal] [varchar](255) NULL,
	[notes] [varchar](255) NULL,
	[is_merged] [int] NOT NULL,
	[is_split] [int] NOT NULL,
	[is_moved] [int] NOT NULL,
	[is_promoted] [int] NOT NULL,
	[is_renamed] [int] NOT NULL,
	[is_new] [int] NOT NULL,
	[is_deleted] [int] NOT NULL,
	[is_now_type] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[queue_delta] ADD  CONSTRAINT [DF_queue_delta_is_merged]  DEFAULT ((0)) FOR [is_merged]
GO
ALTER TABLE [dbo].[queue_delta] ADD  CONSTRAINT [DF_queue_delta_is_moved]  DEFAULT ((0)) FOR [is_moved]
GO
ALTER TABLE [dbo].[queue_delta] ADD  CONSTRAINT [DF_queue_delta_is_renamed]  DEFAULT ((0)) FOR [is_renamed]
GO
ALTER TABLE [dbo].[queue_delta] ADD  CONSTRAINT [DF_queue_delta_is_new]  DEFAULT ((0)) FOR [is_new]
GO
ALTER TABLE [dbo].[queue_delta] ADD  CONSTRAINT [DF_queue_delta_is_deleted]  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[queue_delta] ADD  CONSTRAINT [DF_queue_delta_is_now_type]  DEFAULT ((0)) FOR [is_now_type]
GO
