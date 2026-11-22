
CREATE DATABASE BidNile
GO

USE BidNile
GO

CREATE SCHEMA [identity]
GO

CREATE SCHEMA [finance]
GO

CREATE SCHEMA [inventory]
GO

CREATE SCHEMA [auctions]
GO

CREATE TABLE [identity].Persons
(
    Id INT IDENTITY NOT NULL
        CONSTRAINT PK_Persons PRIMARY KEY
);
GO

CREATE TABLE [identity].Employees
(
    Id INT NOT NULL
        CONSTRAINT PK_Employees PRIMARY KEY,

    WarehouseId INT NOT NULL
);
GO

CREATE TABLE [identity].Members
(
    Id UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_Members_Id DEFAULT NEWID()
        CONSTRAINT PK_Members PRIMARY KEY,

    FullName NVARCHAR(100) NOT NULL,

    Email VARCHAR(254) NOT NULL
        CONSTRAINT UQ_Members_Email UNIQUE,

    Mobile VARCHAR(16) NOT NULL,

    IdentityDocumentNumber VARCHAR(20) NOT NULL
        CONSTRAINT UQ_Members_IdentityDocumentNumber UNIQUE,

    BirthDate DATE NOT NULL,

    IsVerified BIT NOT NULL
        CONSTRAINT DF_Members_IsVerified DEFAULT 0,

    RegisteredAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Members_RegisteredAt DEFAULT SYSDATETIME(),

    CityId INT NOT NULL,

    InviterId UNIQUEIDENTIFIER NULL
);
GO

CREATE TABLE [identity].Countries
(
    CountryCode CHAR(2) NOT NULL
        CONSTRAINT PK_Countries PRIMARY KEY,

    NameEn NVARCHAR(60) NOT NULL,

    NameAr NVARCHAR(60) NOT NULL,

    PhoneCode VARCHAR(5) NOT NULL
);
GO

CREATE TABLE [identity].Cities
(
    Id INT IDENTITY NOT NULL
        CONSTRAINT PK_Cities PRIMARY KEY,

    Name NVARCHAR(60) NOT NULL,

    CountryCode CHAR(2) NOT NULL,

    CONSTRAINT UQ_Cities_Name_CountryCode UNIQUE (Name, CountryCode),

    CONSTRAINT CK_Cities_CountryCode CHECK (CountryCode IN ('EG', 'SA', 'AE'))
);
GO

CREATE TABLE [finance].Wallets
(
    Id BIGINT IDENTITY NOT NULL
        CONSTRAINT PK_Wallets PRIMARY KEY,

    MemberId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT UQ_Wallets_MemberId UNIQUE,

    Balance DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Wallets_Balance DEFAULT 0
        CONSTRAINT CK_Wallets_Balance CHECK (Balance >= 0),

    OnHoldAmount DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Wallets_OnHoldAmount DEFAULT 0
        CONSTRAINT CK_Wallets_OnHoldAmount CHECK (OnHoldAmount >= 0),

    Currency CHAR(3) NOT NULL
        CONSTRAINT DF_Wallets_Currency DEFAULT 'EGP',

    LastUpdated DATETIME2(3) NOT NULL
        CONSTRAINT DF_Wallets_LastUpdated DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Wallets_OnHoldAmount_Balance CHECK (OnHoldAmount <= Balance)
);
GO

CREATE TABLE [inventory].Warehouses
(
    Id INT IDENTITY NOT NULL
        CONSTRAINT PK_Warehouses PRIMARY KEY,

    Name NVARCHAR(80) NOT NULL
        CONSTRAINT UQ_Warehouses_Name UNIQUE,

    Capacity INT NOT NULL
        CONSTRAINT CK_Warehouses_Capacity CHECK (Capacity > 0),

    Latitude FLOAT NOT NULL
        CONSTRAINT CK_Warehouses_Latitude CHECK (Latitude BETWEEN -90 AND 90),

    Longitude FLOAT NOT NULL
        CONSTRAINT CK_Warehouses_Longitude CHECK (Longitude BETWEEN -180 AND 180),

    CityId INT NOT NULL,

    ManagerId INT NULL
        CONSTRAINT UQ_Warehouses_ManagerId UNIQUE,

    StartManagingDate DATE NULL
);
GO

CREATE TABLE [inventory].Categories
(
    Id INT NOT NULL
        CONSTRAINT PK_Categories PRIMARY KEY,

    EnglishName NVARCHAR(50) NOT NULL
        CONSTRAINT UQ_Categories_EnglishName UNIQUE,

    ArabicName NVARCHAR(50) NULL,

    Code INT NOT NULL
        CONSTRAINT UQ_Categories_Code UNIQUE,

    Commision DECIMAL(5,2) NOT NULL
        CONSTRAINT CK_Categories_Commision CHECK (Commision BETWEEN 0 AND 30),

    ParentId INT NULL
);
GO

CREATE TABLE [inventory].Items
(
    Id INT IDENTITY NOT NULL
        CONSTRAINT PK_Items PRIMARY KEY,

    Title NVARCHAR(150) NOT NULL,

    Descrpion NVARCHAR(MAX) NULL,

    ConditionScore TINYINT NOT NULL
        CONSTRAINT CK_Items_ConditionScore CHECK (ConditionScore BETWEEN 1 AND 10),

    Specifications NVARCHAR(MAX) NOT NULL
        CONSTRAINT CK_Items_Specifications CHECK (ISJSON(Specifications) = 1),

    EmployeeId INT NOT NULL,

    WarehouseId INT NULL,

    MemberId UNIQUEIDENTIFIER NOT NULL,

    ListedDate DATETIME2(3) NOT NULL
        CONSTRAINT DF_Items_ListedDate DEFAULT SYSDATETIME(),

    CategoryId INT NOT NULL
);
GO

CREATE TABLE [inventory].ItemPhotos
(
    ItemId INT NOT NULL,

    Position TINYINT NOT NULL
        CONSTRAINT CK_ItemPhotos_Position CHECK (Position BETWEEN 1 AND 20),

    URL VARCHAR(500) NOT NULL,

    IsMainPhoto BIT NOT NULL
        CONSTRAINT DF_ItemPhotos_IsMainPhoto DEFAULT 0,

    CONSTRAINT PK_ItemPhotos PRIMARY KEY (ItemId, Position)
);
GO

CREATE TABLE [auctions].Auctions
(
    Id INT IDENTITY NOT NULL
        CONSTRAINT PK_Auctions PRIMARY KEY,

    StartingPrice DECIMAL(12,2) NOT NULL
        CONSTRAINT CK_Auctions_StartingPrice CHECK (StartingPrice > 0),

    ReservePrice DECIMAL(12,2) NULL,

    BidIncrement DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Auctions_BidIncrement DEFAULT 50.00
        CONSTRAINT CK_Auctions_BidIncrement CHECK (BidIncrement > 0),

    StartDateTime DATETIMEOFFSET NOT NULL,

    EndDateTime DATETIMEOFFSET NOT NULL,

    Status VARCHAR(10) NOT NULL
        CONSTRAINT DF_Auctions_Status DEFAULT 'Draft'
        CONSTRAINT CK_Auctions_Status CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled')),

    ItemId INT NOT NULL,

    CONSTRAINT CK_Auctions_ReservePrice CHECK (ReservePrice IS NULL OR ReservePrice >= StartingPrice),

    CONSTRAINT CK_Auctions_DateRange CHECK (EndDateTime > StartDateTime)
);
GO

CREATE TABLE [auctions].Bids
(
    Id BIGINT IDENTITY NOT NULL
        CONSTRAINT PK_Bids PRIMARY KEY,

    DeviceIPAddress VARCHAR(45) NOT NULL,

    Amount DECIMAL(12,2) NOT NULL
        CONSTRAINT CK_Bids_Amount CHECK (Amount > 0),

    PlacedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Bids_PlacedAt DEFAULT SYSDATETIME(),

    AuctionId INT NOT NULL,

    MemberId UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_Bids_AuctionId_Amount UNIQUE (AuctionId, Amount)
);
GO

CREATE TABLE [auctions].FollowedBy
(
    AuctionId INT NOT NULL,

    MemberId UNIQUEIDENTIFIER NOT NULL,

    StartFollowingDate DATETIME2(3) NOT NULL
        CONSTRAINT DF_FollowedBy_StartFollowingDate DEFAULT SYSDATETIME(),

    CONSTRAINT PK_FollowedBy PRIMARY KEY (AuctionId, MemberId)
);
GO


-- 3.1

ALTER TABLE [identity].Employees
    ADD CONSTRAINT FK_Employees_Persons
    FOREIGN KEY (Id) REFERENCES [identity].Persons(Id);
GO

ALTER TABLE [identity].Employees
    ADD CONSTRAINT FK_Employees_Warehouses
    FOREIGN KEY (WarehouseId) REFERENCES [inventory].Warehouses(Id);
GO

ALTER TABLE [identity].Members
    ADD CONSTRAINT FK_Members_Cities
    FOREIGN KEY (CityId) REFERENCES [identity].Cities(Id);
GO

ALTER TABLE [identity].Members
    ADD CONSTRAINT FK_Members_Members_Inviter
    FOREIGN KEY (InviterId) REFERENCES [identity].Members(Id);
GO

ALTER TABLE [identity].Cities
    ADD CONSTRAINT FK_Cities_Countries
    FOREIGN KEY (CountryCode) REFERENCES [identity].Countries(CountryCode);
GO

ALTER TABLE [finance].Wallets
    ADD CONSTRAINT FK_Wallets_Members
    FOREIGN KEY (MemberId) REFERENCES [identity].Members(Id);
GO

ALTER TABLE [inventory].Warehouses
    ADD CONSTRAINT FK_Warehouses_Cities
    FOREIGN KEY (CityId) REFERENCES [identity].Cities(Id);
GO

ALTER TABLE [inventory].Warehouses
    ADD CONSTRAINT FK_Warehouses_Employees_Manager
    FOREIGN KEY (ManagerId) REFERENCES [identity].Employees(Id);
GO

ALTER TABLE [inventory].Categories
    ADD CONSTRAINT FK_Categories_Categories_Parent
    FOREIGN KEY (ParentId) REFERENCES [inventory].Categories(Id);
GO

ALTER TABLE [inventory].Items
    ADD CONSTRAINT FK_Items_Employees
    FOREIGN KEY (EmployeeId) REFERENCES [identity].Employees(Id);
GO

ALTER TABLE [inventory].Items
    ADD CONSTRAINT FK_Items_Warehouses
    FOREIGN KEY (WarehouseId) REFERENCES [inventory].Warehouses(Id);
GO

ALTER TABLE [inventory].Items
    ADD CONSTRAINT FK_Items_Members
    FOREIGN KEY (MemberId) REFERENCES [identity].Members(Id);
GO

ALTER TABLE [inventory].Items
    ADD CONSTRAINT FK_Items_Categories
    FOREIGN KEY (CategoryId) REFERENCES [inventory].Categories(Id);
GO

ALTER TABLE [inventory].ItemPhotos
    ADD CONSTRAINT FK_ItemPhotos_Items
    FOREIGN KEY (ItemId) REFERENCES [inventory].Items(Id)
    ON DELETE CASCADE;
GO

ALTER TABLE [auctions].Auctions
    ADD CONSTRAINT FK_Auctions_Items
    FOREIGN KEY (ItemId) REFERENCES [inventory].Items(Id);
GO

ALTER TABLE [auctions].Bids
    ADD CONSTRAINT FK_Bids_Auctions
    FOREIGN KEY (AuctionId) REFERENCES [auctions].Auctions(Id);
GO

ALTER TABLE [auctions].Bids
    ADD CONSTRAINT FK_Bids_Members
    FOREIGN KEY (MemberId) REFERENCES [identity].Members(Id);
GO

ALTER TABLE [auctions].FollowedBy
    ADD CONSTRAINT FK_FollowedBy_Auctions
    FOREIGN KEY (AuctionId) REFERENCES [auctions].Auctions(Id);
GO

ALTER TABLE [auctions].FollowedBy
    ADD CONSTRAINT FK_FollowedBy_Members
    FOREIGN KEY (MemberId) REFERENCES [identity].Members(Id);
GO


-- 3.2

ALTER TABLE [identity].Members
    ADD AppLanguage CHAR(2) NOT NULL
        CONSTRAINT DF_Members_AppLanguage DEFAULT 'ar';
GO


-- 3.3

ALTER TABLE [inventory].Items
    ADD IsFeatured BIT NOT NULL
        CONSTRAINT DF_Items_IsFeatured DEFAULT 0;
GO


-- 3.4

EXEC sp_rename
    'auctions.Bids.DeviceIPAddress',
    'DeviceIp',
    'COLUMN';
GO

ALTER TABLE [inventory].Warehouses
    DROP CONSTRAINT CK_Warehouses_Capacity;
GO

EXEC sp_rename
    'inventory.Warehouses.Capacity',
    'MaxItems',
    'COLUMN';
GO


-- 3.5

ALTER TABLE [identity].Members
    ALTER COLUMN FullName NVARCHAR(150) NOT NULL;
GO


-- 3.6

ALTER TABLE [inventory].Warehouses
    ALTER COLUMN MaxItems SMALLINT NOT NULL;
GO

ALTER TABLE [inventory].Warehouses
    ADD CONSTRAINT CK_Warehouses_MaxItems
    CHECK (MaxItems > 0);
GO


-- 3.7

ALTER TABLE [inventory].Categories
    DROP CONSTRAINT CK_Categories_Commision;
GO

ALTER TABLE [inventory].Categories
    ADD CONSTRAINT CK_Categories_Commision
    CHECK (Commision BETWEEN 0 AND 25);
GO


-- 3.8

ALTER TABLE [auctions].Auctions
    DROP CONSTRAINT CK_Auctions_Status;
GO

ALTER TABLE [auctions].Auctions
    DROP CONSTRAINT DF_Auctions_Status;
GO

ALTER TABLE [auctions].Auctions
    ALTER COLUMN Status VARCHAR(13) NOT NULL;
GO

ALTER TABLE [auctions].Auctions
    ADD CONSTRAINT DF_Auctions_Status
    DEFAULT 'PendingReview' FOR Status;
GO

ALTER TABLE [auctions].Auctions
    ADD CONSTRAINT CK_Auctions_Status
    CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled', 'PendingReview'));
GO


-- 3.9

ALTER TABLE [auctions].Auctions
    ADD BuyNowPrice DECIMAL(12,2) NULL;
GO

-- WITH CHECK validates existing rows against the new constraint.
-- It is used because existing data should satisfy the new rule.

ALTER TABLE [auctions].Auctions
    WITH CHECK ADD CONSTRAINT CK_Auctions_BuyNowPrice
    CHECK (BuyNowPrice IS NULL OR BuyNowPrice > StartingPrice);
GO


-- 3.10

ALTER TABLE [identity].Members
    ADD CONSTRAINT UQ_Members_Mobile UNIQUE (Mobile);
GO


-- 3.11

ALTER TABLE [identity].Members
    ADD VerifiedAt DATETIME2(3) NULL;
GO

ALTER TABLE [identity].Members
    DROP CONSTRAINT DF_Members_IsVerified;
GO

ALTER TABLE [identity].Members
    DROP COLUMN IsVerified;
GO


-- 3.12

CREATE SCHEMA Marketing;
GO

ALTER SCHEMA Marketing
    TRANSFER [auctions].FollowedBy;
GO
