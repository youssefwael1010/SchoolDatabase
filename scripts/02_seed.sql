USE SchoolDB;
GO

-- 1. DEPARTMENTS

INSERT INTO DEPARTMENT (Name)
VALUES
    (N'Computer Science'),
    (N'Mathematics'),
    (N'Physics');
GO
----------------------------------------------------------------------------------------
-- 2. TEACHERS

INSERT INTO TEACHER (FullName, Email, DepId, SupervisorId) VALUES
('Ahmed Youssef', 'ahmed_youssef@school.edu', 1, NULL),  -- TeacherID 1  CS Lead
('Sara Hassan',   'sara_hassan@school.edu',   1, 1),      -- 2
('Omar Adel',     'omar_adel@school.edu',     1, 1),      -- 3
('Yara Mostafa',  'yara_mostafa@school.edu',  1, 1),      -- 4
('Nour Ibrahim',  'nour_ibrahim@school.edu',  1, 1),      -- 5
('Menna Haitham',   'menna_haitham@school.edu',   1, 1),      -- 6
('Dina Mahmoud',  'dina_mahmoud@school.edu',  1, 1);      -- 7
GO

INSERT INTO TEACHER (FullName, Email, DepId, SupervisorId) VALUES
('Laila Fathy',   'laila_fathy@school.edu',   2, NULL),   -- 8  Math Lead
('Mona Tarek',    'mona_tarek@school.edu',    2, 8),      -- 9
('Khaled Samir',  'khaled_samir@school.edu',  2, 8);      -- 10
GO

INSERT INTO TEACHER (FullName, Email, DepId, SupervisorId) VALUES
('Hany Nabil',    'hany_nabil@school.edu',    3, NULL),   -- 11 Physics Lead
('Rania Fouad',   'rania_fouad@school.edu',   3, 11),     -- 12
('Tamer Adel',    'tamer_adel@school.edu',    3, 11);     -- 13
GO

----------------------------------------------------------------------------------------
-- 3. STUDENTS (6 kol department)

INSERT INTO STUDENT (Name, DateOfBirth, DepId) VALUES
('Mahmoud Ali',    '2006-02-14', 1),  -- 1
('Hend Kamal',     '2005-11-02', 1),  -- 2
('Youssef Adel',   '2006-06-21', 1),  -- 3
('Salma Reda',     '2005-09-09', 1),  -- 4
('Karim Fathy',    '2006-01-30', 1),  -- 5
('Nadia Samir',    '2005-05-17', 1),  -- 6

('Aya Mostafa',    '2006-03-11', 2),  -- 7
('Ziad Hassan',    '2005-12-25', 2),  -- 8
('Marwa Tarek',    '2006-07-04', 2),  -- 9
('Omar Nabil',     '2005-08-19', 2),  -- 10
('Nourhan Adel',   '2006-04-06', 2),  -- 11
('Sherif Kamal',   '2005-10-13', 2),  -- 12

('Lina Fouad',     '2006-05-22', 3),  -- 13
('Adham Samuel',   '2005-06-30', 3),  -- 14
('Rana Ibrahim',   '2006-09-15', 3),  -- 15
('Tarek Youssef',  '2005-02-27', 3),  -- 16
('Mariam Hany',    '2006-08-08', 3),  -- 17
('Bassel Fathy',   '2005-01-19', 3);  -- 18
GO  


UPDATE DEPARTMENT SET LeadTeacherId = 1  WHERE DepID = 1;
UPDATE DEPARTMENT SET LeadTeacherId = 8  WHERE DepID = 2;
UPDATE DEPARTMENT SET LeadTeacherId = 11 WHERE DepID = 3;
GO
----------------------------------------------------------------------------------------
-- 4. COURSES

INSERT INTO COURSE (Name, DepId, TeacherId) VALUES
('Database',  1, 1),          -- 1
('Algorithms',        1, 1),  -- 2
('Operating Systems', 1, 1),  -- 3
('Web Development',   1, 1),  -- 4
('Data Structures',   1, 2),  -- 5

('Calculus I',        2, 9),  -- 6
('Linear Algebra',    2, 10), -- 7
('Statistics',        2, 8),  -- 8

('Mechanics',         3, 12), -- 9
('Electromagnetism',  3, 13); -- 10
GO

----------------------------------------------------------------------------------------
-- 5. ENROLLMENTS


INSERT INTO ENROLLMENT
    (StudentId, CourseId, EnrollmentDate, Grade)
VALUES

(1, 1, '2026-01-10', 88.0),
(1, 2, '2026-01-10', 76.5),
(1, 5, '2026-01-10', NULL),
(2, 1, '2026-01-11', 92.0),
(2, 3, '2026-01-11', 45.0),
(3, 2, '2026-01-11', 67.0),
(3, 4, '2026-01-12', 81.0),
(4, 1, '2026-01-12', NULL),
(4, 5, '2026-01-12', 58.0),
(5, 3, '2026-01-13', 39.5),
(5, 4, '2026-01-13', 74.0),
(6, 1, '2026-01-13', NULL),
(6, 2, '2026-01-14', NULL),

(7, 6, '2026-01-10', 90.0),
(7, 7, '2026-01-10', 84.0),
(8, 6, '2026-01-11', 55.0),
(8, 8, '2026-01-11', NULL),
(9, 7, '2026-01-12', 62.0),
(9, 8, '2026-01-12', 71.0),
(10, 6, '2026-01-12', 48.0),
(11, 7, '2026-01-13', 95.0),
(12, 8, '2026-01-13', 33.0),

(13, 9, '2026-01-10', 80.0),
(13, 10, '2026-01-10', 66.0),
(14, 9, '2026-01-11', 91.0),
(15, 10, '2026-01-11', NULL),
(16, 9, '2026-01-12', 52.0),
(17, 10, '2026-01-12', 47.0),
(18, 9, '2026-01-13', 73.0);
GO