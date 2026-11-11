-- Executing these queries individually without a transaction block so an expected failure doesn't abort the rest of the script in Postgres.
-- Using 500-series IDs for test inputs to clearly separate negative test cases from existing seed data.

-- Re-using existing student ID 101 to verify the primary key prevents duplicate record creation.
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active")
VALUES (101, '2026-02-01', TRUE);

-- Passing NULL for enrolled_on to make sure mandatory field checks happen at the database level rather than relying solely on application code.
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active")
VALUES (509, NULL, TRUE);

-- Testing a primary key collision on course ID 201 to ensure reference tables maintain strict unique identifiers.
INSERT INTO portfolio."courses" ("course_id", "course_code", "title")
VALUES (201, 'SYN103', 'Synthetic Alternate');

-- Using duplicate code 'SYN101' with a fresh ID to verify unique business keys are enforced independently of primary keys.
INSERT INTO portfolio."courses" ("course_id", "course_code", "title")
VALUES (501, 'SYN101', 'Synthetic Duplicate Code');

-- Attempting duplicate ID 301 to ensure surrogate key rules hold for schedule records.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (301, 202, '2028FA', '2028-09-01', '2028-12-15');

-- Scheduling course 201 in term 2026FA again to make sure the composite key prevents double-booking a course in the same term.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (502, 201, '2026FA', '2026-09-02', '2026-12-15');

-- Passing non-existent course ID 999999 to test that foreign key constraints block orphan offerings.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (503, 999999, '2028SP', '2028-01-10', '2028-05-20');

-- Putting an end date before a start date to verify the table's CHECK constraint catches timeline logic errors.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (507, 201, '2029FA', '2029-12-16', '2029-09-01');

-- Re-using result ID 401 to ensure unique key enforcement holds on grade junction records.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (401, 101, 302, 80, '2027-05-22T09:00:00Z');

-- Entering a second grade for student 101 in offering 301 to confirm composite unique rules stop duplicate grade records for the same attempt.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (504, 101, 301, 80, '2026-12-17T09:00:00Z');

-- Using invalid student ID 999999 to confirm grades can't be logged for non-existent users.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (505, 999999, 302, 80, '2027-05-22T09:00:00Z');

-- Using invalid offering ID 999999 to verify grades can only be tied to real course offerings.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (506, 101, 999999, 80, '2027-05-22T09:00:00Z');

-- Entering a score of 101 to verify range limits prevent out-of-bounds numbers from hitting the database.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (508, 101, 302, 101, '2027-05-22T09:00:00Z');
