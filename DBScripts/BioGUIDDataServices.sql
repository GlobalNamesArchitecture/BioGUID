USE [master]
GO
/****** Object:  Database [BioGUIDDataServices]    Script Date: 10/5/2015 9:14:36 AM ******/
CREATE DATABASE [BioGUIDDataServices]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BioGUIDDataServices', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\BioGUIDDataServices.mdf' , SIZE = 438464KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BioGUIDDataServices_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\BioGUIDDataServices_log.ldf' , SIZE = 4632576KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [BioGUIDDataServices] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BioGUIDDataServices].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BioGUIDDataServices] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET ARITHABORT OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BioGUIDDataServices] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BioGUIDDataServices] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BioGUIDDataServices] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BioGUIDDataServices] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET RECOVERY FULL 
GO
ALTER DATABASE [BioGUIDDataServices] SET  MULTI_USER 
GO
ALTER DATABASE [BioGUIDDataServices] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BioGUIDDataServices] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BioGUIDDataServices] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BioGUIDDataServices] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [BioGUIDDataServices] SET DELAYED_DURABILITY = DISABLED 
GO
USE [BioGUIDDataServices]
GO
/****** Object:  UserDefinedTableType [dbo].[DupeIOType]    Script Date: 10/5/2015 9:14:38 AM ******/
CREATE TYPE [dbo].[DupeIOType] AS TABLE(
	[IdentifiedObjectID] [bigint] NOT NULL,
	[CorrectObjectID] [bigint] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[IdentifiedObjectID] ASC,
	[CorrectObjectID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedTableType [dbo].[IDResponseType]    Script Date: 10/5/2015 9:14:38 AM ******/
CREATE TYPE [dbo].[IDResponseType] AS TABLE(
	[ObjectID] [int] NOT NULL,
	[ObjectClass] [nvarchar](255) NULL,
	[IdentifierDomainUUID] [uniqueidentifier] NOT NULL,
	[IdentifierClass] [nvarchar](255) NULL,
	[Abbreviation] [nvarchar](50) NULL,
	[IdentifierDomain] [nvarchar](255) NULL,
	[IdentifierDomainDescription] [nvarchar](255) NULL,
	[IdentifierDomainLogo] [nvarchar](255) NULL,
	[AgentUUID] [uniqueidentifier] NULL,
	[PreferredDereferenceServiceUUID] [uniqueidentifier] NULL,
	[PreferredDereferenceServiceProtocol] [nvarchar](255) NULL,
	[PreferredDereferenceService] [nvarchar](255) NULL,
	[PreferredDereferenceServiceDescription] [nvarchar](255) NULL,
	[PreferredDereferencePrefix] [nvarchar](255) NULL,
	[Identifier] [nvarchar](255) NOT NULL,
	[PreferredDereferenceSuffix] [nvarchar](255) NULL,
	[PreferredDereferenceServiceLogo] [nvarchar](255) NULL,
	[AlternateDereferenceServices] [nvarchar](1000) NULL,
	[IsMatch] [bit] NOT NULL,
	[IsExactMatch] [bit] NOT NULL,
	[PrioritySort] [int] NULL,
	PRIMARY KEY CLUSTERED 
(
	[ObjectID] ASC,
	[IdentifierDomainUUID] ASC,
	[Identifier] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedTableType [dbo].[PKIDListType]    Script Date: 10/5/2015 9:14:42 AM ******/
CREATE TYPE [dbo].[PKIDListType] AS TABLE(
	[PKID] [int] NOT NULL,
	[TableName] [varchar](255) NOT NULL,
	[PrioritySort] [int] NULL,
	PRIMARY KEY CLUSTERED 
(
	[PKID] ASC,
	[TableName] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedFunction [dbo].[CanonicalIdentifier]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--********************************************************************
--CREATE StripDiacritics Function
--********************************************************************

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 13 March 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Processes an Identifier string to its canonical form
--
-- INPUT PARAMETERS:
--		@String		String to be cleared of Diacritics
--
-- OUTPUT PARAMETERS:
--		@Result		Same as input @String, with any diacritics replaced by 
--					plain-text equivalents
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[CanonicalIdentifier] 
(
	-- Add the parameters for the function here
	@Identifier nvarchar(MAX)	= ''
)
RETURNS varchar(255)
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result nvarchar(MAX)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================		
	-- Strip Diacritics
	SET @Result = dbo.StripDiacritics(@Identifier)
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Replace additional characters as needed
	IF @Result <> N''
	BEGIN
		-- Replace accented Characters
		SELECT @Result=
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
				@Result
			,N'-', '')
			,N',', '')
			,N';', '')
			,N'!', '')
			,N'?', '')
			,N'#', '')
			,N'%', '')
			,N'^', '')
			,N'&', '')
			,N'*', '')
			,N'+', '')
			,N':', '')
			,N'=', '')
			,N'_', '')
			,N'@', '')
			,N'$', '')
	END

-- =============================================================================

-- Return the result of the function
-- =============================================================================
	RETURN CAST(LEFT(@Result, 255) as varchar(255))
-- =============================================================================
END

GO
/****** Object:  UserDefinedFunction [dbo].[FormatAlternateDereferenceServices]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 29 March 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Formats list of alternate DereferenceServices
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[FormatAlternateDereferenceServices] 
(
	-- Add the parameters for the function here
	@IdentifierDomainID			varchar(36)		= ''
)
RETURNS varchar(MAX)
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @AlternateDereferenceServices		varchar(MAX)	= ''	-- Output formatted Dereference Services
	DECLARE @IdentifierDomainPKID				int				= 0
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	SET @IdentifierDomainPKID = dbo.GetItemID(@IdentifierDomainID, 1)
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF ISNULL(@IdentifierDomainPKID, 0) <> 0
	BEGIN
		SELECT @AlternateDereferenceServices = 
			COALESCE(@AlternateDereferenceServices + '|', '') + dbo.NormalizeUUID(PK.UUID) + '~' + DS.DereferenceService + '~' + DS.DereferencePrefix + '~' + ISNULL(DS.DereferenceSuffix, '') + '~' + DS.Logo
		FROM BioGUID.dbo.IdentifierDomain AS ID
			INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON ID.IdentifierDomainID = IDDS.IdentifierDomainID
			INNER JOIN BioGUID.dbo.DereferenceService AS DS ON IDDS.DereferenceServiceID = DS.DereferenceServiceID
			INNER JOIN BioGUID.dbo.PK AS PK ON DS.DereferenceServiceID = PK.PKID
		WHERE ID.IdentifierDomainID = @IdentifierDomainPKID 
			AND DS.DereferenceServiceID <> ID.PreferredDereferenceServiceID
			AND DS.DereferencePrefix IS NOT NULL
		ORDER BY DS.DereferenceService
	END
-- =============================================================================

-- Return the result of the function
-- =============================================================================
	RETURN NULLIF(@AlternateDereferenceServices, '')
-- =============================================================================

END
GO
/****** Object:  UserDefinedFunction [dbo].[GetDereferenceServiceID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 23 January 2013
-- DESCRIPTION:
--		Retrieves the PKID and UUID for a provided DereferenceService, regardless of 
--		whether it is represented as a PKID, UUID, or Name.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[GetDereferenceServiceID] 
(
	-- Add the parameters for the function here
	@DereferenceService		varchar(255)	= '',
	@AutoCorrect			bit				= 1
)
RETURNS int
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @DereferenceServiceID		int	= 0
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Check for PKID or UUID for @Enumeration, unless it's a numeric value less than 32768
	SET @DereferenceServiceID = dbo.GetItemID(CAST(@DereferenceService AS varchar(36)), @AutoCorrect)

	-- If it's been set, make sure it exists in the DereferenceService Table
	IF ISNULL(@DereferenceServiceID, 0) <> 0 AND (SELECT COUNT(*) FROM BioGUID.dbo.DereferenceService WHERE DereferenceServiceID = ISNULL(@DereferenceServiceID, 0)) = 0
		SET @DereferenceServiceID = 0
-- =============================================================================
-- Operational Code
-- =============================================================================
	-- If we don't yet have a value for @DereferenceServiceID, then Attempt to find it by DereferenceService Name or DerefencePrefix
	IF ISNULL(@DereferenceServiceID, 0) = 0 AND ISNULL(@DereferenceService, '') <> ''
	BEGIN	
		SELECT @DereferenceServiceID = DereferenceServiceID
		FROM BioGUID.dbo.DereferenceService 
		WHERE DereferenceService = @DereferenceService

		-- If we didn't get it, try it with DereferencePrefix
		IF ISNULL(@DereferenceServiceID, 0) = 0 AND CHARINDEX('|', @DereferenceService) > 0
			IF RIGHT(@DereferenceService, 1) = '|'
				SELECT @DereferenceServiceID = DereferenceServiceID
				FROM BioGUID.dbo.DereferenceService 
				WHERE DereferencePrefix = LEFT(@DereferenceService, LEN(@DereferenceService) - 1) AND DereferenceSuffix IS NULL
			ELSE
				SELECT @DereferenceServiceID = DereferenceServiceID
				FROM BioGUID.dbo.DereferenceService 
				WHERE DereferencePrefix = LEFT(@DereferenceService, CHARINDEX('|', @DereferenceService) - 1) AND DereferenceSuffix = SUBSTRING(@DereferenceService, CHARINDEX('|', @DereferenceService) + 1, LEN(@DereferenceService))
					
	END
	
	-- AutoCorrect
	IF ISNULL(@AutoCorrect, 0) = 1
		SELECT @DereferenceServiceID = CorrectID FROM BioGUID.dbo.PK WHERE PKID = ISNULL(@DereferenceServiceID, 0)
-- =============================================================================

-- Return the result of the function
-- =============================================================================
	RETURN ISNULL(@DereferenceServiceID, 0)
-- =============================================================================

END

	






GO
/****** Object:  UserDefinedFunction [dbo].[GetEnumerationID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 23 January 2013
-- DESCRIPTION:
--		Retrieves the PKID and UUID for a provided EnumerationValue, regardless of 
--		whether it is represented as a PKID, UUID, or Name.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[GetEnumerationID] 
(
	-- Add the parameters for the function here
	@Enumeration		varchar(255)	= '',
	@EnumerationType	varchar(255)	= ''
)
RETURNS int
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @EnumerationID		int	= 0
	DECLARE @EnumerationTypeID	int	= 0
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Check for PKID or UUID for @Enumeration, unless it's a numeric value less than 32768
	SET @EnumerationID = dbo.GetItemID(CAST(@Enumeration AS varchar(36)), 1)

	-- If it's been set, make sure it exists in the Enumeration Table
	IF ISNULL(@EnumerationID, 0) > 0 
		IF (SELECT COUNT(*) FROM BioGUID.dbo.Enumeration WHERE EnumerationID = @EnumerationID) =0
			SET @EnumerationID = 0
	
	-- Get the @EnumerationTypeID
	IF ISNULL(@EnumerationType, '') <> ''
	BEGIN
		SET @EnumerationTypeID = dbo.GetEnumerationID(@EnumerationType, '')	
	END

-- =============================================================================

-- Operational Code
-- =============================================================================
	-- If we don't yet have a value for EnumerationID, then Attempt to find it by @Enumeration
	IF ISNULL(@EnumerationID, 0) = 0 AND ISNULL(@Enumeration, '') <> ''
	BEGIN	
		-- First check to see if there is only one match
		IF ISNULL(@EnumerationTypeID, 0) <> 0 OR @EnumerationType = '0'
		BEGIN
			-- @EnumerationTypeID has been determined, so look for a match on the direct parent
			SELECT @EnumerationID = EnumerationID
			FROM BioGUID.dbo.Enumeration 
			WHERE EnumerationValue = @Enumeration
				AND EnumerationTypeID = @EnumerationTypeID

			-- If we didn't get it, try it with any tier parent
			IF ISNULL(@EnumerationID, 0) = 0
				SELECT @EnumerationID = EnumerationID
				FROM BioGUID.dbo.Enumeration 
				WHERE EnumerationValue = @Enumeration
					AND EnumerationTypeID IN (SELECT ParentEnumerationID FROM dbo.FullEnumerationParentList(@EnumerationTypeID))
					
		END
		ELSE
		BEGIN			
			-- Need to see if we can figure it out based on how many matches there are
			IF (SELECT COUNT(*) FROM BioGUID.dbo.Enumeration WHERE EnumerationValue = @Enumeration) > 1
				-- Look for a match with EnumerationTypeID=0
				SELECT @EnumerationID = EnumerationID 
				FROM BioGUID.dbo.Enumeration 
				WHERE EnumerationValue = @Enumeration 
					AND EnumerationTypeID = 0
			ELSE
				-- Only one match, so get it
				SELECT @EnumerationID = EnumerationID 
				FROM BioGUID.dbo.Enumeration 
				WHERE EnumerationValue = @Enumeration 
		END
		
		-- If we still don't have it, try @Enumeration as Sequence value
		IF ISNULL(@EnumerationID, 0) = 0 AND ISNUMERIC(@Enumeration) = 1 AND ISNULL(@EnumerationTypeID, 0) <> 0
			IF CAST(@Enumeration AS int) < 32768
			BEGIN
				SELECT @EnumerationID = ISNULL(EnumerationID, 0)
				FROM BioGUID.dbo.Enumeration
				WHERE Sequence = CAST(@Enumeration AS smallint) 
					AND EnumerationTypeID = @EnumerationTypeID

			END
		
	END
	
	-- AutoCorrect
	SELECT @EnumerationID = CorrectID FROM BioGUID.dbo.PK WHERE PKID = @EnumerationID
-- =============================================================================

-- Return the result of the function
-- =============================================================================
	RETURN ISNULL(@EnumerationID, 0)
-- =============================================================================

END

	






GO
/****** Object:  UserDefinedFunction [dbo].[GetIdentifierDomainID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 23 October 2013
-- DESCRIPTION:
--		Retrieves the Correct PKID for a provided @IdentifierDomain value, regardless of whether that 
--			value is represented as a PKID or UUID, or as a an IdentifierDomain or Abbreviation.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[GetIdentifierDomainID] 
(
	-- Add the parameters for the function here
	@IdentifierDomain		varchar(255) = '',
	@AutoCorrect			bit			= 1
)
RETURNS int
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @PKID int = NULL
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	SET @IdentifierDomain = dbo.RemoveWhitespace(@IdentifierDomain)
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF ISNULL(@IdentifierDomain, '') <> ''
	BEGIN
		SET @PKID = dbo.GetItemID(@IdentifierDomain, @AutoCorrect)

		IF ISNULL(@PKID, 0) = 0
			SELECT @PKID = IdentifierDomainID FROM BioGUID.dbo.IdentifierDomain WHERE IdentifierDomain = @IdentifierDomain OR Abbreviation = @IdentifierDomain
	END
-- =============================================================================

-- Return the result of the function
-- =============================================================================
	RETURN @PKID
-- =============================================================================
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetItemID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 21 October 2013
-- DESCRIPTION:
--		Retrieves the Correct PKID for a provided @Item value, regardless of whether that 
--			value is represented as a PKID or UUID.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[GetItemID] 
(
	-- Add the parameters for the function here
	@Item			varchar(36) = '',
	@AutoCorrect	bit			= 0
)
RETURNS int
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @PKID int = NULL
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF ISNUMERIC(@Item) = 1
		SET @PKID = CAST(@Item AS int)
	ELSE 
	BEGIN
		SET @Item = dbo.NormalizeUUID(@Item)
		IF dbo.IsUUID(@Item) = 1
			SELECT @PKID = PKID FROM BioGUID.dbo.PK WHERE UUID = @Item
	END
	-- AutoCorrect ID, if needed
	IF ISNULL(@PKID, 0) <> 0 AND ISNULL(@AutoCorrect, 0) = 1
		SELECT @PKID = CorrectID FROM BioGUID.dbo.PK WHERE PKID = @PKID
-- =============================================================================

-- Return the result of the function
-- =============================================================================
	RETURN @PKID
-- =============================================================================
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetParameterValue]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Richard L. Pyle
-- Create date: 27 March 2015
-- Description:	Extracts the value of a provided parameter from a structured Parameter list
-- =============================================
CREATE FUNCTION [dbo].[GetParameterValue] 
(
	-- Add the parameters for the function here
	@Parameter varchar(255),
	@ParameterValues	nvarchar(MAX)
)
RETURNS nvarchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(255)

	-- Add the T-SQL statements to compute the return value here
	SET @Result = SUBSTRING(@ParameterValues, CHARINDEX(@Parameter, @ParameterValues), LEN(@ParameterValues))

	SET @Result = SUBSTRING(@Result, CHARINDEX('=', @Result) + 1, LEN(@Result))

	SET @Result = LEFT(@Result, CHARINDEX('|', @Result) - 1)

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetPKID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 30 March 2012
-- EDIT DATE:	11 Matrch 2014 -- Added support for HTTP input
-- DESCRIPTION:
--		Returns the PKID for a provided UUID
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[GetPKID] 
(
	-- Add the parameters for the stored procedure here
	-- =============================================
	@UUID varchar(MAX)
)
RETURNS int
AS
BEGIN
-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result int		= NULL
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	IF LEN(@UUID) > 36
		SET @UUID = RIGHT(@UUID, 36)
	
-- =============================================================================

-- Operational Code
-- =============================================================================

	IF dbo.IsUUID(dbo.NormalizeUUID(@UUID)) = 1
		SELECT @Result = PKID FROM BioGUID.dbo.PK WHERE UUID = @UUID
			
	-- Get Correct @PKID
	IF ISNULL(@Result, 0) <> 0
		SELECT @Result = CorrectID FROM BioGUID.dbo.PK WHERE PKID = @Result
-- =============================================================================

	-- Return the result of the function
	RETURN @Result

END
	

GO
/****** Object:  UserDefinedFunction [dbo].[GetSchemaItemID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 29 May 2007
-- EDIT DATE:	1 June 2007
-- DESCRIPTION:
--		Returns the SchemaItemID value for the supplied SchemaItem Name and Parent
--
-- INPUT PARAMETERS:
--		@ItemNm		- Name of Schema Item
--		@ParID		- ID Number for the Parent SchemaItem
--
-- OUTPUT PARAMETERS:
--		@ID			- SchemaItem ID number
--
-- CALLED PROCEDURES:
--		dbo.GetSchemaItemID [Recursive]
-- =============================================================================
CREATE FUNCTION [dbo].[GetSchemaItemID] 
(
	-- Add the parameters for the function here
	@SchemaItem				varchar(128),	-- Name of the SchemaItem for which an ID is needed
	@ParentSchemaItem		varchar(128),
	@SchemaItemType			varchar(255)
)
RETURNS int
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @SchemaItemID		int	= 0
	DECLARE @ParentSchemaItemID int	= 0
	DECLARE @SchemaItemTypeID	int	= 0
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Check for PKID or UUID for @SchemaItem
	SET @SchemaItemID = dbo.GetItemID(CAST(@SchemaItem AS varchar(36)), 1)

	-- Attempt to get the @ParentSchemaItemID, if needed
	IF ISNULL(@SchemaItemID, 0) = 0
		IF @ParentSchemaItem = '-1'
			-- A value of -1 is assumed to mean the BioGUID Database
			SET @ParentSchemaItemID = dbo.GetSchemaItemID('BioGUID', '0', 'Database')
		ELSE IF ISNULL(@ParentSchemaItem, '') <> ''
			SET @ParentSchemaItemID = dbo.GetSchemaItemID(@ParentSchemaItem, '', '')

	-- Convert @SchemaItemType
	IF ISNULL(@SchemaItemType, '') <> ''
		SET @SchemaItemTypeID = ISNULL(dbo.GetEnumerationID(@SchemaItemType, 'SchemaItemTypes'), 0)
-- =============================================================================
-- Operational Code
-- =============================================================================
	-- If we don't yet have a value for SchemaItemID, , then Attempt to find it by @SchemaItem
	IF ISNULL(@SchemaItemID, 0) = 0 AND ISNULL(@SchemaItem, '') <> ''
	BEGIN
		-- First check to see if there is only one match
		IF ISNULL(@ParentSchemaItemID, 0) <> 0 OR @ParentSchemaItem = '0'
		BEGIN
			-- @ParentSchemaItemID has been determined, so look for a match on the direct parent
			SELECT @SchemaItemID = SchemaItemID
			FROM BioGUID.dbo.SchemaItem 
			WHERE SchemaItemName = @SchemaItem
				AND ParentSchemaItemID = @ParentSchemaItemID

			-- If we didn't get it, try it with any tier parent
			IF ISNULL(@SchemaItemID, 0) = 0
				SELECT @SchemaItemID = SchemaItemID
				FROM BioGUID.dbo.SchemaItem 
				WHERE SchemaItemName = @SchemaItem
					AND ParentSchemaItemID IN (SELECT ParentSchemaItemID FROM dbo.FullSchemaItemParentList(@ParentSchemaItemID))
		END
		ELSE
		BEGIN
			-- Need to see if we can figure it out based on how many matches there are
			IF (SELECT COUNT(*) FROM BioGUID.dbo.SchemaItem WHERE SchemaItemName = @SchemaItem) > 1
			BEGIN
				-- Look for a match based on @SchemaItemTypeID
				IF ISNULL(@SchemaItemTypeID, 0) <> 0 AND (SELECT COUNT(*) FROM BioGUID.dbo.SchemaItem WHERE SchemaItemName = @SchemaItem AND SchemaItemTypeID = @SchemaItemTypeID) = 1
					SELECT @SchemaItemID = SchemaItemID 
					FROM BioGUID.dbo.SchemaItem 
					WHERE SchemaItemName = @SchemaItem 
						AND	SchemaItemTypeID = @SchemaItemTypeID

				ELSE
				BEGIN
					-- Look for a match with ParentSchemaItemID=0
					SELECT @SchemaItemID = SchemaItemID 
					FROM BioGUID.dbo.SchemaItem 
					WHERE SchemaItemName = @SchemaItem 
						AND ParentSchemaItemID = 0
					
					-- If we still don't have it, then take the highest tier in the hierarchy
					IF ISNULL(@SchemaItemID, 0) = 0
						SELECT TOP(1) @SchemaItemID = SchemaItemID 
						FROM BioGUID.dbo.SchemaItem AS SI
							INNER JOIN BioGUID.dbo.Enumeration AS E ON SI.SchemaItemTypeID = E.EnumerationID
						WHERE SchemaItemName = @SchemaItem 
						ORDER BY E.Sequence					

				END
				
			END
			ELSE
				-- Only one match, so get it
				SELECT @SchemaItemID = SchemaItemID 
				FROM BioGUID.dbo.SchemaItem 
				WHERE SchemaItemName = @SchemaItem 
		END
	END
-- =============================================================================

-- Return the result of the function
-- =============================================================================
	RETURN @SchemaItemID
-- =============================================================================

END


GO
/****** Object:  UserDefinedFunction [dbo].[GetUUID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 30 March 2012
-- EDIT DATE:	
-- DESCRIPTION:
--		Returns the UUID for a provided PKID
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[GetUUID] 
(
	-- Add the parameters for the stored procedure here
	-- =============================================
	@PKID int
)
RETURNS varchar(36)
AS
BEGIN
-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result varchar(36)		= NULL
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Get Correct @PKID
	IF ISNULL(@PKID, 0) <> 0
		SELECT @PKID = CorrectID FROM BioGUID.dbo.PK WHERE PKID = @PKID
-- =============================================================================

-- Operational Code
-- =============================================================================

	IF ISNULL(@PKID, 0) <> 0
		SELECT @Result = dbo.NormalizeUUID(UUID) FROM BioGUID.dbo.PK WHERE PKID = @PKID		

-- =============================================================================

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[IsUUID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 24 March 2012
-- EDIT DATE:	
-- DESCRIPTION:
--		Checks whether the provided text string matches the pattern for a UUID
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[IsUUID] 
(
	-- Add the parameters for the stored procedure here
	-- =============================================
	@UUID varchar(36)
)
RETURNS bit
AS
BEGIN
-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result bit		= 0
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
-- =============================================================================

-- Operational Code
-- =============================================================================

	SELECT @Result = 1 
	WHERE @UUID LIKE REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')

-- =============================================================================

	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  UserDefinedFunction [dbo].[NormalizeDOI]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 February 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Checks whether the provided text string matches the pattern for a DOI
--		and Normalizes it to standard form
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[NormalizeDOI] 
(
	-- Add the parameters for the stored procedure here
	-- =============================================
	@DOI nvarchar(255)
)
RETURNS nvarchar(255)
AS
BEGIN
-- Declare Internal Variables
-- =============================================================================
	DECLARE @Process		nvarchar(255)
	DECLARE @MatchString	nvarchar(255)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	SET @Process = dbo.RemoveWhitespace(@DOI)
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @Process NOT LIKE '10.[0-9][0-9][0-9][0-9]%/%'
	BEGIN
		SET @MatchString = 'doi:'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'doi'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'http://'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'www.'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'dx.doi.org/'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'doi.org/'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		IF @Process LIKE '1.%' OR @Process LIKE '0.%'
			SET @Process = '10' + SUBSTRING(@Process, 2, LEN(@Process))

		IF @Process LIKE '10/%'
			SET @Process = '10.' + SUBSTRING(@Process, 4, LEN(@Process))
	END

	IF @Process LIKE '10.[0-9][0-9][0-9][0-9]%/%'
		SET @DOI = @Process
-- =============================================================================

	-- Return the result of the function
	RETURN @DOI

END

GO
/****** Object:  UserDefinedFunction [dbo].[NormalizeISSN]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 February 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Checks whether the provided text string matches the pattern for a ISSN
--		and Normalizes it to standard form
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[NormalizeISSN] 
(
	-- Add the parameters for the stored procedure here
	-- =============================================
	@ISSN nvarchar(255)
)
RETURNS nvarchar(255)
AS
BEGIN
-- Declare Internal Variables
-- =============================================================================
	DECLARE @Process		nvarchar(255)
	DECLARE @MatchString	nvarchar(255)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	SET @Process = dbo.RemoveWhitespace(@ISSN)
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @Process NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
	BEGIN
		SET @Process = REPLACE(@Process, ' ', '')
		SET @Process = REPLACE(@Process, '–', '-')
		SET @Process = REPLACE(@Process, '—', '-')

		SET @MatchString = 'issn:'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'eissn:'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'issn'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'eissn'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = 'essn'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		SET @MatchString = '-'
		IF @Process LIKE @MatchString + '%'
			SET @Process = LTRIM(RTRIM(SUBSTRING(@Process, LEN(@MatchString) + 1, LEN(@Process))))

		IF @Process LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9X]' AND LEN(@Process) = 8
			SET @Process = LEFT(@Process, 4) + '-' + RIGHT(@Process, 4)
	END

	IF @Process LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
		SET @ISSN = @Process
-- =============================================================================

	-- Return the result of the function
	RETURN @ISSN

END

GO
/****** Object:  UserDefinedFunction [dbo].[NormalizeUUID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 February 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Checks whether the provided text string matches the pattern for a UUID
--		and Normalizes it to standard form
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[NormalizeUUID] 
(
	-- Add the parameters for the stored procedure here
	-- =============================================
	@UUID varchar(36)
)
RETURNS varchar(36)
AS
BEGIN
-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result varchar(36)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Remove all dashes and whitespace
	SET @UUID = dbo.RemoveWhitespace(@UUID)
	WHILE CHARINDEX(' ', @UUID) > 0
		SET @UUID = REPLACE(@UUID, ' ', '')
	WHILE CHARINDEX('-', @UUID) > 0
		SET @UUID = REPLACE(@UUID, '-', '')

	-- Set to lowercase
	SET @UUID = LOWER(@UUID)
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Check for 32 hex characters
	IF LEN(@UUID) = 32 AND @UUID LIKE REPLACE('00000000000000000000000000000000', '0', '[0-9a-f]')
		SET @Result = SUBSTRING(@UUID, 1, 8) + '-' +
					SUBSTRING(@UUID, 9, 4) + '-' +
					SUBSTRING(@UUID, 13, 4) + '-' +
					SUBSTRING(@UUID, 17, 4) + '-' +
					SUBSTRING(@UUID, 21, 12) + '-'
-- =============================================================================

	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  UserDefinedFunction [dbo].[ParseSearchTerm]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 September 2011
-- EDIT DATE:	11 April 2012 Added support for Word Start
--				26 February 2015 (Added support for dbo.RemoveWhitespace)
-- DESCRIPTION:
--		Parses a search term into space-delimited individual terms and treats 
--		them as separate search terms.
--
-- INPUT PARAMETERS:
--		@SearchTerm		Search term to be parsed
--		@FieldName		Name of field to be searched
--		@OrTerms		Boolean indicating whether to treat parsed terms as 'Or' (1), 
--						or 'And' (0)
--		@FuzzyMatch		Strip @SearchTerm of diacritics
--		@SearchType		Indication of how to process the match
--						'Equals' (searched string is exact match of parsed SearchTerm)
--						'Begins With' (whole searched string begins with parsed SearchTerm)
--						'Ends With' (whole searched string ends with parsed SearchTerm)
--						'Word Start' (any word in searched string begins with parsed SearchTerm)
--						'Contains' (parsed SearchTerm appears anywhere in searched string)
--						'FullString' (unparsed SearchTerm appears anywhere in searched string)
--						
--
-- OUTPUT PARAMETERS:
--		@Result			SQL WHERE clause, with individual search terms
--
-- CALLED PROCEDURES:
--		dbo.StripDiacritics
--		dbo.RemoveWhitespace
-- =============================================================================
CREATE FUNCTION [dbo].[ParseSearchTerm] 
(
	-- Add the parameters for the stored procedure here
	-- =============================================
	@SearchTerm			nvarchar(1000)	='',
	@FieldName			nvarchar(255)	='',
	@ORTerms			bit				=0,
	@FuzzyMatch			bit				=1,
	@SearchType			varchar(15)		='Contains'
)
RETURNS nvarchar(2000)
AS
BEGIN
-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result			nvarchar(MAX)
	DECLARE @AndOr			varchar(3)
	DECLARE @Term			nvarchar(255)
	DECLARE @TermCount		int
	DECLARE @WCL			bit			-- Left-hand Wildcard
	DECLARE @WCR			bit			-- Right-hand Wildcard
	DECLARE @SD				varchar(15) = ''-- Strip Diacritics
	DECLARE @Operand		varchar(10) = 'LIKE'
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	SET @Result=''

	--Set @AndOr
	IF @ORTerms=1
		SET @AndOr = 'OR'
	ELSE
		SET @AndOr = 'AND'

	SET @TermCount = 1
			
	--Set default @FieldName
	IF @FieldName=''
		IF @Fuzzymatch > 0
			SET @FieldName='CleanSearchString'
		ELSE
			SET @FieldName='SearchString'
				
	--Adjust for Word Start
	IF @SearchType = 'Word Start'
		SET @SearchTerm = REPLACE(@Searchterm,'-',' ')
	ELSE
		SET @SearchTerm = REPLACE(@Searchterm,'.',' ')
		
	--Clean up @SearchTerm for punctuation, diacritics, and leading, trailing, parens, and double spaces; 
	IF @FuzzyMatch <> 0
		SET @SearchTerm = CAST(CAST(dbo.StripDiacritics(dbo.StripHTML(@SearchTerm)) AS varchar(1000)) AS nvarchar(1000))
	SET @SearchTerm = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@SearchTerm,',',''),';',' '),'!',' '),':',' '),'%',' '),'~',' ')
	SET @SearchTerm = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@SearchTerm,')',''),'(',' '),']',' '),'[',' '),'{',' '),'}',' '),'>',' '),'<',' ')
	SET @Searchterm = dbo.RemoveWhitespace(@Searchterm)
	SET @SearchTerm = @SearchTerm + ' '
				
	IF @FuzzyMatch > 1
		SET @SD = 'dbo.StripDiacritics'
		
	--Establish Wildcard values
	SET @WCL = 
	CASE 
		WHEN @SearchType = 'Equals' OR @SearchType = 'Begins With'
			THEN 0
		ELSE
			1
	END		

	SET @WCR = 
	CASE 
		WHEN @SearchType = 'Equals' OR @SearchType = 'Ends With'
			THEN 0
		ELSE
			1
	END

	IF @SearchType = 'Equals'
		SET @Operand = '='
	ELSE
		SET @Operand = 'LIKE'

-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @SearchType = 'FullString'
	BEGIN
		SET @Result = @FieldName + ' LIKE ''%' + LTRIM(RTRIM(@SearchTerm)) + '%'''
	END
	ELSE
	BEGIN
		WHILE LEN(@SearchTerm) > 0
		BEGIN
			--Extract first term
			SET @Term=SUBSTRING(@SearchTerm,1,CHARINDEX(' ',@SearchTerm,1)-1)
			--Truncate remaining term(s), if any
			SET @SearchTerm = SUBSTRING(@SearchTerm,CHARINDEX(' ',@SearchTerm,1)+1,LEN(@SearchTerm))
				
			IF @SearchType = 'Word Start'
				SET @Result = @Result + ' ' + @AndOr + 
				' ((' + 
					@SD + '(' + @FieldName + ') LIKE ''' + @Term + '%'') OR (' +   
					@SD + '(' + @FieldName + ') LIKE ''% ' + @Term + '%'') OR (' +
					@SD + '(' + @FieldName + ') LIKE ''%-' + @Term + '%'') OR (' +
					@SD + '(' + @FieldName + ') LIKE ''%''''' + @Term + '%''))'
			ELSE
			BEGIN
				--Add WildCards
				IF @WCL = 1 OR @TermCount > 1
					SET @Term = '%' + @Term

				IF @WCR = 1 OR @TermCount > 1
					SET @Term = @Term + '%'

				SET @Result = @Result + ' ' + @AndOr + ' (' + @SD + '(' + @FieldName + ') ' + @Operand + ' ''' + @Term + ''')'

			END			
				
			SET @TermCount = @TermCount + 1
		END	
	END
				
	IF @Result<>''
	BEGIN
		IF SUBSTRING(LTRIM(@Result),1,LEN(@AndOr)) = @AndOr
			SET @Result = SUBSTRING(@Result,LEN(@AndOr)+3,LEN(@Result))
				
		SET @Result = '(' + RTRIM(LTRIM(@Result)) + ')'
	END
-- =============================================================================
	-- Return the result of the function
	RETURN @Result
-- =============================================================================
END

GO
/****** Object:  UserDefinedFunction [dbo].[RemoveWhitespace]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Richard L. Pyle
-- Create date: 25 February 2015
-- Description:	Removes extra whitespace from a provided text string
-- =============================================
CREATE FUNCTION [dbo].[RemoveWhitespace] 
(
	-- Add the parameters for the function here
	@String nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX)

	-- Add the T-SQL statements to compute the return value here
	-- Remove CR
	WHILE CHARINDEX(CHAR(13), @String) > 0
		SET @String = REPLACE(@String, CHAR(13), ' ')
	-- Remove LF
	WHILE CHARINDEX(CHAR(10), @String) > 0
		SET @String = REPLACE(@String, CHAR(10), ' ')
	-- Remove Tab
	WHILE CHARINDEX(CHAR(9), @String) > 0
		SET @String = REPLACE(@String, CHAR(9), ' ')

	-- Remove Double Space
	WHILE CHARINDEX('  ', @String) > 0
		SET @String = REPLACE(@String, '  ', ' ')

	-- Trim leading and trailing spaces
	SELECT @Result = LTRIM(RTRIM(@String))

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[StripDiacritics]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--********************************************************************
--CREATE StripDiacritics Function
--********************************************************************

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 12 September 2011
-- EDIT DATE:	
-- DESCRIPTION:
--		Replaces ASCII and Unicode diacritics with lower-128 equivalents
--
-- INPUT PARAMETERS:
--		@String		String to be cleared of Diacritics
--
-- OUTPUT PARAMETERS:
--		@Result		Same as input @String, with any diacritics replaced by 
--					plain-text equivalents
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[StripDiacritics] 
(
	-- Add the parameters for the function here
	@String nvarchar(MAX)	= ''
)
RETURNS nvarchar(MAX)
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result nvarchar(MAX)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================		
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Replace specific accented characters with zero-length string, if any
	IF @String <> ''
	BEGIN
		-- Strip excess whitespace
		SELECT @String = dbo.RemoveWhitespace(@String)

		-- Replace accented Characters
		SELECT @String=
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
				@String COLLATE SQL_Latin1_General_CP1_CS_AS
			,N'à', 'a')
			,N'á', 'a')
			,N'â', 'a')
			,N'ã', 'a')
			,N'ä', 'a')
			,N'å', 'a')
			,N'æ', 'ae')
			,N'ç', 'c')
			,N'è', 'e')
			,N'é', 'e')
			,N'ê', 'e')
			,N'ë', 'e')
			,N'ì', 'i')
			,N'í', 'i')
			,N'î', 'i')
			,N'ï', 'i')
			,N'ñ', 'n')
			,N'ò', 'o')
			,N'ó', 'o')
			,N'ô', 'o')
			,N'õ', 'o')
			,N'ö', 'o')
			,N'ø', 'o')
			,N'œ', 'oe')
			,N'š', 's')
			,N'ß', 'ss')
			,N'ù', 'u')
			,N'ú', 'u')
			,N'û', 'u')
			,N'ü', 'u')
			,N'ý', 'y')
			,N'ÿ', 'y')
			,N'ž', 'z')
			,N'À', 'A')
			,N'Á', 'A')
			,N'Â', 'A')
			,N'Ã', 'A')
			,N'Ä', 'A')
			,N'Å', 'A')
			,N'Æ', 'AE')
			,N'Ç', 'C')
			,N'È', 'E')
			,N'É', 'E')
			,N'Ê', 'E')
			,N'Ë', 'E')
			,N'Ì', 'I')
			,N'Í', 'I')
			,N'Î', 'I')
			,N'Ï', 'I')
			,N'Ñ', 'N')
			,N'Ò', 'O')
			,N'Ó', 'O')
			,N'Ô', 'O')
			,N'Õ', 'O')
			,N'Ö', 'O')
			,N'Ø', 'O')
			,N'Œ', 'OE')
			,N'Š', 's')
			,N'Ù', 'U')
			,N'Ú', 'U')
			,N'Û', 'U')
			,N'Ü', 'U')
			,N'Ý', 'Y')
			,N'Ÿ', 'Y')
			,N'Ž', 'Z')

--		Replace Special characters
		SELECT @String=
--			REPLACE(
--			REPLACE(
--			REPLACE(
--			REPLACE(
			REPLACE(
				@String COLLATE SQL_Latin1_General_CP1_CS_AS
			,N'ſ', 's')
--			,N'ð', 'e')
--			,N'þ', 'th')
--			,N'Ð', 'E')
--			,N'Þ', 'TH')


		-- Replace symbols
		SELECT @String=
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
				@String
			,N'…', '...')
			,N'–', '-')
			,N'—', '-')
			,N'˜', '~')
			,N'™', 'TM')
			,N'¡', '!')
			,N'©', '(c)')
			,N'ª', '')
			,N'º', '')
			,N'®', '(R)')
			,N'¿', '?')
			,N'¦', '|')
			,N'°', 'o')
			,N'µ', 'u')
			,N'¶', ' ')
			,N'·', ' ')
			,N'•', ' ')

		-- Replace Numeric symbols
		SELECT @String=
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
				@String
			,N'ƒ', 'f')
			,N'‰', '0/00')
			,N'¹', '1')
			,N'²', '2')
			,N'³', '3')
			,N'¼', '1/4')
			,N'½', '1/2')
			,N'¾', '3/4')
			,N'×', 'x')
			,N'±', '+/-')

		-- Replace Quotes
		SELECT @String=
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
				@String
			,N'‘', '''')
			,N'’', '''')
			,N'‚', '''')
			,N'‹', '''')
			,N'›', '''')
			,N'“', '"')
			,N'”', '"')
			,N'„', '"')
			,N'«', '"')
			,N'»', '"')

		-- Strip straight accents and other symbols
		SELECT @String=
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
				@String
			,N'ˆ', '')
			,N'¨', '')
			,N'¯', '')
			,N'', '')
			,N'´', '')
			,N'`', '')

		-- Strip Quotes and Apostrophes 
		SELECT @String=
			REPLACE(
			REPLACE(
				@String
			,N'''', '')
			,N'"', '')

		-- Strip Brackets
		SELECT @String=
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(@String
			, N'[', '')
			, N']', '')
			, N'(', '')
			, N')', '')
			, N'{', '')
			, N'}', '')
			, N'<', '')
			, N'>', '')
			, N'/', '')
			, N'\', '')

	END

	-- Convert input string to varchar
	SET @String = CAST(CAST(@String AS varchar(MAX)) AS nvarchar(MAX))

	-- Transfer cleaned @String to @Result, if non-zero-length
	IF @String <> ''
		SET @RESULT = CAST(@String AS nvarchar(MAX))
-- =============================================================================


-- Return the result of the function
-- =============================================================================
	RETURN @Result
-- =============================================================================
END

GO
/****** Object:  UserDefinedFunction [dbo].[StripHTML]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 10 July 2007
-- EDIT DATE:	
-- DESCRIPTION:
--		Strips specific HTML tags from a provided text string
--
-- INPUT PARAMETERS:
--		@String		String to be cleared of HTML Tags
--
-- OUTPUT PARAMETERS:
--		@Result		Same as input @String, minus HTML tags, if any
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[StripHTML] 
(
	-- Add the parameters for the function here
	@String nvarchar(MAX)	= ''
)
RETURNS nvarchar(MAX)
AS
BEGIN

-- Declare Internal Variables
-- =============================================================================
	DECLARE @Result nvarchar(MAX)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================

-- =============================================================================

-- Operational Code
-- =============================================================================
-- Replace specific HTML tags with zero-length string, if any
	IF @String <> ''
	BEGIN
		SET @String = 
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(@String,'<b>','')
			,'</b>','')
			,'<i>','')
			,'</i>','')
			,'<sub>','')
			,'</sub>','')
			,'<sup>','')
			,'</sup>','')
			,'<em>','')
			,'</em>','')
	END

	-- Transfer cleaned @String to @Result, if non-zero-length
	IF @String <> ''
		SET @RESULT = @String
-- =============================================================================


-- Return the result of the function
-- =============================================================================
	RETURN @Result
-- =============================================================================

END

	


GO
/****** Object:  Table [dbo].[FAQ]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FAQ](
	[FAQID] [int] IDENTITY(1,1) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[Question] [nvarchar](255) NOT NULL,
	[Answer] [nvarchar](max) NOT NULL,
	[Sequence] [int] NOT NULL,
 CONSTRAINT [PK_FAQ] PRIMARY KEY CLUSTERED 
(
	[FAQID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FilterTerm]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FilterTerm](
	[FilterTerm] [varchar](50) NOT NULL,
 CONSTRAINT [PK_FilterTerm] PRIMARY KEY CLUSTERED 
(
	[FilterTerm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FixELObjects]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FixELObjects](
	[Identifier] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_FixELObjects] PRIMARY KEY CLUSTERED 
(
	[Identifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NewsItem]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsItem](
	[NewsItemID] [int] IDENTITY(1,1) NOT NULL,
	[NewsItem] [nvarchar](max) NOT NULL,
	[PostTimeStamp] [datetime] NOT NULL CONSTRAINT [DF_NewsItem_PostTimeStamp]  DEFAULT (getutcdate()),
	[IsSuppressed] [bit] NOT NULL CONSTRAINT [DF_NewsItem_IsSuppressed]  DEFAULT ((0)),
 CONSTRAINT [PK_NewsItem] PRIMARY KEY CLUSTERED 
(
	[NewsItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SearchIndex]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SearchIndex](
	[SearchIndexID] [bigint] NOT NULL,
	[SearchLogUUID] [uniqueidentifier] NOT NULL,
	[SearchSet] [nvarchar](255) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Temp_MultipleIdentifiers]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp_MultipleIdentifiers](
	[IdentifiedObjectID] [bigint] NOT NULL,
	[IdentifierDomainID] [int] NOT NULL,
	[RecordCount] [int] NOT NULL,
 CONSTRAINT [PK_Temp_MultipleIdentifiers] PRIMARY KEY CLUSTERED 
(
	[IdentifiedObjectID] ASC,
	[IdentifierDomainID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[view_SearchDereferenceService]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_SearchDereferenceService]
AS
SELECT        dbo.NormalizeUUID(PK.UUID) AS DereferenceServiceUUID, DS.DereferenceServiceID, P.EnumerationValue AS DereferenceServiceProtocol, DS.DereferenceService, 
                         DS.DereferencePrefix, DS.DereferenceSuffix, DS.Description
FROM            BioGUID.dbo.DereferenceService AS DS INNER JOIN
                         BioGUID.dbo.PK AS PK ON DS.DereferenceServiceID = PK.PKID INNER JOIN
                         BioGUID.dbo.Enumeration AS P ON DS.ProtocolID = P.EnumerationID
WHERE        (PK.CorrectID = PK.CorrectID)

GO
/****** Object:  View [dbo].[view_SearchIdentifierDomain]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_SearchIdentifierDomain]
AS
SELECT        dbo.NormalizeUUID(PK.UUID) AS IdentifierDomainUUID, ID.IdentifierDomainID, IC.EnumerationValue AS IdentifierClass, 
                         CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE dbo.NormalizeUUID(PKDR.UUID) END AS PreferredDereferenceServiceUUID, 
                         CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE P.EnumerationValue END AS PreferredDereferenceServiceProtocol, 
                         CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE DR.DereferenceService END AS PreferredDereferenceService, 
                         CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE DR.DereferencePrefix END AS PreferredDereferencePrefix, 
                         CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE DR.DereferenceSuffix END AS PreferredDereferenceSuffix, ID.Abbreviation, ID.IdentifierDomain,
                          ID.Description, ID.Logo, ID.AgentUUID, ID.IsHidden
FROM            BioGUID.dbo.PK AS PK INNER JOIN
                         BioGUID.dbo.IdentifierDomain AS ID ON PK.PKID = ID.IdentifierDomainID INNER JOIN
                         BioGUID.dbo.Enumeration AS IC ON ID.IdentifierClassID = IC.EnumerationID INNER JOIN
                         BioGUID.dbo.DereferenceService AS DR ON ID.PreferredDereferenceServiceID = DR.DereferenceServiceID INNER JOIN
                         BioGUID.dbo.PK AS PKDR ON DR.DereferenceServiceID = PKDR.PKID INNER JOIN
                         BioGUID.dbo.Enumeration AS P ON DR.ProtocolID = P.EnumerationID
WHERE        (PK.CorrectID = PK.PKID)

GO
/****** Object:  View [dbo].[view_GetIdentifierDomainDereferenceService]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_GetIdentifierDomainDereferenceService]
AS
SELECT        IDDS.IdentifierDomainDereferenceServiceID, dbo.NormalizeUUID(PK.UUID) AS IdentifierDomainDereferenceServiceUUID, ID.IdentifierDomainUUID, 
                         ID.IdentifierClass, ID.PreferredDereferenceServiceUUID, ID.PreferredDereferenceServiceProtocol, ID.PreferredDereferenceService, ID.PreferredDereferencePrefix, 
                         ID.PreferredDereferenceSuffix, ID.Abbreviation, ID.IdentifierDomain, ID.Description AS IdentifierDomainDescription, ID.Logo, ID.IsHidden, 
                         DS.DereferenceServiceUUID, DS.DereferenceServiceProtocol, DS.DereferenceService, DS.DereferencePrefix, DS.DereferenceSuffix, 
                         DS.Description AS DereferenceServiceDescription
FROM            BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS INNER JOIN
                         dbo.view_SearchIdentifierDomain AS ID ON IDDS.IdentifierDomainID = ID.IdentifierDomainID INNER JOIN
                         dbo.view_SearchDereferenceService AS DS ON IDDS.DereferenceServiceID = DS.DereferenceServiceID INNER JOIN
                         BioGUID.dbo.PK AS PK ON IDDS.IdentifierDomainDereferenceServiceID = PK.PKID
WHERE        (PK.CorrectID = PK.PKID)

GO
/****** Object:  UserDefinedFunction [dbo].[FullEnumerationChildList]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 18 September 2013
-- EDIT DATE:	21 October 2013
-- DESCRIPTION:
--		Returns the provided EnumerationID and EnumerationID values for all Descendant Enumeration instancess of the provided EnumerationID
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[FullEnumerationChildList] 
(
	-- Add the parameters for the function here
	-- =============================================
	@EnumerationID int
)
RETURNS TABLE 
AS RETURN
(
-- SQL Statement
-- =============================================================================

	WITH FullEnumerationList (EnumerationID, Degree) AS 
	(
	 SELECT EnumerationID, 0 AS Degree
		 FROM BioGUID.dbo.Enumeration
		 WHERE EnumerationID=@EnumerationID
	 UNION ALL
	 SELECT ChildEnumeration.EnumerationID, FullEnumerationList.Degree + 1
		 FROM BioGUID.dbo.Enumeration AS ChildEnumeration
			 INNER JOIN FullEnumerationList
				 ON ChildEnumeration.EnumerationTypeID = FullEnumerationList.EnumerationID
	)
	SELECT @EnumerationID AS EnumerationID, EnumerationID AS ChildEnumerationID, MIN(Degree) AS Degree 
	FROM FullEnumerationList 
	GROUP BY EnumerationID

-- =============================================================================
)




GO
/****** Object:  UserDefinedFunction [dbo].[FullEnumerationParentList]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 18 September 2013
-- EDIT DATE:	21 October 2013
-- DESCRIPTION:
--		Returns the provided EnumerationID and EnumerationID values for all Parent Enumeration instancess of the provided EnumerationID
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================
CREATE FUNCTION [dbo].[FullEnumerationParentList] 
(
	-- Add the parameters for the function here
	-- =============================================
	@EnumerationID int
)
RETURNS TABLE 
AS RETURN
(
-- SQL Statement
-- =============================================================================

	WITH FullEnumerationList (EnumerationID, Degree) AS 
		(
		SELECT EnumerationID, 0 AS Degree
		FROM BioGUID.dbo.Enumeration
		WHERE EnumerationID=@EnumerationID
		UNION ALL
		SELECT ParentEnumeration.EnumerationTypeID, FullEnumerationList.Degree - 1
		FROM BioGUID.dbo.Enumeration AS ParentEnumeration
			INNER JOIN FullEnumerationList ON ParentEnumeration.EnumerationID = FullEnumerationList.EnumerationID
		WHERE ParentEnumeration.EnumerationTypeID <> 0 AND ParentEnumeration.EnumerationTypeID <> ParentEnumeration.EnumerationID
		)
	SELECT @EnumerationID AS EnumerationID, EnumerationID AS ParentEnumerationID, MAX(Degree) AS Degree 
	FROM FullEnumerationList 
	GROUP BY EnumerationID

-- =============================================================================
)

GO
/****** Object:  View [dbo].[view_BatchImportStatus]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_BatchImportStatus]
AS
SELECT        ObjectClass, IdentifierDomainUUID, DereferencePrefix, DereferenceSuffix, IMPORTIdentifier, Identifier, RelatedObjectClass, RelatedIdentifierDomainUUID, 
                         RelatedDereferencePrefix, RelatedDereferenceSuffix, IMPORTRelatedIdentifier, RelatedIdentifier, RelationshipType, ImportStatus, BatchUUID
FROM            BioGUID_IMPORT.dbo.IMPORT

GO
/****** Object:  View [dbo].[view_MultipleIdentifiers]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_MultipleIdentifiers]
AS
SELECT        TOP (100) PERCENT IdentifierDomainID, COUNT(*) AS MultipleIdentifiers
FROM            (SELECT        IdentifierDomainID, IdentifiedObjectID
                          FROM            BioGUID.dbo.Identifier AS I
                          WHERE        (IdentifierDomainID <> 100548)
                          GROUP BY IdentifierDomainID, IdentifiedObjectID
                          HAVING         (COUNT(*) > 1)) AS SRC
GROUP BY IdentifierDomainID

GO
/****** Object:  View [dbo].[view_SearchFAQ]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_SearchFAQ]
AS
SELECT        FAQID, Category, Question, Answer, Sequence
FROM            dbo.FAQ

GO
/****** Object:  View [dbo].[view_SearchIdentifier]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_SearchIdentifier]
AS
SELECT        I.IdentifiedObjectID AS ObjectID, OC.EnumerationValue AS ObjectClass, dbo.NormalizeUUID(IDPK.UUID) AS IdentifierDomainUUID, ID.Abbreviation, 
                         ID.IdentifierDomain, ID.Description AS IdentifierDomainDescription, ID.Logo AS IdentifierDomainLogo, ID.IsHidden, dbo.NormalizeUUID(ID.AgentUUID) AS AgentUUID, 
                         IC.EnumerationValue AS IdentifierClass, CASE WHEN DS.DereferenceServiceID = 0 THEN NULL ELSE dbo.NormalizeUUID(DSPK.UUID) 
                         END AS PreferredDereferenceServiceUUID, P.EnumerationValue AS PreferredDereferenceServiceProtocol, DS.DereferenceService AS PreferredDereferenceService, 
                         DS.Description AS PreferredDereferenceServiceDescription, DS.DereferencePrefix AS PreferredDereferencePrefix, I.Identifier, 
                         DS.DereferenceSuffix AS PreferredDereferenceSuffix, DS.Logo AS PreferredDereferenceServiceLogo
FROM            BioGUID.dbo.Identifier AS I INNER JOIN
                         BioGUID.dbo.IdentifiedObject AS Obj ON I.IdentifiedObjectID = Obj.IdentifiedObjectID INNER JOIN
                         BioGUID.dbo.Enumeration AS OC ON Obj.ObjectClassID = OC.EnumerationID INNER JOIN
                         BioGUID.dbo.IdentifierDomain AS ID ON I.IdentifierDomainID = ID.IdentifierDomainID INNER JOIN
                         BioGUID.dbo.PK AS IDPK ON ID.IdentifierDomainID = IDPK.PKID INNER JOIN
                         BioGUID.dbo.DereferenceService AS DS ON ID.PreferredDereferenceServiceID = DS.DereferenceServiceID INNER JOIN
                         BioGUID.dbo.PK AS DSPK ON DS.DereferenceServiceID = DSPK.PKID INNER JOIN
                         BioGUID.dbo.Enumeration AS IC ON ID.IdentifierClassID = IC.EnumerationID INNER JOIN
                         BioGUID.dbo.Enumeration AS P ON DS.ProtocolID = P.EnumerationID

GO
/****** Object:  View [dbo].[view_SearchNewsItem]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_SearchNewsItem]
AS
SELECT        NewsItemID, NewsItem, CONVERT(nvarchar, PostTimeStamp, 100) + N' (UTC)' AS DisplayDate, PostTimeStamp, IsSuppressed
FROM            dbo.NewsItem

GO
/****** Object:  Index [IX_Temp_MultipleIdentifiers]    Script Date: 10/5/2015 9:14:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Temp_MultipleIdentifiers] ON [dbo].[Temp_MultipleIdentifiers]
(
	[IdentifierDomainID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Temp_MultipleIdentifiers_IdentifiedObjectID]    Script Date: 10/5/2015 9:14:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Temp_MultipleIdentifiers_IdentifiedObjectID] ON [dbo].[Temp_MultipleIdentifiers]
(
	[IdentifiedObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Temp_MultipleIdentifiers_RecordCount]    Script Date: 10/5/2015 9:14:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Temp_MultipleIdentifiers_RecordCount] ON [dbo].[Temp_MultipleIdentifiers]
(
	[RecordCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[sp_AdjustCreatedUsername]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 23 June 2008
-- EDIT DATE:	
-- DESCRIPTION:
--		Adjusts the <CREATED> record in the EditLog table for the corresponding 
--		@PKID value to the provided @LogUserName value
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_AdjustCreatedUsername] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@PKID int = 0, 
	@LogUserName nvarchar(128) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @LogUserName <> '' AND @PKID<>0
	BEGIN
		UPDATE BioGUID.dbo.EditLog
			SET Username = @LogUserName
		WHERE PKID=@PKID AND 
			  PreviousValue='[CREATED]' AND
			  SchemaItemID IN 
				(
				SELECT 
				SchemaItemID 
				FROM BioGUID.dbo.SchemaItem AS SI 
					INNER JOIN BioGUID.dbo.Enumeration AS E ON SI.SchemaItemTypeID = E.EnumerationID
					INNER JOIN BioGUID.dbo.Enumeration AS ET ON E.EnumerationTypeID = ET.EnumerationID
				WHERE E.EnumerationValue = 'Table' AND ET.EnumerationValue='SchemaItemTypes'
				)
	END
-- =============================================================================
END


GO
/****** Object:  StoredProcedure [dbo].[sp_CompareValues]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 29 May 2012
-- EDIT DATE:	
-- DESCRIPTION:
--		Compares the provided @Value with the corresponding value in the indicated 
--		@FieldName of the indicated @TableName for the record represented by the 
--		indicated @PKID.
--		NOTE: The Function assumes that the provided @TableName, @FieldName, @PKFieldNm
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		@Result		Boolean value where 1 means the values are identical, 
--					and 0 means they are non-identical.  NULL is returned
--					if @TableName, @FieldName or @PKFieldNm are not legitimate,
--					or if there is no record in the indicated table with a corresponding
--					@PKID record. 
--
-- CALLED PROCEDURES:
--		sp_executesql
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_CompareValues] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@TableName		varchar(128)	= '',
	@FieldName		varchar(128)	= '',
	@PKFieldName	varchar(128)	= '',
	@PKID			int				= 0,
	@Value			nvarchar(MAX)	= NULL,
	@Result			bit				= NULL		OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @SQL			nvarchar(MAX)
	DECLARE @FieldType		varchar(128)
	DECLARE @ExistingValue	nvarchar(MAX)
	DECLARE @IsLegitimate	bit
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Set Default Values for @IsLegitimate and @Result
	SET @IsLegitimate = 0
	SET @Result = NULL	
		
	-- Get @FieldType
	SELECT @FieldType = Cols.DATA_TYPE
	FROM BioGUID.INFORMATION_SCHEMA.COLUMNS AS Cols
	WHERE Cols.TABLE_NAME = @TableName AND
		Cols.COLUMN_NAME = @FieldName	

	-- If @FieldType was successfully retrieved, @PKFieldNm is a field in the indicated table,
	-- and the @PKID record is non-zero and actually exists, then get the @ExistingValue and 
	-- set @IsLegitimate=1
	IF ISNULL(@FieldType, '') <> '' AND
		isnull(@PKID, 0) > 0 and
		(SELECT COUNT(TABLE_NAME) FROM BioGUID.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName AND COLUMN_NAME = @PKFieldName ) > 0
	BEGIN
		-- Make sure the Record exists for the provided @PKID
		SET @SQL = N'SELECT @ExistingValue = CAST(COUNT([' + @PKFieldName + N']) AS nvarchar) FROM BioGUID.dbo.[' + @TableName + N'] WHERE [' + @PKFieldName + N'] = ' + CAST(@PKID AS nvarchar)
		EXEC sp_executesql @SQL, N'@ExistingValue nvarchar(MAX) OUTPUT', @ExistingValue OUTPUT

		IF CAST(@ExistingValue AS int) = 1
		BEGIN
			SET @ExistingValue = NULL
			-- Get @ExistingValue
			SET @SQL = N'SELECT @ExistingValue = CAST([' + @FieldName + N'] AS nvarchar(MAX)) FROM BioGUID.dbo.[' + @TableName + N'] WHERE [' + @PKFieldName + N'] = ' + CAST(@PKID AS nvarchar)
			EXEC sp_executesql @SQL, N'@ExistingValue nvarchar(MAX) OUTPUT', @ExistingValue OUTPUT
			SET @IsLegitimate = 1
		END

	END

-- =============================================================================

-- Operational Code
-- =============================================================================

	IF @IsLegitimate = 1
	BEGIN
		-- Set Default Value for @Result to be different, unless proven to be the same.
		SET @Result = 0

		-- Compare @Value to @ExistingValue
		-- Catch cases where both values are null
		IF @Value IS NULL AND @ExistingValue IS NULL
			SET @Result = 1
		ELSE
		BEGIN
			IF @Value IS NOT NULL AND @ExistingValue IS NOT NULL
			BEGIN
				IF CAST(@Value AS varbinary(MAX)) = CAST(@ExistingValue AS varbinary(MAX))
					SET @Result = 1
			END		
		END
	END		
-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ConvertCRTABtoSpace]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ricvhard L. Pyle
-- Create date: 21 December 2014
-- Description:	Finds all carriage returns and tab characters and converts them to space
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvertCRTABtoSpace] 
	-- Add the parameters for the stored procedure here
	@TableName nvarchar(255) = '',
	@SchemaName	nvarchar(255) = 'dbo',
	@DatabaseName nvarchar(255) = 'BioGUIDDataServices'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ColumnList AS TABLE (ColumnName nvarchar(255))
	DECLARE @SQL AS nvarchar(MAX)
	DECLARE @ColumnName AS nvarchar(MAX)
	DECLARE @TotalCount	AS int = 0
	
    -- Insert statements for procedure here
	
	INSERT INTO @ColumnList(ColumnName)
	SELECT DISTINCT COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @TableName AND TABLE_SCHEMA=@SchemaName AND DATA_TYPE IN ('nvarchar','varchar','nchar','char','text','ntext')
	
	WHILE (SELECT COUNT(*) FROM @ColumnList) > 0
	BEGIN
		SELECT TOP(1) @ColumnName = ColumnName FROM @ColumnList
		
		SET @SQL = 'UPDATE ' + ISNULL(@DatabaseName, 'BioGUIDDataServices') + '.' + ISNULL(@SchemaName, 'dbo') + '.' + @TableName + ' SET [' + @ColumnName + '] = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE([' + @ColumnName + '], CHAR(9), '' ''), CHAR(10), '' ''), CHAR(13), '' ''), ''  '', '' ''))) WHERE [' + @ColumnName + '] LIKE ''%'' + CHAR(9) + ''%'' OR [' + @ColumnName + '] LIKE ''%'' + CHAR(10) + ''%'' OR [' + @ColumnName + '] LIKE ''%'' + CHAR(13) + ''%'''
		EXEC(@SQL)
		
		SET @TotalCount = @TotalCount + @@ROWCOUNT
		
		DELETE @ColumnList WHERE ColumnName = @ColumnName
	END
	
	SELECT @TotalCount AS TotalCount

END


GO
/****** Object:  StoredProcedure [dbo].[sp_ConvertEmptyToNull]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ricvhard L. Pyle
-- Create date: 8 October 2014
-- Description:	Finds all zero-length Strings and converts them to NULL
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvertEmptyToNull] 
	-- Add the parameters for the stored procedure here
	@TableName nvarchar(255) = '',
	@SchemaName	nvarchar(255) = 'dbo',
	@DatabaseName nvarchar(255) = 'BioGUIDDataServices',
	@TrimValues	bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ColumnList AS TABLE (ColumnName nvarchar(255))
	DECLARE @SQL AS nvarchar(MAX)
	DECLARE @ColumnName AS nvarchar(MAX)
	DECLARE @TotalCount	AS int = 0
	
    -- Insert statements for procedure here
	
	INSERT INTO @ColumnList(ColumnName)
	SELECT DISTINCT COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @TableName AND TABLE_SCHEMA=@SchemaName AND DATA_TYPE IN ('nvarchar','varchar','nchar','char','text','ntext')
	
	WHILE (SELECT COUNT(*) FROM @ColumnList) > 0
	BEGIN
		SELECT TOP(1) @ColumnName = ColumnName FROM @ColumnList

		IF ISNULL(@TrimValues, 0) = 1
		BEGIN
			SET @SQL = 'UPDATE ' + ISNULL(@DatabaseName, 'BioGUIDDataServices') + '.' + ISNULL(@SchemaName, 'dbo') + '.' + @TableName + ' SET [' + @ColumnName + '] = LTRIM(RTRIM([' + @ColumnName + '])) WHERE [' + @ColumnName + '] LIKE '' %'' OR [' + @ColumnName + '] LIKE ''% '''
			EXEC(@SQL)
		END
				
		SET @SQL = 'UPDATE ' + ISNULL(@DatabaseName, 'BioGUIDDataServices') + '.' + ISNULL(@SchemaName, 'dbo') + '.' + @TableName + ' SET [' + @ColumnName + '] = NULL WHERE [' + @ColumnName + '] = '''''
		EXEC(@SQL)
		
		SET @TotalCount = @TotalCount + @@ROWCOUNT
		
		DELETE @ColumnList WHERE ColumnName = @ColumnName
	END
	
	SELECT @TotalCount AS TotalCount

END


GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteRecord]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 28 February 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Deletes a record based on the provided @ID value
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_DeleteRecord] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@ID				varchar(36)		= ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @PKID			int				= 0
	DECLARE @TableName		nvarchar(255)	= ''
	DECLARE @SQL			nvarchar(MAX)	= ''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Get @PKID
	SET @PKID = dbo.GetItemID(@ID, 0)

	-- Get @TableName
	IF ISNULL(@PKID, 0) <> 0
		SELECT @TableName = SI.SchemaItemName 
		FROM BioGUID.dbo.SchemaItem AS SI
			INNER JOIN BioGUID.dbo.PK AS PK ON SI.SchemaItemID = PK.TableID
		WHERE PK.PKID = @PKID
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF ISNULL(@PKID, 0) <> 0 AND ISNULL(@TableName, '') <> ''
	BEGIN
		-- Delete the EditLog record
		ALTER TABLE BioGUID.dbo.EditLog DISABLE TRIGGER tr_DeleteEditLog
		DELETE BioGUID.dbo.EditLog WHERE PKID = @PKID
		ALTER TABLE BioGUID.dbo.EditLog ENABLE TRIGGER tr_DeleteEditLog

		-- Delete the record from the Table itself
		SET @SQL = 'ALTER TABLE BioGUID.dbo.[' + @TableName + '] DISABLE TRIGGER tr_Delete' + @TableName
		EXEC(@SQL)
		SET @SQL = 'DELETE BioGUID.dbo.[' + @TableName + '] WHERE [' + @TableName + 'ID] = ' + CAST(@PKID AS nvarchar)
		EXEC(@SQL)
		SET @SQL = 'ALTER TABLE BioGUID.dbo.[' + @TableName + '] ENABLE TRIGGER tr_Delete' + @TableName
		EXEC(@SQL)

		-- Delete the PK record
		ALTER TABLE BioGUID.dbo.PK DISABLE TRIGGER tr_DeletePK
		DELETE BioGUID.dbo.PK WHERE PKID = @PKID
		ALTER TABLE BioGUID.dbo.PK ENABLE TRIGGER tr_DeletePK
		
	END
-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EditValue]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 5 October 2008
-- EDIT DATE:	27 December 2014 (added support for Performance Logging)
-- DESCRIPTION:
--		Updates the value of the indicated field of the indicated record in 
--		the indicated table.  NOTE: In order to set a value to NULL, it must be passed
--		as a zero-length string ''. If @Value is Null, the update is aborted.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES AND VIEWS:
--		dbo.GetSchemaItemID
--		dbo.CompareValues
--		view_FKSubTypes
--		view_FieldDetails
--		view_PKFields
--
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_EditValue] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@PKID		int				= 0, 
	@TableName		varchar(128)	= '',
	@FieldName		varchar(128)	= '',
	@Value		nvarchar(MAX)	= NULL,
	@UserName	varchar(128)	= '',
	@SessionID	uniqueidentifier	= NULL,
	@DoLog		bit				= 1,
	@Debug				bit		= 0,
	@Out		nvarchar(MAX)	= ''		OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @TableID		int				--SchemaItemID for Table
	DECLARE @FieldID		int				--SchemaItemID for Field
	DECLARE @RootTableID	int				--SchemaItemID for TableID of provided @PKID
	DECLARE @RootTableName	varchar(128)	--Name of table for TableID of provided @PKID
	DECLARE @PKFieldName	varchar(128)	--Name of Primary Key Field of the Table to be updated
	DECLARE @FieldType		varchar(128)	--DataType of provided @FieldName
	DECLARE @STCount	int				--Count of Subtype tables with matching field name
	DECLARE @SQL		nvarchar(MAX)	--SQL Statement
	DECLARE @PrevELID	int				--Initial EditLogID
	DECLARE @ELID		int				--New EditLogID
	DECLARE @SameValue	bit				--Flag indicating that the value has changed
	DECLARE @StartTime	datetime		= NULL
	DECLARE @Parameters	nvarchar(MAX)	= NULL
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Establish Performance Log variables
	IF @DoLog = 1
	BEGIN
		SET @StartTime = GETUTCDATE()
		IF @SessionID IS NULL
			SET @SessionID = NEWID()
	END

	-- Capture Parameter Values
	SET @Parameters = 
		'@PKID=' + ISNULL(CAST(@PKID AS nvarchar), '[NULL]') + '|' +
		'@TableName=' + ISNULL(@TableName, '[NULL]') + '|' +
		'@FieldName=' + ISNULL(@FieldName, '[NULL]') + '|' +
		'@Value=' + ISNULL(@Value, '[NULL]') + '|' +
		'@UserName=' + ISNULL(@UserName, '[NULL]') + '|' +
		'@SessionID=' + ISNULL(CAST(@SessionID AS nvarchar(36)), '[NULL]') + '|' +
		'@DoLog=' + ISNULL(CAST(@DoLog AS nvarchar), '[NULL]') + '|' +
		'@Debug=' + ISNULL(CAST(@Debug AS nvarchar), '[NULL]') + '|' +
		'@Out=' + ISNULL(@Out, '[NULL]') + '|'

	-- Only proceed if a non-null value was passed
	IF @Value IS NOT NULL
	BEGIN
		-- SET Initial Values for declared variables
		SET @PKID = ISNULL(@PKID,0)
		SET @TableName = ISNULL(@TableName,'')
		SET @FieldName = ISNULL(@FieldName,'')
		SET @Value = LTRIM(RTRIM(REPLACE(@Value,'''','''''')))
		SET @UserName = ISNULL(@UserName,'')
		SET @TableID = 0
		SET @FieldID = 0
		SET @RootTableID = 0
		SET @RootTableName = ''
		SET @FieldType = ''
		SET @PKFieldName = ''
		SET @Out = ''
		SET @SameValue = 0

		-- Catch explict NULL values
		IF @Value = ''
			SET @Value = 'NULL'
		
		-- Remove whitespace from Value
		SET @Value = dbo.RemoveWhitespace(@Value)
		
		-- First test that values have been provided for @PKID, @FieldName, and @UserName
		IF ISNULL(@PKID, 0)<>0 AND ISNULL(@FieldName, '')<>'' AND ISNULL(@UserName, '') <>''
		BEGIN
			SET @Out = '@PKID=' + CAST(@PKID AS varchar) + '|@FieldName=' + @FieldName + '|UserName=' + @UserName
			-- Only Proceed if a @PKID is legitimate, and TableID can be retrieved for 
			-- the provided @PKID. This serves two purposes: validates the existince of
			-- a record corresponding to @PKID, and establishes a default value for @TableID
			-- An exception is when the provided TblNm is 'PK' and the provided @FieldName is 'CorrectID'
			SELECT @RootTableID = PK.TableID, @RootTableName = SI.SchemaItemName
			FROM BioGUID.dbo.PK AS PK 
				INNER JOIN BioGUID.dbo.SchemaItem AS SI
					ON PK.TableID=SI.SchemaItemID
			WHERE (PK.PKID=PK.CorrectID OR (@TableName='PK' AND @FieldName='CorrectID')) AND PK.PKID=@PKID

			IF @RootTableID<>0 AND @RootTableName<>''
			BEGIN
				SET @Out = @Out + '|@RootTableID=' + CAST(@RootTableID AS varchar) + '|@RootTableName=' + @RootTableName
				-- If @TableName is provided, attempt to Retrieve Corresponding @TableID 
				IF @TableName<>''
				BEGIN
					SET @TableID = dbo.GetSchemaItemID(@TableName, -1, 'Table')
					SET @Out = @Out + '|@TableName=' + @TableName
				END
				ELSE
					SET @Out = @Out + '|@TableName NOT PROVIDED'

				-- If @TableID has been set, but differs from @RootTableID, check if it's the PK Table, 
				-- and if not, then check to see if it's a subtype
				-- by attempting to retrieve the PK field name on the sybtype table					
				IF @TableID<>0 AND @TableID <> @RootTableID
					IF @TableName='PK'
						SET @PKFieldName = 'PKID'
					ELSE
						SELECT @PKFieldName=FKST.FKColumn 
						FROM BioGUID.dbo.view_FKSubTypes AS FKST 
						WHERE FKST.PKTableID=@RootTableID AND FKST.FKTableID=@TableID
					
					SET @Out = @Out + '|@TableID=' + CAST(@TableID AS varchar)

				-- If we have a value for @PKFieldName, that means the provided @TableName is legitimate, and
				-- is a subtype of the table corresponding to @PKID. We need only to verify that the provided
				-- @FieldName is in the subtype table. If it is, then we can be confident that the update needs
				-- to occur in the subtype table.
				IF ISNULL(@PKFieldName, '') <> ''
				BEGIN
					SELECT @FieldID=FD.FieldID, @FieldType=FD.DataType 
					FROM BioGUID.dbo.view_FieldDetails AS FD 
					WHERE FD.TableID=@TableID AND FD.FieldName=@FieldName
					SET @Out = @Out + '|@PKFieldName=' + @PKFieldName + '|@FieldID=' + CAST(ISNULL(@FieldID,0) AS varchar) + '@FieldType=' + ISNULL(@FieldType,'NULL')
				END
				ELSE
					SET @Out = @Out + '|@PKFieldName Not Found'

				--If @FieldID has not been set, then the provided @TableName is not right, so reset it and the @TableID
				--and see if @FieldName belongs to the Root Table
				IF ISNULL(@FieldID, 0) = 0 
				BEGIN
					SET @Out = @Out + '|@FieldID Not Yet Set'
					SET @TableName=@RootTableName
					SET @TableID=@RootTableID
					SELECT @FieldID=FD.FieldID, @FieldType=FD.DataType 
					FROM BioGUID.dbo.view_FieldDetails AS FD 
					WHERE FD.TableID=@TableID AND FD.FieldName=@FieldName

					SET @Out = @Out + '|@FieldID(Root)=' + CAST(@FieldID AS varchar) + '|@TableID(Root)=' + CAST(@TableID AS varchar)

					--Find out how many subtypes the @FieldName belongs to (excluding cases where the field name is the PK for the subtype table)
					SELECT @STCount= COUNT(FD.TableID) FROM BioGUID.dbo.view_FKSubtypes AS FKS
						INNER JOIN BioGUID.dbo.view_FieldDetails AS FD
							ON FKS.FKTableID = FD.TableID
					WHERE FKS.PKTableID=@TableID AND FD.FieldName=@FieldName AND FKS.FKColumn <> FD.FieldName
					
					SET @Out = @Out + '|Subtypes=' + CAST(@STCount AS nvarchar) 

					IF ISNULL(@FieldID, 0) = 0
						-- The @FieldName is not in the root table, but it is in exactly one of the
						-- subtype tables, so get @TableName, @TableID, @FieldID, @FieldType and @PKFieldName from that subtype Table.
						SET @Out = @Out + '|Checking Subtype Tables'
						IF @STCount=1
						BEGIN
							SELECT @TableName=FKS.FKTable, @TableID=FKS.FKTableID, @FieldID=FD.FieldID, @FieldType=FD.DataType, @PKFieldName=PKF.PKField
							FROM BioGUID.dbo.view_FKSubtypes AS FKS
								INNER JOIN BioGUID.dbo.view_FieldDetails AS FD
									ON FKS.FKTableID = FD.TableID
								INNER JOIN BioGUID.dbo.view_PKFields AS PKF
									ON FKS.FKTableID = PKF.SchemaItemID
							WHERE FKS.PKTableID=@RootTableID AND FD.FieldName=@FieldName
							SET @Out = @Out + '|In Subtype ' + ISNULL(@TableName,'NULL') + '|@TableID=' + CAST(ISNULL(@TableID,'NULL') AS varchar) + '|@FieldID=' + CAST(ISNULL(@FieldID,'NULL') AS varchar) + '|@FieldType=' + ISNULL(@FieldType,'NULL') + '|@PKFieldName=' + ISNULL(@PKFieldName,'NULL')
						END
					ELSE
					BEGIN
						-- The @FieldName is in the root table, so as long as it's not in any of the subtype tables,
						-- we will assume this is the field to be updated, in which case we need to update
						-- @TableName to @RootTableName, @TableID to @RootTableID, and retrieve @FieldID, @FieldTypee and @PKFieldName accordingly.
						IF @STCount=0
						BEGIN
							SET @Out = @Out + 'Final Stage'
							SELECT @FieldID=FD.FieldID, @FieldType=FD.DataType, @PKFieldName=PKF.PKField
							FROM BioGUID.dbo.view_FieldDetails as FD
								INNER JOIN BioGUID.dbo.view_PKFields as PKF
									ON FD.TableID=PKF.SchemaItemID
							WHERE  FD.TableID=@TableID AND FD.FieldName=@FieldName

						END
					END
				END
			END
		END
		
		-- Check to see if the value has changed from the value in the database
		EXEC sp_CompareValues @TableName=@TableName, @FieldName=@FieldName, @PKFieldName=@PKFieldName, @PKID=@PKID, @Value=@Value, @Result=@SameValue OUTPUT

		--Verify @Username
--		IF NOT EXISTS(
--			 SELECT UN.UserName 
--			 FROM dbo.UserName AS UN 
--			 WHERE UN.UserName=@UserName
--			 )
--			SET @UserName=''
	END

	--Performance Check
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EditValue', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Skip if @Value is NULL
	IF ISNULL(@Value, '') <> ''
	BEGIN
		--Only Proceed if a values are provided for @PKID, @TableID, @FieldID, @PKFieldName, 
		--@FieldType, and @UserName; that the PK Field is not the one being updated; and
		--that the value is different from the existing value in the database.
		IF ISNULL(@PKID, 0) <> 0 AND 
		   ISNULL(@TableID, 0) <> 0 AND 
		   ISNULL(@TableName, '') <> '' AND 
		   ISNULL(@FieldID, 0) <> 0 AND 
		   ISNULL(@FieldName, '') <> '' AND 
		   ISNULL(@PKFieldName, '') <> '' AND 
		   ISNULL(@FieldType, '') <> '' AND 
		   ISNULL(@UserName, '') <> '' AND
		   @FieldName<>@PKFieldName AND
		   @SameValue = 0
		BEGIN
			--Build UPDATE SQl
			--Make adjustments to @Value depending on @FieldType
			IF @FieldType='bit' OR @FieldType='tinyint' OR @FieldType='smallint' OR @FieldType='int' OR @FieldType='bigint' OR @FieldType='decimal' OR @FieldType='numeric' OR @FieldType='money' OR @FieldType='smallmoney' OR @Value='NULL'
			BEGIN
				IF @FieldType='bit' AND (@Value='True')
					SET @Value='1'
				IF @FieldType='bit' AND (@Value='False')
					SET @Value='0'
					
				SET @SQL = @Value
			END
			ELSE 
				IF @FieldType = 'nvarchar'
					SET @SQL = 'N''' + @Value + ''''
				ELSE
					SET @SQL = '''' + @Value + ''''
				
			SET @SQL = 'UPDATE T SET T.[' + @FieldName + '] = ' + @SQL + ' FROM BioGUID.dbo.[' + @TableName + '] AS T WHERE T.' + @PKFieldName + ' = ' + CAST(@PKID AS varchar)
			
			-- Capture EditLogID values immediately before and after the Update
			SELECT @PrevELID = MAX(EditLogID) FROM BioGUID.dbo.EditLog

			--Performance Check
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EditValue', @Task = 'Generated SQL', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

			EXEC(@SQL)

			SELECT @ELID = MAX(EditLogID) FROM BioGUID.dbo.EditLog

			--Performance Check
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EditValue', @Task = 'Executed SQL', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
			
			-- If we are confident that the correct update actually took place, then adjust the UserName in the EditLog table
			IF @ELID > @PrevELID
			BEGIN
				SET @SQL = 'UPDATE EL SET EL.Username=''' + @UserName + ''' FROM BioGUID.dbo.EditLog AS EL WHERE EL.EditLogID > ' + CAST(@PrevELID AS varchar) + ' AND EL.EditLogID <= ' + CAST(@ELID AS varchar) --+ ' AND EL.PKID=' + CAST(@PKID AS varchar) + ' AND EL.SchemaItemID=' + CAST(@FieldID AS varchar) 
				EXEC(@SQL)

				--Performance Check
				IF @DoLog = 1
				BEGIN
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EditValue', @Task = 'Adjusted Logged Username', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
			END
			ELSE
			BEGIN
				IF @ELID=@PrevELID
					SET @Out='Value was not updated!'
				ELSE
					SET @Out='Update succeeded, but Username was not set due to multiple updated records'
			END

			--Next Line is for testing purposes only.
			SET @Out = 'SUCCESS!!! PKID:' + CAST(@PKID AS varchar) + '|TblID:' + CAST(@TableID AS varchar) + '|TblNm:' + @TableName  + '|@FieldID:' + CAST(@FieldID AS varchar) + '|FldNm:' + @FieldName + '|FldTyp:' + @FieldType + '|PKFldNm:' + @PKFieldName + '|Value:' + @Value + '|UserName:' + @UserName

		END
		ELSE
		BEGIN
			--
			SET @Out='FAILED!!! [' + @Out + ']'
			IF ISNULL(@PKID, 0) = 0
				SET @Out = @Out + '@PKID=' + CAST(ISNULL(@PKID,'NULL') AS varchar)
			IF ISNULL(@TableID, 0) = 0
				SET @Out = @Out + '@TableID=' + CAST(ISNULL(@TableID,'NULL') AS varchar)
			IF ISNULL(@TableName, '') = ''
				SET @Out = @Out + '@TableName=' + ISNULL(@TableName,'NULL')
			IF ISNULL(@FieldID, 0) = 0
				SET @Out = @Out + '@FieldID=' + CAST(ISNULL(@FieldID,'NULL') AS varchar)
			IF ISNULL(@FieldName, '') = ''
				SET @Out = @Out + '@FieldName=' + ISNULL(@FieldName,'NULL')
			IF ISNULL(@PKFieldName, '') = ''
				SET @Out = @Out + '@PKFieldName=' + ISNULL(@PKFieldName,'NULL')
			IF ISNULL(@FieldType, '') = ''
				SET @Out = @Out + '@FieldType=' + ISNULL(@FieldType,'NULL')
			IF ISNULL(@UserName, '') = ''
				SET @Out = @Out + '@UserName=' + ISNULL(@UserName,'NULL')
			IF @FieldName=@PKFieldName
				SET @OUT = @Out + '@FieldName ' + @FieldName + '=@PKFieldName ' + @PKFieldName
		END
	END

	IF @Debug=1
		SELECT @Out

-- =============================================================================

END

GO
/****** Object:  StoredProcedure [dbo].[sp_EXPORTIdentifier]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 6 June 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Creates a list of Identifiers to export based on a provided IdentifierDomain.
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		sp_PerformanceLog
--		dbo.GetItemID
--		dbo.IsUUID
--		dbo.GetPKID
--
-- REFERENCED VIEWS
--		
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_EXPORTIdentifier]
	-- Add the parameters for the stored procedure here
	-- =============================================
	@IdentifierDomain			nvarchar(255)	= N'',
	@RelatedIdentifierDomain	nvarchar(255)	= N'',
	@IncludeRelated				bit				= 0,
	@Top						int				= 1000000,
	@SessionID					uniqueidentifier= NULL,
	@DoLog						bit				= 1,
	@Debug						bit				= 0	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IdentifierDomainPKID			int					= 0
	DECLARE @RelatedIdentifierDomainPKID	int					= 0
	DECLARE @T0						datetime			= GETUTCDATE()
	DECLARE @StartTime				datetime			= GETUTCDATE()
	DECLARE @Parameters				nvarchar(MAX)		= ''
	DECLARE @RecordCount			int					= -1
	DECLARE @RootSet TABLE (
		IdentifierDomainUUID uniqueidentifier, 	
		IdentifierDomain nvarchar(255), 
		DereferencePrefix nvarchar(255), 
		DereferenceSuffix nvarchar(255), 
		Identifier nvarchar(255), 
		ObjectID bigint INDEX idx_Root_ObjectID CLUSTERED)
	DECLARE @Output TABLE (
		ObjectClass nvarchar(255), 
		IdentifierDomainUUID uniqueidentifier, 
		IdentifierDomain nvarchar(255), 
		DereferencePrefix nvarchar(255),
		DereferenceSuffix nvarchar(255),
		Identifier nvarchar(255),
		RelatedObjectClass nvarchar(255), 
		RelatedIdentifierDomainUUID uniqueidentifier, 
		RelatedIdentifierDomain nvarchar(255), 
		RelatedDereferencePrefix nvarchar(255),
		RelatedDereferenceSuffix nvarchar(255),
		RelatedIdentifier nvarchar(255),
		RelationshipType nvarchar(255),
		ObjectID bigint INDEX idx_Output_ObjectID CLUSTERED, 
		RelatedObjectID bigint INDEX idx_Output_RelatedObjectID NONCLUSTERED)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Capture Input Parameters
	SET @Parameters = 
		N'@IdentifierDomain=' + ISNULL(@IdentifierDomain, N'[NULL]') + N'|' + 
		N'@RelatedIdentifierDomain=' + ISNULL(@RelatedIdentifierDomain, N'[NULL]') + N'|' + 
		N'@IncludeRelated=' + ISNULL(CAST(@IncludeRelated AS nvarchar(255)), N'[NULL]') + N'|' + 
		N'@Top=' + ISNULL(CAST(@Top AS nvarchar), N'[NULL]') + N'|' + 
		N'@SessionID=' + ISNULL(CAST(@SessionID AS nvarchar(36)), N'[NULL]') + N'|' + 
		N'@DoLog=' + ISNULL(CAST(@DoLog AS nvarchar), N'[NULL]') + N'|' + 
		N'@Debug=' + ISNULL(CAST(@Debug AS nvarchar), N'[NULL]')

	-- Convert @IdentifierDomain to @IdentifierDomainPKID
	IF ISNULL(@IdentifierDomain, '') <> ''
		SET @IdentifierDomainPKID = dbo.GetIdentifierDomainID(@IdentifierDomain, 1)

	-- Convert @RelatedIdentifierDomain to @RelatedIdentifierDomainPKID
	IF ISNULL(@RelatedIdentifierDomain, '') <> ''
		SET @RelatedIdentifierDomainPKID = dbo.GetIdentifierDomainID(@RelatedIdentifierDomain, 1)

	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())

	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF ISNULL(@IdentifierDomainPKID, 0) <> 0
	BEGIN
		-- Capture Base Recordset
		INSERT INTO @RootSet(IdentifierDomainUUID, IdentifierDomain, DereferencePrefix, DereferenceSuffix, Identifier, ObjectID)
		SELECT TOP(@Top) PK.UUID AS IdentifierDomainUUID, D.IdentifierDomain, DR.DereferencePrefix, DR.DereferenceSuffix, I.Identifier AS Identifier, I.IdentifiedObjectID
		FROM BioGUID.dbo.Identifier AS I
			INNER JOIN BioGUID.dbo.PK ON I.IdentifierDomainID = PK.PKID
			INNER JOIN BioGUID.dbo.IdentifierDomain AS D ON I.IdentifierDomainID = D.IdentifierDomainID
			LEFT OUTER JOIN BioGUID.dbo.DereferenceService AS DR ON D.PreferredDereferenceServiceID = DR.DereferenceServiceID
		WHERE PK.PKID = PK.CorrectID AND I.IdentifierDomainID = @IdentifierDomainPKID

		-- Performance Log
		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Base Recordset Captured', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		-- Capture Related Records, if requested
		IF ISNULL(@IncludeRelated, 0) = 1
		BEGIN
			-- Capture the Congruent related Identifiers
			INSERT INTO @Output (
				IdentifierDomainUUID, 
				IdentifierDomain, 
				DereferencePrefix,
				DereferenceSuffix,
				Identifier,
				RelatedIdentifierDomainUUID, 
				RelatedIdentifierDomain, 
				RelatedDereferencePrefix,
				RelatedDereferenceSuffix,
				RelatedIdentifier,
				RelationshipType,
				ObjectID, 
				RelatedObjectID
				)
			SELECT 
				RS.IdentifierDomainUUID, 
				RS.IdentifierDomain, 
				RS.DereferencePrefix,
				RS.DereferenceSuffix,
				RS.Identifier,
				PK.UUID AS RelatedIdentifierDomainUUID, 
				D.IdentifierDomain AS RelatedIdentifierDomain, 
				DR.DereferencePrefix AS RelatedDereferencePrefix,
				DR.DereferenceSuffix AS RelatedDereferenceSuffix,
				I.Identifier AS RelatedIdentifier,
				'Congruent' AS RelationshipType,
				RS.ObjectID, 
				RS.ObjectID AS RelatedIdentifiedObjectID
			FROM @RootSet AS RS
				INNER JOIN BioGUID.dbo.Identifier AS I ON RS.ObjectID = I.IdentifiedObjectID
				INNER JOIN BioGUID.dbo.PK ON I.IdentifierDomainID = PK.PKID
				INNER JOIN BioGUID.dbo.IdentifierDomain AS D ON I.IdentifierDomainID = D.IdentifierDomainID
				LEFT OUTER JOIN BioGUID.dbo.DereferenceService AS DR ON D.PreferredDereferenceServiceID = DR.DereferenceServiceID
			WHERE PK.PKID = PK.CorrectID AND I.IdentifierDomainID <> @IdentifierDomainPKID

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Congruent Records Captured', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

			-- Capture the non-Congruent related Objects and their Identifiers
			INSERT INTO @Output (
				IdentifierDomainUUID, 
				IdentifierDomain, 
				DereferencePrefix,
				DereferenceSuffix,
				Identifier,
				RelatedIdentifierDomainUUID, 
				RelatedIdentifierDomain, 
				RelatedDereferencePrefix,
				RelatedDereferenceSuffix,
				RelatedIdentifier,
				RelationshipType,
				ObjectID, 
				RelatedObjectID
				)
			SELECT 
				RS.IdentifierDomainUUID, 
				RS.IdentifierDomain,
				RS.DereferencePrefix,
				RS.DereferenceSuffix,
				RS.Identifier,
				PK.UUID AS RelatedIdentifierDomainUUID, 
				D.IdentifierDomain AS RelatedIdentifierDomain,
				DR.DereferencePrefix AS RelatedDereferencePrefix,
				DR.DereferenceSuffix AS RelatedDereferenceSuffix,
				I.Identifier AS RelatedIdentifier,
				E.EnumerationValue AS RelationshipType,
				RS.ObjectID, 
				RR.RelatedObjectID AS RelatedIdentifiedObjectID
			FROM @RootSet AS RS
				INNER JOIN BioGUID.dbo.ResourceRelationship AS RR ON RS.ObjectID = RR.ObjectID
				INNER JOIN BioGUID.dbo.Enumeration AS E ON RR.RelationshipID = E.EnumerationID
				INNER JOIN BioGUID.dbo.Identifier AS I ON RR.RelatedObjectID = I.IdentifiedObjectID
				INNER JOIN BioGUID.dbo.PK ON I.IdentifierDomainID = PK.PKID
				INNER JOIN BioGUID.dbo.IdentifierDomain AS D ON I.IdentifierDomainID = D.IdentifierDomainID
				LEFT OUTER JOIN BioGUID.dbo.DereferenceService AS DR ON D.PreferredDereferenceServiceID = DR.DereferenceServiceID
			WHERE PK.PKID = PK.CorrectID AND I.IdentifierDomainID <> @IdentifierDomainPKID

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Non-Congruent Records Captured', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

			-- Capture the Reciprocal non-Congruent related objects and their Identifiers
			INSERT INTO @Output (
				IdentifierDomainUUID, 
				IdentifierDomain, 
				DereferencePrefix,
				DereferenceSuffix,
				Identifier,
				RelatedIdentifierDomainUUID, 
				RelatedIdentifierDomain, 
				RelatedDereferencePrefix,
				RelatedDereferenceSuffix,
				RelatedIdentifier,
				RelationshipType,
				ObjectID, 
				RelatedObjectID
				)
			SELECT 
				RS.IdentifierDomainUUID, 
				RS.IdentifierDomain, 
				RS.DereferencePrefix,
				RS.DereferenceSuffix,
				RS.Identifier,
				PK.UUID AS RelatedIdentifierDomainUUID, 
				D.IdentifierDomain AS RelatedIdentifierDomain, 
				DR.DereferencePrefix AS RelatedDereferencePrefix,
				DR.DereferenceSuffix AS RelatedDereferenceSuffix,
				I.Identifier AS RelatedIdentifier,
				CASE WHEN E.EnumerationValue = 'Includes' THEN 'Included In' ELSE E.EnumerationValue END AS RelationshipType,
				RS.ObjectID, 
				RR.RelatedObjectID AS RelatedIdentifiedObjectID
			FROM @RootSet AS RS
				INNER JOIN BioGUID.dbo.ResourceRelationship AS RR ON RS.ObjectID = RR.RelatedObjectID
				INNER JOIN BioGUID.dbo.Enumeration AS E ON RR.RelationshipID = E.EnumerationID
				INNER JOIN BioGUID.dbo.Identifier AS I ON RR.ObjectID = I.IdentifiedObjectID
				INNER JOIN BioGUID.dbo.PK ON I.IdentifierDomainID = PK.PKID
				INNER JOIN BioGUID.dbo.IdentifierDomain AS D ON I.IdentifierDomainID = D.IdentifierDomainID
				LEFT OUTER JOIN BioGUID.dbo.DereferenceService AS DR ON D.PreferredDereferenceServiceID = DR.DereferenceServiceID
			WHERE PK.PKID = PK.CorrectID AND I.IdentifierDomainID <> @IdentifierDomainPKID
			
			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Reciprocal Non-Congruent Records Captured', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

		END
		ELSE
		BEGIN
			INSERT INTO @Output (
				IdentifierDomainUUID, 
				IdentifierDomain, 
				DereferencePrefix,
				DereferenceSuffix,
				Identifier,
				ObjectID 
				)
			SELECT 
				RS.IdentifierDomainUUID, 
				RS.IdentifierDomain, 
				RS.DereferencePrefix,
				RS.DereferenceSuffix,
				RS.Identifier,
				RS.ObjectID
			FROM @RootSet AS RS

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Direct Identifier Records Captured', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END

		-- Get ObjectClass for Object
		UPDATE @Output SET ObjectClass = E.EnumerationValue
		FROM @Output AS RS
			INNER JOIN BioGUID.dbo.IdentifiedObject AS O ON RS.ObjectID = O.IdentifiedObjectID
			INNER JOIN BioGUID.dbo.Enumeration AS E ON O.ObjectClassID = E.EnumerationID

		-- Performance Log
		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Updated ObjectClass', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		-- Get ObjectClass for RelatedObject
		UPDATE @Output SET RelatedObjectClass = E.EnumerationValue
		FROM @Output AS RS
			INNER JOIN BioGUID.dbo.IdentifiedObject AS O ON RS.RelatedObjectID = O.IdentifiedObjectID
			INNER JOIN BioGUID.dbo.Enumeration AS E ON O.ObjectClassID = E.EnumerationID

		-- Performance Log
		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Updated RelatedObjectClass', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		SELECT
			ObjectClass,
			IdentifierDomainUUID, 
			IdentifierDomain, 
			DereferencePrefix,
			DereferenceSuffix,
			Identifier,
			RelatedObjectClass, 
			RelatedIdentifierDomainUUID, 
			RelatedIdentifierDomain, 
			RelatedDereferencePrefix,
			RelatedDereferenceSuffix,
			RelatedIdentifier,
			RelationshipType
		FROM @Output

		-- Performance Log
		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Results Returned', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		-- Log Query Results
		IF ISNULL(@Debug, 0) = 0
		BEGIN
			INSERT INTO BioGUIDLocalLog.dbo.SearchLog (SearchUUID, StoredProcedure, [Parameters], UserName, StartTime, EndTime)
			SELECT @SessionID, N'sp_EXPORTIdentifier', @Parameters, N'Anonymous', @T0, GETUTCDATE()
--			INSERT INTO BioGUIDLocalLog.dbo.SearchResult (SearchLogID, PKID)
--			SELECT DISTINCT IDENT_CURRENT('BioGUIDLocalLog.dbo.SearchLog'), PKID FROM @IDList
		END
--		DELETE BioGUIDDataServices.dbo.SearchIndex WHERE SearchLogUUID = @SessionID

		-- Performance Log
		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_EXPORTIdentifier', @Task = 'Search Parameters and Results Logged', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			IF ISNULL(@Debug, 0) = 1
				EXEC sp_PerformanceSummary @SessionID = @SessionID
		END
	END
-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EXPORTWithinDomainMultipleIdentifiers]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 27 March 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Processes records in IMPORT Table in preparation for importing.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_EXPORTWithinDomainMultipleIdentifiers] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@BatchType			varchar(255)	= NULL,
	@IdentifierDomainID	int				= NULL,
	@DoPurge			bit				= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	IF ISNULL(@DoPurge, 0) = 1
		DELETE BioGUID_IMPORT.dbo.EXPORT WHERE BatchType = @BatchType AND IdentifierDomainUUID = CAST(dbo.GetUUID(@IdentifierDomainID) AS varchar(36))
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @BatchType IS NOT NULL AND @IdentifierDomainID IS NOT NULL
	BEGIN
		INSERT INTO BioGUID_IMPORT.dbo.EXPORT(
			[BatchType],
			[ObjectClass],
			[IdentifierDomainUUID],
			[IdentifierDomain],
			[DereferencePrefix],
			[Identifier],
			[DereferenceSuffix],
			[RelatedObjectClass],
			[RelatedIdentifierDomainUUID],
			[RelatedIdentifierDomain],
			[RelatedDereferencePrefix],
			[RelatedIdentifier],
			[RelatedDereferenceSuffix],
			[RelationshipOfResource])
		SELECT @BatchType AS BatchType, E.EnumerationValue AS ObjectClass, LOWER(CAST(PK.UUID AS char(36))) AS IdentifierDomainUUID, ID.IdentifierDomain, CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE DS.DereferencePrefix END AS DereferencePrefix, B.BaseIdentifier AS Identifier, CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE DS.DereferenceSuffix END AS DereferenceSuffix, E.EnumerationValue AS RelatedObjectClass, LOWER(CAST(PK.UUID AS char(36))) AS RelatedIdentifierDomainUUID, ID.IdentifierDomain AS RelatedIdentifierDomain, CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE DS.DereferencePrefix END AS RelatedDereferencePrefix, I.Identifier AS RelatedIdentifier, CASE WHEN ID.PreferredDereferenceServiceID = 0 THEN NULL ELSE DS.DereferenceSuffix END AS RelatedDereferenceSuffix, 'sameAs' AS ReltionshipType
		FROM BioGUID.dbo.Identifier AS I 
			INNER JOIN (SELECT IdentifiedObjectID, IdentifierDomainID, MIN(Identifier) AS BaseIdentifier FROM BioGUID.dbo.Identifier WHERE IdentifierDomainID = @IdentifierDomainID GROUP BY IdentifiedObjectID, IdentifierDomainID HAVING COUNT(*) > 1) AS B ON I.IdentifiedObjectID = B.IdentifiedObjectID AND I.IdentifierDomainID = B.IdentifierDomainID
			INNER JOIN BioGUID.dbo.PK AS PK ON I.IdentifierDomainID = PK.PKID
			INNER JOIN BioGUID.dbo.IdentifiedObject AS O ON I.IdentifiedObjectID = O.IdentifiedObjectID
			INNER JOIN BioGUID.dbo.Enumeration AS E ON O.ObjectClassID = E.EnumerationID
			INNER JOIN BioGUID.dbo.IdentifierDomain AS ID ON I.IdentifierDomainID = ID.IdentifierDomainID
			INNER JOIN BioGUID.dbo.DereferenceService AS DS ON ID.PreferredDereferenceServiceID = DS.DereferenceServiceID
		WHERE I.Identifier <> B.BaseIdentifier

	END
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetBatchImportStatus]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 2 September 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Returns the Import Status of a batch of records.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_GetBatchImportStatus] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@BatchUUID			uniqueidentifier	= NULL,
	@SessionID			uniqueidentifier	= NULL,
	@LogUserName		nvarchar(128)		= 'deepreef',
	@Debug				bit					= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @StartTime		datetime			= GETUTCDATE()
	DECLARE @RecordCount	AS int
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @BatchUUID IS NOT NULL
	BEGIN
		SELECT * FROM view_BatchImportStatus WHERE BatchUUID = @BatchUUID
		--Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTRecordStatus', @Task = 'Batch Import Status Recordset Returned', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

	END
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetEXPORTStats]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 4 April 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Provides current stats on records in the EXPORT Table
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_GetEXPORTStats] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@BatchType		nvarchar(255)		= N''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
-- =============================================================================

-- Operational Code
-- =============================================================================

	IF ISNULL(@BatchType, '') = ''
		SELECT BatchType, ObjectClass, FORMAT(COUNT(*), '#,###') AS RecordCount 
		FROM BioGUID_IMPORT.dbo.EXPORT 
		GROUP BY BatchType, ObjectClass 
		ORDER BY COUNT(*) DESC
	ELSE
		SELECT BatchType, ObjectClass, FORMAT(COUNT(*), '#,###') AS RecordCount 
		FROM BioGUID_IMPORT.dbo.EXPORT 
		WHERE BatchType = @BatchType
		GROUP BY BatchType, ObjectClass 
		ORDER BY COUNT(*) DESC

-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetIdentifierDomainDereferenceService]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 1 March 2015
-- DESCRIPTION:
--		Returns a list of matching IdentifierDomain/DereferenceService Values
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_GetIdentifierDomainDereferenceService]
	-- Add the parameters for the stored procedure here
	-- =============================================
	@IdentifierDomain		nvarchar(255)	= N'',
	@DereferenceService		nvarchar(255)	= N'',
	@IncludeHidden			bit				= 0,
	@UserName				nvarchar(128)	= N'Anonymous',
	@Top					int				= 0,
	@SessionID				uniqueidentifier= NULL,
	@DoLog					bit				= 1,
	@Debug					bit				= 0	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IdentifierDomainPKID	int				= 0
	DECLARE @DereferenceServicePKID	int				= 0
	DECLARE @SQL				nvarchar(MAX)		= N''
	DECLARE @WHERE				nvarchar(MAX)		= N''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Convert @IdentifierDomain to @IdentifierDomainPKID
	IF ISNULL(@IdentifierDomain, '') <> ''
		SET @IdentifierDomainPKID = dbo.GetIdentifierDomainID(@IdentifierDomain, 1)

	-- Convert @DereferenceService to @DereferenceServicePKID
	IF ISNULL(@DereferenceService, '') <> ''
		SET @DereferenceServicePKID = dbo.GetDereferenceServiceID(@DereferenceService, 1)
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF ISNULL(@IdentifierDomainPKID, 0) <> 0 OR ISNULL(@DereferenceServicePKID, 0) <> 0
	BEGIN
		IF ISNULL(@IdentifierDomainPKID, 0) <> 0
			SET @WHERE = @WHERE + N' AND (GIDDS.IdentifierDomainUUID = ''' + dbo.GetUUID(@IdentifierDomainPKID) + N''')'

		IF ISNULL(@DereferenceServicePKID, 0) <> 0
		BEGIN
			SET @WHERE = @WHERE + N' AND (GIDDS.DereferenceServiceUUID = ''' + dbo.GetUUID(@DereferenceServicePKID) + N''')'

			IF ISNULL(@IncludeHidden, 0) <> 1
				SET @WHERE = @WHERE + N' AND (GIDDS.IsHidden = 0)'
		END

		SET @WHERE = N' WHERE ' + SUBSTRING(@WHERE, 5, LEN(@WHERE))

	END
	ELSE
		SET @WHERE = N' WHERE (GIDDS.IdentifierDomainDereferenceServiceID IS NULL)'

	SET @SQL = N'SELECT * FROM view_GetIdentifierDomainDereferenceService AS GIDDS ' + @WHERE + N' ORDER BY GIDDS.IdentifierDomain, GIDDS.DereferenceService'
	
	IF @Debug = 1
		SELECT @SQL
	ELSE
		EXEC(@SQL)
-- =============================================================================
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetSearchDetails]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Richard L. Pyle
-- Create date: 27 March 2015
-- Description:	Returns information on Searches from the SearchLog
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSearchDetails] 
	-- Add the parameters for the stored procedure here
	@Top int = 0, 
	@Debug bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT S.*, dbo.GetParameterValue('@SearchTerm', S.[Parameters]) AS SearchTerm, DATEDIFF(ms, S.StartTime, S.EndTime) AS Duration, ISNULL(R.ResultCount, 0) AS ResultCount
	FROM BioGUIDLocalLog.dbo.SearchLog AS S
		LEFT OUTER JOIN
		(SELECT SearchLogID, COUNT(*) AS ResultCount FROM BioGUIDLocalLog.dbo.SearchResult GROUP BY SearchLogID) AS R ON S.SearchLogID = R.SearchLogID
	ORDER BY S.SearchLogID DESC
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetStatistics]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 28 February 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Provides current stats on records in the database
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_GetStatistics] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@ResultType		nvarchar(255)		= N'Basic',
	@BatchUUID		nvarchar(36)	= NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IDList as PKIDListType
	DECLARE @IDCount as bigint
	DECLARE @ObjCount as bigint
	DECLARE @Ratio AS float
	DECLARE @Stats AS TABLE (Item nvarchar(255), RecordCount float, [Sequence] int)
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	SELECT @IDCount = BioGUID.dbo.GetRecordCount('Identifier')
	SELECT @ObjCount = BioGUID.dbo.GetRecordCount('IdentifiedObject')
	SET @Ratio = (CAST(@IDCount AS float)/CAST(@ObjCount AS float))
	-- Normalize @BatchUUID
	SET @BatchUUID = dbo.NormalizeUUID(@BatchUUID)
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @ResultType = 'ImportBatch'
	BEGIN
		INSERT INTO @Stats(Item, RecordCount, [Sequence])
		SELECT ImportStatus, COUNT(*) AS RecordCount, 0 AS [Sequence]
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE BatchUUID = @BatchUUID
		GROUP BY ImportStatus

		INSERT INTO @Stats(Item, RecordCount, [Sequence])
		SELECT '[Adjusted Identifier]', COUNT(*) AS RecordCount, 1 AS [Sequence]
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE BatchUUID = @BatchUUID
			AND IMPORTIdentifier <> Identifier
	END
	ELSE
	BEGIN
		INSERT INTO @Stats(Item, RecordCount, [Sequence])
		SELECT 'Identifiers' AS Item, @IDCount, 2

		INSERT INTO @Stats(Item, RecordCount, [Sequence])
		SELECT 'Data Objects' AS Item, @ObjCount, 3

		INSERT INTO @Stats(Item, RecordCount, [Sequence])
		SELECT 'Identifier Domains', COUNT(IdentifierDomainID), 0 
		FROM BioGUID.dbo.IdentifierDomain

		INSERT INTO @Stats(Item, RecordCount, [Sequence])
		SELECT 'Dereference Services', COUNT(DereferenceServiceID), 1 
		FROM BioGUID.dbo.DereferenceService

		INSERT INTO @Stats(Item, RecordCount, [Sequence])
		SELECT N'Ratio', @Ratio, 4

		IF @ResultType = N'Details'
			INSERT INTO @Stats(Item, RecordCount, [Sequence])
			SELECT OC.EnumerationValue AS Item, Obj.RecordCount, 5
			FROM 
				(SELECT ObjectClassID, COUNT(IdentifiedObjectID) AS RecordCount
				FROM BioGUID.dbo.IdentifiedObject
				GROUP BY ObjectClassID) AS Obj
					INNER JOIN BioGUID.dbo.Enumeration AS OC ON Obj.ObjectClassID = OC.EnumerationID
	END

	-- Return Results
	SELECT Item, CASE WHEN Item = N'Ratio' THEN FORMAT(RecordCount, '#,###.00') ELSE FORMAT(RecordCount, '#,###') END AS RecordCount
	FROM @Stats
	ORDER BY ISNULL([Sequence], 999), Item

-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_IMPORTBatchTransfer]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 30 August 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Transfers records from CSV file to IMPORT_Temp table.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_IMPORTBatchTransfer] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@FileName			varchar(255)	= NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================

-- CODE REMOVED FOR SECURITY PURPOSES

-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	SELECT 'Failure' AS Result
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_IMPORTDuplicateObjects]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 March 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Manages merged Objects from IMPORT Table.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_IMPORTDuplicateObjects] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@BatchUUID			uniqueidentifier	= NULL,
	@SessionID			uniqueidentifier	= NULL,
	@LogUserName		nvarchar(128)		= 'deepreef',
	@Debug				bit					= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @DupeIO AS DupeIOType
	DECLARE @IDList AS PKIDListType
	DECLARE @StartTime		datetime			= GETUTCDATE()
	DECLARE @RecordCount	AS int
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @BatchUUID IS NOT NULL
	BEGIN
		-- ====================================
		-- Merge Duplicate Object ID values 
		-- ====================================
		-- Capture Affected Records
		INSERT INTO @DupeIO(IdentifiedObjectID, CorrectObjectID)
		SELECT DISTINCT II.RelatedIdentifiedObjectID, II.IdentifiedObjectID
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I
				ON II.IdentifierDomainID = I.IdentifierDomainID AND II.IdentifiedObjectID = I.IdentifiedObjectID AND II.Identifier = I.Identifier
			INNER JOIN BioGUID.dbo.Identifier AS I2
				ON II.RelatedIdentifierDomainID = I2.IdentifierDomainID AND II.RelatedIdentifiedObjectID = I2.IdentifiedObjectID AND II.RelatedIdentifier = I2.Identifier
		WHERE II.BatchUUID = @BatchUUID
			AND II.ImportStatus = 'DUPLICATE Object'
			AND II.RelationshipType = 'Congruent'
			AND II.RelatedIdentifiedObjectID IS NOT NULL
			AND II.IdentifiedObjectID IS NOT NULL
			AND II.RelatedIdentifiedObjectID <> II.IdentifiedObjectID
		--Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTDuplicateObjects', @Task = 'Populated @DupeIO', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		EXEC sp_MergeObjects @DupeIO = @DupeIO, @SessionID = @SessionID, @LogUserName = @LogUserName, @Debug = @Debug

		--Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTDuplicateObjects', @Task = 'Objects Merged', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		IF ISNULL(@Debug, 0) = 1
		BEGIN
			-- Rercords to update status
			SELECT 'Update ImportStatus' AS RecordSet, II.*
			FROM BioGUID_IMPORT.dbo.IMPORT AS II
				INNER JOIN @IDList AS IDL ON II.IdentifiedObjectID = IDL.PKID
			WHERE II.BatchUUID = @BatchUUID
				AND IDL.TableName = 'IdentifiedObject'
		END
		ELSE
		BEGIN
			-- Update ImportStatus in IMPORT table
			UPDATE BioGUID_IMPORT.dbo.IMPORT
			SET ImportStatus = 'Imported'
			FROM BioGUID_IMPORT.dbo.IMPORT AS II
				INNER JOIN @IDList AS IDL ON II.IdentifiedObjectID = IDL.PKID
			WHERE II.BatchUUID = @BatchUUID
				AND IDL.TableName = 'IdentifiedObject'
			SET @RecordCount = @@ROWCOUNT
			--Performance Log
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTDuplicateObjects', @Task = 'Update Status on IMPORT records', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		--Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTDuplicateObjects', @Task = 'Merged Duplicate Records Complete', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

	END
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_IMPORTIdentifierProcess]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 28 February 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Processes records in IMPORT Table in preparation for importing.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_IMPORTIdentifierProcess] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@BatchUUID			varchar(36)	= NULL,
	@ProcessAll			bit					= 0,
	@SessionID			uniqueidentifier	= NULL,
	@RS					bit					= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @OCEnumID AS int = 0
	DECLARE @ICEnumID AS int = 0
	DECLARE @RTEnumID AS int = 0
	DECLARE @IDDOI AS uniqueidentifier = NULL
	DECLARE @IDISSN AS uniqueidentifier = NULL
	DECLARE @MatchString nvarchar(MAX) = ''
	DECLARE @StartTime				datetime			= GETUTCDATE()
	DECLARE @T0						datetime			= @StartTime
	DECLARE @IDList		PKIDListType
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	
	-- Normalize @BatchUUID
	SET @BatchUUID = dbo.NormalizeUUID(@BatchUUID)
	
	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())

	-- Get ObjectClasses EnumerationType
	SET @OCEnumID = dbo.GetEnumerationID('ObjectClasses', NULL)

	-- Get IdentifierClasses EnumerationType
	SET @ICEnumID = dbo.GetEnumerationID('IdentifierClasses', NULL)

	-- Get RelationshipTypes EnumerationType
	SET @RTEnumID = dbo.GetEnumerationID('RelationshipTypes', NULL)

	-- Get DOI IdentifierDomain
	SET @IDDOI = dbo.GetUUID(dbo.GetIdentifierDomainID('DOI', 1))

	-- Get ISSN IdentifierDomain
	SET @IDISSN = dbo.GetUUID(dbo.GetIdentifierDomainID('ISSN', 1))

	-- Normalize BatchUUID values in IMPORT_Temp table
	UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp SET BatchUUID = dbo.NormalizeUUID(BatchUUID)

	-- Reset Status if @ProcessAll set to True
	IF ISNULL(@ProcessAll, 0) = 1
	BEGIN
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'Unprocessed', Identifier = NULL, RelatedIdentifier = NULL
		WHERE BatchUUID = @BatchUUID AND LEFT(ISNULL(ImportStatus, ''), 11) <> 'BAD RECORD:'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Updated Status to ''In Process'' For @ProcessAll', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @BatchUUID IS NOT NULL
	BEGIN
		-- Process IMPORT_Temp table
		IF (SELECT COUNT(*) FROM BioGUID_IMPORT.dbo.IMPORT_Temp WHERE BatchUUID = @BatchUUID) > 0
		BEGIN
			-- Adjust all cases where RelationshipType = 'Inluded In'
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp SET 
				ObjectClass = RelatedObjectClass, 
				IdentifierDomainUUID = RelatedIdentifierDomainUUID, 
				DereferencePrefix = RelatedDereferencePrefix, 
				DereferenceSuffix = RelatedDereferenceSuffix, 
				Identifier = RelatedIdentifier,
				RelatedObjectClass = ObjectClass, 
				RelatedIdentifierDomainUUID = IdentifierDomainUUID, 
				RelatedDereferencePrefix = DereferencePrefix, 
				RelatedDereferenceSuffix = DereferenceSuffix, 
				RelatedIdentifier = Identifier,
				RelationshipType = 'Includes'
			WHERE RelationshipType = 'Included In'

			-- Convert all empty strings to NULL
			EXEC sp_ConvertCRTABtoSpace @TableName = 'IMPORT_Temp', @DatabaseName = 'BioGUID_IMPORT'
			EXEC sp_ConvertEmptyToNull @TableName = 'IMPORT_Temp', @DatabaseName = 'BioGUID_IMPORT', @TrimValues=1
			
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Converted empty strings to NULL, trimmed values, and removed tabs and carriage returns in IMPORT_Temp table', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Make sure all records are flagged as 'Unprocessed'
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp SET ImportStatus = 'Unprocessed' WHERE BatchUUID = @BatchUUID AND (ImportStatus <> 'Unprocessed' OR ImportStatus IS NULL)
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Established ImportStatus as Unprocessed in IMPORT_Temp table', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Make sure all records without a value for RelationshipType are set to 'Congruent'
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp SET RelationshipType = 'Congruent' WHERE BatchUUID = @BatchUUID AND RelationshipType IS NULL
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Established RelationskipType as Congruent in IMPORT_Temp table', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Verify ObjectClass
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp
			SET ImportStatus = 'BAD RECORD: Unrecognized ObjectClass'
			WHERE BatchUUID = @BatchUUID
				AND ImportStatus = 'Unprocessed'
				AND ObjectClass NOT IN (SELECT E.EnumerationValue FROM BioGUID.dbo.Enumeration AS E INNER JOIN dbo.FullEnumerationChildList(@OCEnumID) AS FECL ON E.EnumerationID = FECL.ChildEnumerationID)
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked IMPORT_Temp for Unrecognized ObjectClass', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp
			SET ImportStatus = 'BAD RECORD: Unrecognized RelatedObjectClass'
			WHERE BatchUUID = @BatchUUID
				AND ImportStatus = 'Unprocessed'
				AND RelatedObjectClass NOT IN (SELECT E.EnumerationValue FROM BioGUID.dbo.Enumeration AS E INNER JOIN dbo.FullEnumerationChildList(@OCEnumID) AS FECL ON E.EnumerationID = FECL.ChildEnumerationID)
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked IMPORT_Temp for Unrecognized RelatedObjectClass', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Verify IdentifierDomainUUID is a UUID
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp
			SET ImportStatus = 'BAD RECORD: IdentifierDomainUUID is not a UUID', IdentifierDomainUUID = '00000000-0000-0000-0000-000000000000'
			WHERE BatchUUID = @BatchUUID
				AND ImportStatus = 'Unprocessed'
				AND dbo.IsUUID(IdentifierDomainUUID) = 0
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked IMPORT_Temp for bad IdentifierDomainUUID', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp
			SET ImportStatus = 'BAD RECORD: RelatedIdentifierDomainUUID is not a UUID', RelatedIdentifierDomainUUID = '00000000-0000-0000-0000-000000000000'
			WHERE BatchUUID = @BatchUUID
				AND ImportStatus = 'Unprocessed'
				AND ISNULL(RelatedIdentifier, '') <> ''
				AND dbo.IsUUID(RelatedIdentifierDomainUUID) = 0
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked IMPORT_Temp for bad RelatedIdentifierDomainUUID', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Verify Identifier is provided
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp
			SET ImportStatus = 'BAD RECORD: No Identifier provided', Identifier = ''
			WHERE BatchUUID = @BatchUUID
				AND ImportStatus = 'Unprocessed'
				AND ISNULL(Identifier, '') = ''
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked IMPORT_Temp for missing Identifier', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Verify RelationshipType
			UPDATE BioGUID_IMPORT.dbo.IMPORT_Temp
			SET ImportStatus = 'BAD RECORD: Unrecognized RelationshipType'
			WHERE BatchUUID = @BatchUUID
				AND ImportStatus = 'Unprocessed'
				AND RelationshipType NOT IN (SELECT E.EnumerationValue FROM BioGUID.dbo.Enumeration AS E INNER JOIN dbo.FullEnumerationChildList(@RTEnumID) AS FECL ON E.EnumerationID = FECL.ChildEnumerationID)
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked IMPORT_Temp for Unrecognized RelationshipType', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Transfer records from Temp table to IMPORT Table
			INSERT INTO BioGUID_IMPORT.dbo.IMPORT(
				BatchUUID,
				ObjectClass,
				IdentifierDomainUUID,
				DereferencePrefix,
				DereferenceSuffix,
				IMPORTIdentifier,
				RelatedObjectClass,
				RelatedIdentifierDomainUUID,
				RelatedDereferencePrefix,
				RelatedDereferenceSuffix,
				IMPORTRelatedIdentifier,
				RelationshipType,
				ImportStatus
			)
			SELECT
				BatchUUID,
				ObjectClass,
				IdentifierDomainUUID,
				DereferencePrefix,
				DereferenceSuffix,
				Identifier,
				RelatedObjectClass,
				RelatedIdentifierDomainUUID,
				RelatedDereferencePrefix,
				RelatedDereferenceSuffix,
				RelatedIdentifier,
				RelationshipType,
				ImportStatus
			FROM BioGUID_IMPORT.dbo.IMPORT_Temp
			WHERE BatchUUID = @BatchUUID
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Transferred records from IMPORT_Temp to IMPORT', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Clear IMPORT_Temp Table
			DELETE BioGUID_IMPORT.dbo.IMPORT_Temp WHERE BatchUUID = @BatchUUID
			-- PerformanceLog
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Removed records from IMPORT_Temp', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

		END

		-- Process IMPORT Table

		-- Flag all records as In-Process
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'In Process'
		WHERE BatchUUID = @BatchUUID
			AND ISNULL(ImportStatus, '') NOT IN('In Process', 'Processed') AND LEFT(ISNULL(ImportStatus, ''), 11) <> 'BAD RECORD:' 
		-- PerformanceLog
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Updated Status to ''In Process''', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Shift RelatedIdentifier over to Identifier, as needed
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET IdentifierDomainUUID = RelatedIdentifierDomainUUID, IMPORTIdentifier = IMPORTRelatedIdentifier, Identifier = RelatedIdentifier, RelatedIdentifierDomainUUID = NULL, IMPORTRelatedIdentifier = NULL, RelatedIdentifier = NULL
		WHERE BatchUUID = @BatchUUID
			AND ISNULL(IdentifiedObjectID, RelatedIdentifiedObjectID) = RelatedIdentifiedObjectID
			AND ISNULL(IdentifierDomainUUID, RelatedIdentifierDomainUUID) = RelatedIdentifierDomainUUID 
			AND (ISNULL(Identifier, RelatedIdentifier) = RelatedIdentifier
				OR ISNULL(IMPORTIdentifier, IMPORTRelatedIdentifier) = IMPORTRelatedIdentifier)

		-- Transfer Identifier and RelatedIdentifier values
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET Identifier = IMPORTIdentifier
		WHERE BatchUUID = @BatchUUID
			AND Identifier IS NULL 
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifier = IMPORTRelatedIdentifier
		WHERE BatchUUID = @BatchUUID
			AND IMPORTRelatedIdentifier IS NOT NULL
			AND RelatedIdentifier IS NULL 
		-- PerformanceLog
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Transferred Identifier and RelatedIdentifier values from Imported values', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
			
		-- Clean Identifier String
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET Identifier = dbo.RemoveWhitespace(Identifier)
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND (Identifier LIKE ' %'
				OR Identifier LIKE '% '
				OR Identifier LIKE '%' + CHAR(9) + '%' 
				OR Identifier LIKE '%' + CHAR(10) + '%' 
				OR Identifier LIKE '%' + CHAR(13) + '%')
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET Identifier = SUBSTRING(Identifier, 2, LEN(Identifier))
		WHERE BatchUUID = @BatchUUID
			AND Identifier LIKE '/%'

		-- Clean RelatedIdentifier String
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifier = dbo.RemoveWhitespace(RelatedIdentifier)
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND (RelatedIdentifier LIKE ' %'
				OR RelatedIdentifier LIKE '% '
				OR RelatedIdentifier LIKE '%' + CHAR(9) + '%' 
				OR RelatedIdentifier LIKE '%' + CHAR(10) + '%' 
				OR RelatedIdentifier LIKE '%' + CHAR(13) + '%'
				OR RelatedIdentifier LIKE '%''%')
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifier = SUBSTRING(RelatedIdentifier, 2, LEN(RelatedIdentifier))
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifier LIKE '/%'
		-- PerformanceLog
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Removed Whitespace, single qoute and leading slash from Identifier String and RelatedIdentifier String', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Parse Identifier when it includes the DereferencePrefix
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET Identifier = SUBSTRING(Identifier, LEN(DereferencePrefix) + 1, LEN(Identifier))
		WHERE 
			BatchUUID = @BatchUUID
			AND Identifier IS NOT NULL
			AND DereferencePrefix IS NOT NULL
			AND LEFT(Identifier, LEN(DereferencePrefix)) = DereferencePrefix
			AND LEN(Identifier) > LEN(DereferencePrefix)
		-- Parse Identifier when it includes the DereferenceSuffix
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET Identifier = SUBSTRING(Identifier, 1, LEN(Identifier) - LEN(DereferenceSuffix))
		WHERE BatchUUID = @BatchUUID
			AND Identifier IS NOT NULL
			AND DereferenceSuffix IS NOT NULL
			AND RIGHT(Identifier, LEN(DereferenceSuffix)) = DereferenceSuffix
			AND LEN(Identifier) > LEN(DereferenceSuffix)

		-- Parse RelatedIdentifier when it includes the RelatedDereferencePrefix
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifier = SUBSTRING(RelatedIdentifier, LEN(RelatedDereferencePrefix) + 1, LEN(RelatedIdentifier))
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifier IS NOT NULL
			AND RelatedDereferencePrefix IS NOT NULL
			AND LEFT(RelatedIdentifier, LEN(RelatedDereferencePrefix)) = RelatedDereferencePrefix
			AND LEN(RelatedIdentifier) > LEN(RelatedDereferencePrefix)
		-- Parse Identifier when it includes the RelatedDereferenceSuffix
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifier = SUBSTRING(RelatedIdentifier, 1, LEN(RelatedIdentifier) - LEN(RelatedDereferenceSuffix))
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifier IS NULL
			AND RelatedDereferenceSuffix IS NOT NULL
			AND RIGHT(RelatedIdentifier, LEN(RelatedDereferenceSuffix)) = RelatedDereferenceSuffix
			AND LEN(RelatedIdentifier) > LEN(RelatedDereferenceSuffix)
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Parsed Identifier and RelatedIdentifier based on DereferencePrefix and DereferenceSuffix', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Look for identifiers with delimiters
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'POSSIBLE multiple Identifiers'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IdentifierDomainUUID <> '220857fb-216b-48e1-8ad7-78ebb34d8f71'
			AND (Identifier LIKE '%|%'
				OR Identifier LIKE '%;%')
--				OR Identifier LIKE '%,%')
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'POSSIBLE multiple RelatedIdentifiers'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IdentifierDomainUUID <> '220857fb-216b-48e1-8ad7-78ebb34d8f71'
			AND (RelatedIdentifier LIKE '%|%'
				OR RelatedIdentifier LIKE '%;%')
--				OR RelatedIdentifier LIKE '%,%')
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Check for POSSIBLE multiple identifiers', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- ==========================================
		-- PROCESS DOIs
		-- ==========================================
		-- Check for DOIs not classified as such
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'POSSIBLE DOI'
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			LEFT OUTER JOIN BioGUID.dbo.PK AS PK ON I.IdentifierDomainUUID = PK.UUID
			LEFT OUTER JOIN BioGUID.dbo.IdentifierDomain AS ID ON PK.PKID = ID.IdentifierDomainID
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND ISNULL(ID.Abbreviation, '') <> 'DOI'
			AND Identifier LIKE '%10[.][0-9][0-9][0-9][0-9]%/%'
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'POSSIBLE Related DOI'
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			LEFT OUTER JOIN BioGUID.dbo.PK AS PK ON I.RelatedIdentifierDomainUUID = PK.UUID
			LEFT OUTER JOIN BioGUID.dbo.IdentifierDomain AS ID ON PK.PKID = ID.IdentifierDomainID
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND ISNULL(ID.Abbreviation, '') <> 'DOI'
			AND RelatedIdentifier LIKE '%10[.][0-9][0-9][0-9][0-9]%/%'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked for POSSIBLE DOI', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Set IdentifierDomain for DOIs
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET IdentifierDomainUUID = @IDDOI
		WHERE BatchUUID = @BatchUUID
			AND Identifier LIKE '10[.][0-9][0-9][0-9][0-9]%/%'
			AND IdentifierDomainUUID <> @IDDOI
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifierDomainUUID = @IDDOI
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifier LIKE '10[.][0-9][0-9][0-9][0-9]%/%'
			AND RelatedIdentifierDomainUUID <> @IDDOI

		-- Clean DOIs
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET Identifier = dbo.NormalizeDOI(Identifier)
		WHERE BatchUUID = @BatchUUID
			AND Identifier NOT LIKE '10[.][0-9][0-9][0-9][0-9]%/%'
			AND IdentifierDomainUUID = @IDDOI
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifier = dbo.NormalizeDOI(RelatedIdentifier)
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifier NOT LIKE '10[.][0-9][0-9][0-9][0-9]%/%'
			AND RelatedIdentifierDomainUUID = @IDDOI
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Cleaned various forms of aberrant DOIs', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Check for bad DOI pattern
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'BAD DOI Pattern'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND Identifier NOT LIKE '10[.][0-9][0-9][0-9][0-9]%/%'
			AND IdentifierDomainUUID = @IDDOI
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'BAD Related DOI Pattern'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND RelatedIdentifier NOT LIKE '10[.][0-9][0-9][0-9][0-9]%/%'
			AND RelatedIdentifierDomainUUID = @IDDOI
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked for BAD DOI Pattern', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- ==========================================
		-- PROCESS ISSNs
		-- ==========================================
		-- Check for ISSNs not classified as such
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'POSSIBLE ISSN'
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			LEFT OUTER JOIN BioGUID.dbo.PK AS PK ON I.IdentifierDomainUUID = PK.UUID
			LEFT OUTER JOIN BioGUID.dbo.IdentifierDomain AS ID ON PK.PKID = ID.IdentifierDomainID
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND ISNULL(ID.Abbreviation, '') <> 'ISSN'
			AND ISNULL(ID.Abbreviation, '') <> 'eISSN'
			AND Identifier LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'POSSIBLE Related ISSN'
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			LEFT OUTER JOIN BioGUID.dbo.PK AS PK ON I.RelatedIdentifierDomainUUID = PK.UUID
			LEFT OUTER JOIN BioGUID.dbo.IdentifierDomain AS ID ON PK.PKID = ID.IdentifierDomainID
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND ISNULL(ID.Abbreviation, '') <> 'ISSN'
			AND ISNULL(ID.Abbreviation, '') <> 'eISSN'
			AND RelatedIdentifier LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked for POSSIBLE ISSN', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Set IdentifierDomain for ISSNs
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET IdentifierDomainUUID = @IDISSN
		WHERE BatchUUID = @BatchUUID
			AND Identifier LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
			AND IdentifierDomainUUID <> @IDISSN
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifierDomainUUID = @IDISSN
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifier LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
			AND RelatedIdentifierDomainUUID <> @IDISSN

		-- Clean ISSNs
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET Identifier = dbo.NormalizeISSN(Identifier)
		WHERE BatchUUID = @BatchUUID
			AND Identifier NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
			AND IdentifierDomainUUID = @IDISSN
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifier = dbo.NormalizeISSN(RelatedIdentifier)
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifier NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
			AND RelatedIdentifierDomainUUID = @IDISSN
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Cleaned various forms of aberrant ISSNs', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Check for bad ISSN pattern
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'BAD ISSN Pattern'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND RelatedIdentifier NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
			AND RelatedIdentifierDomainUUID = @IDISSN
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'BAD Related ISSN Pattern'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND RelatedIdentifier NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9X]'
			AND RelatedIdentifierDomainUUID = @IDISSN
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Checked for BAD ISSN Pattern', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- ==========================================
		-- PROCESS IdentifierDomains
		-- ==========================================
		-- Flag Missing IdentifierDomainUUID
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'MISSING IdentifierDomainUUID'
		WHERE BatchUUID = @BatchUUID
			AND IdentifierDomainUUID IS NULL
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'MISSING Related IdentifierDomainUUID'
		WHERE BatchUUID = @BatchUUID
			AND RelatedIdentifierDomainUUID IS NULL
			AND RelatedIdentifier IS NOT NULL

		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'MISSING Identifier'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND Identifier IS NULL
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'MISSING RelatedIdentifier'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND RelatedIdentifier IS NULL
			AND RelatedIdentifierDomainUUID IS NOT NULL
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Check for MISSING IdentifierDomainUUID and Identifier values', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Capture IdentifierDomainID and RelatedIdentifierDomainID
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET IdentifierDomainID = PK.PKID
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			INNER JOIN BioGUID.dbo.PK AS PK ON I.IdentifierDomainUUID = PK.UUID
		WHERE BatchUUID = @BatchUUID
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'BAD IdentifierDomain'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IdentifierDomainID IS NULL
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET RelatedIdentifierDomainID = PK.PKID
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			INNER JOIN BioGUID.dbo.PK AS PK ON I.RelatedIdentifierDomainUUID = PK.UUID
		WHERE BatchUUID = @BatchUUID
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'BAD RelatedIdentifierDomain'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND RelatedIdentifierDomainID IS NULL
			AND RelatedIdentifierDomainUUID IS NOT NULL

		-- ==========================================
		-- PROCESS Duplicate entries
		-- ==========================================
		-- Search for Duplicate records
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'DUPLICATE Record'
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IMPORTID IN
			(
			SELECT IMPORTID
			FROM BioGUID_IMPORT.dbo.IMPORT AS I
				INNER JOIN
					(
					SELECT IdentifierDomainUUID, Identifier, IdentifiedObjectID
					FROM BioGUID_IMPORT.dbo.IMPORT
					WHERE ImportStatus = 'In Process'
						AND BatchUUID=@BatchUUID
						AND IdentifierDomainUUID IS NOT NULL 
						AND Identifier IS NOT NULL
						AND RelatedIdentifierDomainUUID IS NULL 
						AND RelatedIdentifier IS NULL
					GROUP BY IdentifierDomainUUID, Identifier, IdentifiedObjectID
					HAVING COUNT(*) > 1
					) AS Dupe ON I.IdentifierDomainUUID = Dupe.IdentifierDomainUUID AND I.Identifier = Dupe.Identifier AND ISNULL(I.IdentifiedObjectID, 0) = ISNULL(Dupe.IdentifiedObjectID, 0)
			)
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'DUPLICATE Related Record'
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IMPORTID IN
			(
			SELECT IMPORTID
			FROM BioGUID_IMPORT.dbo.IMPORT AS I
				INNER JOIN
					(
					SELECT IdentifierDomainUUID, Identifier, IdentifiedObjectID, RelatedIdentifierDomainUUID, RelatedIdentifier, RelatedIdentifiedObjectID
					FROM BioGUID_IMPORT.dbo.IMPORT
					WHERE ImportStatus = 'In Process'
						AND BatchUUID=@BatchUUID
						AND IdentifierDomainUUID IS NOT NULL 
						AND Identifier IS NOT NULL
						AND RelatedIdentifierDomainUUID IS NOT NULL 
						AND RelatedIdentifier IS NOT NULL
					GROUP BY IdentifierDomainUUID, Identifier, IdentifiedObjectID, RelatedIdentifierDomainUUID, RelatedIdentifier, RelatedIdentifiedObjectID
					HAVING COUNT(*) > 1
					) AS Dupe ON I.IdentifierDomainUUID = Dupe.IdentifierDomainUUID AND I.Identifier = Dupe.Identifier AND I.RelatedIdentifierDomainUUID = Dupe.RelatedIdentifierDomainUUID AND I.RelatedIdentifier = Dupe.RelatedIdentifier AND ISNULL(I.IdentifiedObjectID, 0) = ISNULL(Dupe.IdentifiedObjectID, 0) AND ISNULL(I.RelatedIdentifiedObjectID, 0) = ISNULL(Dupe.RelatedIdentifiedObjectID, 0)
			)
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Check for DUPLICATE Identifier', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Revert Status for first record of each duplicate set
		-- Capture the first record of each duplicate
		INSERT INTO @IDList (PKID, TableName)
		SELECT MIN(IMPORTID), 'RevertDuplicate'
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE ImportStatus IN('DUPLICATE Identifier', 'DUPLICATE Related Record')
			AND BatchUUID = @BatchUUID
		GROUP BY IdentifierDomainUUID, Identifier, RelatedIdentifierDomainUUID, RelatedIdentifier
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'In Process'
		FROM BioGUID_IMPORT.dbo.IMPORT AS I INNER JOIN @IDList AS IDL ON I.IMPORTID = IDL.PKID
		WHERE TableName = 'RevertDuplicate'
		DELETE @IDList WHERE TableName = 'RevertDuplicate'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Reset first record of each duplicate set', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- ==========================================
		-- PROCESS Objects
		-- ==========================================
		-- Check for IdentifiedObjectID
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET IdentifiedObjectID = I.IdentifiedObjectID
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I ON II.IdentifierDomainID = I.IdentifierDomainID AND I.Identifier = II.Identifier
		WHERE II.BatchUUID = @BatchUUID
			AND II.IdentifiedObjectID IS NULL
			AND II.ImportStatus = 'In Process'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Searched for matching Identified Objects', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Check for RelatedIdentifiedObjectID
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET RelatedIdentifiedObjectID = I.IdentifiedObjectID
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I ON II.RelatedIdentifierDomainID = I.IdentifierDomainID AND II.RelatedIdentifier = I.Identifier
		WHERE II.BatchUUID = @BatchUUID
			AND II.RelatedIdentifiedObjectID IS NULL
			AND II.ImportStatus = 'In Process'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Searched for matching Related Identified Objects', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Make sure all records with an IdentifiedObjectID propagate among identical Identifiers
		UPDATE I SET I.IdentifiedObjectID = I2.IdentifiedObjectID
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			INNER JOIN BioGUID_IMPORT.dbo.IMPORT AS I2 ON I.IdentifierDomainUUID = I2.IdentifierDomainUUID AND I.Identifier = I2.Identifier
		WHERE I.BatchUUID = @BatchUUID
			AND I2.BatchUUID = @BatchUUID
			AND I.ImportStatus = 'In Process'
			AND I2.ImportStatus = 'In Process'
			AND I.IdentifiedObjectID IS NULL 
			AND I2.IdentifiedObjectID IS NOT NULL
		UPDATE I SET I.RelatedIdentifiedObjectID = I2.RelatedIdentifiedObjectID
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			INNER JOIN BioGUID_IMPORT.dbo.IMPORT AS I2 ON I.RelatedIdentifierDomainUUID = I2.RelatedIdentifierDomainUUID AND I.RelatedIdentifier = I2.RelatedIdentifier
		WHERE I.BatchUUID = @BatchUUID
			AND I2.BatchUUID = @BatchUUID
			AND I.ImportStatus = 'In Process'
			AND I2.ImportStatus = 'In Process'
			AND I.RelatedIdentifiedObjectID IS NULL 
			AND I2.RelatedIdentifiedObjectID IS NOT NULL
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Propagated IdentifiedObjectID and RelatedIdentifiedObjectID values', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Synchronize RelatedIdentfifiedObjectID and IdentfifiedObjectID for Congruent
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET IdentifiedObjectID = RelatedIdentifiedObjectID
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IdentifiedObjectID IS NULL 
			AND RelatedIdentifiedObjectID IS NOT NULL
			AND RelationshipType = 'Congruent'
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET RelatedIdentifiedObjectID = IdentifiedObjectID
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IdentifiedObjectID IS NOT NULL 
			AND RelatedIdentifiedObjectID IS NULL
			AND RelatedIdentifierDomainID IS NOT NULL 
			AND RelatedIdentifier IS NOT NULL
			AND RelationshipType = 'Congruent'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Synchronize RelatedIdentfifiedObjectID and IdentfifiedObjectID for Congruent records', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Check for identical IdentfifiedObjectID and RelatedIdentfifiedObjectID for non-Congruent records
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET ImportStatus = 'IDENTICAL IdentifiedObject and Related Object for non-Congruent records!'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IdentifiedObjectID = RelatedIdentifiedObjectID
			AND RelationshipType <> 'Congruent'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Check for identical IdentfifiedObjectID and RelatedIdentfifiedObjectID for non-Congruent records', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Synchronize RelatedObjectClass and IdentfifiedObjectClass
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET ObjectClass = RelatedObjectClass
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND ObjectClass IS NULL 
			AND RelatedObjectClass IS NOT NULL
			AND RelationshipType = 'Congruent'
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET RelatedObjectClass = ObjectClass
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND ObjectClass IS NOT NULL 
			AND RelatedObjectClass IS NULL
			AND RelationshipType = 'Congruent'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Synchronize RelatedObjectClass and IdentfifiedObjectClass for Congruent records', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Search for Mismatched ObjectClass and RelatedObjectClass for Congruent
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET ImportStatus = 'MISMATCHED IdentifiedObjectClass'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND ISNULL(ObjectClass, '') <> ISNULL(RelatedObjectClass, '')
			AND RelationshipType = 'Congruent'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Search for Mismatched ObjectClass and RelatedObjectClass for Congruent records', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Search for Inconsistent Object Classes for each IdentifiedObjectID
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'INCONSISTENT ObjectClass'
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND IdentifiedObjectID IN
				(
				SELECT IdentifiedObjectID
				FROM
					(
					SELECT DISTINCT IdentifiedObjectID, ObjectClass
					FROM BioGUID_IMPORT.dbo.IMPORT
					WHERE BatchUUID = @BatchUUID
						AND ImportStatus = 'In Process'
					) AS SRC
				GROUP BY IdentifiedObjectID
				HAVING COUNT(*) > 1
				)
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'INCONSISTENT RelatedObjectClass'
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
			AND RelatedIdentifiedObjectID IN
				(
				SELECT RelatedIdentifiedObjectID
				FROM
					(
					SELECT DISTINCT RelatedIdentifiedObjectID, RelatedObjectClass
					FROM BioGUID_IMPORT.dbo.IMPORT
					WHERE BatchUUID = @BatchUUID
						AND ImportStatus = 'In Process'
					) AS SRC
				GROUP BY RelatedIdentifiedObjectID
				HAVING COUNT(*) > 1
				)
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Check for INCONSISTENT ObjectClass', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Flag Duplicate Objects
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'DUPLICATE Object'
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I 
				ON II.IdentifierDomainID = I.IdentifierDomainID 
					AND II.IdentifiedObjectID = I.IdentifiedObjectID 
					AND II.Identifier = I.Identifier
			INNER JOIN BioGUID.dbo.Identifier AS I2
				ON II.RelatedIdentifierDomainID = I2.IdentifierDomainID 
					AND II.RelatedIdentifiedObjectID = I2.IdentifiedObjectID 
					AND II.RelatedIdentifier = I2.Identifier
		WHERE II.BatchUUID = @BatchUUID
			AND II.ImportStatus = 'In Process'
			AND II.IdentifiedObjectID <> II.RelatedIdentifiedObjectID
			AND II.RelationshipType = 'Congruent'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Searched for DuplicateObjects', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Flag identifiers that are already in BioGUID
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'Previously Imported (Primary)'
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I 
				ON II.IdentifierDomainID = I.IdentifierDomainID 
					AND II.IdentifiedObjectID = I.IdentifiedObjectID 
					AND II.Identifier = I.Identifier
		WHERE II.BatchUUID = @BatchUUID
			AND II.ImportStatus = 'In Process'
			AND ISNULL(II.RelatedIdentifiedObjectID, II.IdentifiedObjectID) = II.IdentifiedObjectID
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Searched for matching Identifiers already in BioGUID', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Flag related identifiers that are already in BioGUID
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = CASE WHEN ImportStatus = 'In Process' THEN 'Previously Imported (Related)' ELSE 'Imported' END
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I 
				ON II.RelatedIdentifierDomainID = I.IdentifierDomainID 
					AND II.RelatedIdentifiedObjectID = I.IdentifiedObjectID 
					AND II.RelatedIdentifier = I.Identifier
		WHERE II.BatchUUID = @BatchUUID
			AND II.ImportStatus IN ('In Process', 'Previously Imported (Primary)')
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Searched for matching Identifiers already in BioGUID', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- ==========================================
		-- PROCESS Completion
		-- ==========================================
		-- Update Status of completed records
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'Processed'
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus = 'In Process'
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Updated Status to ''Processed''', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Return Status Report
		EXEC sp_GetStatistics @ResultType='ImportBatch', @BatchUUID = @BatchUUID
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Returned Status Report', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END

	IF @RS = 1
		SELECT @SessionID AS SessionID, 'Complete' AS ProcessStatus, (SELECT COUNT(*) FROM BioGUID_IMPORT.dbo.IMPORT WHERE BatchUUID = @BatchUUID AND ImportStatus = 'Processed') AS ProcessedRecords, (SELECT COUNT(*) FROM BioGUID_IMPORT.dbo.IMPORT WHERE BatchUUID = @BatchUUID AND ISNULL(ImportStatus, '') <> 'Processed') AS ProblemRecords, DATEDIFF(ms, @T0, GETUTCDATE()) AS Duration

	EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierProcess', @Task = 'Procedure Completed', @RecordCount = 0, @StartTime = @T0, @EndTime=NULL

-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_IMPORTIdentifierTransfer]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 28 February 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Processes records in IMPORT Table in preparation for importing.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_IMPORTIdentifierTransfer] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@BatchUUID			varchar(36)	= NULL,
	@SessionID			uniqueidentifier	= NULL,
	@LogUserName		nvarchar(128)		= 'deepreef',
	@RS					bit					= 0,
	@Debug				bit					= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @TableID AS int
	DECLARE @OCEID AS int
	DECLARE @RTEnumID AS int = 0
	DECLARE @LastID AS bigint
	DECLARE @NewID AS TABLE (ID int IDENTITY(1,1), ImportID bigint, IdentifiedObjectID bigint, ObjectClassID int, IsRelated bit)
	DECLARE @Import AS TABLE (IdentifierDomainID int NOT NULL, IdentifiedObjectID bigint NOT NULL, Identifier varchar(255) NOT NULL PRIMARY KEY (IdentifierDomainID, IdentifiedObjectID, Identifier))
	DECLARE @IDList AS PKIDListType
	DECLARE @StartTime		datetime			= GETUTCDATE()
	DECLARE @T0 AS datetime = @StartTime
	DECLARE @RecordCount	AS int
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Normalize @BatchUUID
	SET @BatchUUID = dbo.NormalizeUUID(@BatchUUID)

	-- Get SchemaItemID for Object Table
	SET @TableID = dbo.GetSchemaItemID('IdentifiedObject',-1,'Table')

	-- Get @OCEID for ObjectClasses enumeration
	SET @OCEID = dbo.GetEnumerationID('ObjectClasses', NULL)

	-- Get RelationshipTypes EnumerationType
	SET @RTEnumID = dbo.GetEnumerationID('RelationshipTypes', NULL)

	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @BatchUUID IS NOT NULL
	BEGIN
		-- ====================================
		-- Merge Duplicate Object ID values 
		-- ====================================
		EXEC sp_IMPORTDuplicateObjects @BatchUUID = @BatchUUID, @SessionID = @SessionID, @LogUserName = @LogUserName, @Debug = @Debug

		-- ====================================
		-- Update Status of Already Existing Identifiers
		-- ====================================
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET ImportStatus = 'Previously Imported (Both)'
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I 
				ON II.IdentifierDomainID = I.IdentifierDomainID
					AND II.IdentifiedObjectID = I.IdentifiedObjectID
					AND II.Identifier = I.Identifier
			INNER JOIN BioGUID.dbo.Identifier AS I2
				ON II.RelatedIdentifierDomainID = I2.IdentifierDomainID
					AND II.RelatedIdentifiedObjectID = I2.IdentifiedObjectID
					AND II.RelatedIdentifier = I2.Identifier
		WHERE BatchUUID = @BatchUUID
			AND II.ImportStatus NOT LIKE '%Imported%'

		UPDATE BioGUID_IMPORT.dbo.IMPORT SET ImportStatus = 'Previously Imported (Primary)'
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I 
				ON II.IdentifierDomainID = I.IdentifierDomainID
					AND II.IdentifiedObjectID = I.IdentifiedObjectID
					AND II.Identifier = I.Identifier
		WHERE BatchUUID = @BatchUUID
			AND II.ImportStatus NOT LIKE '%Imported%'
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET ImportStatus = 'Previously Imported (Related)'
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Identifier AS I 
				ON II.RelatedIdentifierDomainID = I.IdentifierDomainID
					AND II.RelatedIdentifiedObjectID = I.IdentifiedObjectID
					AND II.RelatedIdentifier = I.Identifier
		WHERE BatchUUID = @BatchUUID
			AND II.ImportStatus <> 'Imported'


		-- ====================================
		-- Generate IdentifiedObjectID values 
		-- ====================================
		-- Create temporary Object rows for identifiers as needed
		INSERT INTO @NewID(I.IMPORTID, ObjectClassID, IsRelated)
		SELECT I.IMPORTID, ISNULL(E.EnumerationID, 0), 0
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			LEFT OUTER JOIN BioGUID.dbo.Enumeration AS E ON I.ObjectClass = E.EnumerationValue
		WHERE BatchUUID = @BatchUUID
			AND I.IdentifiedObjectID IS NULL
			AND I.IdentifierDomainUUID IS NOT NULL
			AND I.Identifier IS NOT NULL
			AND I.ImportStatus IN('Processed', 'Previously Imported (Related)')
			AND ISNULL(E.EnumerationTypeID, @OCEID) = @OCEID

		SELECT @RecordCount = COUNT(*) FROM @NewID
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Populated @NewID Table from Primary Identifiers', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Create temporary Object rows for Relatedidentifiers as needed
		INSERT INTO @NewID(I.IMPORTID, ObjectClassID, IsRelated)
		SELECT I.IMPORTID, ISNULL(E.EnumerationID, 0), 1
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			LEFT OUTER JOIN BioGUID.dbo.Enumeration AS E ON I.RelatedObjectClass = E.EnumerationValue
		WHERE BatchUUID = @BatchUUID
			AND I.IdentifiedObjectID IS NOT NULL
			AND I.RelatedIdentifiedObjectID IS NULL
			AND I.RelatedIdentifierDomainUUID IS NOT NULL
			AND I.RelatedIdentifier IS NOT NULL
			AND I.ImportStatus IN('Processed', 'Previously Imported (Primary)')
			AND ISNULL(E.EnumerationTypeID, @OCEID) = @OCEID

		SELECT @RecordCount = COUNT(*) FROM @NewID
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Populated @NewID Table from Related Identifiers', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Get the last IdentifiedObjectID Value
		SELECT @LastID = MAX(IdentifiedObjectID) FROM BioGUID.dbo.IdentifiedObject

		-- Set the IdentifiedObjectID values in @NewID 
		UPDATE @NewID SET IdentifiedObjectID = ID + @LastID

		-- Generate the Object records
		IF ISNULL(@Debug, 0) = 1
		BEGIN
			SELECT 'New Object Record' AS RecordSet, * FROM @NewID
		END
		ELSE
		BEGIN
			SET IDENTITY_INSERT BioGUID.dbo.IdentifiedObject ON
			INSERT INTO BioGUID.dbo.IdentifiedObject (IdentifiedObjectID, ObjectClassID)
			SELECT DISTINCT IdentifiedObjectID, ObjectClassID FROM @NewID
			SET IDENTITY_INSERT BioGUID.dbo.IdentifiedObject OFF
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Generated new IdentifiedObject records', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		-- Transfer the new IdentifiedObjectID values to the Import table
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET IdentifiedObjectID = N.IdentifiedObjectID, RelatedIdentifiedObjectID = ISNULL(RelatedIdentifiedObjectID, N.IdentifiedObjectID)
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			INNER JOIN @NewID AS N ON I.IMPORTID = N.IMPORTID
		WHERE I.IdentifiedObjectID IS NULL
			AND N.IsRelated = 0
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Transferred IdentifiedObjectID values to IMPORT table', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Transfer the new Related IdentifiedObjectID values to the Import table
		UPDATE BioGUID_IMPORT.dbo.IMPORT SET RelatedIdentifiedObjectID = N.IdentifiedObjectID
		FROM BioGUID_IMPORT.dbo.IMPORT AS I
			INNER JOIN @NewID AS N ON I.IMPORTID = N.IMPORTID
		WHERE I.RelatedIdentifiedObjectID IS NULL
			AND N.IsRelated = 1
		-- Performance Log
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Transferred Related IdentifiedObjectID values to IMPORT table', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- ====================================
		-- Generate the Identifier records
		-- ====================================

		-- Capture Identifiers into @Import Table
		INSERT INTO @Import(IdentifierDomainID, IdentifiedObjectID, Identifier)
		SELECT DISTINCT IdentifierDomainID, IdentifiedObjectID, Identifier
		FROM BioGUID_IMPORT.dbo.IMPORT
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus IN('Processed', 'Previously Imported (Related)')
			AND IdentifierDomainID IS NOT NULL
			AND IdentifiedObjectID IS NOT NULL
			AND Identifier IS NOT NULL

		-- Capture RelatedIdentifiers into @Import Table
		INSERT INTO @Import(IdentifierDomainID, IdentifiedObjectID, Identifier)
		SELECT DISTINCT II.RelatedIdentifierDomainID, II.RelatedIdentifiedObjectID, II.RelatedIdentifier
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			LEFT OUTER JOIN @Import AS I
				ON II.RelatedIdentifierDomainID = I.IdentifierDomainID
					AND II.RelatedIdentifiedObjectID = I.IdentifiedObjectID 
						AND II.RelatedIdentifier = I.Identifier
		WHERE BatchUUID = @BatchUUID
			AND ImportStatus IN('Processed', 'Previously Imported (Primary)')
			AND RelatedIdentifierDomainID IS NOT NULL
			AND RelatedIdentifiedObjectID IS NOT NULL
			AND RelatedIdentifier IS NOT NULL
			AND I.IdentifierDomainID IS NULL
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Identifiers transferred to @Import', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Remove Identifiers that already exist
		DELETE @Import
		FROM @Import AS II
			INNER JOIN BioGUID.dbo.Identifier AS I
				ON II.IdentifierDomainID = I.IdentifierDomainID
					AND II.IdentifiedObjectID = I.IdentifiedObjectID 
						AND II.Identifier = I.Identifier
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Existing Identifiers removed from @Import', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Insert Identifiers
		IF ISNULL(@Debug, 0) = 1
			SELECT 'New Identifier' AS Recordset, * FROM @Import
		ELSE
		BEGIN
			INSERT INTO BioGUID.dbo.Identifier (IdentifierDomainID, IdentifiedObjectID, Identifier)
			SELECT DISTINCT I.IdentifierDomainID, I.IdentifiedObjectID, I.Identifier
			FROM @Import AS I
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Insert New Identifiers', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		-- Update Status
		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'Imported' + CASE WHEN ISNULL(@Debug, 0) = 1 THEN ' [DEBUG: ' + ImportStatus ELSE '' END
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN @Import AS I
				ON II.IdentifierDomainID = I.IdentifierDomainID
					AND II.IdentifiedObjectID = I.IdentifiedObjectID 
						AND II.Identifier = I.Identifier
			INNER JOIN @Import AS I2
				ON ISNULL(II.RelatedIdentifierDomainID, I2.IdentifierDomainID) = I2.IdentifierDomainID
					AND ISNULL(II.RelatedIdentifiedObjectID, I2.IdentifiedObjectID) = I2.IdentifiedObjectID 
						AND ISNULL(II.RelatedIdentifier, I2.Identifier) = I2.Identifier

		UPDATE BioGUID_IMPORT.dbo.IMPORT
		SET ImportStatus = 'Previously Imported' + CASE WHEN ISNULL(@Debug, 0) = 1 THEN ' [DEBUG: ' + ImportStatus ELSE '' END
		WHERE ImportStatus IN('Previously Imported (Primary)', 'Previously Imported (Related)', 'Previously Imported (Both)')
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Update Status for Previously Imported Identifiers', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		-- Update Cache
		IF ISNULL(@Debug, 0) = 1
			SELECT 'Cache Update' AS Recordset, * FROM @Import
		ELSE
		BEGIN
			EXEC BioGUID.dbo.sp_CreateCache @BatchUUID = @BatchUUID, @SessionID = @SessionID

			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Cache Updated', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

		-- Create ResourceRelationship Records for non-Congruent records, which don't already exist
		INSERT INTO BioGUID.dbo.ResourceRelationship(
			ObjectID,
			RelatedObjectID,
			RelationshipID,
			RelationshipAccordingToUUID,
			RelationshipRemarks
		)
		SELECT DISTINCT 
			II.IdentifiedObjectID,
			II.RelatedIdentifiedObjectID,
			E.EnumerationID,
			@BatchUUID,
			'AccordingToUUID refers to IMPORT BatchUUID, processed ' + CAST(GETUTCDATE() as nvarchar(255)) + ' (UTC).'
		FROM BioGUID_IMPORT.dbo.IMPORT AS II
			INNER JOIN BioGUID.dbo.Enumeration AS E ON II.RelationshipType = E.EnumerationValue 
			INNER JOIN dbo.FullEnumerationChildList(@RTEnumID) AS FECL ON E.EnumerationTypeID = FECL.ChildEnumerationID
			LEFT OUTER JOIN BioGUID.dbo.ResourceRelationship AS RR ON II.IdentifiedObjectID = RR.ObjectID AND II.RelatedIdentifiedObjectID = RR.RelatedObjectID AND II.BatchUUID = RR.RelationshipAccordingToUUID
		WHERE BatchUUID = @BatchUUID
			AND II.IdentifiedObjectID IS NOT NULL
			AND II.RelatedIdentifiedObjectID IS NOT NULL
			AND II.RelationshipType <> 'Congruent'
			AND RR.ResourceRelationshipID IS NULL

		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Create ResourceRelationship Records for non-Congruent records', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()


		-- Return Status Report
		IF @RS = 1
		BEGIN
			SELECT ImportStatus, COUNT(*) AS RecordCount
			FROM BioGUID_IMPORT.dbo.IMPORT
			WHERE BatchUUID = @BatchUUID
			GROUP BY ImportStatus

			SELECT @RecordCount = COUNT(*) FROM BioGUID_IMPORT.dbo.IMPORT WHERE BatchUUID = @BatchUUID
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Returned Status Report', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END
		-- Clean up Debug Values
		IF ISNULL(@Debug, 0) = 1
		BEGIN

			SELECT 'Preview Records' AS RecordSet, * FROM BioGUID_IMPORT.dbo.IMPORT WHERE BatchUUID=@BatchUUID
			
			UPDATE BioGUID_IMPORT.dbo.IMPORT SET IdentifiedObjectID = NULL, RelatedIdentifiedObjectID = NULL
			FROM BioGUID_IMPORT.dbo.IMPORT AS I
				INNER JOIN @NewID AS N ON I.IMPORTID = N.IMPORTID AND I.IdentifiedObjectID = N.IdentifiedObjectID AND I.RelatedIdentifiedObjectID = ISNULL(I.RelatedIdentifiedObjectID, N.IdentifiedObjectID)
			WHERE N.IsRelated = 0
			UPDATE BioGUID_IMPORT.dbo.IMPORT SET RelatedIdentifiedObjectID = NULL
			FROM BioGUID_IMPORT.dbo.IMPORT AS I
				INNER JOIN @NewID AS N ON I.IMPORTID = N.IMPORTID AND I.RelatedIdentifiedObjectID = N.IdentifiedObjectID
			WHERE N.IsRelated = 1

			UPDATE BioGUID_IMPORT.dbo.IMPORT
			SET ImportStatus = LTRIM(RTRIM(SUBSTRING(ImportStatus, CHARINDEX('DEBUG:', ImportStatus) + 6, LEN(ImportStatus))))
			WHERE ImportStatus LIKE '%DEBUG:%'
		END

	END

	EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_IMPORTIdentifierTransfer', @Task = 'Procedure Completed', @RecordCount = 0, @StartTime = @T0, @EndTime=NULL
	
	-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_InsertDereferenceService]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 Feb 2015
-- DESCRIPTION:
--		Inserts a new DereferenceService
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_InsertDereferenceService] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@Protocol			nvarchar(255)	= N'',
	@DereferenceService	nvarchar(255)	= N'',
	@DereferencePrefix	nvarchar(255)	= N'',
	@DereferenceSuffix	nvarchar(255)	= N'',
	@IdentifierDomain	nvarchar(255)	= N'',
	@Description			nvarchar(255)	= N'',
	@Logo					nvarchar(255)	= N'',
	@LogUserName			nvarchar(128)	= N'Anonymous',
	@SessionID				uniqueidentifier	= NULL,
	@DoLog					bit				= 1,
	@RS						bit				= 1,
	@DereferenceServiceID	int				= 0		OUTPUT,
	@DereferenceServiceUUID	varchar(36)		= ''	OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IsUpdate							bit				= 0 -- Indicates whether this should be treated as an Update
	DECLARE @ProtocolPKID						int				= -1
	DECLARE @IdentifierDomainPKID				int				= 0
	DECLARE @StartTime							datetime		= NULL
	DECLARE @OUT								nvarchar(MAX)	= N''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Establish Performance Log variables
	IF @DoLog = 1
	BEGIN
		SET @StartTime = GETUTCDATE()
		IF @SessionID IS NULL
			SET @SessionID = NEWID()
	END

	-- Convert @DereferenceServiceUUID to @DereferenceServiceID
	SET @DereferenceServiceUUID = dbo.NormalizeUUID(@DereferenceServiceUUID)
	IF dbo.IsUUID(@DereferenceServiceUUID) = 1
		SET @DereferenceServiceID = ISNULL(dbo.GetDereferenceServiceID(@DereferenceServiceUUID, 1), 0)
	ELSE
		SET @DereferenceServiceUUID = ''

	-- Check to see if it already exists based on either @DereferenceService or @DereferencePrefix
	IF ISNULL(@DereferenceServiceID, 0) = 0
	BEGIN
		IF ISNULL(@DereferenceService, '') <> ''
			SET @DereferenceServiceID = ISNULL(dbo.GetDereferenceServiceID(@DereferenceService, 1), 0)
		IF ISNULL(@DereferencePrefix, '') <> '' AND ISNULL(@DereferenceServiceID, 0) = 0
			SET @DereferenceServiceID = ISNULL(dbo.GetDereferenceServiceID(@DereferencePrefix + '|' + ISNULL(@DereferenceSuffix, ''), 1), 0)
	END

	-- Get Protocol
	IF ISNULL(@Protocol, '') <> ''
		SET @ProtocolPKID = dbo.GetEnumerationID(@Protocol, 'DereferenceProtocols')
	
	-- Get @IdentifierDomainPKID
	SET @IdentifierDomainPKID = ISNULL(dbo.GetIdentifierDomainID(@IdentifierDomain, 1), 0)

	SET @IsUpdate = CAST(ISNULL(@DereferenceServiceID, 0) AS bit)		

	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertDereferenceService', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END

-- =============================================================================
-- Operational Code
-- =============================================================================
	-- Check to see if it's an Insert
	IF @IsUpdate = 0
	BEGIN
		-- Only proceed if legitimate values have been provided and if an existing record doesn't already exist
		IF ISNULL(@DereferenceService, '') <> '' AND ISNULL(@OUT, N'') = N'' AND ISNULL(@LogUserName, N'') <> N'' AND ISNULL(@Logo, N'') <> N'' 
		AND NOT EXISTS(SELECT DereferenceServiceID FROM BioGUID.dbo.DereferenceService WHERE DereferenceService = @DereferenceService OR (DereferencePrefix = @DereferencePrefix AND (DereferenceSuffix = @DereferenceSuffix OR (ISNULL(@DereferenceSuffix, N'') = N'' AND DereferenceSuffix IS NULL))))
		BEGIN
			-- Generate a new PKID for the new DereferenceService
			EXEC sp_NewPKID
				@TableName = 'DereferenceService',
				@PKID = @DereferenceServiceID		OUTPUT,
				@UUID = @DereferenceServiceUUID	OUTPUT

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertDereferenceService', @Task = 'Generated New PKID', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
			
			-- Adjust Logged UserName
			EXEC sp_AdjustCreatedUsername
				@PKID = @DereferenceServiceID,
				@LogUserName = @LogUserName

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertDereferenceService', @Task = 'Adjusted Logged Username', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

			-- Insert New Record
			INSERT INTO BioGUID.dbo.DereferenceService
				(
				DereferenceServiceID,
				ProtocolID,
				DereferenceService,
				DereferencePrefix,
				DereferenceSuffix,
				[Description],
				Logo
				)
			VALUES
				(
				@DereferenceServiceID,
				ISNULL(NULLIF(@ProtocolPKID,-1),0),
				@DereferenceService,
				NULLIF(@DereferencePrefix, N''),
				NULLIF(@DereferenceSuffix, N''),
				NULLIF(@Description, N''),
				NULLIF(@Logo, '')
				)

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertDereferenceService', @Task = 'Generated New DereferenceService Record', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

		END
		ELSE
		BEGIN
			IF ISNULL(@DereferenceService, '') = ''
				SET @OUT = @OUT + N'DereferenceService not provided.'
			IF ISNULL(@LogUserName, '') = ''
				SET @OUT = @OUT + N'LogUserName not provided. '
			IF ISNULL(@Logo, '') = ''
				SET @OUT = @OUT + N'Logo not provided. '
			IF EXISTS(SELECT * FROM BioGUID.dbo.DereferenceService WHERE DereferenceService = @DereferenceService)
				SET @OUT = @OUT + N'Provided DereferenceService ''' + @DereferenceService + N''' already exists.'
			IF EXISTS(SELECT * FROM BioGUID.dbo.DereferenceService WHERE (DereferencePrefix = @DereferencePrefix AND (DereferenceSuffix = @DereferenceSuffix OR (ISNULL(@DereferenceSuffix, '') = '' AND DereferenceSuffix IS NULL))))
				SET @OUT = @OUT + N'Provided DereferencePrefix ''' + @DereferencePrefix + N''' ' + CASE WHEN ISNULL(@DereferenceSuffix, N'') = N'' THEN N'' ELSE N'and Dereference Suffix ''' + @DereferenceSuffix + N''' ' END + N'already exists.'
			IF ISNULL(@OUT, '') = ''
				SET @OUT = 'Unspecified Error. '
		END

	END
	ELSE
	BEGIN
		-- Check for Orphan Record
		IF EXISTS(SELECT * FROM BioGUID.dbo.DereferenceService WHERE DereferenceServiceID = @DereferenceServiceID)
		BEGIN
			-- Update Indicated Record
			IF ISNULL(@ProtocolPKID, -1) <> -1
				EXEC sp_EditValue @PKID=@DereferenceServiceID, @TableName='DereferenceService', @FieldName='ProtocolID', @Value=@ProtocolPKID, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF ISNULL(@DereferenceService, '') <> ''
				EXEC sp_EditValue @PKID=@DereferenceServiceID, @TableName='DereferenceService', @FieldName='DereferenceService', @Value=@DereferenceService, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF ISNULL(@DereferencePrefix, '') <> ''
				EXEC sp_EditValue @PKID=@DereferenceServiceID, @TableName='DereferenceService', @FieldName='DereferencePrefix', @Value=@DereferencePrefix, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF ISNULL(@DereferenceSuffix, '') <> ''
				EXEC sp_EditValue @PKID=@DereferenceServiceID, @TableName='DereferenceService', @FieldName='DereferenceSuffix', @Value=@DereferenceSuffix, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF ISNULL(@Description, '') <> ''
				EXEC sp_EditValue @PKID=@DereferenceServiceID, @TableName='DereferenceService', @FieldName='Description', @Value=@Description, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF ISNULL(@Logo, '') <> ''
				EXEC sp_EditValue @PKID=@DereferenceServiceID, @TableName='DereferenceService', @FieldName='Logo', @Value=@Logo, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID
		END
		ELSE
		BEGIN
			-- Insert New Record
			INSERT INTO BioGUID.dbo.DereferenceService
				(
				DereferenceServiceID,
				ProtocolID,
				DereferenceService,
				DereferencePrefix,
				DereferenceSuffix,
				[Description],
				Logo
				)
			VALUES
				(
				@DereferenceServiceID,
				ISNULL(NULLIF(@ProtocolPKID,-1),0),
				@DereferenceService,
				NULLIF(@DereferencePrefix, N''),
				NULLIF(@DereferenceSuffix, N''),
				NULLIF(@Description, N''),
				NULLIF(@Logo, '')
				)
		END
		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomain', @Task = 'Updated Existing IdentifierDomain Record', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END
	END

	-- Manage cross-linked IdentifierDomain
	IF ISNULL(@IdentifierDomainPKID, 0) <> 0 
		AND ISNULL(@DereferenceServiceID, 0) <> 0 
	BEGIN
		-- Add link to @IdentifierDomainPKID, if it doesn't already exist as a link
		EXEC sp_InsertIdentifierDomainDereferenceService @IdentifierDomain = @IdentifierDomainPKID, @DereferenceService = @DereferenceServiceID, @LogUserName = @LogUserName, @RS = 0
		
		-- If this is the only DereferenceService associated with this IdentifierDomain, and a value has not already been set,
		-- then set it as the Preferred DereferenceService
		IF (SELECT COUNT(*) FROM BioGUID.dbo.IdentifierDomainDereferenceService WHERE IdentifierDomainID = @IdentifierDomainPKID) = 1
			AND (SELECT ISNULL(PreferredDereferenceServiceID, 0) FROM BioGUID.dbo.IdentifierDomain WHERE IdentifierDomainID = @IdentifierDomainPKID) = 0
			EXEC sp_EditValue 
				@PKID = @IdentifierDomainPKID, 
				@TableName = 'IdentifierDomain', 
				@FieldName='PreferredDereferenceServiceID', 
				@Value = @DereferenceServiceID, 
				@UserName = @LogUserName,
				@SessionID = @SessionID,
				@DoLog = @DoLog
	END
-- =============================================================================

-- Return the result
-- =============================================================================
	IF @RS = 1
	BEGIN
		SET @DereferenceServiceUUID = dbo.GetUUID(@DereferenceServiceID)
		SELECT ISNULL(NULLIF(LTRIM(RTRIM(@OUT)), ''), 'Success') AS [Message], @DereferenceServiceID AS DereferenceServiceID, @DereferenceServiceUUID AS DereferenceServiceUUID
	END
-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertEnumeration]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 17 October 2013
-- EDIT DATE:	
-- DESCRIPTION:
--		Inserts an Enumeration record in the database
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
--
-- CALLED FUNCTIONS:
--		dbo.IsUUID
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_InsertEnumeration] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@EnumerationType		nvarchar(255)	= NULL,
	@EnumerationValue		nvarchar(255)	= NULL,
	@Description			nvarchar(500)	= NULL,
	@Sequence				smallint		= -1,
	@LogUserName			nvarchar(128)	= N'Anonymous',
	@RS						bit				= 1,
	@EnumerationID			int				= 0		OUTPUT,
	@EnumerationUUID		varchar(36)		= ''	OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IsUpdate		bit				= 0 -- Indicates whether this should be treated as an Update
	DECLARE @OUT			nvarchar(MAX)	= N''
	DECLARE @EnumerationTypeID	int			= 0
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Convert @EnumerationUUID to @EnumerationID
	SET @EnumerationUUID = dbo.NormalizeUUID(@EnumerationUUID)
	IF dbo.IsUUID(@EnumerationUUID) = 1
		SET @EnumerationID = ISNULL(dbo.GetItemID(@EnumerationUUID, 1), ISNULL(@EnumerationID, 0))
	ELSE
		SET @EnumerationUUID = ''

	-- Convert @EnumerationType
	IF ISNULL(@EnumerationType, '') <> ''
		SET @EnumerationTypeID = ISNULL(dbo.GetEnumerationID(@EnumerationType, ''), 0)
		
	-- Determine if it's an Update
	SET @IsUpdate = CAST(@EnumerationID AS bit)		
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @IsUpdate = 0
	BEGIN
		-- Only proceed if legitimate values have been provided, and the Enumeration record does not already exist
		IF ISNULL(@EnumerationValue, '') <> '' AND ISNULL(@Description, '') <> '' AND ISNULL(@OUT, '') = '' AND ISNULL(@LogUserName, '') <> '' AND
			EXISTS (SELECT * FROM BioGUID.dbo.Enumeration WHERE EnumerationID = @EnumerationTypeID) AND
			NOT EXISTS (SELECT EnumerationID FROM BioGUID.dbo.Enumeration WHERE EnumerationTypeID = ISNULL(@EnumerationTypeID, 0) AND EnumerationValue = ISNULL(@EnumerationValue, ''))
		BEGIN
			-- Generate a PKID for the new Enumeration
			EXEC sp_NewPKID
				@TableName = 'Enumeration',
				@PKID = @EnumerationID	OUTPUT

			-- Adjust Logged UserName
			EXEC sp_AdjustCreatedUsername
				@PKID = @EnumerationID,
				@LogUserName = @LogUserName

			-- Insert New Record
			INSERT INTO BioGUID.dbo.Enumeration
				(
				EnumerationID,
				EnumerationTypeID,									
				EnumerationValue,
				[Description],
				Sequence
				)
			VALUES
				(
				@EnumerationID,
				@EnumerationTypeID,
				@EnumerationValue,
				NULLIF(@Description, ''),
				NULLIF(@Sequence, -1)
				)	

		END
		ELSE
		BEGIN
			IF ISNULL(@EnumerationValue, '') = ''
				SET @OUT = @OUT + N'EnumerationValue not provided.'
			ELSE IF ISNULL(@Description, '') = ''
				SET @OUT = @OUT + N'Description not provided.'
			ELSE IF NOT EXISTS (SELECT * FROM BioGUID.dbo.Enumeration WHERE EnumerationID = @EnumerationTypeID)
				SET @OUT = @OUT + N'Provided EnumerationTypeID does not exist.'
			IF ISNULL(@LogUserName, '') = ''
				SET @OUT = @OUT + N'LogUserName not provided. '
			ELSE IF EXISTS (SELECT EnumerationID FROM BioGUID.dbo.Enumeration WHERE EnumerationTypeID = ISNULL(@EnumerationTypeID, 0) AND EnumerationValue = ISNULL(@EnumerationValue, N''))
				SET @OUT = @OUT + N'Enumeration record already exists for ' + @EnumerationValue + CASE WHEN ISNULL(@EnumerationTypeID, 0) <> 0 THEN N' within the EnumerationType ' + ISNULL((SELECT EnumerationValue FROM BioGUID.dbo.Enumeration WHERE EnumerationID = @EnumerationTypeID), N'') ELSE N'' END + N'.'
			IF ISNULL(@OUT, '') = ''
				SET @OUT = 'Unspecified Error. '
		END
	END
	ELSE
	BEGIN
		-- Check for Orphan Record
		IF EXISTS(SELECT * FROM BioGUID.dbo.Enumeration WHERE EnumerationID = @EnumerationID)
		BEGIN
			IF ISNULL(@EnumerationTypeID, -1) <> -1
				EXEC sp_EditValue @PKID=@EnumerationID, @TableName='Enumeration', @FieldName='EnumerationTypeID', @Value=@EnumerationTypeID, @Username=@LogUserName

			IF ISNULL(@EnumerationValue, '') <> ''
				EXEC sp_EditValue @PKID=@EnumerationID, @TableName='Enumeration', @FieldName='EnumerationValue', @Value=@EnumerationValue, @Username=@LogUserName

			IF ISNULL(@Description, '') <> ''
				EXEC sp_EditValue @PKID=@EnumerationID, @TableName='Enumeration', @FieldName='Description', @Value=@Description, @Username=@LogUserName

			IF ISNULL(@Sequence, -1) <> -1
				EXEC sp_EditValue @PKID=@EnumerationID, @TableName='Enumeration', @FieldName='Sequence', @Value=@Sequence, @Username=@LogUserName
		END
		ELSE
		BEGIN
			-- Insert New Record
			INSERT INTO BioGUID.dbo.Enumeration
				(
				EnumerationID,
				EnumerationTypeID,									
				EnumerationValue,
				[Description],
				Sequence
				)
			VALUES
				(
				@EnumerationID,
				@EnumerationTypeID,
				@EnumerationValue,
				NULLIF(@Description, ''),
				NULLIF(@Sequence, -1)
				)	
		END
	END	
-- =============================================================================

-- Return the result
-- =============================================================================
	IF @RS = 1
	BEGIN
		SET @EnumerationUUID = dbo.GetUUID(@EnumerationID)
		SELECT ISNULL(NULLIF(LTRIM(RTRIM(@OUT)), ''), 'Success') AS [Message], @EnumerationID AS EnumerationID, @EnumerationUUID AS EnumerationUUID
	END
-- =============================================================================
END


GO
/****** Object:  StoredProcedure [dbo].[sp_InsertIdentifierDomain]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 22 August 2012
-- EDIT DATE:	27 December 2014 (added support for PerformanceLog)
--				25 February 2015 (converted to BioGUID)
-- DESCRIPTION:
--		Inserts a new IdentifierDomain
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_InsertIdentifierDomain] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@IdentifierClass		nvarchar(255)	= '',
	@PreferredDereferenceServiceID	varchar(36)		= '',
	@Abbreviation			nvarchar(50)	= NULL,
	@IdentifierDomain		nvarchar(255)	= NULL,
	@Description			nvarchar(255)	= NULL,
	@Logo					nvarchar(255)	= NULL,
	@IsHidden				bit				= 0,
	@AgentUUID				varchar(36)		= NULL,
	@LogUserName			nvarchar(128)	= 'Anonymous',
	@SessionID				uniqueidentifier	= NULL,
	@DoLog					bit				= 1,
	@RS						bit				= 1,
	@IdentifierDomainID		int				= 0		OUTPUT,
	@IdentifierDomainUUID	varchar(36)		= ''	OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IsUpdate							bit			= 0 -- Indicates whether this should be treated as an Update
	DECLARE @AgentID							int			= -1	--
	DECLARE @IdentifierClassPKID				int			= -1
	DECLARE @PreferredDereferenceServicePKID	int			= -1
	DECLARE @StartTime							datetime	= NULL
	DECLARE @OUT								nvarchar(MAX)	= N''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Establish Performance Log variables
	IF @DoLog = 1
	BEGIN
		SET @StartTime = GETUTCDATE()
		IF @SessionID IS NULL
			SET @SessionID = NEWID()
	END

	-- Convert @IdentifierDomainUUID to @IdentifierDomainID
	SET @IdentifierDomainUUID = dbo.NormalizeUUID(@IdentifierDomainUUID)
	IF dbo.IsUUID(@IdentifierDomainUUID) = 1
		SET @IdentifierDomainID = ISNULL(dbo.GetIdentifierDomainID(@IdentifierDomainUUID, 1), 0)
	ELSE
		SET @IdentifierDomainUUID = ''

	-- Check to see if it already exists
	IF ISNULL(@IdentifierDomain, '') <> '' AND ISNULL(@IdentifierDomainID, 0) = 0
		SET @IdentifierDomainID = ISNULL(dbo.GetIdentifierDomainID(@IdentifierDomain, 1), 0)
	
	-- Get IdentifierClass
	SET @IdentifierClassPKID = dbo.GetEnumerationID(@IdentifierClass, 'Identifier Classes')
	
	-- Get @PreferredDereferenceServicePKID
	SET @PreferredDereferenceServicePKID = ISNULL(dbo.GetDereferenceServiceID(@PreferredDereferenceServiceID, 1), 0)

	SET @IsUpdate = CAST(ISNULL(@IdentifierDomainID, 0) AS bit)		

	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomain', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END

-- =============================================================================
-- Operational Code
-- =============================================================================
	-- Check to see if it's an Insert
	IF @IsUpdate = 0
	BEGIN
		-- Only proceed if legitimate values have been provided
		IF ISNULL(@Abbreviation, '') <> '' AND ISNULL(@IdentifierDomain, '') <> '' AND ISNULL(@OUT, '') = '' AND ISNULL(@LogUserName, '') <> ''
			AND NOT EXISTS(SELECT IdentifierDomainID FROM BioGUID.dbo.IdentifierDomain WHERE Abbreviation = @Abbreviation OR IdentifierDomain = @IdentifierDomain OR Abbreviation = @IdentifierDomain OR IdentifierDomain = @Abbreviation)
		BEGIN

			-- Generate a new PKID for the new IdentifierDomain
			EXEC sp_NewPKID
				@TableName = 'IdentifierDomain',
				@PKID = @IdentifierDomainID		OUTPUT,
				@UUID = @IdentifierDomainUUID	OUTPUT

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomain', @Task = 'Generated New PKID', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
			
			-- Adjust Logged UserName
			EXEC sp_AdjustCreatedUsername
				@PKID = @IdentifierDomainID,
				@LogUserName = @LogUserName

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomain', @Task = 'Adjusted Logged Username', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

			-- Insert New Record
			INSERT INTO BioGUID.dbo.IdentifierDomain
				(
				IdentifierDomainID,
				IdentifierClassID,
				PreferredDereferenceServiceID,
				Abbreviation,
				IdentifierDomain,
				[Description],
				Logo,
				IsHidden,
				AgentUUID
				)
			VALUES
				(
				@IdentifierDomainID,
				ISNULL(NULLIF(@IdentifierClassPKID,-1),0),
				ISNULL(NULLIF(@PreferredDereferenceServicePKID,-1),0),
				NULLIF(@Abbreviation, ''),
				NULLIF(@IdentifierDomain, ''),
				NULLIF(@Description, ''),
				NULLIF(@Logo, ''),
				ISNULL(@IsHidden, 0),
				NULLIF(@AgentUUID, '')
				)

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomain', @Task = 'Generated New IdentifierDomain Record', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

		END
		ELSE
		BEGIN
			IF ISNULL(@Abbreviation, '') = ''
				SET @OUT = @OUT + N'Abbreviation not provided. '
			IF ISNULL(@IdentifierDomain, '') = ''
				SET @OUT = @OUT + N'IdentifierDomain not provided. '
			IF ISNULL(@LogUserName, '') = ''
				SET @OUT = @OUT + N'LogUserName not provided. '
			IF EXISTS(SELECT * FROM BioGUID.dbo.IdentifierDomain WHERE Abbreviation = @Abbreviation)
				SET @OUT = @OUT + N'Provided Abbreviation ''' + @Abbreviation + N''' already exists. '
			IF EXISTS(SELECT * FROM BioGUID.dbo.IdentifierDomain WHERE IdentifierDomain = @IdentifierDomain)
				SET @OUT = @OUT + N'Provided IdentifierDomain ''' + @IdentifierDomain + N''' already exists. '
			IF EXISTS(SELECT * FROM BioGUID.dbo.IdentifierDomain WHERE Abbreviation = @IdentifierDomain)
				SET @OUT = @OUT + N'Provided IdentifierDomain ''' + @IdentifierDomain + N''' already exists as an Abbreviation. '
			IF EXISTS(SELECT * FROM BioGUID.dbo.IdentifierDomain WHERE IdentifierDomain = @Abbreviation)
				SET @OUT = @OUT + N'Provided Abbreviation ''' + @Abbreviation + N''' already exists as an IdentifierDomain. '
			IF ISNULL(@OUT, '') = ''
				SET @OUT = 'Unspecified Error. '
		END
	END
	ELSE
	BEGIN
		-- Check for Orphan Record
		IF EXISTS(SELECT * FROM BioGUID.dbo.IdentifierDomain WHERE IdentifierDomainID = @IdentifierDomainID)
		BEGIN

			-- Update Indicated Record
			IF ISNULL(@IdentifierClassPKID, -1) <> -1
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='IdentifierClassID', @Value=@IdentifierClassPKID, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF ISNULL(@PreferredDereferenceServicePKID, -1) <> -1
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='PreferredDereferenceServiceID', @Value=@PreferredDereferenceServicePKID, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF @Abbreviation IS NOT NULL
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='Abbreviation', @Value=@Abbreviation, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF @IdentifierDomain IS NOT NULL
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='IdentifierDomain', @Value=@IdentifierDomain, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF @Description IS NOT NULL
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='Description', @Value=@Description, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF @Logo IS NOT NULL
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='Logo', @Value=@Logo, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF @IsHidden IS NOT NULL
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='IsHidden', @Value=@IsHidden, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF @AgentUUID IS NOT NULL
				EXEC sp_EditValue @PKID=@IdentifierDomainID, @TableName='IdentifierDomain', @FieldName='AgentUUID', @Value=@AgentUUID, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID
		END
		ELSE
		BEGIN
			-- Insert New Record
			INSERT INTO BioGUID.dbo.IdentifierDomain
				(
				IdentifierDomainID,
				IdentifierClassID,
				PreferredDereferenceServiceID,
				Abbreviation,
				IdentifierDomain,
				[Description],
				Logo,
				IsHidden,
				AgentUUID
				)
			VALUES
				(
				@IdentifierDomainID,
				ISNULL(NULLIF(@IdentifierClassPKID,-1),0),
				ISNULL(NULLIF(@PreferredDereferenceServicePKID,-1),0),
				NULLIF(@Abbreviation, ''),
				NULLIF(@IdentifierDomain, ''),
				NULLIF(@Description, ''),
				NULLIF(@Logo, ''),
				ISNULL(@IsHidden, 0),
				@AgentUUID
				)
		END

		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomain', @Task = 'Updated Existing IdentifierDomain Record', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END
	END

	-- Add link to @PreferredDereferenceServicePKID, if it doesn't already exist as a link
	IF ISNULL(@PreferredDereferenceServicePKID, 0) <> 0 
		AND ISNULL(@IdentifierDomainID, 0) <> 0 
		EXEC sp_InsertIdentifierDomainDereferenceService @IdentifierDomain = @IdentifierDomainID, @DereferenceService = @PreferredDereferenceServicePKID, @LogUserName = @LogUserName, @RS = 0
-- =============================================================================

-- Return the result
-- =============================================================================
	IF @RS = 1
	BEGIN
		SET @IdentifierDomainUUID = dbo.GetUUID(@IdentifierDomainID)
		SELECT ISNULL(NULLIF(LTRIM(RTRIM(@OUT)), ''), 'Success') AS [Message], @IdentifierDomainID AS IdentifierDomainID, @IdentifierDomainUUID AS IdentifierDomainUUID
	END
-- =============================================================================

END
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertIdentifierDomainDereferenceService]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 22 August 2012
-- EDIT DATE:	27 December 2014 (added support for PerformanceLog)
--				25 February 2015 (converted to BioGUID)
-- DESCRIPTION:
--		Inserts a new IdentifierDomainDereferenceService
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_InsertIdentifierDomainDereferenceService] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@IdentifierDomain		nvarchar(255)	= N'',
	@DereferenceService		nvarchar(255)	= N'',
	@IsPreferred			bit				= 0,
	@LogUserName			nvarchar(128)	= N'Anonymous',
	@SessionID				uniqueidentifier	= NULL,
	@DoLog					bit				= 1,
	@RS						bit				= 1,
	@IdentifierDomainDereferenceServiceID		int				= 0		OUTPUT,
	@IdentifierDomainDereferenceServiceUUID	varchar(36)		= ''	OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IsUpdate							bit				= 0 -- Indicates whether this should be treated as an Update
	DECLARE @IdentifierDomainPKID				int				= -1
	DECLARE @DereferenceServicePKID				int				= -1
	DECLARE @StartTime							datetime		= NULL
	DECLARE @OUT								nvarchar(MAX)	= N''
	DECLARE @IDList								PKIDListType
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Establish Performance Log variables
	IF @DoLog = 1
	BEGIN
		SET @StartTime = GETUTCDATE()
		IF @SessionID IS NULL
			SET @SessionID = NEWID()
	END

	-- Convert @IdentifierDomainDereferenceServiceUUID to @IdentifierDomainDereferenceServiceID
	SET @IdentifierDomainDereferenceServiceUUID = dbo.NormalizeUUID(@IdentifierDomainDereferenceServiceUUID)
	IF dbo.IsUUID(@IdentifierDomainDereferenceServiceUUID) = 1
		SET @IdentifierDomainDereferenceServiceID = ISNULL(dbo.GetItemID(@IdentifierDomainDereferenceServiceUUID, 1), 0)
	ELSE
		SET @IdentifierDomainDereferenceServiceUUID = ''

	-- Establish IdentifierDomainPKID
	IF ISNULL(@IdentifierDomain, '') <> ''
		SET @IdentifierDomainPKID = ISNULL(dbo.GetIdentifierDomainID(@IdentifierDomain, 1), 0)

	-- Establish DereferenceServicePKID
	SET @DereferenceServicePKID = ISNULL(dbo.GetDereferenceServiceID(@DereferenceService, 1), 0)

	-- Check to see if it already exists
	IF ISNULL(@IdentifierDomainPKID, 0) <> 0 AND ISNULL(@DereferenceServicePKID, 0) <> 0
		SELECT @IdentifierDomainDereferenceServiceID = IdentifierDomainDereferenceServiceID 
		FROM BioGUID.dbo.IdentifierDomainDereferenceService
		WHERE IdentifierDomainID = @IdentifierDomainPKID AND DereferenceServiceID = @DereferenceServicePKID
	
	SET @IsUpdate = CAST(ISNULL(@IdentifierDomainDereferenceServiceID, 0) AS bit)		

	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomainDereferenceService', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================
-- Operational Code
-- =============================================================================
	-- Check to see if it's an Insert
	IF @IsUpdate = 0
	BEGIN
		-- Only proceed if legitimate values have been provided
		IF ISNULL(@IdentifierDomainPKID, 0) <> 0 AND ISNULL(@DereferenceServicePKID, 0) <> 0 AND ISNULL(@OUT, '') = '' AND ISNULL(@LogUserName, '') <> ''
			AND NOT EXISTS(SELECT IdentifierDomainDereferenceServiceID FROM BioGUID.dbo.IdentifierDomainDereferenceService WHERE IdentifierDomainID=@IdentifierDomainPKID AND DereferenceServiceID = @DereferenceServicePKID)
		BEGIN

			-- Generate a new PKID for the new IdentifierDomainDereferenceService
			EXEC sp_NewPKID
				@TableName = 'IdentifierDomainDereferenceService',
				@PKID = @IdentifierDomainDereferenceServiceID		OUTPUT,
				@UUID = @IdentifierDomainDereferenceServiceUUID		OUTPUT

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomainDereferenceService', @Task = 'Generated New PKID', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
			
			-- Adjust Logged UserName
			EXEC sp_AdjustCreatedUsername
				@PKID = @IdentifierDomainDereferenceServiceID,
				@LogUserName = @LogUserName

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomainDereferenceService', @Task = 'Adjusted Logged Username', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

			-- Insert New Record
			INSERT INTO BioGUID.dbo.IdentifierDomainDereferenceService
				(
				IdentifierDomainDereferenceServiceID,
				IdentifierDomainID,
				DereferenceServiceID
				)
			VALUES
				(
				@IdentifierDomainDereferenceServiceID,
				ISNULL(NULLIF(@IdentifierDomainPKID,-1),0),
				ISNULL(NULLIF(@DereferenceServicePKID,-1),0)
				)	

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomainDereferenceService', @Task = 'Generated New IdentifierDomainDereferenceService Record', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

		END
		ELSE
		BEGIN
			IF ISNULL(@IdentifierDomainPKID, 0) = 0
				SET @OUT = @OUT + N'IdentifierDomain not provided. '
			IF ISNULL(@DereferenceServicePKID, 0) = 0
				SET @OUT = @OUT + N'DereferenceService not provided. '
			IF ISNULL(@LogUserName, '') = ''
				SET @OUT = @OUT + N'LogUserName not provided. '
			IF EXISTS(SELECT * FROM BioGUID.dbo.IdentifierDomainDereferenceService WHERE IdentifierDomainID=@IdentifierDomainPKID AND DereferenceServiceID = @DereferenceServicePKID)
				SET @OUT = @OUT + N'Provided IdentifierDomain ''' + dbo.GetUUID(@IdentifierDomainPKID) + N''' already linked to DereferenceService ''' + dbo.GetUUID(@DereferenceServicePKID) + '''. '
			IF ISNULL(@OUT, '') = ''
				SET @OUT = 'Unspecified Error. '
		END
	END
	ELSE
	BEGIN
		-- Check for Orphan Record
		IF EXISTS(SELECT * FROM BioGUID.dbo.IdentifierDomainDereferenceService WHERE IdentifierDomainDereferenceServiceID = @IdentifierDomainDereferenceServiceID)
		BEGIN
		-- Edits not yet supported
			-- Update Indicated Record
			IF ISNULL(NULLIF(@IdentifierDomainPKID, -1), 0) <> 0 AND 1=0
				EXEC sp_EditValue @PKID=@IdentifierDomainDereferenceServiceID, @TableName='IdentifierDomainDereferenceService', @FieldName='IdentifierDomainID', @Value=@IdentifierDomainPKID, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID

			IF ISNULL(NULLIF(@DereferenceServicePKID, -1), 0) <> 0 AND 1=0
				EXEC sp_EditValue @PKID=@IdentifierDomainDereferenceServiceID, @TableName='IdentifierDomainDereferenceService', @FieldName='DereferenceServiceID', @Value=@DereferenceServicePKID, @Username=@LogUserName, @DoLog = @Dolog, @SessionID = @SessionID
		END
		ELSE
		BEGIN
			-- Insert New Record
			INSERT INTO BioGUID.dbo.IdentifierDomainDereferenceService
				(
				IdentifierDomainDereferenceServiceID,
				IdentifierDomainID,
				DereferenceServiceID
				)
			VALUES
				(
				@IdentifierDomainDereferenceServiceID,
				ISNULL(NULLIF(@IdentifierDomainPKID,-1),0),
				ISNULL(NULLIF(@DereferenceServicePKID,-1),0)
				)
		END

		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomainDereferenceService', @Task = 'Updated Existing IdentifierDomainDereferenceService Record', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END
	END

	IF (ISNULL(@IsPreferred, 0) = 1 OR (SELECT PreferredDereferenceServiceID FROM BioGuid.dbo.IdentifierDomain WHERE IdentifierDomainID = @IdentifierDomainPKID) = 0)
		AND ISNULL(NULLIF(@IdentifierDomainPKID,-1),0) <> 0 AND ISNULL(NULLIF(@DereferenceServicePKID,-1),0) <> 0 
		AND (SELECT PreferredDereferenceServiceID FROM BioGuid.dbo.IdentifierDomain WHERE IdentifierDomainID = @IdentifierDomainPKID) <> @DereferenceServicePKID
	BEGIN
		EXEC sp_EditValue 
			@PKID = @IdentifierDomainPKID, 
			@TableName = 'IdentifierDomain', 
			@FieldName='PreferredDereferenceServiceID', 
			@Value = @DereferenceServicePKID, 
			@UserName = @LogUserName,
			@SessionID = @SessionID,
			@DoLog = @DoLog

			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_InsertIdentifierDomainDereferenceService', @Task = 'Updated IdentiferDomain PreferredDereferenceServiceID Record', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END

	END

-- =============================================================================

-- Return the result
-- =============================================================================
	IF @RS = 1
	BEGIN
		SET @IdentifierDomainDereferenceServiceUUID = dbo.GetUUID(@IdentifierDomainDereferenceServiceID)
		SELECT ISNULL(NULLIF(LTRIM(RTRIM(@OUT)), ''), 'Success') AS [Message], @IdentifierDomainDereferenceServiceID AS IdentifierDomainDereferenceServiceID, @IdentifierDomainDereferenceServiceUUID AS IdentifierDomainDereferenceServiceUUID
	END
-- =============================================================================
END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertNewsItem]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 3 March 2015
-- DESCRIPTION:
--		Inserts a new record in the NewsItem table, using the provided values.
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_InsertNewsItem] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@NewsItem				varchar(max)	= NULL, 
	@PostTimeStamp			datetime		= NULL, 
	@IsSuppressed			bit				= NULL,
	@LogUserName			nvarchar(128)	= N'Anonymous',
	@NewsItemID				int				= 0		OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IsUpdate		bit				= 0 -- Indicates whether this should be treated as an Update
	DECLARE @OUT			nvarchar(MAX)	= N''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Determine if it's an Update
	SET @IsUpdate = CAST(ISNULL(@NewsItemID, 0) AS bit)

	-- Deal with NULL @PostTimeStamp
	IF @PostTimeStamp IS NULL
		SET @PostTimeStamp = GETUTCDATE()

	-- Deal with NULL @IsSuppressed
	IF @IsSuppressed IS NULL
		SET @IsSuppressed = 0
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @IsUpdate = 0
	BEGIN
		-- Only proceed if legitimate values have been provided, and the Enumeration record does not already exist
		IF ISNULL(@NewsItem, '') <> '' AND ISNULL(@OUT, '') = ''
		BEGIN
			-- Insert New Record
			INSERT INTO BioGUIDDataServices.dbo.NewsItem 
				(
				NewsItem,
				PostTimeStamp,
				IsSuppressed
				)
			VALUES
				(
				@NewsItem,
				@PostTimeStamp,
				@IsSuppressed
				)

		END
		ELSE
		BEGIN
			IF ISNULL(@NewsItem, '') = ''
				SET @OUT = @OUT + N'NewsItem not provided. '
			IF ISNULL(@OUT, '') = ''
				SET @OUT = 'Unspecified Error. '
		END
	END
	ELSE
	BEGIN
		IF @NewsItem IS NOT NULL
			UPDATE BioGUIDDataServices.dbo.NewsItem
			SET NewsItem = @NewsItem WHERE NewsItemID = @NewsItemID

		IF @PostTimeStamp IS NOT NULL
			UPDATE BioGUIDDataServices.dbo.NewsItem
			SET PostTimeStamp = @PostTimeStamp WHERE NewsItemID = @NewsItemID

		IF @IsSuppressed IS NOT NULL
			UPDATE BioGUIDDataServices.dbo.NewsItem
			SET IsSuppressed = @IsSuppressed WHERE NewsItemID = @NewsItemID
	END	
-- =============================================================================

-- Return the result
-- =============================================================================
	SELECT ISNULL(NULLIF(LTRIM(RTRIM(@OUT)), ''), 'Success') AS [Message], @NewsItemID AS NewsItemID, @PostTimeStamp AS PostTimeStamp, @IsSuppressed AS IsSuppressed
-- =============================================================================

END

GO
/****** Object:  StoredProcedure [dbo].[sp_InsertSchemaItem]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 1 June 2007
-- EDIT DATE:	4 July 2007, 17 October 2013
-- DESCRIPTION:
--		Inserts a new record in the SchemaItem table, using the provided values.
--
-- INPUT PARAMETERS:
--		@Type		- String indicating Type of new SchemaItem ("Database", 
--						"Table", "Field", etc.)
--		@Nm			- String representing Name of new SchemaItem
--		@Parent		- Either a string representing Parent SchemaItemName, or
--						the corresponding SchemaItemID
--		@Descr		- String description of the new SchemaItem
--		@Log		- Boolean indicator for whether this SchemaItem is logged
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		sp_NewPKID
--		sp_SynchronizeSchemaItemDescription
--		dbo.IsUUID
--		dbo.GetItemID
--		dbo.GetEnumerationID
--		dbo.GetSchemaItemID
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_InsertSchemaItem] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@SchemaItemType			varchar(255)	= NULL, 
	@SchemaItemName			varchar(128)	= NULL,
	@ParentSchemaItem		varchar(128)	= NULL, 
	@Description			varchar(MAX)	= NULL,
	@IsLogged				bit				= NULL,
	@LogUserName			nvarchar(128)	= N'Anonymous',
	@RS						bit				= 1,
	@SchemaItemID			int				= 0		OUTPUT,
	@SchemaItemUUID			char(36)		= ''	OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IsUpdate		bit				= 0 -- Indicates whether this should be treated as an Update
	DECLARE @OUT			nvarchar(MAX)	= N''
	DECLARE @SchemaItemTypeID		int		= 0	-- Type of Schema Item being created (Table, Field, etc.)
	DECLARE @ParentSchemaItemID		int		= 0	-- ParentSchemaItemID
	DECLARE @DescriptionAnnotationID	int		= 0 
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Convert @SchemaItemUUID to @SchemaItemID
	SET @SchemaItemUUID = dbo.NormalizeUUID(@SchemaItemUUID)
	IF dbo.IsUUID(@SchemaItemUUID) = 1
		SET @SchemaItemID = ISNULL(dbo.GetItemID(@SchemaItemUUID, 1), ISNULL(@SchemaItemID, 0))
	ELSE
		SET @SchemaItemUUID = ''

	-- Convert @SchemaItemType
	IF ISNULL(@SchemaItemType, '') <> ''
		SET @SchemaItemTypeID = ISNULL(dbo.GetEnumerationID(@SchemaItemType, 'SchemaItemTypes'), 0)

	-- Convert @ParentSchemaItem
	IF ISNULL(@ParentSchemaItem, '') <> '' AND @ParentSchemaItem <> '0'
		SELECT @ParentSchemaItemID = ISNULL(dbo.GetSchemaItemID(@ParentSchemaItem, '', ''), 0)

	-- Determine if it's an Update
	SET @IsUpdate = CAST(ISNULL(@SchemaItemID, 0) AS bit)
	
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF @IsUpdate = 0
	BEGIN
		-- Only proceed if legitimate values have been provided, and the Enumeration record does not already exist
		IF ISNULL(@SchemaItemName, '') <> '' AND ISNULL(@SchemaItemTypeID, 0) <> 0 AND ISNULL(@OUT, '') = '' AND ISNULL(@LogUserName, '') <> '' AND
			(ISNULL(@ParentSchemaItemID, 0) <> 0 OR (@ParentSchemaItemID = 0 AND (SELECT EnumerationValue FROM BioGUID.dbo.Enumeration WHERE EnumerationID = ISNULL(@SchemaItemTypeID, 0)) = 'Database')) 
			AND EXISTS (SELECT EnumerationID FROM BioGUID.dbo.Enumeration WHERE EnumerationID = @SchemaItemTypeID) 
			AND NOT EXISTS (SELECT SchemaItemID FROM BioGUID.dbo.SchemaItem WHERE SchemaItemName = @SchemaItemName AND ParentSchemaItemID = @ParentSchemaItemID)
		BEGIN
			-- Generate a new PKID for the new Schemaitem
			EXEC sp_NewPKID
				@TableName = 'SchemaItem',
				@PKID = @SchemaItemID	OUTPUT

			-- Adjust Logged UserName
			EXEC sp_AdjustCreatedUsername
				@PKID = @SchemaItemID,
				@LogUserName = @LogUserName

			-- Insert New Record
			INSERT INTO BioGUID.dbo.SchemaItem 
				(
				SchemaItemID, 
				SchemaItemTypeID,
				SchemaItemName,
				ParentSchemaItemID,
				[Description],
				IsLogged
				)
			VALUES
				(
				@SchemaItemID,
				@SchemaItemTypeID,
				@SchemaItemName,
				@ParentSchemaItemID,
				NULLIF(@Description, ''),
				ISNULL(@IsLogged, 0)
				)

		END
		ELSE
		BEGIN
			IF ISNULL(@SchemaItemName, '') = ''
				SET @OUT = @OUT + N'SchemaItemName not provided. '
			IF ISNULL(@SchemaItemTypeID, 0) = 0 OR NOT EXISTS(SELECT * FROM BioGUID.dbo.Enumeration WHERE EnumerationID = @SchemaItemTypeID)
				SET @OUT = @OUT + N'Legitimate SchemaItemTypeID not provided. '
			IF ISNULL(@ParentSchemaItemID, 0) = 0
				SET @OUT = @OUT + N'Legitimate ParentSchemaItemID not provided. '
			IF ISNULL(@LogUserName, '') = ''
				SET @OUT = @OUT + N'LogUserName not provided. '
			IF EXISTS (SELECT * FROM BioGUID.dbo.SchemaItem WHERE SchemaItemName = @SchemaItemName AND ParentSchemaItemID = @ParentSchemaItemID)
				SET @OUT = @OUT + N'SchemaItem record already exists for ''' + @SchemaItemName + N'''. '
			IF ISNULL(@OUT, '') = ''
				SET @OUT = 'Unspecified Error. '
		END
	END
	ELSE
	BEGIN
		-- Check for Orphan Record
		IF EXISTS(SELECT * FROM BioGUID.dbo.SchemaItemID WHERE SchemaItemID = @SchemaItemID)
		BEGIN
			IF ISNULL(@SchemaItemTypeID, 0) <> 0
				EXEC sp_EditValue @PKID=@SchemaItemID, @TableName='SchemaItem', @FieldName='SchemaItemTypeID', @Value=@SchemaItemTypeID, @Username=@LogUserName

			IF ISNULL(@SchemaItemName, '') <> ''
				EXEC sp_EditValue @PKID=@SchemaItemID, @TableName='SchemaItem', @FieldName='SchemaItemName', @Value=@SchemaItemName, @Username=@LogUserName

			IF @IsLogged IS NOT NULL
				EXEC sp_EditValue @PKID=@SchemaItemID, @TableName='SchemaItem', @FieldName='IsLogged', @Value=@IsLogged, @Username=@LogUserName

			IF ISNULL(@Description, '') <> ''
				EXEC sp_EditValue @PKID=@SchemaItemID, @TableName='SchemaItem', @FieldName='Description', @Value=@Description, @Username=@LogUserName
		END
		ELSE
		BEGIN
			-- Insert New Record
			INSERT INTO BioGUID.dbo.SchemaItem 
				(
				SchemaItemID, 
				SchemaItemTypeID,
				SchemaItemName,
				ParentSchemaItemID,
				[Description],
				IsLogged
				)
			VALUES
				(
				@SchemaItemID,
				@SchemaItemTypeID,
				@SchemaItemName,
				@ParentSchemaItemID,
				NULLIF(@Description, ''),
				ISNULL(@IsLogged, 0)
				)
		END
	END	
-- =============================================================================

-- Return the result
-- =============================================================================
	IF @RS = 1
	BEGIN
		SET @SchemaItemUUID = dbo.GetUUID(@SchemaItemID)
		SELECT ISNULL(NULLIF(LTRIM(RTRIM(@OUT)), ''), 'Success') AS [Message], @SchemaItemID AS SchemaItemID, @SchemaItemUUID AS SchemaItemUUID
	END
-- =============================================================================

END

GO
/****** Object:  StoredProcedure [dbo].[sp_LookupDereferenceService]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==========================================================================================
AUTHOR:		Richard L. Pyle
CREATE DATE: 27 January 2015
EDIT DATE:	
DESCRIPTION: Fast Lookup of DereferenceService

INPUT PARAMETERS:
Term			DataTyp			Default	Description
------------------------------------------------------------------------------------
@SearchTerm		nvarchar(4000)	''		Search term compared against any part of an 
											DereferenceService or DereferencePrefix; accepts a UUID
@MinTermLength	tinyint			3		Minimum length of SearchTerm for results to be returned
@Top			bit				0		Maximum number of records to return. 0 = Unlimited
@Debug			bit				0		0 = Executes SQL statement; 1 = Returns SQL statement

OUTPUT PARAMETERS:
	NONE

OUTPUT COLUMNS:
	DereferenceServiceUUID	UUID value for the returned IdentifierDomain row.
	FormattedDereferenceService	A formatted representation of the IdentifierDomain

CALLED PROCEDURES:
	dbo.IsUUID
	dbo.NormalizeUUID
	dbo.GetItemID

REFERENCED VIEWS
	NONE
==========================================================================================
*/
CREATE PROCEDURE [dbo].[sp_LookupDereferenceService] 
	-- Add the parameters for the stored procedure here
	@SearchTerm			nvarchar(4000)	= '', 
	@MinTermLength		tinyint			= 3,
	@Top				int				= 0,
	@Debug				bit				= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
-- Declare Internal Variables
-- =============================================================================
	DECLARE @PKID				int					= 0
	DECLARE @SQL				nvarchar(MAX)		= ''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Intercept UUID in @SearchTerm
	IF dbo.IsUUID(RIGHT(@SearchTerm, 36)) = 1 AND LEN(@SearchTerm)>36
		SET @SearchTerm = RIGHT(@SearchTerm, 36)
	IF dbo.IsUUID(RIGHT(dbo.NormalizeUUID(@SearchTerm), 32)) = 1 AND LEN(@SearchTerm) > 32
		SET @SearchTerm = dbo.NormalizeUUID(RIGHT(@SearchTerm, 32))

	IF dbo.IsUUID(dbo.NormalizeUUID(@SearchTerm)) = 1
	BEGIN
		SET @PKID = dbo.GetItemID(@SearchTerm, 1)
		SET @SearchTerm = N''
	END

	-- Process Searchterm
	IF LEN(@SearchTerm) >= @MinTermLength
	BEGIN
		SET @SearchTerm = dbo.RemoveWhitespace(@SearchTerm)
	END
	ELSE
		SET @SearchTerm = N''
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Initialize SQL
	SET @SQL = N'SELECT '
	IF ISNULL(@Top, 0) > 0
		SET @SQL = @SQL + N'TOP(' + CAST(@Top AS nvarchar) + N') '
			
	SET @SQL = @SQL +
	N'LOWER(CAST(PK.UUID AS char(36))) AS DereferenceServiceUUID, DS.DereferenceService + '' ('' + DS.DereferencePrefix + ''[IDENTIFIER]'' + CASE WHEN DS.DereferenceSuffix IS NOT NULL THEN DS.DereferenceSuffix ELSE '''' END + '')'' AS FormattedDereferenceService ' + 
	N'FROM BioGUID.dbo.DereferenceService AS DS ' +
		N'INNER JOIN BioGUID.dbo.PK AS PK ON DS.DereferenceServiceID = PK.PKID '	
	-- First see if it's a PKID value or if no @SearchTerm is processed
	IF ISNULL(@PKID, 0) <> 0 OR ISNULL(@SearchTerm, N'') = N''
		SET @SQL = @SQL + N'WHERE PK.PKID = ' + CAST(ISNULL(@PKID, -1) AS nvarchar) + N' '
	ELSE 
	BEGIN

		-- Build SQL according to filter cirteria
		SET @SQL = @SQL + N'WHERE PK.PKID = PK.CorrectID AND (' + dbo.ParseSearchTerm(@SearchTerm, 'DS.DereferenceService', 0, 1, 'Contains') + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'DS.DereferencePrefix', 0, 1, 'Contains') + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'DS.[Description]', 0, 1, 'Contains') + N') '
			
	END

	SET @SQL = @SQL + N'ORDER BY DS.DereferenceService'

	-- Complete Procedure
	IF ISNULL(@Debug, 0 ) = 1
		SELECT @SQL
	ELSE
		EXEC(@SQL)

-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_LookupIdentifierDomain]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==========================================================================================
AUTHOR:		Richard L. Pyle
CREATE DATE: 27 January 2015
EDIT DATE:	
DESCRIPTION: Fast Lookup of IdentifierDomain

INPUT PARAMETERS:
Term			DataTyp			Default	Description
------------------------------------------------------------------------------------
@SearchTerm		nvarchar(4000)	''		Search term compared against any part of an 
											IdentifierDomain or Abbreviation; accepts a UUID
@MinTermLength	tinyint			3		Minimum length of SearchTerm for results to be returned
@Top			bit				0		Maximum number of records to return. 0 = Unlimited
@Debug			bit				0		0 = Executes SQL statement; 1 = Returns SQL statement

OUTPUT PARAMETERS:
	NONE

OUTPUT COLUMNS:
	IdentifierDomainUUID	UUID value for the returned IdentifierDomain row.
	FormattedIdentifierDomain	A formatted representation of the IdentifierDomain

CALLED PROCEDURES:
	dbo.IsUUID
	dbo.NormalizeUUID
	dbo.GetItemID

REFERENCED VIEWS
	NONE
==========================================================================================
*/
CREATE PROCEDURE [dbo].[sp_LookupIdentifierDomain] 
	-- Add the parameters for the stored procedure here
	@SearchTerm			nvarchar(4000)	= '', 
	@MinTermLength		tinyint			= 3,
	@Top				int				= 0,
	@Debug				bit				= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
-- Declare Internal Variables
-- =============================================================================
	DECLARE @PKID				int					= 0
	DECLARE @SQL				nvarchar(MAX)		= ''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Intercept UUID in @SearchTerm
	IF dbo.IsUUID(RIGHT(@SearchTerm, 36)) = 1 AND LEN(@SearchTerm)>36
		SET @SearchTerm = RIGHT(@SearchTerm, 36)
	IF dbo.IsUUID(RIGHT(dbo.NormalizeUUID(@SearchTerm), 32)) = 1 AND LEN(@SearchTerm) > 32
		SET @SearchTerm = dbo.NormalizeUUID(RIGHT(@SearchTerm, 32))

	IF dbo.IsUUID(dbo.NormalizeUUID(@SearchTerm)) = 1
	BEGIN
		SET @PKID = dbo.GetItemID(@SearchTerm, 1)
		SET @SearchTerm = N''
	END

	-- Process Searchterm
	IF LEN(@SearchTerm) >= @MinTermLength
	BEGIN
		SET @SearchTerm = dbo.RemoveWhitespace(@SearchTerm)
	END
	ELSE
		SET @SearchTerm = N''
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Initialize SQL
	SET @SQL = N'SELECT '
	IF ISNULL(@Top, 0) > 0
		SET @SQL = @SQL + N'TOP(' + CAST(@Top AS nvarchar) + N') '
			
	SET @SQL = @SQL +
	N'LOWER(CAST(PK.UUID AS char(36))) AS IdentifierDomainUUID, ID.IdentifierDomain + CASE WHEN ID.Abbreviation IS NOT NULL THEN ''('' + ID.Abbreviation + '')'' ELSE '''' END AS FormattedIdentifierDomain ' + 
	N'FROM BioGUID.dbo.IdentifierDomain AS ID ' +
		N'INNER JOIN BioGUID.dbo.PK AS PK ON ID.IdentifierDomainID = PK.PKID '	
	-- First see if it's a PKID value or if no @SearchTerm is processed
	IF ISNULL(@PKID, 0) <> 0 OR ISNULL(@SearchTerm, N'') = N''
		SET @SQL = @SQL + N'WHERE PK.PKID = ' + CAST(ISNULL(@PKID, -1) AS nvarchar) + N' '
	ELSE 
	BEGIN

		-- Build SQL according to filter cirteria
		SET @SQL = @SQL + N'WHERE PK.PKID = PK.CorrectID AND (' + dbo.ParseSearchTerm(@SearchTerm, 'ID.IdentifierDomain', 0, 1, 'Contains') + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'ID.Abbreviation', 0, 1, 'Contains') + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'ID.[Description]', 0, 1, 'Contains') + N') '
			
	END

	SET @SQL = @SQL + N'ORDER BY ID.IdentifierDomain'

	-- Complete Procedure
	IF ISNULL(@Debug, 0 ) = 1
		SELECT @SQL
	ELSE
		EXEC(@SQL)

-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_MergeObjects]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 March 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Merges two objects.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_MergeObjects] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@DupeIO					DupeIOType	READONLY,
	@SessionID				uniqueidentifier	= NULL,
	@LogUserName			nvarchar(128)		= 'deepreef',
	@Debug					bit					= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @IDList AS PKIDListType
	DECLARE @StartTime		datetime			= GETUTCDATE()
	DECLARE @RecordCount	AS int
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF (SELECT COUNT(*) FROM @DupeIO) > 0
	BEGIN
		-- ====================================
		-- Merge Duplicate Object ID values 
		-- ====================================

		IF ISNULL(@Debug, 0) = 1
		BEGIN

			-- Identifier Records to be deleted
			SELECT 'Identifiers to be Deleted' AS RecordSet, I.IdentifierDomainID, I.IdentifiedObjectID, I.Identifier
			FROM BioGUID.dbo.Identifier AS I
				INNER JOIN @DupeIO AS D ON I.IdentifiedObjectID = D.IdentifiedObjectID
				INNER JOIN BioGUID.dbo.Identifier AS IC 
					ON D.CorrectObjectID = IC.IdentifiedObjectID 
						AND I.Identifier = IC.Identifier 
						AND I.IdentifierDomainID = IC.IdentifierDomainID
			ORDER BY D.IdentifiedObjectID

			-- Transfer remaining Identifiers to CorrectObjectID
			SELECT 'Transfer Object Identifier' AS RecordSet, I.*
			FROM BioGUID.dbo.Identifier AS I
				INNER JOIN @DupeIO AS O ON I.IdentifiedObjectID = O.IdentifiedObjectID

			-- Object Records to be deleted
			SELECT 'Delete Objects' AS RecordSet, O.*
			FROM BioGUID.dbo.IdentifiedObject AS O
				INNER JOIN @DupeIO AS D ON O.IdentifiedObjectID = D.IdentifiedObjectID

		END
		ELSE
		BEGIN
			-- Delete existing Identifier Records
			DELETE I
			FROM BioGUID.dbo.Identifier AS I
				INNER JOIN @DupeIO AS D ON I.IdentifiedObjectID = D.IdentifiedObjectID
				INNER JOIN BioGUID.dbo.Identifier AS IC 
					ON D.CorrectObjectID = IC.IdentifiedObjectID 
						AND I.Identifier = IC.Identifier 
						AND I.IdentifierDomainID = IC.IdentifierDomainID
			SET @RecordCount = @@ROWCOUNT
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_MergeObjects', @Task = 'Delete duplicate Identifiers', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Transfer remaining Identifiers to CorrectObjectID
			UPDATE BioGUID.dbo.Identifier SET IdentifiedObjectID = O.CorrectObjectID 
			FROM BioGUID.dbo.Identifier AS I
				INNER JOIN @DupeIO AS O ON I.IdentifiedObjectID = O.IdentifiedObjectID
			SET @RecordCount = @@ROWCOUNT
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_MergeObjects', @Task = 'Update Identifiers to CorrectObjectID', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

			-- Delete Duplicate Objects
			DELETE BioGUID.dbo.IdentifiedObject
			FROM BioGUID.dbo.IdentifiedObject AS O
				INNER JOIN @DupeIO AS D ON O.IdentifiedObjectID = D.IdentifiedObjectID
			SET @RecordCount = @@ROWCOUNT
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_MergeObjects', @Task = 'Delete duplicate Objects', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()

		END

		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_MergeObjects', @Task = 'Merged Duplicate Records Complete', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

	END
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_MergeObjectsSimple]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 March 2015
-- EDIT DATE:	
-- DESCRIPTION:
--		Merges two objects.
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--
-- CALLED PROCEDURES:
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_MergeObjectsSimple] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@IdentifiedObjectID		bigint				= NULL,
	@CorrectObjectID		bigint				= NULL,
	@SessionID				uniqueidentifier	= NULL,
	@LogUserName			nvarchar(128)		= 'deepreef',
	@Debug					bit					= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @DupeIO AS DupeIOType
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())
-- =============================================================================

-- Operational Code
-- =============================================================================
	IF ISNULL(@IdentifiedObjectID, 0) <> 0 AND ISNULL(@CorrectObjectID, 0) <> 0 AND ISNULL(@IdentifiedObjectID, 0) <> ISNULL(@CorrectObjectID, 0)
	BEGIN
		INSERT INTO @DupeIO (IdentifiedObjectID, CorrectObjectID)
		SELECT @IdentifiedObjectID, @CorrectObjectID

		EXEC sp_MergeObjects @DupeIO = @DupeIO, @SessionID =  @SessionID, @LogUserName = @LogUserName, @Debug = @Debug
	END
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_NewPKID]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 16 March 2007
-- EDIT DATE:	25 May 2007; 29 May 2007; 1 June 2007, 16 October 2013
--				21 Feb 2015 (Redesigned to generate next PKID and/or new UUID as needed)
-- DESCRIPTION:
--		Inserts a new record into the PK table associated with the provided 
--		table name, and returns the new PKID value.
--
-- INPUT PARAMETERS:
--		@TblNm		String representing name of table for which new PKID is 
--					created.
--
-- OUTPUT PARAMETERS:
--		@PKID			PKID value of new record inserted into PK Table.
--		@UUID			UUID value of new record inserted into PK Table.
--
-- CALLED FUNCTIONS:
--		dbo.IsUUID
--		dbo.GetSchemaItemID
--
-- CALLED PROCEDURES:
--		NONE		
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_NewPKID] 
	-- Add the parameters for the stored procedure here
	@TableName	varchar(128),
	@PKID		int				= 0		OUTPUT,
	@UUID		varchar(36)		= ''	OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @TableID		int		-- PKID for the table indicated by @TableName
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Convert the supplied @TableName string into the corresponding SchemaItemID
	SET @TableID = dbo.GetSchemaItemID(@TableName, -1, 'Table')

	-- Get next available @PKID, if not provided
	IF ISNULL(@PKID, 0) = 0
		SELECT @PKID = MAX(PKID) + 1 FROM BioGUID.dbo.PK

	-- Get @UUID, if not provided
	IF dbo.IsUUID(@UUID) <> 1
		SET @UUID = NEWID()
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Create the Record in PK
	IF ISNULL(@TableID, 0) <> 0
		INSERT INTO BioGUID.dbo.PK (PKID, UUID, CorrectID, TableID) VALUES (@PKID, @UUID, @PKID, @TableID)
	
	-- If no value is returned, set OUTPUT values to zero and ''
	SET @PKID = ISNULL(@PKID, 0)
	SET @UUID = ISNULL(@UUID, '')
-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_PerformanceLog]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Richard L. Pyle
-- Create date: 12 December 2014
-- EDIT DATE:	21 January 2015 (Adjusted for BioGUIDLocalLog)
-- Description:	Logs an event in the PerformanceLog table
-- =============================================
CREATE PROCEDURE [dbo].[sp_PerformanceLog] 
	-- Add the parameters for the stored procedure here
	@SessionID	uniqueidentifier = NULL,
	@Process nvarchar(255) = NULL,
	@Task nvarchar(MAX) = NULL,
	@RecordCount int = NULL,
	@StartTime datetime = NULL,
	@EndTime datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @DoLog as bit = 1
	DECLARE @MyStartTime AS datetime

	SET @MyStartTime = GETUTCDATE()

	IF @EndTime IS NULL
		SET @EndTime = GETUTCDATE()

    -- Insert statements for procedure here
	IF @Process IS NOT NULL 
		AND @Task IS NOT NULL
		AND @StartTime IS NOT NULL
		AND @EndTime IS NOT NULL
		INSERT INTO BioGUIDLocalLog.dbo.PerformanceLog(SessionID, Process, Task, RecordCount, StartTime, EndTime)
		SELECT @SessionID, @Process, @Task, @RecordCount, @StartTime, @EndTime		

	IF @DoLog = 1
	BEGIN
		INSERT INTO BioGUIDLocalLog.dbo.PerformanceLog(SessionID, Process, Task, RecordCount, StartTime, EndTime)
		SELECT @SessionID, 'DS.sp_PerformanceLog', 'Completed Performance Log', 0, @MyStartTime, GETUTCDATE()
	END
END



GO
/****** Object:  StoredProcedure [dbo].[sp_PerformanceSummary]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Richard L. Pyle
-- Create date: 22 December 2014
-- Description:	Displays a summary of performance statistics from the PerformanceLog table.
-- =============================================
CREATE PROCEDURE [dbo].[sp_PerformanceSummary] 
	-- Add the parameters for the stored procedure here
	@Type nvarchar(255) = 'Task',
	@Process	nvarchar(255) = '',
	@Task		nvarchar(255) = '',
	@SessionID	nvarchar(MAX) = '',
	@MinTime	datetime = NULL,
	@MaxTime	datetime = NULL,
	@MinID		int	= NULL,
	@MaxID		int	= NULL,
	@OrderBy	nvarchar(255) = '',
	@Debug		bit	= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL AS nvarchar(MAX) = ''
	DECLARE @GROUP AS nvarchar(255) = ''
	DECLARE @WHERE AS nvarchar(255) = ''

	SET @SQL = 'MIN(StartTime) AS Earliest, MAX(EndTime) AS Latest, MIN(Duration) AS MinDuration, MAX(Duration) AS MaxDuration, AVG(Duration) AS AverageDuration, COUNT(*) AS LogCount, SUM(RecordCount) AS TotalRecordCount, (AVG(Duration) * COUNT(*)) AS TotalDuration, ((AVG(Duration) * COUNT(*)) / (DATEDIFF(d, MIN(StartTime), MAX(EndTime))+1)) AS DailyDuration, CONVERT(varchar(8), DATEADD(s,(((SUM(CAST(Duration AS bigint))) / (DATEDIFF(d, MIN(StartTime), MAX(EndTime))+1))/1000),''00:00:00''),8) As DailyTime FROM (SELECT *, DATEDIFF(ms, StartTime, EndTime) AS Duration FROM BioGUIDLocalLog.dbo.PerformanceLog) AS SRC'

    -- Insert statements for procedure here
	If @Type = 'Process'
		SET @GROUP = 'Process'
	ELSE IF @Type = 'Totals'
		SET @GROUP = ''
	ELSE
		SET @GROUP = 'Process, Task'

	IF ISNULL(@Process, '') <> ''
	BEGIN
		SET @Process = REPLACE(@Process, '''', '')
		IF CHARINDEX(',', @Process, 1) > 0
			SET @WHERE = ISNULL(@WHERE, '') + ' AND (Process IN (''' + REPLACE(@Process, ',', ''',''') + '''))'
		ELSE IF CHARINDEX('%', @Process, 1) > 0
			SET	@WHERE = ISNULL(@WHERE, '') + ' AND (Process LIKE ''' + @Process + ''')'
		ELSE
			SET @WHERE = ISNULL(@WHERE, '') + ' AND (Process = ''' + @Process + ''')'
	END

	IF ISNULL(@Task, '') <> ''
		IF CHARINDEX('%', @Task, 1) > 0
			SET	@WHERE = ISNULL(@WHERE, '') + ' AND (Task LIKE ''' + @Task + ''')'
		ELSE
			SET	@WHERE = ISNULL(@WHERE, '') + ' AND (Task = ''' + @Task + ''')'

	IF ISNULL(@SessionID, '') <> ''
	BEGIN
		SET @SessionID = REPLACE(@SessionID, '''', '')
		IF CHARINDEX(',', @SessionID, 1) > 0
			SET @WHERE = ISNULL(@WHERE, '') + ' AND (SessionID IN (''' + REPLACE(@SessionID, ',', ''',''') + '''))'
		ELSE
			SET @WHERE = ISNULL(@WHERE, '') + ' AND (SessionID = ''' + @SessionID + ''')'
	END


	IF @MinTime IS NOT NULL
		SET	@WHERE = ISNULL(@WHERE, '') + ' AND (StartTime >= ''' + CAST(@MinTime AS nvarchar) + ''')'

	IF @MaxTime IS NOT NULL
		SET	@WHERE = ISNULL(@WHERE, '') + ' AND (EndTime <= ''' + CAST(@MaxTime AS nvarchar) + ''')'

	IF @MinID IS NOT NULL
		SET	@WHERE = ISNULL(@WHERE, '') + ' AND (PerformanceLogID >= ''' + CAST(@MinID AS nvarchar) + ''')'

	IF @MaxID IS NOT NULL
		SET	@WHERE = ISNULL(@WHERE, '') + ' AND (PerformanceLogID <= ''' + CAST(@MaxID AS nvarchar) + ''')'
	
	IF ISNULL(@WHERE, '') <> ''
		SET @WHERE = ' WHERE ' + SUBSTRING(@WHERE, 6, LEN(@WHERE))

	SET @OrderBy = ISNULL(NULLIF(@OrderBy, ''), @GROUP)
	IF ISNULL(@OrderBy, '') <> ''
		SET @OrderBy = ' ORDER BY ' + @OrderBy

	SET @SQL = 'SELECT ' + @GROUP + CASE WHEN ISNULL(@GROUP, '') = '' THEN '' ELSE ', ' END + @SQL + @WHERE + CASE WHEN ISNULL(@GROUP, '') = '' THEN '' ELSE ' GROUP BY ' END + @GROUP + @OrderBy
	
	IF ISNULL(@Debug, 0) = 1
		SELECT @SQL
	ELSE
		EXEC(@SQL)		
END



GO
/****** Object:  StoredProcedure [dbo].[sp_SearchDereferenceService]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 27 February 2015
-- DESCRIPTION:
--		Creates a list of DereferenceServices based on various input search parameters.
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		sp_GetUserName
--		sp_aspnetdbGetRolesForUser
--		sp_PerformanceLog
--		dbo.ParseSearchTerm
--		dbo.GetItemID
--		dbo.IsUUID
--		dbo.GetPKID
--
-- REFERENCED VIEWS
--		view_SearchDereferenceService
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_SearchDereferenceService]
	-- Add the parameters for the stored procedure here
	-- =============================================
	@DereferenceService		nvarchar(255)	= N'',
	@IdentifierDomain		nvarchar(255)	= N'',
	@ObjectClass			nvarchar(255)	= N'',
	@SearchTerm				nvarchar(255)	= N'',
	@MinTermLength			tinyint			= 2,
	@SearchType				nvarchar(15)	= N'Word Start',
	@SearchIdentifier		bit				= 0,
	@UserName				nvarchar(128)	= N'Anonymous',
	@OrderBy				nvarchar(1000)	= N'',
	@Top					int				= 0,
	@SessionID				uniqueidentifier= NULL,
	@DoLog					bit				= 1,
	@Debug					bit				= 0	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @SQL					nvarchar(MAX)		= ''
	DECLARE @FROM					varchar(MAX)		= ''
	DECLARE @WHERE					nvarchar(MAX)		= ''
	DECLARE @ColumnList				nvarchar(MAX)		= N''
	DECLARE @DereferenceServicePKID	int					= 0
	DECLARE @IdentifierDomainPKID	int					= 0
	DECLARE @ObjectClassPKID		int					= 0
	DECLARE @T0						datetime			= GETUTCDATE()
	DECLARE @StartTime				datetime			= GETUTCDATE()
	DECLARE @Parameters				nvarchar(MAX)		= ''
	DECLARE @IDList					PKIDListType
	DECLARE @RecordCount			int					= -1
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Capture Input Parameters
	SET @Parameters = 
		N'@DereferenceService=' + ISNULL(@DereferenceService, N'[NULL]') + N'|' + 
		N'@IdentifierDomain=' + ISNULL(@IdentifierDomain, N'[NULL]') + N'|' + 
		N'@ObjectClass=' + ISNULL(@ObjectClass, N'[NULL]') + N'|' + 
		N'@SearchTerm=' + ISNULL(CAST(@SearchTerm AS nvarchar(255)), N'[NULL]') + N'|' + 
		N'@MinTermLength=' + ISNULL(CAST(@MinTermLength AS nvarchar), N'[NULL]') + N'|' + 
		N'@SearchType=' + ISNULL(@SearchType, N'[NULL]') + N'|' + 
		N'@SearchIdentifier=' + ISNULL(CAST(@SearchIdentifier AS nvarchar), N'[NULL]') + N'|' + 
		N'@OrderBy=' + ISNULL(@OrderBy, N'[NULL]') + N'|' + 
		N'@Top=' + ISNULL(CAST(@Top AS nvarchar), N'[NULL]') + N'|' + 
		N'@SessionID=' + ISNULL(CAST(@SessionID AS nvarchar(36)), N'[NULL]') + N'|' + 
		N'@DoLog=' + ISNULL(CAST(@DoLog AS nvarchar), N'[NULL]') + N'|' + 
		N'@Debug=' + ISNULL(CAST(@Debug AS nvarchar), N'[NULL]')

	-- Convert @DereferenceService to @DereferenceServicePKID
	IF ISNULL(@DereferenceService, '') <> ''
		SET @DereferenceServicePKID = dbo.GetDereferenceServiceID(@DereferenceService, 1)

	-- Convert @IdentifierDomain to @IdentifierDomainPKID
	IF ISNULL(@IdentifierDomain, '') <> ''
		SET @IdentifierDomainPKID = dbo.GetIdentifierDomainID(@IdentifierDomain, 1)

	-- Convert @ObjectClass to @ObjectClassPKID
	IF ISNULL(@ObjectClass, '') <> ''
		SET @ObjectClassPKID = dbo.GetEnumerationID(@ObjectClass, 'ObjectClasses')

	-- Trap for null or empty @SearchType
	SET @SearchType = ISNULL(NULLIF(@SearchType, N''), N'Word Start')

	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())

	-- Intercept UUID in @SearchTerm
	IF dbo.IsUUID(dbo.NormalizeUUID(@SearchTerm)) = 1 AND ISNULL(@DereferenceServicePKID, 0) = 0
	BEGIN
		SET @DereferenceServicePKID = dbo.GetDereferenceServiceID(@SearchTerm, 1)
		SET @SearchTerm = ''
	END

	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Filter Records, starting with @DereferenceServicePKID
	IF ISNULL(@DereferenceServicePKID, 0) <> 0
	BEGIN 
		INSERT INTO @IDList(PKID, TableName, PrioritySort)
		SELECT @DereferenceServicePKID, N'Master', 0

		SET @OrderBy = ''
		SET @RecordCount = 1
	END
	ELSE
	BEGIN
		--Initialize @OrderBy
		IF ISNULL(@OrderBy, '') = ''
			SET @OrderBy = N'SDS.DereferenceService'
		ELSE
			SET @OrderBy = N'SDS.' + REPLACE(REPLACE(@OrderBy, N' ', N''), N',', N', SDS.')
		
		SET @OrderBy = N' ORDER BY ' + @OrderBy			

		-- Filter based on provided criteria, starting with most restrictive
		-- Filter based on @DereferenceService
		IF LEN(ISNULL(@DereferenceService, '')) >= @MinTermLength
		BEGIN
			INSERT INTO @IDList(PKID, TableName, PrioritySort)
			SELECT DISTINCT DS.DereferenceServiceID, N'Master', 1
			FROM BioGUID.dbo.DereferenceService AS DS
				INNER JOIN BioGUID.dbo.PK AS PK ON DS.DereferenceServiceID = PK.PKID
			WHERE (DS.DereferenceService LIKE N'%' + @DereferenceService + N'%' OR
				DS.DereferencePrefix LIKE N'%' + @DereferenceService + N'%')

			-- Capture RecordCount
			SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Added Records based on @DereferenceService', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END

		-- Filter based on @IdentifierDomain
		IF ISNULL(@IdentifierDomainPKID, 0) <> 0  OR LEN(ISNULL(@IdentifierDomain, '')) >= @MinTermLength
		BEGIN
			IF ISNULL(@RecordCount, 0) = -1
			BEGIN
				IF ISNULL(@IdentifierDomainPKID, 0) <> 0 
				BEGIN
					INSERT INTO @IDList(PKID, TableName, PrioritySort)
					SELECT DISTINCT DS.DereferenceServiceID, N'Master', 2
					FROM BioGUID.dbo.DereferenceService AS DS
						INNER JOIN BioGUID.dbo.PK AS PK ON DS.DereferenceServiceID = PK.PKID
						INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON DS.DereferenceServiceID = IDDS.DereferenceServiceID
					WHERE IDDS.IdentifierDomainID = @IdentifierDomainPKID
						AND DS.DereferenceServiceID NOT IN (SELECT PKID FROM @IDList WHERE TableName = N'Master')
				END
				ELSE IF LEN(ISNULL(@IdentifierDomain, '')) >= @MinTermLength
				BEGIN
					INSERT INTO @IDList(PKID, TableName, PrioritySort)
					SELECT DISTINCT DS.DereferenceServiceID, N'Master', 2
					FROM BioGUID.dbo.DereferenceService AS DS
						INNER JOIN BioGUID.dbo.PK AS PK ON DS.DereferenceServiceID = PK.PKID
						INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON DS.DereferenceServiceID = IDDS.DereferenceServiceID
						INNER JOIN BioGUID.dbo.IdentifierDomain AS ID ON IDDS.IdentifierDomainID = ID.IdentifierDomainID
					WHERE (ID.IdentifierDomain LIKE N'%' + @IdentifierDomain + N'%' OR
						ID.Abbreviation LIKE N'%' + @IdentifierDomain + N'%')
						AND DS.DereferenceServiceID NOT IN (SELECT PKID FROM @IDList WHERE TableName = N'Master')
				END

				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				-- Performance Log
				IF @DoLog = 1
				BEGIN
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Added Records based on @IdentifierDomain', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
			END
			ELSE IF ISNULL(@RecordCount, 0) > 0
			BEGIN
				IF ISNULL(@IdentifierDomainPKID, 0) <> 0 
				BEGIN
					-- Remove unmatched records
					DELETE @IDList
					FROM @IDList AS IDL 
					WHERE TableName = N'Master' 
						AND IDL.PKID NOT IN
							(
							SELECT DISTINCT DS.DereferenceServiceID
							FROM BioGUID.dbo.DereferenceService AS DS
								INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON DS.DereferenceServiceID = IDDS.DereferenceServiceID
							WHERE IDDS.IdentifierDomainID = @IdentifierDomainPKID
							)

					-- Performance Log
					IF @DoLog = 1
					BEGIN
						-- Capture RecordCount
						SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
						EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Removed Records based on @IdentifierDomain', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
						SET @StartTime = GETUTCDATE()
					END
					-- Capture RecordCount
					SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				END
				ELSE
				BEGIN
					-- Remove unmatched records
					DELETE @IDList
					FROM @IDList AS IDL 
					WHERE TableName = N'Master' 
						AND IDL.PKID NOT IN
							(
							SELECT DISTINCT DS.DereferenceServiceID
							FROM BioGUID.dbo.DereferenceService AS DS
								INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON DS.DereferenceServiceID = IDDS.DereferenceServiceID
								INNER JOIN BioGUID.dbo.IdentifierDomain AS ID ON IDDS.IdentifierDomainID = ID.IdentifierDomainID
							WHERE ID.IdentifierDomain LIKE N'%' + @IdentifierDomain + N'%' OR
								ID.Abbreviation LIKE N'%' + @IdentifierDomain + N'%'
							)

					-- Performance Log
					IF @DoLog = 1
					BEGIN
						-- Capture RecordCount
						SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
						EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Removed Records based on @IdentifierDomain', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
						SET @StartTime = GETUTCDATE()
					END
					-- Capture RecordCount
					SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				END

			END
		END

		-- Filter according to @SearchTerm
		IF LEN(ISNULL(@SearchTerm, N'')) >= @MinTermLength
		BEGIN
	
			-- Remove excess whitespace and single quotes
			SET @SearchTerm = dbo.RemoveWhitespace(@SearchTerm)
			SET @SearchTerm = REPLACE(@SearchTerm, '''', '')

			-- Need to process Identifier search before processing @SearchTerm
			IF ISNULL(@SearchIdentifier, 0) = 1
			BEGIN
				-- Add Records based on Vernacular Name Match
				SET @SQL =
				N'INSERT INTO BioGUIDDataServices.dbo.SearchIndex (SearchIndexID, SearchLogUUID, SearchSet) ' + 
				N'SELECT DISTINCT DS.DereferenceServiceID, N''' + CAST(@SessionID as nvarchar(36)) + N''', N''Identifier'' ' +
				N'FROM BioGUID.dbo.DereferenceService AS DS INNER JOIN BioGUID.dbo.Identifier AS I ON DS.DereferenceServiceID = I.PKID INNER JOIN BioGUID.dbo.PK AS IPK ON I.IdentifierID = IPK.PKID ' +
				N'WHERE IPK.PKID = IPK.CorrectID AND I.Identifier = ''' + @SearchTerm + ''''
				IF ISNULL(@Debug, 0) = 1
					SELECT @SQL
				ELSE
					EXEC(@SQL)
			END

			-- Generate @WHERE
			IF @SearchType = N'Equals'
				SET @WHERE = @WHERE + N'WHERE ' + dbo.ParseSearchTerm(@SearchTerm, 'DS.DereferenceService', 0, 1, @SearchType) + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'DS.DereferencePrefix', 0, 1, @SearchType) 
			ELSE
				SET @WHERE = @WHERE + N'WHERE ' + dbo.ParseSearchTerm(@SearchTerm, 'DS.DereferenceService', 0, 1, @SearchType) + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'DS.DereferencePrefix', 0, 1, @SearchType) + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'DS.[Description]', 0, 1, @SearchType) 

			-- Add Records based on search
			SET @SQL =
			N'INSERT INTO BioGUIDDataServices.dbo.SearchIndex (SearchIndexID, SearchLogUUID, SearchSet) ' + 
			N'SELECT DISTINCT DS.DereferenceServiceID, N''' + CAST(@SessionID as nvarchar(36)) + N''', N''DereferenceService'' ' +
			N'FROM BioGUID.dbo.DereferenceService AS DS ' +
			@WHERE
			IF ISNULL(@Debug, 0) = 1
				SELECT @SQL
			ELSE
				EXEC(@SQL)

			IF ISNULL(@RecordCount, 0) = -1
			BEGIN
				-- Insert the records
				INSERT INTO @IDList(PKID, TableName, PrioritySort)
				SELECT DISTINCT SearchIndexID, N'Master', 3 FROM SearchIndex WHERE SearchLogUUID = @SessionID AND SearchSet = N'DereferenceService'
				INSERT INTO @IDList(PKID, TableName, PrioritySort)
				SELECT DISTINCT SearchIndexID, N'Master', 4 FROM SearchIndex WHERE SearchLogUUID = @SessionID AND SearchSet = N'Identifier'

				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				-- Performance Log
				IF @DoLog = 1
				BEGIN
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Added Records based on @SearchTerm', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
			END
			ELSE IF ISNULL(@RecordCount, 0) > 0
			BEGIN
				-- Remove unmatched records
				DELETE @IDList
				WHERE TableName = N'Master' 
					AND PKID NOT IN (SELECT DISTINCT SearchIndexID FROM SearchIndex WHERE SearchLogUUID = @SessionID AND SearchSet IN(N'DereferenceService', N'Identifier'))

				-- Performance Log
				IF @DoLog = 1
				BEGIN
					-- Capture RecordCount
					SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Removed Records based on @SearchTerm', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
			END
		END		

		-- Filter based on @ObjectClassPKID
		IF ISNULL(@ObjectClassPKID, 0) <> 0
		BEGIN
			IF ISNULL(@RecordCount, 0) = -1
			BEGIN
				INSERT INTO @IDList(PKID, TableName, PrioritySort)
				SELECT DISTINCT DS.DereferenceServiceID, N'Master', 1
				FROM BioGUID.dbo.DereferenceService AS DS
					INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON DS.DereferenceServiceID = IDDS.DereferenceServiceID
					INNER JOIN BioGUID.dbo.Identifier AS I ON IDDS.IdentifierDomainID = I.IdentifierDomainID
					INNER JOIN BioGUID.dbo.IdentifiedObject AS O ON I.IdentifiedObjectID = O.IdentifiedObjectID
					INNER JOIN BioGUID.dbo.PK AS PK ON I.IdentifiedObjectID = PK.PKID
				WHERE PK.PKID = PK.CorrectID AND
				O.ObjectClassID = @ObjectClassPKID

				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'

				-- Performance Log
				IF @DoLog = 1
				BEGIN
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Added Records based on @ObjectClassPKID', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
			END
			ELSE
			BEGIN
				-- Remove unmatched records
				DELETE @IDList
				FROM @IDList AS IDL 
				WHERE TableName = N'Master' 
					AND IDL.PKID NOT IN
						(
						SELECT DISTINCT DS.DereferenceServiceID
						FROM BioGUID.dbo.DereferenceService AS DS
							INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON DS.DereferenceServiceID = IDDS.DereferenceServiceID
							INNER JOIN BioGUID.dbo.Identifier AS I ON IDDS.IdentifierDomainID = I.IdentifierDomainID
							INNER JOIN BioGUID.dbo.IdentifiedObject AS O ON I.IdentifiedObjectID = O.IdentifiedObjectID
							INNER JOIN BioGUID.dbo.PK AS PK ON I.IdentifiedObjectID = PK.PKID
						WHERE PK.PKID = PK.CorrectID AND
							O.ObjectClassID = @ObjectClassPKID
						)
				-- Performance Log
				IF @DoLog = 1
				BEGIN
					-- Capture RecordCount
					SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Removed Records based on @ObjectClassPKID', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
			END
		END

		-- Remove records
		IF ISNULL(@RecordCount, 0) > 0
		BEGIN
			-- Remove Zero records 
			DELETE IDL FROM @IDList AS IDL WHERE IDL.PKID=0

			-- Remove Non-Correct Records
			DELETE IDL FROM @IDList AS IDL INNER JOIN BioGUID.dbo.PK AS PK ON IDL.PKID = PK.PKID WHERE PK.PKID <> PK.CorrectID

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				-- Capture RecordCount
				SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Removed Zero and Incorrect Records', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
			-- Capture RecordCount
			SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
		END
	END

	-- Generate Results
	--Establish FROM
	SET @FROM = N'FROM view_SearchDereferenceService AS SDS INNER JOIN @IDList AS IDL ON SDS.DereferenceServiceID = IDL.PKID '

	-- Establish @ColumnList
	SET @ColumnList = @ColumnList + N'SDS.DereferenceServiceUUID, SDS.DereferenceServiceProtocol, SDS.DereferenceService, SDS.DereferencePrefix, SDS.DereferenceSuffix, SDS.Description '

	-- Finalize @SQL
	SET @SQL = 'SELECT '
	IF ISNULL(@Top, 0) > 0
		SET @SQL = @SQL + 'TOP(' + CAST(@Top AS varchar) + ') '
	SET @SQL = @SQL + @ColumnList + @FROM + @OrderBy
		
	-- Retrieve Results
	IF ISNULL(@Debug, 0) = 1
	BEGIN
		SELECT @SQL
		SELECT * FROM @IDList
	END
	ELSE
		EXEC sp_executesql @SQL, N'@IDList PKIDListType READONLY', @IDList

	SELECT @RecordCount = COUNT(*) FROM @IDList
	
	-- Performance Log
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Results Returned', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
	
	-- Log Query Results
	INSERT INTO BioGUIDLocalLog.dbo.SearchLog (SearchUUID, StoredProcedure, [Parameters], UserName, StartTime, EndTime)
	SELECT @SessionID, N'sp_SearchDereferenceService', @Parameters, NULLIF(@UserName, N''), @T0, GETUTCDATE()
	INSERT INTO BioGUIDLocalLog.dbo.SearchResult (SearchLogID, PKID)
	SELECT DISTINCT IDENT_CURRENT('BioGUIDLocalLog.dbo.SearchLog'), PKID FROM @IDList
	DELETE BioGUIDDataServices.dbo.SearchIndex WHERE SearchLogUUID = @SessionID

	-- Performance Log
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchDereferenceService', @Task = 'Search Parameters and Results Logged', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SearchEnumeration]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 30 April 2013
-- DESCRIPTION:
--		Returns a list of matching Enumeration Values
--
-- INPUT PARAMETERS:
--		NONE
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		NONE
--
-- REFERENCED VIEWS:
--		NONE
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_SearchEnumeration]
	-- Add the parameters for the stored procedure here
	-- =============================================
	@EnumerationID			int				= 0,
	@EnumerationUUID		varchar(36)		= 0,
	@Enumeration			nvarchar(500)	= '',
	@EnumerationType		nvarchar(500)	= '',
	@SearchTerm				nvarchar(500)	= '',
	@Debug					bit				= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @EnumerationTypeID	int				= 0
	DECLARE @SQL				nvarchar(MAX)	= ''		-- 
	DECLARE @FROM				varchar(MAX)	= ''
	DECLARE @WHERE				nvarchar(MAX)	= ''		--
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	IF ISNULL(@EnumerationType, '') <> ''
		SET @EnumerationTypeID = dbo.GetEnumerationID(@EnumerationType, '')

	IF ISNULL(@EnumerationID, 0) = 0
		SET @EnumerationID = dbo.GetEnumerationID(@Enumeration, @EnumerationType)
-- =============================================================================

-- Operational Code
-- =============================================================================

	IF ISNULL(@EnumerationID, 0) <> 0
		SET @WHERE = @WHERE + ' AND (E.EnumerationID = ' + CAST(@EnumerationID AS nvarchar) + ')'

	IF ISNULL(@EnumerationTypeID, 0) <> 0
		SET @WHERE = @WHERE + ' AND (E.EnumerationTypeID IN (SELECT EnumerationID FROM dbo.FullEnumerationParentList(' + CAST(@EnumerationTypeID AS nvarchar) + ')))'

	IF ISNULL(@Enumeration, '') <> ''
		SET @WHERE = @WHERE + ' AND (E.EnumerationValue = ''' + @Enumeration + ''')'

	IF ISNULL(@SearchTerm, '') <> ''
		SET @WHERE = @WHERE + ' AND (E.EnumerationValue LIKE ''%' + @SearchTerm + '%'')'
	
	IF ISNULL(@WHERE, '') <> ''
	BEGIN

		SET @WHERE = SUBSTRING(@WHERE, 6, LEN(@WHERE))

		SET @SQL = 'SELECT E.EnumerationID, E.EnumerationValue, E.EnumerationTypeID, ET.EnumerationValue AS EnumerationType, E.Description, E.Sequence FROM BioGUID.dbo.Enumeration AS E LEFT OUTER JOIN BioGUID.dbo.Enumeration AS ET ON E.EnumerationTypeID = ET.EnumerationID WHERE ' + @WHERE + ' ORDER BY ET.Sequence, ET.EnumerationValue, E.Sequence, E.EnumerationValue'
		
	END
	
	IF @Debug = 1
		SELECT @SQL
	ELSE
		EXEC(@SQL)
-- =============================================================================
END




GO
/****** Object:  StoredProcedure [dbo].[sp_SearchFAQ]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 9 March 2015
-- DESCRIPTION:
--		Searches news items
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_SearchFAQ] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@FAQ					varchar(255)	= NULL, 
	@Category				varchar(255)	= NULL, 
	@LogUserName			nvarchar(128)	= NULL,
	@Top					int				= 0,
	@FAQID				int				= 0	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @OUT			nvarchar(MAX)	= N''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	IF ISNULL(@Top, 0) = 0
		SET @TOP = 100000
-- =============================================================================

-- Operational Code
-- =============================================================================
	SELECT TOP(@TOP) *
	FROM BioGUIDDataServices.dbo.view_SearchFAQ
	WHERE (ISNULL(@FAQ, '') = '' OR Question LIKE '%' + @FAQ + '%' OR Question LIKE '%' + @FAQ + '%' )
		AND (@Category IS NULL OR Category LIKE '%' + @Category + '%')
		AND (ISNULL(@FAQID, 0) = 0 OR FAQID = @FAQID)
	ORDER BY 
		CASE 
			WHEN Category = 'Genera1' THEN 1
			WHEN Category = 'Identifier' THEN 2
			WHEN Category = 'IdentifierDomain' THEN 3
			WHEN Category = 'DereferenceService' THEN 4
			WHEN Category = 'Object' THEN 5
		END,
		[Sequence]
-- =============================================================================
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SearchIdentifier]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 1 March 2015
-- EDIT DATE:	8 April 2015 (added @SearchType as input param and added support for 'Identifier' SearchType
-- DESCRIPTION:
--		Creates a list of Objects based on Identifier search parameters.
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		sp_PerformanceLog
--		dbo.GetItemID
--		dbo.IsUUID
--		dbo.GetPKID
--
-- REFERENCED VIEWS
--		view_SearchIdentifier
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_SearchIdentifier]
	-- Add the parameters for the stored procedure here
	-- =============================================
	@IdentifierDomain		nvarchar(255)	= N'',
	@DereferenceService		nvarchar(255)	= N'',
	@ObjectClass			nvarchar(255)	= N'',
	@SearchTerm				nvarchar(255)	= N'',
	@SearchType				nvarchar(255)	= N'Word Equals',
	@MinTermLength			tinyint			= 2,
	@IncludeHidden			bit				= 0,
	@UserName				nvarchar(128)	= N'Anonymous',
	@Top					int				= 500,
	@SessionID				uniqueidentifier= NULL,
	@DoLog					bit				= 1,
	@Debug					bit				= 0	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @SQL					nvarchar(MAX)		= ''
	DECLARE @FROM					varchar(MAX)		= ''
	DECLARE @WHERE					nvarchar(MAX)		= ''
	DECLARE @OrderBy				nvarchar(MAX)		= ''
	DECLARE @OriginalSearchterm		nvarchar(255)		= N''
	DECLARE @ColumnList				nvarchar(MAX)		= N''
	DECLARE @IdentifierDomainPKID	int					= 0
	DECLARE @DereferenceServicePKID	int					= 0
	DECLARE @ObjectClassPKID		int					= 0
	DECLARE @T0						datetime			= GETUTCDATE()
	DECLARE @StartTime				datetime			= GETUTCDATE()
	DECLARE @Parameters				nvarchar(MAX)		= ''
	DECLARE @IDList					PKIDListType
	DECLARE @ResultSet				IDResponseType
	DECLARE @RecordCount			int					= -1
	DECLARE @Pos					int					= 0
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Capture Input Parameters
	SET @Parameters = 
		N'@IdentifierDomain=' + ISNULL(@IdentifierDomain, N'[NULL]') + N'|' + 
		N'@DereferenceService=' + ISNULL(@DereferenceService, N'[NULL]') + N'|' + 
		N'@ObjectClass=' + ISNULL(@ObjectClass, N'[NULL]') + N'|' + 
		N'@SearchTerm=' + ISNULL(CAST(@SearchTerm AS nvarchar(255)), N'[NULL]') + N'|' + 
		N'@SearchType=' + ISNULL(CAST(@SearchType AS nvarchar(255)), N'[NULL]') + N'|' + 
		N'@MinTermLength=' + ISNULL(CAST(@MinTermLength AS nvarchar), N'[NULL]') + N'|' + 
		N'@IncludeHidden=' + ISNULL(CAST(@IncludeHidden AS nvarchar), N'[NULL]') + N'|' + 
		N'@UserName=' + ISNULL(@UserName, N'[NULL]') + N'|' + 
		N'@Top=' + ISNULL(CAST(@Top AS nvarchar), N'[NULL]') + N'|' + 
		N'@SessionID=' + ISNULL(CAST(@SessionID AS nvarchar(36)), N'[NULL]') + N'|' + 
		N'@DoLog=' + ISNULL(CAST(@DoLog AS nvarchar), N'[NULL]') + N'|' + 
		N'@Debug=' + ISNULL(CAST(@Debug AS nvarchar), N'[NULL]')

	-- Convert @IdentifierDomain to @IdentifierDomainPKID
	IF ISNULL(@IdentifierDomain, '') <> ''
		SET @IdentifierDomainPKID = dbo.GetIdentifierDomainID(@IdentifierDomain, 1)

	-- Convert @DereferenceService to @DereferenceServicePKID
	IF ISNULL(@DereferenceService, '') <> ''
		SET @DereferenceServicePKID = dbo.GetDereferenceServiceID(@DereferenceService, 1)

	-- Convert @ObjectClass to @ObjectClassPKID
	IF ISNULL(@ObjectClass, '') <> ''
		SET @ObjectClassPKID = dbo.GetEnumerationID(@ObjectClass, 'ObjectClasses')

	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())

	-- Trap for Null @SearchType
	SET @SearchType = ISNULL(@SearchType, N'Word Equals')

	-- Process SearchTerm
	IF ISNULL(@SearchTerm, '') <> ''
	BEGIN
		SET @SearchTerm = dbo.RemoveWhitespace(@SearchTerm)
		SET @OriginalSearchterm = @Searchterm
		SET @SearchTerm = BioGUID.dbo.CleanSearchTerm(@SearchTerm)
	END

	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================

-- Operational Code
-- =============================================================================
	--Initialize @OrderBy
	SET @OrderBy = N' ORDER BY SI.ObjectClass, IDL.PrioritySort, SI.ObjectID, CASE WHEN BioGUID.dbo.CleanSearchTerm(SI.Identifier) = ''' + BioGUID.dbo.CleanSearchTerm(@OriginalSearchterm) + ''' THEN 0 ELSE 1 END, CASE WHEN BioGUID.dbo.CleanSearchTerm(SI.Identifier) LIKE ''%' + BioGUID.dbo.CleanSearchTerm(@OriginalSearchterm) + '%'' THEN 0 ELSE 1 END, SI.IdentifierDomain, SI.Identifier'

	-- Filter based on provided criteria, starting with most restrictive
	-- Filter based on @SearchTerm

	-- Filter according to @SearchTerm
	IF ISNULL(@SearchTerm, N'') <> N'' AND LEN(@SearchTerm) >= @MinTermLength
	BEGIN
		-- Use Full Text Search
		IF ISNULL(@SearchType, '') = N'Full String'
			SET @SearchTerm = N'"' + @SearchTerm + N'"'
		ELSE IF ISNULL(@SearchType, '') = N'Word Equals'
			SET @SearchTerm = N'"' + REPLACE(@SearchTerm, N' ', N'" AND "') + N'"'
		ELSE IF ISNULL(@SearchType, '') = 'Identifier'
		BEGIN
			IF LEFT(@SearchTerm, 7) = 'http://'
			BEGIN
				WHILE CHARINDEX('/', @SearchTerm, @Pos+1) > 0
				BEGIN
					SET @Pos = CHARINDEX('/', @SearchTerm, @Pos + 1)
				END
				SET @SearchTerm = SUBSTRING(@SearchTerm, @Pos + 1, LEN(@SearchTerm))
			END
		END
		ELSE
			SET @SearchTerm = N'"' + REPLACE(@SearchTerm, N' ', N'*" AND "') + N'*"'
		SET @WHERE = N'WHERE CONTAINS(O.CacheIdentifiers, N''' + @SearchTerm + N''')'

		-- Add Records based on search
		SET @SQL =
		N'INSERT INTO BioGUIDDataServices.dbo.SearchIndex (SearchIndexID, SearchLogUUID, SearchSet) ' + 
		N'SELECT DISTINCT '
		IF ISNULL(@Top, 0) > 0
			SET @SQL = @SQL + N'TOP(' + CAST(@Top as nvarchar) + N') '
		IF @SearchType = N'Identifier'
			SET @SQL = @SQL + N'I.IdentifiedObjectID, N''' + CAST(@SessionID as nvarchar(36)) + N''', N''Object'' FROM BioGUID.dbo.Identifier AS I WHERE I.Identifier = ''' + @SearchTerm + ''''
		ELSE
			SET @SQL = @SQL + N'O.IdentifiedObjectID, N''' + CAST(@SessionID as nvarchar(36)) + N''', N''Object'' FROM BioGUID.dbo.IdentifiedObject AS O ' + @WHERE
		
		EXEC(@SQL)

		IF ISNULL(@Debug, 0) = 1
			SELECT 'SearchTerm SQL' AS Process, @SQL AS [SQL]

		-- Insert the records
		INSERT INTO @IDList(PKID, TableName)
		SELECT DISTINCT SearchIndexID, N'Master' FROM SearchIndex WHERE SearchLogUUID = @SessionID AND SearchSet = N'Object'

		-- Capture RecordCount
		SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
		-- Performance Log
		IF @DoLog = 1
		BEGIN
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Added Records based on @SearchTerm', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END

	-- Future consideration: Add code that repeats the Searchterm search process but removing all spaces.

	END		

	-- Filter based on @IdentifierDomain
	IF ISNULL(@IdentifierDomainPKID, 0) <> 0
	BEGIN
		IF ISNULL(@RecordCount, 0) = -1
		BEGIN
			IF ISNULL(@Top, 0) = 0
				INSERT INTO @IDList(PKID, TableName)
				SELECT DISTINCT O.IdentifiedObjectID, N'Master'
				FROM BioGUID.dbo.IdentifiedObject AS O
					INNER JOIN BioGUID.dbo.Identifier AS I ON O.IdentifiedObjectID = I.IdentifiedObjectID
				WHERE I.IdentifierDomainID = @IdentifierDomainPKID
			ELSE
				INSERT INTO @IDList(PKID, TableName)
				SELECT DISTINCT TOP(@Top) O.IdentifiedObjectID, N'Master'
				FROM BioGUID.dbo.IdentifiedObject AS O
					INNER JOIN BioGUID.dbo.Identifier AS I ON O.IdentifiedObjectID = I.IdentifiedObjectID
				WHERE I.IdentifierDomainID = @IdentifierDomainPKID

			-- Capture RecordCount
			SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Added Records based on @IdentifierDomain', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END
		ELSE IF ISNULL(@RecordCount, 0) > 0
		BEGIN
			-- Remove unmatched records
			DELETE @IDList
			FROM @IDList AS IDL 
			WHERE TableName = N'Master' 
				AND IDL.PKID NOT IN
					(
					SELECT DISTINCT O.IdentifiedObjectID
					FROM BioGUID.dbo.IdentifiedObject AS O
						INNER JOIN BioGUID.dbo.Identifier AS I ON O.IdentifiedObjectID = I.IdentifiedObjectID
					WHERE I.IdentifierDomainID = @IdentifierDomainPKID
					)

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Removed Records based on @IdentifierDomain', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END
	END

	-- Filter based on @DereferenceService
	IF ISNULL(@DereferenceServicePKID, 0) <> 0
	BEGIN
		IF ISNULL(@RecordCount, 0) = -1
		BEGIN
			IF ISNULL(@Top, 0) = 0
				INSERT INTO @IDList(PKID, TableName)
				SELECT DISTINCT O.IdentifiedObjectID, N'Master'
				FROM BioGUID.dbo.IdentifiedObject AS O
					INNER JOIN BioGUID.dbo.Identifier AS I ON O.IdentifiedObjectID = I.IdentifiedObjectID
					INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON I.IdentifierDomainID = IDDS.IdentifierDomainID
				WHERE IDDS.DereferenceServiceID = @DereferenceServicePKID
			ELSE
				INSERT INTO @IDList(PKID, TableName)
				SELECT DISTINCT TOP(@Top) O.IdentifiedObjectID, N'Master'
				FROM BioGUID.dbo.IdentifiedObject AS O
					INNER JOIN BioGUID.dbo.Identifier AS I ON O.IdentifiedObjectID = I.IdentifiedObjectID
					INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON I.IdentifierDomainID = IDDS.IdentifierDomainID
				WHERE IDDS.DereferenceServiceID = @DereferenceServicePKID

			-- Capture RecordCount
			SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Added Records based on @DereferenceService', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END
		ELSE IF ISNULL(@RecordCount, 0) > 0
		BEGIN
			-- Remove unmatched records
			DELETE @IDList
			FROM @IDList AS IDL 
			WHERE TableName = N'Master' 
				AND IDL.PKID NOT IN
					(
					SELECT DISTINCT O.IdentifiedObjectID
					FROM BioGUID.dbo.IdentifiedObject AS O
						INNER JOIN BioGUID.dbo.Identifier AS I ON O.IdentifiedObjectID = I.IdentifiedObjectID
						INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON I.IdentifierDomainID = IDDS.IdentifierDomainID
					WHERE IDDS.DereferenceServiceID = @DereferenceServicePKID
					)
			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Removed Records based on @DereferenceService', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END
	END

	-- Filter based on @ObjectClass
	IF ISNULL(@ObjectClassPKID, 0) <> 0
	BEGIN
		IF ISNULL(@RecordCount, 0) = -1
		BEGIN
			INSERT INTO @IDList(PKID, TableName)
			SELECT DISTINCT O.IdentifiedObjectID, N'Master'
			FROM BioGUID.dbo.IdentifiedObject AS O
			WHERE O.ObjectClassID = @ObjectClassPKID

			-- Capture RecordCount
			SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Added Records based on @ObjectClass', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END
		ELSE IF ISNULL(@RecordCount, 0) > 0
		BEGIN
			-- Remove unmatched records
			DELETE @IDList
			FROM @IDList AS IDL 
			WHERE TableName = N'Master' 
				AND IDL.PKID NOT IN
					(
					SELECT DISTINCT O.IdentifiedObjectID
					FROM BioGUID.dbo.IdentifiedObject AS O
					WHERE O.ObjectClassID = @ObjectClassPKID
					)
			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Removed Records based on @ObjectClass', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END
	END

	-- Remove records
	IF ISNULL(@RecordCount, 0) > 0
	BEGIN
		-- Remove Zero records 
		DELETE IDL FROM @IDList AS IDL WHERE IDL.PKID=0

		-- Remove Non-Correct Records
		DELETE IDL FROM @IDList AS IDL INNER JOIN BioGUID.dbo.PK AS PK ON IDL.PKID = PK.PKID WHERE PK.PKID <> PK.CorrectID

		-- Performance Log
		IF @DoLog = 1
		BEGIN
			-- Capture RecordCount
			SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList
			EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Removed Zero and Incorrect Records', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
			SET @StartTime = GETUTCDATE()
		END
		-- Capture RecordCount
		SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
	END

	-- Generate Results

	-- Prioritize Results
	UPDATE @IDList SET PrioritySort = SRC.PrioritySort
	FROM @IDList AS IDL
		INNER JOIN 
		(
		SELECT IDL.PKID, MIN(CASE WHEN @OriginalSearchterm = I.Identifier THEN 0 WHEN I.Identifier LIKE '%' + @OriginalSearchterm + '%' THEN 1 ELSE 2 END) AS PrioritySort
		FROM @IDList AS IDL
			INNER JOIN BioGUID.dbo.Identifier AS I ON IDL.PKID = I.IdentifiedObjectID
		GROUP BY IDL.PKID
		) AS SRC ON IDL.PKID = SRC.PKID

	-- Performance Log
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Establish PrioritySort', @RecordCount = @@ROWCOUNT, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END

	--Establish FROM
	SET @FROM = N'FROM view_SearchIdentifier AS SI INNER JOIN @IDList AS IDL ON SI.ObjectID = IDL.PKID '

	-- Establish @ColumnList
	SET @ColumnList = @ColumnList + N'SI.ObjectID, SI.ObjectClass, SI.IdentifierDomainUUID, SI.IdentifierClass, SI.Abbreviation, SI.IdentifierDomain, SI.IdentifierDomainDescription, SI.IdentifierDomainLogo, SI.AgentUUID, SI.PreferredDereferenceServiceUUID, SI.PreferredDereferenceServiceProtocol, SI.PreferredDereferenceService, SI.PreferredDereferenceServiceDescription, SI.PreferredDereferencePrefix, SI.Identifier, SI.PreferredDereferenceSuffix, SI.PreferredDereferenceServiceLogo, dbo.FormatAlternateDereferenceServices(SI.IdentifierDomainUUID) AS AlternateDereferenceServices, CASE WHEN IDL.PrioritySort < 2 THEN 1 ELSE 0 END AS IsMatch, CASE WHEN IDL.PrioritySort = 0 THEN 1 ELSE 0 END AS IsExactMatch '-- CASE WHEN BioGUID.dbo.CleanSearchTerm(SI.Identifier) LIKE ''%' + BioGUID.dbo.CleanSearchTerm(@OriginalSearchterm) + '%'' THEN 1 ELSE 0 END AS IsMatch, CASE WHEN BioGUID.dbo.CleanSearchTerm(SI.Identifier) = ''' + BioGUID.dbo.CleanSearchTerm(@OriginalSearchterm) + ''' THEN 1 ELSE 0 END AS IsExactMatch '

	-- Remove Hidden Records
	IF ISNULL(@IncludeHidden, 0) <> 1
		SET @WHERE = ' WHERE IsHidden = 0'
	ELSE
		SET @WHERE = ''

	-- Finalize @SQL
	SET @SQL = 'SELECT '
	IF ISNULL(@Top, 0) > 0
		SET @SQL = @SQL + 'TOP(' + CAST(@Top AS varchar) + ') '
	SET @SQL = @SQL + @ColumnList + @FROM + @WHERE + @OrderBy
		
	-- Retrieve Results
	IF ISNULL(@Debug, 0) = 1
	BEGIN
		SELECT 'Record Retrieval' AS Process, @SQL AS [SQL], @SessionID AS SessionID
		SELECT * FROM @IDList
	END
	ELSE
		EXEC sp_executesql @SQL, N'@IDList PKIDListType READONLY', @IDList

	SELECT @RecordCount = COUNT(*) FROM @IDList
	
	-- Performance Log
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Results Returned', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
	
	-- Log Query Results
	IF ISNULL(@Debug, 0) = 0
	BEGIN
		INSERT INTO BioGUIDLocalLog.dbo.SearchLog (SearchUUID, StoredProcedure, [Parameters], UserName, StartTime, EndTime)
		SELECT @SessionID, N'sp_SearchIdentifier', @Parameters, NULLIF(@UserName, N''), @T0, GETUTCDATE()
		INSERT INTO BioGUIDLocalLog.dbo.SearchResult (SearchLogID, PKID)
		SELECT DISTINCT IDENT_CURRENT('BioGUIDLocalLog.dbo.SearchLog'), PKID FROM @IDList
	END
	DELETE BioGUIDDataServices.dbo.SearchIndex WHERE SearchLogUUID = @SessionID

	-- Performance Log
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifier', @Task = 'Search Parameters and Results Logged', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()

		IF ISNULL(@Debug, 0) = 1
			EXEC sp_PerformanceSummary @SessionID = @SessionID
	END
-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SearchIdentifierDomain]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 26 February 2015
-- DESCRIPTION:
--		Creates a list of IdentifierDomains based on various input search parameters.
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
--		sp_GetUserName
--		sp_aspnetdbGetRolesForUser
--		sp_PerformanceLog
--		dbo.ParseSearchTerm
--		dbo.GetItemID
--		dbo.IsUUID
--		dbo.GetPKID
--
-- REFERENCED VIEWS
--		view_SearchIdentifierDomain
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_SearchIdentifierDomain]
	-- Add the parameters for the stored procedure here
	-- =============================================
	@IdentifierDomain		nvarchar(255)	= N'',
	@DereferenceService		nvarchar(255)	= N'',
	@ObjectClass			nvarchar(255)	= N'',
	@SearchTerm				nvarchar(255)	= N'',
	@MinTermLength			tinyint			= 2,
	@SearchType				nvarchar(15)	= N'Word Start',
	@SearchIdentifier		bit				= 0,
	@IncludeHidden			bit				= 0,
	@UserName				nvarchar(128)	= N'Anonymous',
	@OrderBy				nvarchar(1000)	= N'',
	@Top					int				= 0,
	@SessionID				uniqueidentifier= NULL,
	@DoLog					bit				= 1,
	@Debug					bit				= 0	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @SQL					nvarchar(MAX)		= ''
	DECLARE @FROM					varchar(MAX)		= ''
	DECLARE @WHERE					nvarchar(MAX)		= ''
	DECLARE @ColumnList				nvarchar(MAX)		= N''
	DECLARE @IdentifierDomainPKID	int					= 0
	DECLARE @DereferenceServicePKID	int					= 0
	DECLARE @ObjectClassPKID		int					= 0
	DECLARE @T0						datetime			= GETUTCDATE()
	DECLARE @StartTime				datetime			= GETUTCDATE()
	DECLARE @Parameters				nvarchar(MAX)		= ''
	DECLARE @IDList					PKIDListType
	DECLARE @RecordCount			int					= -1
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	-- Capture Input Parameters
	SET @Parameters = 
		N'@IdentifierDomain=' + ISNULL(@IdentifierDomain, N'[NULL]') + N'|' + 
		N'@DereferenceService=' + ISNULL(@DereferenceService, N'[NULL]') + N'|' + 
		N'@ObjectClass=' + ISNULL(@ObjectClass, N'[NULL]') + N'|' + 
		N'@SearchTerm=' + ISNULL(CAST(@SearchTerm AS nvarchar(255)), N'[NULL]') + N'|' + 
		N'@MinTermLength=' + ISNULL(CAST(@MinTermLength AS nvarchar), N'[NULL]') + N'|' + 
		N'@SearchType=' + ISNULL(@SearchType, N'[NULL]') + N'|' + 
		N'@SearchIdentifier=' + ISNULL(CAST(@SearchIdentifier AS nvarchar), N'[NULL]') + N'|' + 
		N'@IncludeHidden=' + ISNULL(CAST(@IncludeHidden AS nvarchar), N'[NULL]') + N'|' + 
		N'@UserName=' + ISNULL(@UserName, N'[NULL]') + N'|' + 
		N'@OrderBy=' + ISNULL(@OrderBy, N'[NULL]') + N'|' + 
		N'@Top=' + ISNULL(CAST(@Top AS nvarchar), N'[NULL]') + N'|' + 
		N'@SessionID=' + ISNULL(CAST(@SessionID AS nvarchar(36)), N'[NULL]') + N'|' + 
		N'@DoLog=' + ISNULL(CAST(@DoLog AS nvarchar), N'[NULL]') + N'|' + 
		N'@Debug=' + ISNULL(CAST(@Debug AS nvarchar), N'[NULL]')

	-- Convert @IdentifierDomain to @IdentifierDomainPKID
	IF ISNULL(@IdentifierDomain, '') <> ''
		SET @IdentifierDomainPKID = dbo.GetIdentifierDomainID(@IdentifierDomain, 1)

	-- Convert @DereferenceService to @DereferenceServicePKID
	IF ISNULL(@DereferenceService, '') <> ''
		SET @DereferenceServicePKID = dbo.GetDereferenceServiceID(@DereferenceService, 1)

	-- Convert @ObjectClass to @ObjectClassPKID
	IF ISNULL(@ObjectClass, '') <> ''
		SET @ObjectClassPKID = dbo.GetEnumerationID(@ObjectClass, 'ObjectClasses')

	-- Trap for null or empty @SearchType
	SET @SearchType = ISNULL(NULLIF(@SearchType, N''), N'Word Start')

	-- Trap for Null @SessionID
	SET @SessionID = ISNULL(@SessionID, NEWID())

	-- Intercept UUID in @SearchTerm
	IF dbo.IsUUID(dbo.NormalizeUUID(@SearchTerm)) = 1 AND ISNULL(@IdentifierDomainPKID, 0) = 0
	BEGIN
		SET @IdentifierDomainPKID = dbo.GetIdentifierDomainID(@SearchTerm, 1)
		SET @SearchTerm = ''
	END

	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Established initial variable values', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================

-- Operational Code
-- =============================================================================
	-- Filter Records, starting with @IdentifierDomainPKID
	IF ISNULL(@IdentifierDomainPKID, 0) <> 0
	BEGIN 
		INSERT INTO @IDList(PKID, TableName, PrioritySort)
		SELECT @IdentifierDomainPKID, N'Master', 0

		SET @OrderBy = ''
		SET @RecordCount = 1
	END
	ELSE
	BEGIN
		--Initialize @OrderBy
		IF ISNULL(@OrderBy, '') = ''
			SET @OrderBy = N'SID.IdentifierDomain'
		ELSE
			SET @OrderBy = N'SID.' + REPLACE(REPLACE(@OrderBy, N' ', N''), N',', N', SID.')
		
		SET @OrderBy = N' ORDER BY ' + @OrderBy			

		-- Filter based on provided criteria, starting with most restrictive
		-- Filter based on @IdentifierDomain
		IF LEN(ISNULL(@IdentifierDomain, '')) >= @MinTermLength
		BEGIN
			INSERT INTO @IDList(PKID, TableName, PrioritySort)
			SELECT DISTINCT ID.IdentifierDomainID, N'Master', 1
			FROM BioGUID.dbo.IdentifierDomain AS ID
				INNER JOIN BioGUID.dbo.PK AS PK ON ID.IdentifierDomainID = PK.PKID
			WHERE (ID.IdentifierDomain LIKE N'%' + @IdentifierDomain + N'%' OR
				ID.Abbreviation LIKE N'%' + @IdentifierDomain + N'%')

			-- Capture RecordCount
			SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Added Records based on @IdentifierDomain', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
		END

		-- Filter based on @DereferenceService
		IF ISNULL(@DereferenceServicePKID, 0) <> 0  OR LEN(ISNULL(@DereferenceService, '')) >= @MinTermLength
		BEGIN
			IF ISNULL(@RecordCount, 0) = -1
			BEGIN
				IF ISNULL(@DereferenceServicePKID, 0) <> 0 
				BEGIN
					INSERT INTO @IDList(PKID, TableName, PrioritySort)
					SELECT DISTINCT ID.IdentifierDomainID, N'Master', 2
					FROM BioGUID.dbo.IdentifierDomain AS ID
						INNER JOIN BioGUID.dbo.PK AS PK ON ID.IdentifierDomainID = PK.PKID
						INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON ID.IdentifierDomainID = IDDS.IdentifierDomainID
					WHERE IDDS.DereferenceServiceID = @DereferenceServicePKID
						AND ID.IdentifierDomainID NOT IN (SELECT PKID FROM @IDList WHERE TableName = N'Master')
				END
				ELSE IF LEN(ISNULL(@DereferenceService, '')) >= @MinTermLength
				BEGIN
					INSERT INTO @IDList(PKID, TableName, PrioritySort)
					SELECT DISTINCT ID.IdentifierDomainID, N'Master', 2
					FROM BioGUID.dbo.IdentifierDomain AS ID
						INNER JOIN BioGUID.dbo.PK AS PK ON ID.IdentifierDomainID = PK.PKID
						INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON ID.IdentifierDomainID = IDDS.IdentifierDomainID
						INNER JOIN BioGUID.dbo.DereferenceService AS DS ON IDDS.DereferenceServiceID = DS.DereferenceServiceID
					WHERE (DS.DereferenceService LIKE N'%' + @DereferenceService + N'%' OR
						DS.DereferencePrefix LIKE N'%' + @DereferenceService + N'%')
						AND ID.IdentifierDomainID NOT IN (SELECT PKID FROM @IDList WHERE TableName = N'Master')
				END

				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				-- Performance Log
				IF @DoLog = 1
				BEGIN
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Added Records based on @DereferenceService', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
			END
			ELSE IF ISNULL(@RecordCount, 0) > 0
			BEGIN
				IF ISNULL(@DereferenceServicePKID, 0) <> 0 
				BEGIN
					-- Remove unmatched records
					DELETE @IDList
					FROM @IDList AS IDL 
					WHERE TableName = N'Master' 
						AND IDL.PKID NOT IN
							(
							SELECT DISTINCT ID.IdentifierDomainID
							FROM BioGUID.dbo.IdentifierDomain AS ID
								INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON ID.IdentifierDomainID = IDDS.IdentifierDomainID
							WHERE IDDS.DereferenceServiceID = @DereferenceServicePKID
							)

					-- Performance Log
					IF @DoLog = 1
					BEGIN
						-- Capture RecordCount
						SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
						EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Removed Records based on @DereferenceService', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
						SET @StartTime = GETUTCDATE()
					END
					-- Capture RecordCount
					SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				END
				ELSE
				BEGIN
					-- Remove unmatched records
					DELETE @IDList
					FROM @IDList AS IDL 
					WHERE TableName = N'Master' 
						AND IDL.PKID NOT IN
							(
							SELECT DISTINCT ID.IdentifierDomainID
							FROM BioGUID.dbo.IdentifierDomain AS ID
								INNER JOIN BioGUID.dbo.IdentifierDomainDereferenceService AS IDDS ON ID.IdentifierDomainID = IDDS.IdentifierDomainID
								INNER JOIN BioGUID.dbo.DereferenceService AS DS ON IDDS.DereferenceServiceID = DS.DereferenceServiceID
							WHERE DS.DereferenceService LIKE N'%' + @DereferenceService + N'%' OR
								DS.DereferencePrefix LIKE N'%' + @DereferenceService + N'%'
							)

					-- Performance Log
					IF @DoLog = 1
					BEGIN
						-- Capture RecordCount
						SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
						EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Removed Records based on @DereferenceService', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
						SET @StartTime = GETUTCDATE()
					END
					-- Capture RecordCount
					SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				END

			END
		END

		-- Filter according to @SearchTerm
		IF LEN(ISNULL(@SearchTerm, N'')) >= @MinTermLength
		BEGIN
	
			-- Remove excess whitespace and single quotes
			SET @SearchTerm = dbo.RemoveWhitespace(@SearchTerm)
			SET @SearchTerm = REPLACE(@SearchTerm, '''', '')

			-- Need to process Identifier search before processing @SearchTerm
			IF ISNULL(@SearchIdentifier, 0) = 1
			BEGIN
				-- Add Records based on Vernacular Name Match
				SET @SQL =
				N'INSERT INTO BioGUIDDataServices.dbo.SearchIndex (SearchIndexID, SearchLogUUID, SearchSet) ' + 
				N'SELECT DISTINCT ID.IdentifierDomainID, N''' + CAST(@SessionID as nvarchar(36)) + N''', N''Identifier'' ' +
				N'FROM BioGUID.dbo.IdentifierDomain AS ID INNER JOIN BioGUID.dbo.Identifier AS I ON ID.IdentifierDomainID = I.PKID INNER JOIN BioGUID.dbo.PK AS IPK ON I.IdentifierID = IPK.PKID ' +
				N'WHERE IPK.PKID = IPK.CorrectID AND I.Identifier = ''' + @SearchTerm + ''''
				IF ISNULL(@Debug, 0) = 1
					SELECT @SQL
				ELSE
					EXEC(@SQL)
			END

			-- Generate @WHERE
			IF @SearchType = N'Equals'
				SET @WHERE = @WHERE + N'WHERE ' + dbo.ParseSearchTerm(@SearchTerm, 'ID.IdentifierDomain', 0, 1, @SearchType) + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'ID.Abbreviation', 0, 1, @SearchType)
			ELSE
				SET @WHERE = @WHERE + N'WHERE ' + dbo.ParseSearchTerm(@SearchTerm, 'ID.IdentifierDomain', 0, 1, @SearchType) + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'ID.Abbreviation', 0, 1, @SearchType) + N' OR ' + dbo.ParseSearchTerm(@SearchTerm, 'ID.[Description]', 0, 1, @SearchType)

			-- Add Records based on search
			SET @SQL =
			N'INSERT INTO BioGUIDDataServices.dbo.SearchIndex (SearchIndexID, SearchLogUUID, SearchSet) ' + 
			N'SELECT DISTINCT ID.IdentifierDomainID, N''' + CAST(@SessionID as nvarchar(36)) + N''', N''IdentifierDomain'' ' +
			N'FROM BioGUID.dbo.IdentifierDomain AS ID ' +
			@WHERE
			IF ISNULL(@Debug, 0) = 1
				SELECT @SQL
			ELSE
				EXEC(@SQL)

			IF ISNULL(@RecordCount, 0) = -1
			BEGIN
				-- Insert the records
				INSERT INTO @IDList(PKID, TableName, PrioritySort)
				SELECT DISTINCT SearchIndexID, N'Master', 3 FROM SearchIndex WHERE SearchLogUUID = @SessionID AND SearchSet = N'IdentifierDomain'
				INSERT INTO @IDList(PKID, TableName, PrioritySort)
				SELECT DISTINCT SearchIndexID, N'Master', 4 FROM SearchIndex WHERE SearchLogUUID = @SessionID AND SearchSet = N'Identifier'

				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
				-- Performance Log
				IF @DoLog = 1
				BEGIN
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Added Records based on @SearchTerm', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
			END
			ELSE IF ISNULL(@RecordCount, 0) > 0
			BEGIN
				-- Remove unmatched records
				DELETE @IDList
				WHERE TableName = N'Master' 
					AND PKID NOT IN (SELECT DISTINCT SearchIndexID FROM SearchIndex WHERE SearchLogUUID = @SessionID AND SearchSet IN(N'IdentifierDomain', N'Identifier'))

				-- Performance Log
				IF @DoLog = 1
				BEGIN
					-- Capture RecordCount
					SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Removed Records based on @SearchTerm', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
			END
		END		

		-- Filter based on @ObjectClassPKID
		IF ISNULL(@ObjectClassPKID, 0) <> 0
		BEGIN
			IF ISNULL(@RecordCount, 0) = -1
			BEGIN
				INSERT INTO @IDList(PKID, TableName, PrioritySort)
				SELECT DISTINCT ID.IdentifierDomainID, N'Master', 1
				FROM BioGUID.dbo.IdentifierDomain AS ID
					INNER JOIN BioGUID.dbo.Identifier AS I ON ID.IdentifierDomainID = I.IdentifierDomainID
					INNER JOIN BioGUID.dbo.IdentifiedObject AS Obj ON I.IdentifiedObjectID = Obj.IdentifiedObjectID
					INNER JOIN BioGUID.dbo.PK AS PK ON Obj.IdentifiedObjectID = PK.PKID
				WHERE PK.PKID = PK.CorrectID AND
					Obj.ObjectClassID = @ObjectClassPKID

				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'

				-- Performance Log
				IF @DoLog = 1
				BEGIN
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Added Records based on @ObjectClassPKID', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
			END
			ELSE
			BEGIN
				-- Remove unmatched records
				DELETE @IDList
				FROM @IDList AS IDL 
				WHERE TableName = N'Master' 
					AND IDL.PKID NOT IN
						(
						SELECT DISTINCT ID.IdentifierDomainID
						FROM BioGUID.dbo.IdentifierDomain AS ID
							INNER JOIN BioGUID.dbo.Identifier AS I ON ID.IdentifierDomainID = I.IdentifierDomainID
							INNER JOIN BioGUID.dbo.IdentifiedObject AS Obj ON I.IdentifiedObjectID = Obj.IdentifiedObjectID
							INNER JOIN BioGUID.dbo.PK AS PK ON Obj.IdentifiedObjectID = PK.PKID
						WHERE PK.PKID = PK.CorrectID AND
							Obj.ObjectClassID = @ObjectClassPKID
						)
				-- Performance Log
				IF @DoLog = 1
				BEGIN
					-- Capture RecordCount
					SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList WHERE TableName = N'Master'
					EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Removed Records based on @ObjectClassPKID', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
					SET @StartTime = GETUTCDATE()
				END
				-- Capture RecordCount
				SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
			END
		END

		-- Remove records
		IF ISNULL(@RecordCount, 0) > 0
		BEGIN
			-- Remove Zero records 
			DELETE IDL FROM @IDList AS IDL WHERE IDL.PKID=0

			-- Remove Non-Correct Records
			DELETE IDL FROM @IDList AS IDL INNER JOIN BioGUID.dbo.PK AS PK ON IDL.PKID = PK.PKID WHERE PK.PKID <> PK.CorrectID

			-- Remove Hidden Records
			IF ISNULL(@IncludeHidden, 0) <> 1
				DELETE IDL FROM @IDList AS IDL INNER JOIN BioGUID.dbo.IdentifierDomain AS ID ON IDL.PKID = ID.IdentifierDomainID WHERE IsHidden = 1

			-- Performance Log
			IF @DoLog = 1
			BEGIN
				-- Capture RecordCount
				SELECT @RecordCount = @RecordCount - COUNT(*) FROM @IDList
				EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Removed Zero and Incorrect Records', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
				SET @StartTime = GETUTCDATE()
			END
			-- Capture RecordCount
			SELECT @RecordCount = COUNT(*) FROM @IDList WHERE TableName = N'Master'
		END
	END

	-- Generate Results
	--Establish FROM
	SET @FROM = N'FROM view_SearchIdentifierDomain AS SID INNER JOIN @IDList AS IDL ON SID.IdentifierDomainID = IDL.PKID '

	-- Establish @ColumnList
	SET @ColumnList = @ColumnList + N'SID.IdentifierDomainUUID, SID.IdentifierClass, SID.Abbreviation, SID.IdentifierDomain, SID.Description, SID.Logo, SID.AgentUUID, SID.PreferredDereferenceServiceUUID, SID.PreferredDereferenceServiceProtocol, SID.PreferredDereferenceService, SID.PreferredDereferencePrefix, SID.PreferredDereferenceSuffix '

	-- Finalize @SQL
	SET @SQL = 'SELECT '
	IF ISNULL(@Top, 0) > 0
		SET @SQL = @SQL + 'TOP(' + CAST(@Top AS varchar) + ') '
	SET @SQL = @SQL + @ColumnList + @FROM + @OrderBy
		
	-- Retrieve Results
	IF ISNULL(@Debug, 0) = 1
	BEGIN
		SELECT @SQL
		SELECT * FROM @IDList
	END
	ELSE
		EXEC sp_executesql @SQL, N'@IDList PKIDListType READONLY', @IDList

	SELECT @RecordCount = COUNT(*) FROM @IDList
	
	-- Performance Log
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Results Returned', @RecordCount = @RecordCount, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
	
	-- Log Query Results
	INSERT INTO BioGUIDLocalLog.dbo.SearchLog (SearchUUID, StoredProcedure, [Parameters], UserName, StartTime, EndTime)
	SELECT @SessionID, N'sp_SearchIdentifierDomain', @Parameters, NULLIF(@UserName, N''), @T0, GETUTCDATE()
	INSERT INTO BioGUIDLocalLog.dbo.SearchResult (SearchLogID, PKID)
	SELECT DISTINCT IDENT_CURRENT('BioGUIDLocalLog.dbo.SearchLog'), PKID FROM @IDList
	DELETE BioGUIDDataServices.dbo.SearchIndex WHERE SearchLogUUID = @SessionID

	-- Performance Log
	IF @DoLog = 1
	BEGIN
		EXEC sp_PerformanceLog @SessionID = @SessionID, @Process='sp_SearchIdentifierDomain', @Task = 'Search Parameters and Results Logged', @RecordCount = 1, @StartTime = @StartTime, @EndTime=NULL
		SET @StartTime = GETUTCDATE()
	END
-- =============================================================================
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SearchNewsItem]    Script Date: 10/5/2015 9:14:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- AUTHOR:		Richard L. Pyle
-- CREATE DATE: 3 March 2015
-- DESCRIPTION:
--		Searches news items
--
-- INPUT PARAMETERS:
--
-- OUTPUT PARAMETERS:
--		NONE
--
-- CALLED PROCEDURES:
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_SearchNewsItem] 
	-- Add the parameters for the stored procedure here
	-- =============================================
	@NewsItem				varchar(255)	= NULL, 
	@PostTimeStamp			datetime		= NULL, 
	@IsSuppressed			bit				= NULL,
	@LogUserName			nvarchar(128)	= NULL,
	@Top					int				= 0,
	@NewsItemID				int				= 0	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Declare Internal Variables
-- =============================================================================
	DECLARE @OUT			nvarchar(MAX)	= N''
-- =============================================================================

-- Establish initial variable values
-- =============================================================================
	IF ISNULL(@Top, 0) = 0
		SET @TOP = 100000
-- =============================================================================

-- Operational Code
-- =============================================================================
	SELECT TOP(@TOP) *
	FROM BioGUIDDataServices.dbo.view_SearchNewsItem
	WHERE (ISNULL(@NewsItem, '') = '' OR NewsItem LIKE '%' + @NewsItem + '%')
		AND (@PostTimeStamp IS NULL OR CAST(PostTimeStamp AS Date) = CAST(@PostTimeStamp AS Date))
		AND (@IsSuppressed IS NULL OR IsSuppressed = @IsSuppressed)
		AND (ISNULL(@NewsItemID, 0) = 0 OR NewsItemID = @NewsItemID)
	ORDER BY PostTimeStamp DESC
-- =============================================================================
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IMPORT (BioGUID_IMPORT.dbo)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3270
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_BatchImportStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_BatchImportStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IDDS"
            Begin Extent = 
               Top = 44
               Left = 356
               Bottom = 156
               Right = 645
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ID"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 249
               Right = 320
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "DS"
            Begin Extent = 
               Top = 6
               Left = 683
               Bottom = 236
               Right = 917
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PK"
            Begin Extent = 
               Top = 6
               Left = 955
               Bottom = 135
               Right = 1125
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3015
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_GetIdentifierDomainDereferenceService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_GetIdentifierDomainDereferenceService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SRC"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 101
               Right = 243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_MultipleIdentifiers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_MultipleIdentifiers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 184
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PK"
            Begin Extent = 
               Top = 11
               Left = 394
               Bottom = 140
               Right = 564
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 153
               Left = 384
               Bottom = 282
               Right = 578
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2490
         Alias = 2445
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchDereferenceService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchDereferenceService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "FAQ"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 162
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchFAQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchFAQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[49] 4[25] 2[8] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "I"
            Begin Extent = 
               Top = 15
               Left = 510
               Bottom = 127
               Right = 699
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Obj"
            Begin Extent = 
               Top = 11
               Left = 753
               Bottom = 106
               Right = 938
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OC"
            Begin Extent = 
               Top = 163
               Left = 966
               Bottom = 292
               Right = 1160
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ID"
            Begin Extent = 
               Top = 14
               Left = 217
               Bottom = 143
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IDPK"
            Begin Extent = 
               Top = 5
               Left = 2
               Bottom = 134
               Right = 172
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DS"
            Begin Extent = 
               Top = 168
               Left = 494
               Bottom = 297
               Right = 694
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "DSPK"
            Begin Extent = 
               Top = 175
               Left = 738
               Bottom = 304
               Right = 908
            End
            DisplayFlags = 280
            TopColumn = 0
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchIdentifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'      End
         Begin Table = "IC"
            Begin Extent = 
               Top = 158
               Left = 0
               Bottom = 287
               Right = 194
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 168
               Left = 246
               Bottom = 297
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 6225
         Alias = 2715
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchIdentifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchIdentifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PK"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ID"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 135
               Right = 494
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "IC"
            Begin Extent = 
               Top = 6
               Left = 532
               Bottom = 135
               Right = 726
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DR"
            Begin Extent = 
               Top = 153
               Left = 526
               Bottom = 282
               Right = 726
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PKDR"
            Begin Extent = 
               Top = 143
               Left = 807
               Bottom = 272
               Right = 977
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 183
               Left = 263
               Bottom = 312
               Right = 457
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 8430
         Alias = 4290
         Table = 1170' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchIdentifierDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchIdentifierDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchIdentifierDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "NewsItem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2715
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchNewsItem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_SearchNewsItem'
GO
USE [master]
GO
ALTER DATABASE [BioGUIDDataServices] SET  READ_WRITE 
GO
