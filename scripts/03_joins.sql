USE SchoolDB;
GO

-- Get every Student together with their Department name using INNER JOIN
SELECT
    s.StudentId,
    s.Name    AS StudentName,
    d.Name    AS DepartmentName
FROM STUDENT s
INNER JOIN DEPARTMENT d ON d.DepID = s.DepId
ORDER BY d.Name, s.Name;
GO
----------------------------------------------------------------------------------------


-- Get every Teacher who teaches more than 3 Courses
SELECT 
    t.TeacherID,
    t.FullName          AS TeacherName,
    COUNT(c.CourseId)   AS TotalCoursesTaught
FROM TEACHER t
INNER JOIN COURSE c ON c.TeacherId = t.TeacherID AND t.DepId = c.DepId
GROUP BY t.TeacherID, t.FullName
HAVING COUNT(c.CourseId) > 3
ORDER BY TotalCoursesTaught DESC;
GO
----------------------------------------------------------------------------------------


-- Get every Student who has not received a Grade in any enrolled Course using aggregation function
SELECT 
    s.StudentId,
    s.Name AS StudentName
FROM STUDENT s
INNER JOIN ENROLLMENT e ON s.StudentId = e.StudentId
GROUP BY s.StudentId , s.Name
HAVING COUNT(e.Grade) = 0  -- count ignores null so we see if there isn't any grade other than null
ORDER BY s.Name;
GO
----------------------------------------------------------------------------------------


-- Get every Department whose Lead Teacher supervises more than 5 Teachers using a Self JOIN and aggregation
SELECT
    d.DepID,
    d.Name                AS DepartmentName,
    lead.FullName         AS LeadTeacherName,
    COUNT(sub.TeacherID)  AS SupervisedTeachersCount
FROM DEPARTMENT d
INNER JOIN TEACHER lead ON lead.TeacherID = d.LeadTeacherId AND d.DepID = lead.DepId
INNER JOIN TEACHER sub  ON sub.SupervisorId = lead.TeacherID AND lead.DepId = sub.DepId
GROUP BY d.DepID, d.Name, lead.FullName
HAVING COUNT(sub.TeacherID) > 5;
GO
----------------------------------------------------------------------------------------


-- Get average Grade per Course , ignoring null grades in average computation but including it in enrollment count
SELECT
    c.CourseId,
    c.Name              AS CourseName,
    COUNT(e.StudentId)  AS EnrolledCount,
    AVG(e.Grade)         AS AverageGrade
FROM COURSE c
LEFT JOIN ENROLLMENT e ON e.CourseId = c.CourseId
GROUP BY c.CourseId, c.Name
ORDER BY AverageGrade DESC;
GO