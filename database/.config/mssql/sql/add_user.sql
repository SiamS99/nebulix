-- Settings
DECLARE @windowsLogin NVARCHAR(128) = N'nebulix_user';  -- Replace with your actual domain\user
DECLARE @dbName NVARCHAR(128) = N'nebulix';         -- The database name to create or use
DECLARE @dbUserName NVARCHAR(128) = N'nebulix_user';             -- This is the username portion (can match login or be different)
DECLARE @role NVARCHAR(128) = N'db_owner';                       -- Optional role assignment

-- Step 1: Create the login if it doesn't exist
IF NOT EXISTS (
    SELECT 1 FROM sys.server_principals 
    WHERE name = @windowsLogin AND type_desc = 'WINDOWS_LOGIN'
)
BEGIN
    PRINT 'Creating Windows login...';
    CREATE LOGIN [nebulix_user] with PASSWORD = 'YourStrong!Passw0rd'; -- Replace with a strong password
END
ELSE
BEGIN
    PRINT 'Windows login already exists.';
END

-- Step 2: Create the database if it doesn't exist (optional)
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @dbName)
BEGIN
    PRINT 'Creating database...';
    EXEC('CREATE DATABASE [' + @dbName + ']');
END
ELSE
BEGIN
    PRINT 'Database already exists.';
END

-- Step 3: Create the database user and assign a role
DECLARE @sql NVARCHAR(MAX) = '
USE [' + @dbName + '];

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals WHERE name = N''' + @dbUserName + '''
)
BEGIN
    PRINT ''Creating database user for Windows login...'';
    CREATE USER [' + @dbUserName + '] FOR LOGIN [' + @windowsLogin + '];
    EXEC sp_addrolemember N''' + @role + ''', N''' + @dbUserName + ''';
END
ELSE
BEGIN
    PRINT ''Database user already exists.'';
END
';
EXEC(@sql);
