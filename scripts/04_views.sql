USE SchoolDB;
GO

CREATE OR ALTER VIEW vw_DepartmentSummary AS
SELECT
	d.DepID,
	d.Name As DepartmentName,
	COUNT(DISTINCT s.StudentId) As StudentCount ,
	COUNT(DISTINCT t.TeacherID) As TeacherCount 

FROM DEPARTMENT d
LEFT JOIN STUDENT s ON d.DepID = s.DepId
LEFT JOIN TEACHER t ON d.DepID = t.DepId   
GROUP BY d.DepID , d.Name
GO
----------------------------------------------------------------------------------------


CREATE OR ALTER VIEW vw_TeacherCourseLoad AS
SELECT
	t.TeacherID,
	t.FullName AS TeacherName,
	COUNT(c.CourseId) AS CourseCount

FROM TEACHER t
LEFT JOIN COURSE c ON t.TeacherID = c.TeacherId AND t.DepId = c.DepId 
GROUP BY t.TeacherID, t.FullName
GO

----------------------------------------------------------------------------------------


CREATE OR ALTER VIEW vw_StudentFullReport AS
SELECT
    s.StudentId,
    s.Name AS StudentName,
    d.Name AS DepartmentName,
    c.Name AS CourseName,
    e.EnrollmentDate,
    e.Grade,
    CASE
        WHEN e.IsPassed IS NULL THEN 'Pending'
        WHEN e.IsPassed = 1     THEN 'Passed'
        ELSE 'Failed'
    END AS Status
FROM STUDENT s
INNER JOIN DEPARTMENT d ON d.DepID = s.DepId
INNER JOIN ENROLLMENT e ON e.StudentId = s.StudentId
INNER JOIN COURSE c     ON c.CourseId = e.CourseId;
GO

----------------------------------------------------------------------------------------


CREATE OR ALTER VIEW vw_DepartmentTopStudent AS
WITH StudentAverages AS ( -- temp table 
    SELECT 
        s.StudentId,
        s.Name AS StudentName,
        s.DepId,
        AVG(e.Grade) AS AverageGrade,
        RANK() OVER (
            PARTITION BY s.DepId -- separate rank for each department
            ORDER BY AVG(e.Grade) DESC, s.StudentId
        ) AS RankInDept
    FROM STUDENT s
    INNER JOIN ENROLLMENT e ON s.StudentId = e.StudentId
    WHERE e.Grade is not null  -- only graded Enrollments average
    GROUP BY s.StudentId, s.Name, s.DepId
)
SELECT 
    d.Name AS DepartmentName,
    sa.StudentId,
    sa.StudentName,
    sa.AverageGrade
FROM StudentAverages sa
INNER JOIN DEPARTMENT d ON sa.DepId = d.DepID
WHERE sa.RankInDept = 1;
GO
----------------------------------------------------------------------------------------

SELECT * FROM vw_DepartmentSummary ;