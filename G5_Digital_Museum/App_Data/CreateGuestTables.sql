-- =====================================================
-- COMPLETE DATABASE SETUP for G5_Digital_Museum
-- Creates ALL 16 tables + seeds test data
-- 
-- HOW TO RUN:
--   1. Visual Studio > View > Server Explorer
--   2. Right-click MuseumDB.mdf > New Query
--   3. Paste ALL of this > Ctrl+Shift+E
-- =====================================================

-- ==================== CORE TABLES ====================

-- 1. Users
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(200) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL DEFAULT 'Member',
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    LastLoginAt DATETIME NULL
);

-- 2. Feedback
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feedback')
CREATE TABLE Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    GuestName NVARCHAR(100),
    GuestEmail NVARCHAR(200),
    Subject NVARCHAR(200),
    Message NVARCHAR(MAX) NOT NULL,
    Rating INT DEFAULT 5,
    Status NVARCHAR(20) DEFAULT 'Pending',
    InstructorNote NVARCHAR(MAX) NULL,
    ReviewedAt DATETIME NULL,
    SubmittedAt DATETIME DEFAULT GETDATE()
);

-- 3. Exhibitions
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Exhibitions')
CREATE TABLE Exhibitions (
    ExhibitionID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Category NVARCHAR(50),
    Timeline NVARCHAR(100),
    ImageUrl NVARCHAR(500),
    Status NVARCHAR(20) DEFAULT 'Published',
    IsFeatured BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedByID INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL
);

-- 4. Modules
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Modules')
CREATE TABLE Modules (
    ModuleID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Status NVARCHAR(20) DEFAULT 'Published',
    SortOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 5. ModuleContents
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ModuleContents')
CREATE TABLE ModuleContents (
    ContentID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleID INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    ContentText NVARCHAR(MAX),
    ContentType NVARCHAR(50) DEFAULT 'Text',
    MediaUrl NVARCHAR(500),
    SortOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 6. Quizzes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Quizzes')
CREATE TABLE Quizzes (
    QuizID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleID INT NULL,
    Title NVARCHAR(200) NOT NULL,
    QuizType NVARCHAR(50) DEFAULT 'Multiple Choice',
    PassMark INT DEFAULT 60,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 7. QuizQuestions
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuizQuestions')
CREATE TABLE QuizQuestions (
    QuestionID INT IDENTITY(1,1) PRIMARY KEY,
    QuizID INT NOT NULL,
    QuestionText NVARCHAR(MAX) NOT NULL,
    OptionA NVARCHAR(500),
    OptionB NVARCHAR(500),
    OptionC NVARCHAR(500),
    OptionD NVARCHAR(500),
    CorrectAnswer NVARCHAR(10),
    ImageUrl NVARCHAR(500),
    SortOrder INT DEFAULT 0
);

-- 8. QuizAttempts
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuizAttempts')
CREATE TABLE QuizAttempts (
    AttemptID INT IDENTITY(1,1) PRIMARY KEY,
    QuizID INT NOT NULL,
    UserID INT NOT NULL,
    Score INT DEFAULT 0,
    Passed BIT DEFAULT 0,
    AttemptedAt DATETIME DEFAULT GETDATE()
);

-- 9. QuizBase (for member quiz system)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuizBase')
CREATE TABLE QuizBase (
    QuizBaseID INT IDENTITY(1,1) PRIMARY KEY,
    QuizID INT NOT NULL,
    BaseData NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 10. FirstQuestionType (for member quiz system)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FirstQuestionType')
CREATE TABLE FirstQuestionType (
    TypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500)
);

-- 11. Comments
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Comments')
CREATE TABLE Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    ExhibitionID INT NOT NULL,
    UserID INT NOT NULL,
    CommentText NVARCHAR(MAX) NOT NULL,
    Rating INT DEFAULT 5,
    Status NVARCHAR(20) DEFAULT 'Approved',
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 12. Favourites
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Favourites')
CREATE TABLE Favourites (
    FavouriteID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ExhibitionID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 13. PasswordResetOtp
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PasswordResetOtp')
CREATE TABLE PasswordResetOtp (
    OtpID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(200) NOT NULL,
    OtpCode NVARCHAR(10) NOT NULL,
    ExpiresAt DATETIME NOT NULL,
    IsUsed BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- ==================== GUEST TABLES ====================

-- 14. TimelineEvents
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TimelineEvents')
CREATE TABLE TimelineEvents (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    EventDate DATE NOT NULL,
    EventTitle NVARCHAR(200) NOT NULL,
    EventDescription NVARCHAR(MAX),
    Source NVARCHAR(200),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 15. GalleryItems
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GalleryItems')
CREATE TABLE GalleryItems (
    GalleryID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    ImagePath NVARCHAR(500),
    Category NVARCHAR(50),
    YearTaken NVARCHAR(20),
    Source NVARCHAR(200),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 16. LearningResources
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LearningResources')
CREATE TABLE LearningResources (
    ResourceID INT IDENTITY(1,1) PRIMARY KEY,
    ResourceTitle NVARCHAR(200) NOT NULL,
    ResourceType NVARCHAR(50),
    Author NVARCHAR(200),
    YearPublished INT,
    ResourceURL NVARCHAR(500),
    Description NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE()
);

PRINT '=== All 16 tables created ===';

-- ==================== SEED DATA ====================

-- Test Users (password for all: 123456)
-- SHA256 hex of "123456" = 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'admin@museum.com')
INSERT INTO Users (FullName, Email, PasswordHash, Role) VALUES
('Admin User', 'admin@museum.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Admin');

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'instructor@museum.com')
INSERT INTO Users (FullName, Email, PasswordHash, Role) VALUES
('Instructor User', 'instructor@museum.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Instructor');

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'member@museum.com')
INSERT INTO Users (FullName, Email, PasswordHash, Role) VALUES
('Member User', 'member@museum.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Member');

PRINT '=== Test users created (password: 123456) ===';

-- Seed Feedback
IF NOT EXISTS (SELECT 1 FROM Feedback WHERE GuestName = 'Zhang Wei')
INSERT INTO Feedback (GuestName, GuestEmail, Subject, Message, Rating, Status) VALUES
('Zhang Wei', 'zhang@example.com', 'Powerful Experience', 'This museum provides a deeply moving account of history. Everyone should visit.', 5, 'Approved'),
('Sarah Johnson', 'sarah@example.com', 'Educational Visit', 'An important educational resource. The timeline is very well done.', 5, 'Approved'),
('Takeshi Yamamoto', 'takeshi@example.com', 'Never Forget', 'We must remember history to build a peaceful future. Thank you for preserving these memories.', 4, 'Approved');

PRINT '=== Feedback seeded ===';

-- Seed Exhibitions
IF NOT EXISTS (SELECT 1 FROM Exhibitions WHERE Title = 'The Fall of Nanjing')
INSERT INTO Exhibitions (Title, Description, Category, Timeline, Status, IsFeatured) VALUES
('The Fall of Nanjing', 'December 13, 1937 marks the beginning of one of the darkest chapters in modern history.', 'Historical Event', 'December 1937', 'Published', 1),
('The Safety Zone', 'International residents established a safety zone to protect civilians during the massacre.', 'Humanitarian', 'November 1937', 'Published', 1),
('Tokyo War Crimes Tribunal', 'The International Military Tribunal examined evidence of wartime atrocities.', 'Justice', '1946-1948', 'Published', 0),
('Memorial Hall', 'The Memorial Hall was built on the site of a mass grave and opened in 1985.', 'Memorial', 'August 1985', 'Published', 1);

PRINT '=== Exhibitions seeded ===';

-- Seed Modules
IF NOT EXISTS (SELECT 1 FROM Modules WHERE Title = 'Introduction to the Nanjing Massacre')
INSERT INTO Modules (Title, Description, Status, SortOrder) VALUES
('Introduction to the Nanjing Massacre', 'Learn about the historical context and key events of the Nanjing Massacre.', 'Published', 1),
('The International Safety Zone', 'Explore how foreign nationals helped shelter civilians during the crisis.', 'Published', 2),
('Aftermath and Justice', 'Study the Tokyo Trials and the long road to remembrance.', 'Published', 3);

PRINT '=== Modules seeded ===';

-- Seed TimelineEvents
IF NOT EXISTS (SELECT 1 FROM TimelineEvents WHERE EventTitle = 'Marco Polo Bridge Incident')
INSERT INTO TimelineEvents (EventDate, EventTitle, EventDescription, Source) VALUES
('1937-07-07', 'Marco Polo Bridge Incident', 'A confrontation between Japanese and Chinese troops near Beijing marks the beginning of full-scale war.', 'Memorial Hall Archives'),
('1937-08-13', 'Battle of Shanghai Begins', 'Japanese forces launch a major assault on Shanghai with heavy casualties on both sides.', 'Memorial Hall Archives'),
('1937-11-12', 'Shanghai Falls', 'After three months of fighting, Shanghai falls. Japanese forces advance toward Nanjing.', 'Memorial Hall Archives'),
('1937-11-22', 'Nanjing Safety Zone Established', 'John Rabe and foreign nationals establish a demilitarized zone to shelter civilians.', 'Memorial Hall Archives'),
('1937-12-01', 'Japanese Forces Approach Nanjing', 'Japan orders the capture of Nanjing. Approx. 100,000 Chinese troops defend the city.', 'Memorial Hall Archives'),
('1937-12-09', 'Japanese Demand Surrender', 'General Matsui demands surrender. General Tang refuses. Bombardment intensifies.', 'Memorial Hall Archives'),
('1937-12-12', 'Chinese Forces Begin Retreat', 'General Tang orders retreat. Chaotic withdrawal as thousands try to flee across the Yangtze.', 'Memorial Hall Archives'),
('1937-12-13', 'The Fall of Nanjing', 'Japanese troops enter the city. The Nanjing Massacre begins. Now observed as National Memorial Day.', 'Memorial Hall Archives'),
('1938-02-01', 'Order Gradually Restored', 'Japanese authorities begin restoring order. Safety Zone committee documents atrocities.', 'Memorial Hall Archives'),
('1946-01-01', 'Tokyo War Crimes Tribunal', 'IMTFE examines evidence. General Matsui found guilty. Estimated 200,000+ civilians killed.', 'Memorial Hall Archives'),
('1985-08-15', 'Memorial Hall Established', 'The Memorial Hall opens in Nanjing, built on the site of a mass grave.', 'Memorial Hall Archives'),
('2014-12-13', 'First National Memorial Day', 'China holds its first national memorial ceremony on December 13.', 'Memorial Hall Archives');

PRINT '=== TimelineEvents seeded ===';

-- Seed GalleryItems
IF NOT EXISTS (SELECT 1 FROM GalleryItems WHERE Title = 'Atrocities Recorded in Diaries')
INSERT INTO GalleryItems (Title, Description, ImagePath, Category, YearTaken, Source) VALUES
('Atrocities Recorded in Diaries', 'Diary entries documenting atrocities committed by Japanese invaders in 1937.', 'image/AtrocitiesRecordedinDiaries.jpg', 'Documents', '1937', 'Memorial Hall Archives'),
('Nanjing Safety Zone', 'The international safety zone established to shelter Chinese civilians.', 'image/RevisitingtheNanjingSafetyZone.jpg', 'Safety Zone', '1937', 'Memorial Hall Archives'),
('John Rabe Legacy', 'German businessman who led the International Safety Zone Committee.', 'image/JohnRabeLegacy.jpg', 'Safety Zone', '1937', 'Memorial Hall Archives'),
('Minnie Vautrin', 'American missionary who sheltered over 10,000 women at Ginling College.', 'image/MinnieVautrin.jpg', 'Safety Zone', '1937', 'Memorial Hall Archives'),
('Photos by Japanese Soldiers', 'Photographic evidence captured by Japanese soldiers themselves.', 'image/PhotosTakenbyJapaneseSoldiers.png', 'Documents', '1937', 'Memorial Hall Archives'),
('Tokyo Trials Evidence', 'Evidence collection during the International Military Tribunal for the Far East.', 'image/TokyoTrialsEvidenceCollection.jpg', 'Tribunal', '1946', 'Memorial Hall Archives'),
('Memorial Hall Nanjing', 'Built on the original site where remains of victims were found, opened 1985.', 'image/MemorialHall.jpg', 'Memorial', '1985', 'Memorial Hall Archives'),
('National Memorial Day', 'Annual commemoration ceremony held on December 13 since 2014.', 'image/NationalMemorialDay.jpg', 'Memorial', '2014', 'Memorial Hall Archives'),
('Survivor Testimonies', 'Testimonies from survivors preserved for future generations.', 'image/SurvivorTestimonies.jpg', 'Documents', '2014', 'Memorial Hall Archives');

PRINT '=== GalleryItems seeded ===';

-- Seed LearningResources
IF NOT EXISTS (SELECT 1 FROM LearningResources WHERE ResourceTitle = 'Journal of Japanese Invasion of China and Nanjing Massacre')
INSERT INTO LearningResources (ResourceTitle, ResourceType, Author, YearPublished, ResourceURL, Description) VALUES
('Journal of Japanese Invasion of China and Nanjing Massacre', 'Journal', 'Memorial Hall Research Institute', 2021, 'https://www.19371213.com.cn/en/research/rbqhnjdtsyj/', 'Professional academic journal on historical research of the Nanjing Massacre.'),
('Strengthening Translation of Historical Materials', 'Publication', 'Various Scholars', 2025, 'https://www.19371213.com.cn/en/research/publications/', 'New books released to strengthen translation and preserve global memory.'),
('Searching for the Truth', 'Monograph', 'Memorial Hall', 2025, 'https://www.19371213.com.cn/en/research/202601/t20260127_5779648.html', 'Research monograph on the Japanese military comfort women system.'),
('Historical Archives Collection', 'Archive', 'Memorial Hall', 2024, 'https://www.19371213.com.cn/en/research/yjda/', 'Primary historical documents, diaries, photographs, and evidence.'),
('International Peace School Programme', 'Education', 'Memorial Hall', 2024, 'https://www.19371213.com.cn/en/learn/programme/', 'Educational programmes promoting peace and historical awareness.'),
('Nanjing International Peace Newsletter', 'Newsletter', 'Memorial Hall', 2024, 'https://www.19371213.com.cn/en/research/journal/', 'Scholarly newsletter covering peace research and historical memory.');

PRINT '=== LearningResources seeded ===';

PRINT '';
PRINT '=============================================';
PRINT '  DATABASE SETUP COMPLETE!';
PRINT '  16 tables created, test data seeded.';
PRINT '';
PRINT '  Test Accounts (password: 123456):';
PRINT '    Admin:      admin@museum.com';
PRINT '    Instructor: instructor@museum.com';
PRINT '    Member:     member@museum.com';
PRINT '=============================================';
