USE SchoolDB;
GO

CREATE OR ALTER FUNCTION fn_CalculateAge (@DateOfBirth DATE)
RETURNS INT 
As 
BEGIN 
	DECLARE @Age int;

	-- get years but subtracting one year if the exact day and month mgash
	SET @Age = DATEDIFF(year, @DateOfBirth,GETDATE()) -	
	CASE
		WHEN (MONTH(@DateOfBirth) > MONTH(GETDATE()))
		OR (MONTH(@DateOfBirth) = MONTH(GETDATE()) AND DAY(@DateOfBirth) > DAY(GETDATE()))
		THEN 1 
		ELSE 0 
	END;

	RETURN @Age;
END
GO

----------------------------------------------------------------------------------------


CREATE OR ALTER FUNCTION fn_IsPassed (@Grade DECIMAL(5,2))
RETURNS VARCHAR(20)
As 
BEGIN 
 DECLARE @Result VARCHAR(20);

 SET @Result =
 CASE
	WHEN @Grade IS NULL THEN 'Pending'
	WHEN @Grade >= 50.0 THEN 'Passed'
	ELSE 'Failed'
 END;

 RETURN @Result;
END
GO

----------------------------------------------------------------------------------------


CREATE OR ALTER FUNCTION fn_GetCoursesByStudent (@StudentId INT)
RETURNS TABLE 
As 
RETURN
(
	SELECT 
	c.CourseId ,
	c.Name AS CourseName,
	e.EnrollmentDate,
	e.Grade ,
	dbo.fn_IsPassed(e.Grade) AS Status
	FROM ENROLLMENT e 
	INNER JOIN COURSE c ON e.CourseId = c.CourseId
	WHERE e.StudentId = @StudentId

);
GO

----------------------------------------------------------------------------------------

CREATE OR ALTER FUNCTION fn_GetTopStudentsByCourse (@CourseId INT ,@TopN INT)
RETURNS  TABLE
As 
RETURN
(
	WITH RankedEnrollments AS (
		SELECT 
		s.StudentId,
		s.Name AS StudentName,
		e.Grade ,
		DENSE_RANK() OVER (ORDER BY e.Grade DESC) -- used dense_rank not rank because of jumping issuees (looked it up)
		AS StudentRank
		FROM ENROLLMENT e
		INNER JOIN STUDENT s ON e.StudentId = s.StudentId
		WHERE e.CourseId = @CourseId AND e.Grade is not null
	)
	SELECT
	StudentId,
	StudentName,
	Grade,
	StudentRank
	FROM RankedEnrollments
	WHERE StudentRank <= @TopN
);
GO
