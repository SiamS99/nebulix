USE [nebulix]
GO
-- Create a view for easier querying of issues with related data
GO
CREATE VIEW dbo.vw_IssueDetails AS
SELECT 
    i.id,
    i.title,
    i.description,
    i.status,
    i.priority,
    i.board_column_position,
    i.created_at,
    i.updated_at,
    p.name AS project_name,
    assignee.username AS assignee_username,
    s.name AS sprint_name,
    STRING_AGG(t.name, ', ') AS tags
FROM dbo.Issue i
    INNER JOIN dbo.Project p ON i.project_id = p.id
    LEFT JOIN dbo.[User] assignee ON i.assignee_id = assignee.id
    LEFT JOIN dbo.Sprint s ON i.sprint_id = s.id
    LEFT JOIN dbo.IssueTag it ON i.id = it.issue_id
    LEFT JOIN dbo.Tag t ON it.tag_id = t.id
GROUP BY 
    i.id, i.title, i.description, i.status, i.priority, i.board_column_position, i.created_at, i.updated_at,
    p.name, assignee.username, s.name;
GO
-- Create a view for project board visualization
GO
CREATE VIEW dbo.vw_ProjectBoardView AS
SELECT 
    pb.id AS board_id,
    pb.name AS board_name,
    pb.project_id,
    p.name AS project_name,
    bc.id AS column_id,
    bc.name AS column_name,
    bc.status_mapping,
    bc.position_order,
    bc.color,
    bc.wip_limit,
    COUNT(i.id) AS issue_count,
    STRING_AGG(CAST(i.id AS NVARCHAR(MAX)), ',') AS issue_ids
FROM dbo.ProjectBoard pb
    INNER JOIN dbo.Project p ON pb.project_id = p.id
    INNER JOIN dbo.BoardColumn bc ON pb.id = bc.board_id
    LEFT JOIN dbo.Issue i ON (i.project_id = pb.project_id AND i.status = bc.status_mapping)
GROUP BY 
    pb.id, pb.name, pb.project_id, p.name, bc.id, bc.name, 
    bc.status_mapping, bc.position_order, bc.color, bc.wip_limit;
GO
-- Create a view for Kanban board with issues
GO
CREATE VIEW dbo.vw_KanbanBoard AS
SELECT 
    pb.id AS board_id,
    pb.name AS board_name,
    pb.project_id,
    bc.id AS column_id,
    bc.name AS column_name,
    bc.status_mapping,
    bc.position_order AS column_order,
    bc.color AS column_color,
    bc.wip_limit,
    i.id AS issue_id,
    i.title AS issue_title,
    i.priority,
    i.board_column_position AS issue_position,
    assignee.username AS assignee,
    assignee.email AS assignee_email
FROM dbo.ProjectBoard pb
    INNER JOIN dbo.BoardColumn bc ON pb.id = bc.board_id
    LEFT JOIN dbo.Issue i ON (i.project_id = pb.project_id AND i.status = bc.status_mapping)
    LEFT JOIN dbo.[User] assignee ON i.assignee_id = assignee.id;
GO
-- Create a stored procedure for getting project statistics
GO
CREATE PROCEDURE dbo.sp_GetProjectStatistics
    @project_id INT
AS
BEGIN
    SELECT 
        p.name AS project_name,
        COUNT(i.id) AS total_issues,
        SUM(CASE WHEN i.status = 'backlog' THEN 1 ELSE 0 END) AS backlog_issues,
        SUM(CASE WHEN i.status = 'ready' THEN 1 ELSE 0 END) AS ready_issues,
        SUM(CASE WHEN i.status = 'in_progress' THEN 1 ELSE 0 END) AS in_progress_issues,
        SUM(CASE WHEN i.status = 'in_review' THEN 1 ELSE 0 END) AS in_review_issues,
        SUM(CASE WHEN i.status = 'testing' THEN 1 ELSE 0 END) AS testing_issues,
        SUM(CASE WHEN i.status = 'done' THEN 1 ELSE 0 END) AS done_issues,
        COUNT(DISTINCT i.assignee_id) AS unique_assignees,
        COUNT(s.id) AS total_sprints,
        COUNT(pb.id) AS total_boards
    FROM dbo.Project p
        LEFT JOIN dbo.Issue i ON p.id = i.project_id
        LEFT JOIN dbo.Sprint s ON p.id = s.project_id
        LEFT JOIN dbo.ProjectBoard pb ON p.id = pb.project_id
    WHERE p.id = @project_id
    GROUP BY p.id, p.name;
END;
GO
-- Create a stored procedure for moving issues between board columns
GO
CREATE PROCEDURE dbo.sp_MoveIssue
    @issue_id INT,
    @new_status NVARCHAR(50),
    @new_position INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update the issue status and position
        UPDATE dbo.Issue 
        SET status = @new_status,
            board_column_position = ISNULL(@new_position, board_column_position),
            updated_at = GETUTCDATE()
        WHERE id = @issue_id;
        
        -- If no position specified, put it at the end of the column
        IF @new_position IS NULL
        BEGIN
            DECLARE @project_id INT;
            SELECT @project_id = project_id FROM dbo.Issue WHERE id = @issue_id;
            
            DECLARE @max_position INT;
            SELECT @max_position = ISNULL(MAX(board_column_position), 0)
            FROM dbo.Issue 
            WHERE project_id = @project_id AND status = @new_status AND id != @issue_id;
            
            UPDATE dbo.Issue 
            SET board_column_position = @max_position + 1
            WHERE id = @issue_id;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 'Issue moved successfully' AS Result;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- Create a stored procedure for getting a Kanban board view
GO
CREATE PROCEDURE dbo.sp_GetKanbanBoard
    @board_id INT
AS
BEGIN
    SELECT 
        board_id,
        board_name,
        project_id,
        column_id,
        column_name,
        status_mapping,
        column_order,
        column_color,
        wip_limit,
        issue_id,
        issue_title,
        priority,
        issue_position,
        assignee,
        assignee_email
    FROM dbo.vw_KanbanBoard
    WHERE board_id = @board_id
    ORDER BY column_order, issue_position;
END;
GO

-- Sample queries to test the board functionality

-- Get all boards for a project
-- SELECT * FROM dbo.ProjectBoard WHERE project_id = 1;

-- Get the Kanban view for the main board
-- EXEC dbo.sp_GetKanbanBoard @board_id = 1;

-- Get board statistics
-- SELECT * FROM dbo.vw_ProjectBoardView WHERE board_id = 1 ORDER BY position_order;

-- Move an issue to a different status
-- EXEC dbo.sp_MoveIssue @issue_id = 1, @new_status = 'testing', @new_position = 1;

-- Get project statistics including board info
-- EXEC dbo.sp_GetProjectStatistics @project_id = 1;

-- Sample query to see issues organized by board columns
-- SELECT 
--     bc.name AS column_name,
--     bc.status_mapping,
--     bc.wip_limit,
--     COUNT(i.id) AS current_issues,
--     CASE 
--         WHEN bc.wip_limit IS NOT NULL AND COUNT(i.id) > bc.wip_limit 
--         THEN 'WIP Limit Exceeded!' 
--         ELSE 'OK' 
--     END AS wip_status
-- FROM dbo.BoardColumn bc
-- LEFT JOIN dbo.Issue i ON (i.status = bc.status_mapping AND i.project_id = (SELECT project_id FROM dbo.ProjectBoard WHERE id = bc.board_id))
-- WHERE bc.board_id = 1
-- GROUP BY bc.name, bc.status_mapping, bc.wip_limit, bc.position_order
-- ORDER BY bc.position_order;