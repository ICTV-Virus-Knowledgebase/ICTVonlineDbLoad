USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[member]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[member](
	[member_id] [int] IDENTITY(1,1) NOT NULL,
	[is_public] [int] NULL,
	[last_name] [varchar](255) NULL,
	[first_name] [varchar](255) NULL,
	[email] [varchar](255) NULL,
	[alt_email] [text] NULL,
	[country] [varchar](255) NULL,
	[address1] [varchar](255) NULL,
	[address2] [varchar](255) NULL,
	[address3] [varchar](255) NULL,
	[address4] [varchar](255) NULL,
	[address5] [varchar](255) NULL,
	[address6] [varchar](255) NULL,
	[phone] [varchar](255) NULL,
	[fax] [varchar](255) NULL,
	[changes] [text] NULL,
	[notes] [varchar](255) NULL,
	[url] [varchar](255) NULL,
 CONSTRAINT [PK_member] PRIMARY KEY CLUSTERED 
(
	[member_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [DF_member_is_public]  DEFAULT ((0)) FOR [is_public]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'URL to for a member''s professional page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'member', @level2type=N'COLUMN',@level2name=N'url'
GO
