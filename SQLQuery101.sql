/*
RaceDay Event Management System
SQL Sever Database Script

This script creates the raceday database,
its tables, relationships and sample data.
/* ============================================================
   RaceDay Database
   FINAL SSMS VERSION
   ============================================================ */

USE master;
GO

/* ============================================================
   1. DROP EXISTING DATABASE
   ============================================================ */

IF DB_ID(N'RaceDay') IS NOT NULL
BEGIN
    ALTER DATABASE [RaceDay]
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE [RaceDay];
END;
GO

/* ============================================================
   2. CREATE DATABASE
   ============================================================ */

CREATE DATABASE [RaceDay];
GO

USE [RaceDay];
GO

/* ============================================================
   3. USERS
   ============================================================ */

CREATE TABLE [dbo].[Users]
(
    [UserId]        INT IDENTITY(1,1) NOT NULL,
    [FullName]      NVARCHAR(100) NOT NULL,
    [Email]         NVARCHAR(150) NOT NULL,
    [PasswordHash]  NVARCHAR(255) NOT NULL,
    [Role]          VARCHAR(20) NOT NULL,
    [PhoneNumber]   NVARCHAR(20) NULL,
    [CreatedAt]     DATETIME NOT NULL
        CONSTRAINT [DF_Users_CreatedAt] DEFAULT GETDATE(),

    CONSTRAINT [PK_Users]
        PRIMARY KEY ([UserId]),

    CONSTRAINT [UQ_Users_Email]
        UNIQUE ([Email]),

    CONSTRAINT [CK_Users_Role]
        CHECK ([Role] IN ('Organiser', 'Participant'))
);
GO

/* ============================================================
   4. EVENTS
   ============================================================ */

CREATE TABLE [dbo].[Events]
(
    [EventId]       INT IDENTITY(1,1) NOT NULL,
    [OrganiserId]   INT NOT NULL,
    [Name]          NVARCHAR(150) NOT NULL,
    [Description]   NVARCHAR(1000) NULL,
    [EventDate]     DATE NOT NULL,
    [Location]      NVARCHAR(150) NOT NULL,
    [Province]      NVARCHAR(50) NOT NULL,
    [CreatedAt]     DATETIME NOT NULL
        CONSTRAINT [DF_Events_CreatedAt] DEFAULT GETDATE(),

    CONSTRAINT [PK_Events]
        PRIMARY KEY ([EventId]),

    CONSTRAINT [FK_Events_Organiser]
        FOREIGN KEY ([OrganiserId])
        REFERENCES [dbo].[Users]([UserId])
);
GO

/* ============================================================
   5. CATEGORIES
   ============================================================ */

CREATE TABLE [dbo].[Categories]
(
    [CategoryId]      INT IDENTITY(1,1) NOT NULL,
    [EventId]         INT NOT NULL,
    [Name]            NVARCHAR(50) NOT NULL,
    [DistanceKm]      DECIMAL(5,2) NOT NULL,
    [MaxParticipants] INT NULL,
    [EntryFee]        DECIMAL(8,2) NOT NULL
        CONSTRAINT [DF_Categories_EntryFee] DEFAULT 0,

    CONSTRAINT [PK_Categories]
        PRIMARY KEY ([CategoryId]),

    CONSTRAINT [FK_Categories_Events]
        FOREIGN KEY ([EventId])
        REFERENCES [dbo].[Events]([EventId])
        ON DELETE CASCADE,

    CONSTRAINT [CK_Categories_Distance]
        CHECK ([DistanceKm] > 0),

    CONSTRAINT [CK_Categories_MaxParticipants]
        CHECK (
            [MaxParticipants] IS NULL
            OR [MaxParticipants] > 0
        ),

    CONSTRAINT [CK_Categories_EntryFee]
        CHECK ([EntryFee] >= 0)
);
GO

/* ============================================================
   6. ROUTES
   MapUrl changed to NVARCHAR(500)
   ============================================================ */

CREATE TABLE [dbo].[Routes]
(
    [RouteId]        INT IDENTITY(1,1) NOT NULL,
    [EventId]        INT NOT NULL,
    [RouteName]      NVARCHAR(100) NOT NULL,
    [DistanceKm]     DECIMAL(5,2) NOT NULL,
    [ElevationGainM] INT NULL,
    [MapUrl]         NVARCHAR(500) NULL,

    CONSTRAINT [PK_Routes]
        PRIMARY KEY ([RouteId]),

    CONSTRAINT [FK_Routes_Events]
        FOREIGN KEY ([EventId])
        REFERENCES [dbo].[Events]([EventId])
        ON DELETE CASCADE,

    CONSTRAINT [CK_Routes_Distance]
        CHECK ([DistanceKm] > 0),

    CONSTRAINT [CK_Routes_Elevation]
        CHECK (
            [ElevationGainM] IS NULL
            OR [ElevationGainM] >= 0
        )
);
GO

/* ============================================================
   7. ENROLMENTS
   ============================================================ */

CREATE TABLE [dbo].[Enrolments]
(
    [EnrolmentId]   INT IDENTITY(1,1) NOT NULL,
    [ParticipantId] INT NOT NULL,
    [CategoryId]    INT NOT NULL,
    [EnrolmentDate] DATETIME NOT NULL
        CONSTRAINT [DF_Enrolments_Date] DEFAULT GETDATE(),
    [Status]        VARCHAR(20) NOT NULL
        CONSTRAINT [DF_Enrolments_Status] DEFAULT 'Confirmed',

    CONSTRAINT [PK_Enrolments]
        PRIMARY KEY ([EnrolmentId]),

    CONSTRAINT [FK_Enrolments_Users]
        FOREIGN KEY ([ParticipantId])
        REFERENCES [dbo].[Users]([UserId]),

    CONSTRAINT [FK_Enrolments_Categories]
        FOREIGN KEY ([CategoryId])
        REFERENCES [dbo].[Categories]([CategoryId])
        ON DELETE CASCADE,

    CONSTRAINT [UQ_Enrolments_Participant_Category]
        UNIQUE ([ParticipantId], [CategoryId]),

    CONSTRAINT [CK_Enrolments_Status]
        CHECK ([Status] IN ('Confirmed', 'Cancelled'))
);
GO

/* ============================================================
   8. RESULTS
   ============================================================ */

CREATE TABLE [dbo].[Results]
(
    [ResultId]              INT IDENTITY(1,1) NOT NULL,
    [EnrolmentId]           INT NOT NULL,
    [FinishTime]            TIME NULL,
    [Position]              INT NULL,
    [RecordedByOrganiserId] INT NOT NULL,
    [RecordedAt]            DATETIME NOT NULL
        CONSTRAINT [DF_Results_RecordedAt] DEFAULT GETDATE(),

    CONSTRAINT [PK_Results]
        PRIMARY KEY ([ResultId]),

    CONSTRAINT [UQ_Results_Enrolment]
        UNIQUE ([EnrolmentId]),

    CONSTRAINT [FK_Results_Enrolments]
        FOREIGN KEY ([EnrolmentId])
        REFERENCES [dbo].[Enrolments]([EnrolmentId])
        ON DELETE CASCADE,

    CONSTRAINT [FK_Results_Organiser]
        FOREIGN KEY ([RecordedByOrganiserId])
        REFERENCES [dbo].[Users]([UserId]),

    CONSTRAINT [CK_Results_Position]
        CHECK (
            [Position] IS NULL
            OR [Position] > 0
        )
);
GO

/* ============================================================
   9. INSERT USERS
   ============================================================ */

INSERT INTO [dbo].[Users]
(
    [FullName],
    [Email],
    [PasswordHash],
    [Role],
    [PhoneNumber]
)
VALUES
(
    'Thabo Mokoena',
    'thabo.mokoena@raceday.co.za',
    'HASHED_PW_1',
    'Organiser',
    '0821234567'
),
(
    'Sarah van Wyk',
    'sarah.vanwyk@raceday.co.za',
    'HASHED_PW_2',
    'Organiser',
    '0837654321'
),
(
    'Lindiwe Dube',
    'lindiwe.dube@example.com',
    'HASHED_PW_3',
    'Participant',
    '0731112222'
),
(
    'James Botha',
    'james.botha@example.com',
    'HASHED_PW_4',
    'Participant',
    '0793334444'
);
GO

/* ============================================================
   10. INSERT EVENTS
   ============================================================ */

INSERT INTO [dbo].[Events]
(
    [OrganiserId],
    [Name],
    [Description],
    [EventDate],
    [Location],
    [Province]
)
VALUES
(
    1,
    'Pretoria Park Run Challenge',
    'A community 5km/10km run through Pretoria city parks.',
    '2026-11-14',
    'Pretoria',
    'Gauteng'
),
(
    1,
    'Jozi Night Cycle Tour',
    'An evening cycling tour through Johannesburg CBD.',
    '2026-10-03',
    'Johannesburg',
    'Gauteng'
),
(
    2,
    'Cape Coastal Marathon',
    'A scenic marathon and half-marathon along the Cape coastline.',
    '2026-09-20',
    'Cape Town',
    'Western Cape'
);
GO

/* ============================================================
   11. INSERT CATEGORIES
   ============================================================ */

INSERT INTO [dbo].[Categories]
(
    [EventId],
    [Name],
    [DistanceKm],
    [MaxParticipants],
    [EntryFee]
)
VALUES
(
    1,
    '5km Fun Run',
    5.00,
    200,
    100.00
),
(
    1,
    '10km Race',
    10.00,
    150,
    150.00
),
(
    2,
    '20km Night Ride',
    20.00,
    100,
    200.00
),
(
    3,
    'Half Marathon',
    21.10,
    500,
    250.00
),
(
    3,
    'Full Marathon',
    42.20,
    300,
    350.00
);
GO

/* ============================================================
   12. INSERT ROUTES
   ============================================================ */

INSERT INTO [dbo].[Routes]
(
    [EventId],
    [RouteName],
    [DistanceKm],
    [ElevationGainM],
    [MapUrl]
)
VALUES
(
    1,
    'Pretoria Park Loop',
    10.00,
    85,
    'https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fmaps.example.com%2Fpretoria-park-loop&data=05%7C02%7Cst10482742%40rcconnect.edu.za%7Cf09e3140586746b7c20508df0aa2f020%7Ce10c8f44f469448fbc0dd781288ff01b%7C0%7C0%7C639241367119637151%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=ELwH2LaSB%2BtOkrJy1fBNfUWw%2FOLORhkKLLFyNqZgh84%3D&reserved=0'
),
(
    2,
    'Jozi CBD Night Loop',
    20.00,
    120,
    'https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fmaps.example.com%2Fjozi-night-loop&data=05%7C02%7Cst10482742%40rcconnect.edu.za%7Cf09e3140586746b7c20508df0aa2f020%7Ce10c8f44f469448fbc0dd781288ff01b%7C0%7C0%7C639241367119655587%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=ba0Ehr4NInSPW%2Bb6%2F%2B5oMmpw1ZyZSKAFWI3nsXX7Seg%3D&reserved=0'
),
(
    3,
    'Cape Coastal Route',
    42.20,
    310,
    'https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fmaps.example.com%2Fcape-coastal-route&data=05%7C02%7Cst10482742%40rcconnect.edu.za%7Cf09e3140586746b7c20508df0aa2f020%7Ce10c8f44f469448fbc0dd781288ff01b%7C0%7C0%7C639241367119668059%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=fDekU31ap0Dn2CrkJMnNv7%2FwAN4tpOw8QyrYxzBW%2F48%3D&reserved=0'
);
GO

/* ============================================================
   13. INSERT ENROLMENTS
   ============================================================ */

INSERT INTO [dbo].[Enrolments]
(
    [ParticipantId],
    [CategoryId],
    [Status]
)
VALUES
(
    3,
    2,
    'Confirmed'
),
(
    4,
    2,
    'Confirmed'
),
(
    3,
    4,
    'Confirmed'
);
GO

/* ============================================================
   14. INSERT RESULTS
   ============================================================ */

INSERT INTO [dbo].[Results]
(
    [EnrolmentId],
    [FinishTime],
    [Position],
    [RecordedByOrganiserId]
)
VALUES
(
    1,
    '00:52:14',
    1,
    1
),
(
    2,
    '00:55:41',
    2,
    1
);
GO

/* ============================================================
   15. VERIFY TABLES
   ============================================================ */

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

/* ============================================================
   16. VERIFY ROW COUNTS
   ============================================================ */

SELECT
    'Users' AS TableName,
    COUNT(*) AS [RowCount]
FROM [dbo].[Users]

UNION ALL

SELECT
    'Events',
    COUNT(*)
FROM [dbo].[Events]

UNION ALL

SELECT
    'Categories',
    COUNT(*)
FROM [dbo].[Categories]

UNION ALL

SELECT
    'Routes',
    COUNT(*)
FROM [dbo].[Routes]

UNION ALL

SELECT
    'Enrolments',
    COUNT(*)
FROM [dbo].[Enrolments]

UNION ALL

SELECT
    'Results',
    COUNT(*)
FROM [dbo].[Results];
GO

/* ============================================================
   17. SUCCESS MESSAGE
   ============================================================ */

PRINT 'RaceDay database created successfully.';
GO
