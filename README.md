# School Management System — SchoolDB

A SQL Server database for a school management system: departments, teachers, students, courses, and enrollment. Covers schema design, constraints, seed data, JOIN queries, Views, Stored Procedures, Functions, and indexing with execution-plan evidence.

## Project Structure

```
SchoolDatabase/
├── erd/
│   └── erd.png              -> ERD diagram (Chen notation)
├── scripts/
│   ├── 01_schema.sql        -> Tables + constraints
│   ├── 02_seed.sql          -> Sample data
│   ├── 03_joins.sql         -> JOIN queries
│   ├── 04_views.sql         -> Views
│   ├── 05_procedures.sql    -> Stored Procedures + Transaction
│   ├── 06_functions.sql     -> Functions
│   └── 07_indexes.sql       -> Indexing + performance analysis
├── evidence/
│   ├── 01_student_enrollment_plan.png
│   ├── 02_course_grade_plan.png
│   └── 03_low_selectivity_plan.png
└── README.md
```

## How to Run

Run the scripts in order inside SSMS:

1. `01_schema.sql` — creates `SchoolDB` and all tables.
2. `02_seed.sql` — inserts sample data.
3. `03_joins.sql` → `06_functions.sql` — JOIN queries, Views, Procedures, Functions.
4. `07_indexes.sql` — run with **Include Actual Execution Plan** (`Ctrl+M`) enabled to see the plans referenced below.

## Entities & Relationships

- **Department** — has many Teachers, Students, and Courses; has one optional Lead Teacher.
- **Teacher** — belongs to one Department; may supervise other Teachers in the same Department (self-referencing, optional).
- **Student** — belongs to one Department.
- **Course** — belongs to one Department, taught by one Teacher (same Department as the Course).
- **Enrollment** — resolves the Student↔Course many-to-many relationship; stores `EnrollmentDate` and `Grade`.

## Key Design Decisions

**Composite foreign keys** guarantee cross-table consistency at the database level, not just by convention:
- `Course(TeacherId, DepId) → Teacher(TeacherID, DepId)` — a Course's Teacher must be in the Course's own Department.
- `Teacher(SupervisorId, DepId) → Teacher(TeacherID, DepId)` — a Supervisor must be in the same Department.
- `Department(LeadTeacherId, DepID) → Teacher(TeacherID, DepId)` — a Department's Lead must belong to that Department.

**`LeadTeacherId` is nullable**, not `NOT NULL`. Department and Teacher reference each other (a Department needs a Lead, a Teacher needs a Department), so the first Department row can't be inserted with a mandatory Lead that doesn't exist yet. It's set via `UPDATE` in `02_seed.sql` right after the Teachers are inserted.

**Enrollment has no surrogate ID.** Its Primary Key is the pair `(StudentId, CourseId)` itself. It's an **Associative Entity** (depends on two owners, its whole key is borrowed from them) rather than a classic Weak Entity (which depends on a single owner plus a partial key of its own).

**`NOT EXISTS` instead of `NOT IN`** for finding students with no grade — unaffected by NULLs in the subquery, and short-circuits on the first match.

**`ROW_NUMBER()`/`DENSE_RANK()` chosen deliberately over `RANK()`** where used — `RANK()` leaves gaps after ties (1,1,3), which would understate how many distinct grade levels or departments actually qualify.

**`IsPassed`/`Status` is always computed, never stored as data** — a computed column in `ENROLLMENT`, reused by `fn_IsPassed` and `vw_StudentFullReport`, so the Pass/Fail rule lives in exactly one place.

## Indexing — What the Evidence Shows

- `evidence/01_student_enrollment_plan.png`: `WHERE StudentId = 1` already gets a **Clustered Index Seek** on `PK_Enrollment` — proof that a separate index on `Enrollment.StudentId` would be redundant, since the composite PK already leads with that column.
- `evidence/02_course_grade_plan.png`: after creating `IX_Enrollment_Course_GradeDesc`, `WHERE CourseId = 1 ORDER BY Grade DESC` becomes an **Index Seek with no Sort** — the covering index eliminates both the scan and the sort.
- `evidence/03_low_selectivity_plan.png`: even after creating `IX_Course_TeacherId`, `WHERE TeacherId = 1` still runs a **Clustered Index Scan** — confirms that when one Teacher owns a large share of Courses (~40% here), the optimizer correctly prefers a scan over a seek + key lookup per row.
