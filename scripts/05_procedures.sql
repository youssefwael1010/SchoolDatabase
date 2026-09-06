USE SchoolDB;
GO

CREATE OR ALTER PROCEDURE sp_GetStudentsByDepartment 
 @DepartmentId int
AS
BEGIN

IF NOT EXISTS (SELECT 1 FROM DEPARTMENT WHERE DepID = @DepartmentId)
    BEGIN
        RAISERROR('Department does not exist.', 16, 1);
        RETURN;
    END

SELECT 
s.StudentId,
s.Name AS StudentName,
d.Name AS DepartmentName,
s.DateOfBirth
FROM STUDENT s
INNER JOIN DEPARTMENT d ON s.DepId = d.DepID
WHERE s.DepId = @DepartmentId
ORDER BY s.Name;
END
GO

--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_EnrollStudent 
 @StudentId int,
 @CourseId int
AS
BEGIN

DECLARE @StudentDepId int , @CourseDepId int ;

SELECT @StudentDepId = DepId FROM STUDENT  WHERE StudentId = @StudentId ; 
SELECT @CourseDepId = DepId FROM COURSE  WHERE CourseId = @CourseId ; 

 IF @StudentDepId IS NULL OR @CourseDepId IS NULL
    BEGIN
        RAISERROR('Student or Course does not exist.', 16, 1);
        RETURN;
    END

IF @StudentDepId <> @CourseDepId
    BEGIN
        RAISERROR('Student and Course must belong to the same Department.', 16, 1);
        RETURN ;
    END

IF EXISTS (SELECT 1 FROM ENROLLMENT WHERE StudentId = @StudentId AND CourseId = @CourseId) 
BEGIN
    RAISERROR('Student is already enrolled in Course.', 16, 1);
    RETURN;
END


INSERT INTO ENROLLMENT(StudentId,CourseId,EnrollmentDate,Grade)
VALUES (@StudentId, @CourseId, CONVERT(DATE, GETDATE()),NULL);

END
GO

--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_TransferStudent 
 @StudentId int,
 @NewDepartmentId int
AS
BEGIN

SET XACT_ABORT ON; -- make automatic rollback in case of runtime error

IF NOT EXISTS (SELECT 1 FROM STUDENT WHERE StudentId = @StudentId )
BEGIN
    RAISERROR('Student does not exist.', 16, 1);
    RETURN;
END


IF  NOT EXISTS (SELECT 1 FROM DEPARTMENT WHERE DepID = @NewDepartmentId )
BEGIN
    RAISERROR('Department does not exist.', 16, 1);
    RETURN;
END

BEGIN TRANSACTION;


UPDATE STUDENT 
SET DepId = @NewDepartmentId
WHERE StudentId = @StudentId;


IF EXISTS (
    SELECT 1 
    FROM ENROLLMENT e
    INNER JOIN COURSE c ON e.CourseId = c.CourseId
    WHERE e.StudentId = @StudentId AND c.DepId <> @NewDepartmentId
)
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('Student has existing Enrollments that conflict with the new Department.',16,1);
    RETURN;
END

COMMIT TRANSACTION;


END
GO

--------------------------------------------------------------------------------
