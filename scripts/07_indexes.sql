USE SchoolDB;
GO

DBCC FREEPROCCACHE;

DBCC FREEPROCCACHE

-- 1. Index on Enrollment.StudentId 

SET STATISTICS time, IO ON;
GO
SELECT * FROM ENROLLMENT WHERE StudentId = 1;
GO
SET STATISTICS time, IO OFF;
GO
/*
Plan shows Clustered Index Seek on PK_Enrollment, no extra index needed.
PK is composite (StudentId, CourseId) -> that is already the clustered index,
and StudentId is the first column in it, so it seeks fine on its own.
Adding a separate index here would just be a duplicate. Skipped it
*/

--------------------------------------------------------------------------------------
--  2. Composite index on (StudentId, CourseId) 

SET STATISTICS time,IO ON;
GO
-- same check sp_EnrollStudent does before every insert (duplicate-enrollment check)
SELECT 1 FROM ENROLLMENT WHERE StudentId = 4 AND CourseId = 1;
GO
SET STATISTICS time,IO OFF;
GO
-- Same story, still using PK_Enrollment. It's already a composite index
-- on these exact 2 columns, so no need to create another one


--------------------------------------------------------------------------------------

-- 3. single column vs composite index (just a note, no code)

/*
If Enrollment had a normal surrogate ID instead of a composite PK,
these would actually be different indexes
StudentId alone -> best for all enrollments of one student
(StudentId, CourseId) -> best for checking one exact pair
Order matters,here they do the same thing because of the composite PK
*/

--------------------------------------------------------------------------------------
--  4. index for students in a course ordered by grade desc

SET STATISTICS time,IO ON;
GO
SELECT StudentId, Grade, EnrollmentDate
FROM ENROLLMENT
WHERE CourseId = 1
ORDER BY Grade DESC;
GO
SET STATISTICS time,IO OFF;
GO
-- Before the index: full scan + manual sort, since CourseId isn't the leading column of the PK

CREATE INDEX IX_Enrollment_Course_GradeDesc
    ON ENROLLMENT(CourseId, Grade DESC)
    INCLUDE (StudentId, EnrollmentDate);
GO


SET STATISTICS time,IO ON;
GO
SELECT StudentId, Grade, EnrollmentDate
FROM ENROLLMENT
WHERE CourseId = 1
ORDER BY Grade DESC;
GO
SET STATISTICS time,IO OFF;
GO

/*
After: seek, no sort. CourseId is the filter column,
Grade DESC matches the ORDER BY, and INCLUDE covers the rest of the
SELECT so it never has to go back to the table.
*/

--------------------------------------------------------------------------------------
-- extra indexes on FK columns used a lot

/*
Department lookups (sp_GetStudentsByDepartment, vw_DepartmentSummary,
the Student-Department join query). INCLUDE (Name) makes each index
covering for queries that only need the name alongside the FK filter
*/
CREATE INDEX IX_Student_DepId ON STUDENT (DepId) INCLUDE (Name);
GO
CREATE INDEX IX_Teacher_DepId ON TEACHER (DepId) INCLUDE (FullName);
GO
CREATE INDEX IX_Course_DepId  ON COURSE  (DepId) INCLUDE (Name);
GO

-- Used by sp_GetStudentsByDepartment, vw_DepartmentSummary, and any department join
CREATE INDEX IX_Teacher_SupervisorId
    ON TEACHER (SupervisorId)
    INCLUDE (FullName, DepId);
GO
-- Used by the self-join query (lead teacher -> supervised teachers)

--------------------------------------------------------------------------------------
--  6. low selectivity on Course.TeacherId

CREATE INDEX IX_Course_TeacherId ON COURSE(TeacherId);
GO

SET STATISTICS time,IO ON;
GO
SELECT * FROM COURSE WHERE TeacherId = 1;   -- Ahmed teaches 4 of 10 Courses = 40%
GO
SET STATISTICS time,IO OFF;
GO

/*
Plan still does a table scan, ignores the new index. 
40% of the table is too big a chunk, seeking + key lookup per row would
cost more than one sequential scan. Index is unused for reads
*/