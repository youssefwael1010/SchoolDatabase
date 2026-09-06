CREATE DATABASE SchoolDB;
GO
use SchoolDB;
GO

CREATE TABLE DEPARTMENT(
DepID  int identity(1,1),
Name nvarchar(100) not null,
LeadTeacherId int , -- cant make it not null (deadlock)

constraint Unique_Department_Name UNIQUE(Name),
constraint PK_Department PRIMARY KEY(DepID)
);
GO

CREATE TABLE TEACHER(
TeacherID  int identity(1,1),
FullName nvarchar(150) not null,
Email varchar(100) not null,
DepId  int not null,
SupervisorId int ,

constraint Unique_Teacher_Email UNIQUE(Email),
constraint Unique_Teacher_Department UNIQUE (TeacherID, DepId) ,
constraint PK_Teacher PRIMARY KEY(TeacherID),

constraint FK_Department_Teacher FOREIGN KEY(DepId)
REFERENCES DEPARTMENT(DepID),
constraint FK_Teacher_Supervisor FOREIGN KEY (SupervisorId, DepId)
REFERENCES TEACHER(TeacherID, DepId), -- supervisor should supervise the same department he is in 
constraint CK_Teacher_Supervisor CHECK (SupervisorId IS NULL or SupervisorId <> TeacherId) -- cant be teacher and supervisor 

);
GO

ALTER TABLE DEPARTMENT
    ADD constraint FK_Department_LeadTeacher_SameDepartment
        FOREIGN KEY (LeadTeacherId, DepID)
        REFERENCES TEACHER(TeacherId, DepId);
GO


CREATE TABLE STUDENT (
StudentId int identity(1,1),
Name nvarchar(100) not null,
DateOfBirth date not null,
DepId int not null,

constraint PK_Student PRIMARY KEY(StudentId),
constraint FK_Department_Student FOREIGN KEY(DepId)
REFERENCES DEPARTMENT(DepID)
);
GO

CREATE TABLE COURSE (
CourseId int identity(1,1),
Name nvarchar(100) not null ,
DepId int not null , 
TeacherId int not null,

constraint PK_Course PRIMARY KEY (CourseId),
constraint Unique_Course_Name_Department UNIQUE (DepId, Name),-- same course name could be in two diff departments
constraint FK_Department_Course FOREIGN KEY(DepId)
REFERENCES DEPARTMENT(DepID),
constraint FK_Teacher_Course FOREIGN KEY(TeacherId,DepId)
REFERENCES TEACHER(TeacherID,DepId) -- make sure teacher and department are connected

);
GO


CREATE TABLE ENROLLMENT (
StudentId int not null,
CourseId int not null,
EnrollmentDate date not null DEFAULT (CONVERT(date, GETDATE())),
Grade decimal(5,2),
IsPassed AS
(
    CASE
        WHEN Grade IS NULL THEN NULL
        WHEN Grade >= 50 THEN 1
        ELSE 0
    END
),

constraint PK_Enrollment PRIMARY KEY (StudentId,CourseId),
constraint FK_Student_Enrollment FOREIGN KEY(StudentId)
REFERENCES STUDENT(StudentId) ON DELETE CASCADE,
constraint FK_Course_Enrollment FOREIGN KEY(CourseId)
REFERENCES COURSE(CourseId) ON DELETE CASCADE,
constraint CK_Enrollment_Grade CHECK(Grade is null or Grade between 0 and 100), -- grade either not availabe or valid 
constraint CK_Enrollment_EnrollmentDate CHECK (EnrollmentDate <= CONVERT(date, GETDATE())) -- enrollment mynf3sh fl future.
 
);
GO
