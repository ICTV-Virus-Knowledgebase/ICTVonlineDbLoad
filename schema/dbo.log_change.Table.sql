USE [ICTVonlnie34]
GO
/****** Object:  Table [dbo].[log_change]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[log_change](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[major] [int] NULL,
	[minor] [float] NULL,
	[modified] [datetime] NOT NULL,
	[who] [varchar](40) NOT NULL,
	[notes] [text] NOT NULL,
	[version]  AS ((rtrim([major])+'.')+rtrim([minor])),
 CONSTRAINT [IX_log_change] UNIQUE NONCLUSTERED 
(
	[major] ASC,
	[minor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[log_change] ADD  DEFAULT (getdate()) FOR [modified]
GO
ALTER TABLE [dbo].[log_change] ADD  DEFAULT (suser_sname()) FOR [who]
GO
