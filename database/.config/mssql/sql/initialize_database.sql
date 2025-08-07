USE [nebulix]

-- SQL Server 2022 Database Schema and Sample Data
-- Drop existing tables (in reverse order due to foreign keys)
IF OBJECT_ID('dbo.BoardColumn', 'U') IS NOT NULL DROP TABLE dbo.BoardColumn;
IF OBJECT_ID('dbo.ProjectBoard', 'U') IS NOT NULL DROP TABLE dbo.ProjectBoard;
IF OBJECT_ID('dbo.IssueTag', 'U') IS NOT NULL DROP TABLE dbo.IssueTag;
IF OBJECT_ID('dbo.Comment', 'U') IS NOT NULL DROP TABLE dbo.Comment;
IF OBJECT_ID('dbo.WebhookEvent', 'U') IS NOT NULL DROP TABLE dbo.WebhookEvent;
IF OBJECT_ID('dbo.Issue', 'U') IS NOT NULL DROP TABLE dbo.Issue;
IF OBJECT_ID('dbo.Sprint', 'U') IS NOT NULL DROP TABLE dbo.Sprint;
IF OBJECT_ID('dbo.Tag', 'U') IS NOT NULL DROP TABLE dbo.Tag;
IF OBJECT_ID('dbo.Project', 'U') IS NOT NULL DROP TABLE dbo.Project;
IF OBJECT_ID('dbo.[User]', 'U') IS NOT NULL DROP TABLE dbo.[User];

-- Create User table
CREATE TABLE dbo.[User] (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(255) NOT NULL UNIQUE,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    github_id NVARCHAR(100) NULL,
    gitlab_id NVARCHAR(100) NULL,
    role NVARCHAR(50) NOT NULL DEFAULT 'developer',
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Create Project table
CREATE TABLE dbo.Project (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    owner_id INT NOT NULL,
    description NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (owner_id) REFERENCES dbo.[User](id)
);

-- Create ProjectBoard table
CREATE TABLE dbo.ProjectBoard (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    project_id INT NOT NULL,
    description NVARCHAR(MAX) NULL,
    is_default BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (project_id) REFERENCES dbo.Project(id)
);

-- Create BoardColumn table (swim lanes)
CREATE TABLE dbo.BoardColumn (
    id INT IDENTITY(1,1) PRIMARY KEY,
    board_id INT NOT NULL,
    name NVARCHAR(255) NOT NULL,
    status_mapping NVARCHAR(50) NOT NULL, -- Maps to Issue.status values
    position_order INT NOT NULL,
    color NVARCHAR(7) NULL DEFAULT '#6B73FF',
    wip_limit INT NULL, -- Work in Progress limit
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (board_id) REFERENCES dbo.ProjectBoard(id),
    UNIQUE(board_id, position_order),
    UNIQUE(board_id, status_mapping)
);

-- Create Sprint table
CREATE TABLE dbo.Sprint (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    project_id INT NOT NULL,
    start_date DATETIME2 NOT NULL,
    end_date DATETIME2 NOT NULL,
    FOREIGN KEY (project_id) REFERENCES dbo.Project(id)
);

-- Create Issue table
CREATE TABLE dbo.Issue (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    status NVARCHAR(50) NOT NULL DEFAULT 'backlog',
    priority NVARCHAR(50) NOT NULL DEFAULT 'medium',
    assignee_id INT NULL,
    project_id INT NOT NULL,
    sprint_id INT NULL,
    board_column_position INT NULL, -- Position within the column for ordering
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (assignee_id) REFERENCES dbo.[User](id),
    FOREIGN KEY (project_id) REFERENCES dbo.Project(id),
    FOREIGN KEY (sprint_id) REFERENCES dbo.Sprint(id)
);

-- Create Comment table
CREATE TABLE dbo.Comment (
    id INT IDENTITY(1,1) PRIMARY KEY,
    issue_id INT NOT NULL,
    user_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (issue_id) REFERENCES dbo.Issue(id),
    FOREIGN KEY (user_id) REFERENCES dbo.[User](id)
);

-- Create Tag table
CREATE TABLE dbo.Tag (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE,
    color NVARCHAR(7) NOT NULL DEFAULT '#808080'
);

-- Create IssueTag junction table
CREATE TABLE dbo.IssueTag (
    issue_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (issue_id, tag_id),
    FOREIGN KEY (issue_id) REFERENCES dbo.Issue(id),
    FOREIGN KEY (tag_id) REFERENCES dbo.Tag(id)
);

-- Create WebhookEvent table
CREATE TABLE dbo.WebhookEvent (
    id INT IDENTITY(1,1) PRIMARY KEY,
    source NVARCHAR(100) NOT NULL, -- 'GitHub' or 'GitLab'
    event_type NVARCHAR(100) NOT NULL,
    payload NVARCHAR(MAX) NOT NULL, -- JSON data
    received_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    project_id INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES dbo.Project(id)
);

-- Create indexes for performance
CREATE INDEX IX_Issue_project_id ON dbo.Issue(project_id);
CREATE INDEX IX_Issue_assignee_id ON dbo.Issue(assignee_id);
CREATE INDEX IX_Issue_sprint_id ON dbo.Issue(sprint_id);
CREATE INDEX IX_Issue_status ON dbo.Issue(status);
CREATE INDEX IX_Comment_issue_id ON dbo.Comment(issue_id);
CREATE INDEX IX_Comment_user_id ON dbo.Comment(user_id);
CREATE INDEX IX_Sprint_project_id ON dbo.Sprint(project_id);
CREATE INDEX IX_WebhookEvent_project_id ON dbo.WebhookEvent(project_id);
CREATE INDEX IX_ProjectBoard_project_id ON dbo.ProjectBoard(project_id);
CREATE INDEX IX_BoardColumn_board_id ON dbo.BoardColumn(board_id);
CREATE INDEX IX_BoardColumn_status_mapping ON dbo.BoardColumn(status_mapping);

-- Insert sample data
-- Users
INSERT INTO dbo.[User] (username, email, password_hash, github_id, gitlab_id, role) VALUES
('john_doe', 'john.doe@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj2FMVNGM5mS', 'johndoe123', NULL, 'admin'),
('jane_smith', 'jane.smith@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj2FMVNGM5mS', 'janesmith456', '789', 'developer'),
('bob_wilson', 'bob.wilson@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj2FMVNGM5mS', NULL, 'bobw321', 'developer'),
('alice_jones', 'alice.jones@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj2FMVNGM5mS', 'alicej789', NULL, 'tester'),
('mike_brown', 'mike.brown@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj2FMVNGM5mS', 'mikebrown', '654', 'project_manager');

-- Projects
INSERT INTO dbo.Project (name, owner_id, description) VALUES
('E-Commerce Platform', 1, 'Modern e-commerce platform with React frontend and Node.js backend'),
('Mobile Banking App', 2, 'Secure mobile banking application for iOS and Android'),
('Data Analytics Dashboard', 1, 'Business intelligence dashboard with real-time analytics'),
('Customer Support Portal', 5, 'Self-service customer support portal with ticketing system');

-- Project Boards
INSERT INTO dbo.ProjectBoard (name, project_id, description, is_default) VALUES
('Main Kanban Board', 1, 'Primary project board for tracking all issues', 1),
('Development Board', 1, 'Board focused on development tasks', 0),
('Banking App Board', 2, 'Kanban board for mobile banking development', 1),
('Analytics Board', 3, 'Board for analytics dashboard development', 1),
('Support Portal Board', 4, 'Board for customer support portal', 1);

-- Board Columns (Swim Lanes)
INSERT INTO dbo.BoardColumn (board_id, name, status_mapping, position_order, color, wip_limit) VALUES
-- Main Kanban Board columns
(1, 'Backlog', 'backlog', 1, '#9E9E9E', NULL),
(1, 'Ready', 'ready', 2, '#2196F3', NULL),
(1, 'In Progress', 'in_progress', 3, '#FF9800', 3),
(1, 'In Review', 'in_review', 4, '#9C27B0', 2),
(1, 'Testing', 'testing', 5, '#FF5722', 2),
(1, 'Done', 'done', 6, '#4CAF50', NULL),

-- Development Board columns
(2, 'Todo', 'backlog', 1, '#607D8B', NULL),
(2, 'Coding', 'in_progress', 2, '#FF9800', 2),
(2, 'Code Review', 'in_review', 3, '#9C27B0', 1),
(2, 'Completed', 'done', 4, '#4CAF50', NULL),

-- Banking App Board columns
(3, 'New', 'backlog', 1, '#9E9E9E', NULL),
(3, 'Analysis', 'ready', 2, '#03A9F4', NULL),
(3, 'Development', 'in_progress', 3, '#FF9800', 4),
(3, 'Security Review', 'in_review', 4, '#E91E63', 1),
(3, 'Testing', 'testing', 5, '#FF5722', 2),
(3, 'Deployed', 'done', 6, '#4CAF50', NULL),

-- Analytics Board columns
(4, 'Backlog', 'backlog', 1, '#9E9E9E', NULL),
(4, 'In Development', 'in_progress', 2, '#FF9800', 3),
(4, 'Review', 'in_review', 3, '#9C27B0', 2),
(4, 'Complete', 'done', 4, '#4CAF50', NULL),

-- Support Portal Board columns
(5, 'Ideas', 'backlog', 1, '#9E9E9E', NULL),
(5, 'Ready to Start', 'ready', 2, '#2196F3', NULL),
(5, 'Working On', 'in_progress', 3, '#FF9800', 2),
(5, 'Testing', 'testing', 4, '#FF5722', 1),
(5, 'Finished', 'done', 5, '#4CAF50', NULL);

-- Sprints
INSERT INTO dbo.Sprint (name, project_id, start_date, end_date) VALUES
('Sprint 1 - Foundation', 1, '2024-01-01 09:00:00', '2024-01-15 17:00:00'),
('Sprint 2 - User Authentication', 1, '2024-01-16 09:00:00', '2024-01-30 17:00:00'),
('Sprint 3 - Product Catalog', 1, '2024-01-31 09:00:00', '2024-02-14 17:00:00'),
('Sprint 1 - Core Banking Features', 2, '2024-01-01 09:00:00', '2024-01-14 17:00:00'),
('Sprint 2 - Security Implementation', 2, '2024-01-15 09:00:00', '2024-01-29 17:00:00'),
('Sprint 1 - Data Pipeline Setup', 3, '2024-02-01 09:00:00', '2024-02-15 17:00:00'),
('Sprint 2 - Dashboard UI', 3, '2024-02-16 09:00:00', '2024-03-01 17:00:00'),
('Sprint 1 - Portal Framework', 4, '2024-01-15 09:00:00', '2024-01-29 17:00:00');

-- Tags
INSERT INTO dbo.Tag (name, color) VALUES
('bug', '#FF0000'),
('feature', '#00FF00'),
('enhancement', '#0000FF'),
('documentation', '#FFA500'),
('urgent', '#FF69B4'),
('backend', '#800080'),
('frontend', '#008080'),
('testing', '#FFD700'),
('security', '#DC143C'),
('performance', '#32CD32');

-- Issues
INSERT INTO dbo.Issue (title, description, status, priority, assignee_id, project_id, sprint_id, board_column_position) VALUES
('Implement user registration', 'Create user registration form with validation and email verification', 'in_progress', 'high', 2, 1, 1, 1),
('Fix login redirect bug', 'Users are redirected to wrong page after successful login', 'ready', 'medium', 3, 1, 2, 1),
('Add product search functionality', 'Implement search bar with filters for product catalog', 'backlog', 'high', 2, 1, 3, 1),
('Database performance optimization', 'Optimize slow queries in the product catalog', 'done', 'medium', 3, 1, 1, 1),
('Implement two-factor authentication', 'Add 2FA support for enhanced security', 'in_progress', 'high', 2, 2, 5, 1),
('Design mobile app wireframes', 'Create wireframes for all main screens', 'done', 'medium', 4, 2, 4, 1),
('API rate limiting implementation', 'Implement rate limiting to prevent API abuse', 'testing', 'high', 3, 2, 5, 1),
('Set up data ingestion pipeline', 'Configure ETL pipeline for analytics data', 'in_progress', 'high', 2, 3, 6, 1),
('Create dashboard mockups', 'Design mockups for the main dashboard interface', 'ready', 'medium', 4, 3, 7, 1),
('Implement user ticket system', 'Create ticket creation and management system', 'in_progress', 'high', 2, 4, 8, 1),
('Add live chat integration', 'Integrate third-party live chat solution', 'backlog', 'low', 3, 4, 8, 1),
('Write API documentation', 'Document all REST API endpoints', 'in_review', 'medium', 4, 1, 2, 1),
('Setup CI/CD pipeline', 'Configure automated testing and deployment', 'ready', 'high', 3, 1, 2, 2),
('Implement payment gateway', 'Integrate Stripe payment processing', 'backlog', 'high', 2, 1, 3, 2),
('Mobile app authentication', 'Implement biometric authentication for mobile app', 'in_review', 'high', 2, 2, 5, 1),
('Real-time notifications', 'Add push notification support', 'testing', 'medium', 3, 2, 5, 2);

-- Comments
INSERT INTO dbo.Comment (issue_id, user_id, content) VALUES
(1, 1, 'This looks good! Make sure to include proper validation for email addresses.'),
(1, 2, 'I''ve implemented the basic form. Working on email verification now.'),
(1, 3, 'Should we also add social login options like Google/Facebook?'),
(2, 2, 'I can reproduce this issue. It seems related to the session management.'),
(2, 1, 'Let''s prioritize this as it affects user experience significantly.'),
(3, 4, 'The search functionality should include autocomplete suggestions.'),
(3, 2, 'Agreed. I''ll work on the backend API first, then we can add the frontend features.'),
(4, 3, 'Performance improved by 40% after adding the proper indexes.'),
(4, 1, 'Great work! The query execution time is now under 100ms.'),
(5, 2, 'I''m looking into TOTP-based 2FA. Should have a prototype ready soon.'),
(5, 5, 'Make sure to consider SMS backup option for users without authenticator apps.'),
(8, 2, 'The data pipeline is processing about 1M records per hour now.'),
(8, 1, 'Excellent! That should handle our current data volume with room for growth.'),
(10, 2, 'I''ve created the basic ticket CRUD operations. Working on status workflow now.'),
(12, 4, 'I''ve documented about 60% of the endpoints. Should be complete by end of sprint.');

-- IssueTag relationships
INSERT INTO dbo.IssueTag (issue_id, tag_id) VALUES
(1, 2), -- feature
(1, 7), -- frontend
(2, 1), -- bug
(2, 5), -- urgent
(2, 6), -- backend
(3, 2), -- feature
(3, 7), -- frontend
(4, 9), -- performance
(4, 6), -- backend
(5, 2), -- feature
(5, 9), -- security
(6, 4), -- documentation
(6, 7), -- frontend
(7, 2), -- feature
(7, 9), -- security
(7, 6), -- backend
(8, 2), -- feature
(8, 6), -- backend
(9, 4), -- documentation
(9, 7), -- frontend
(10, 2), -- feature
(10, 6), -- backend
(11, 2), -- feature
(11, 3), -- enhancement
(12, 4); -- documentation

-- WebhookEvent sample data
INSERT INTO dbo.WebhookEvent (source, event_type, payload, project_id) VALUES
('GitHub', 'push', '{"ref":"refs/heads/main","commits":[{"id":"a1b2c3d4","message":"Fix user registration validation","author":{"name":"Jane Smith","email":"jane.smith@example.com"}}]}', 1),
('GitHub', 'pull_request', '{"action":"opened","number":42,"title":"Add product search API","user":{"login":"johndoe123"},"head":{"ref":"feature/search-api"}}', 1),
('GitLab', 'merge_request', '{"object_kind":"merge_request","object_attributes":{"action":"opened","title":"Implement 2FA","source_branch":"feature/2fa","target_branch":"main"}}', 2),
('GitHub', 'issues', '{"action":"closed","issue":{"number":15,"title":"Database performance optimization","state":"closed","assignee":{"login":"bobwilson"}}}', 1),
('GitLab', 'push', '{"ref":"refs/heads/develop","commits":[{"id":"e5f6g7h8","message":"Add dashboard chart components","author":{"name":"Jane Smith","email":"jane.smith@example.com"}}]}', 3),
('GitHub', 'pull_request', '{"action":"closed","number":38,"title":"Update API documentation","merged":true,"user":{"login":"alicej789"}}', 4);

-- Add some additional sample data for better testing
INSERT INTO dbo.Issue (title, description, status, priority, assignee_id, project_id, sprint_id, board_column_position) VALUES
('Refactor authentication middleware', 'Clean up and optimize the authentication middleware code', 'backlog', 'low', 3, 1, NULL, 3),
('Add unit tests for user service', 'Increase test coverage for user-related functionality', 'ready', 'medium', 4, 2, NULL, 2),
('Update deployment documentation', 'Documentation needs to be updated for the new deployment process', 'backlog', 'low', 4, 3, NULL, 2);

INSERT INTO dbo.IssueTag (issue_id, tag_id) VALUES
(13, 3), -- enhancement
(13, 6), -- backend
(14, 8), -- testing
(15, 4); -- documentation