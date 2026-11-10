-- Run these deliberately invalid statements one at a time, outside a transaction.
-- Each should fail at the named constraint; the sample rows should remain unchanged.

-- 1. students pk violation. Expected: pk_students, SQLSTATE 23505.
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active")
VALUES (101, '2026-02-01', TRUE);

-- 2. students not null violation. Expected: enrolled_on, SQLSTATE 23502.
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active")
VALUES (509, NULL, TRUE);

-- 3. courses pk violation. Expected: pk_courses, SQLSTATE 23505.
INSERT INTO portfolio."courses" ("course_id", "course_code", "title")
VALUES (201, 'SYN103', 'Synthetic Alternate');

-- 4. courses unique violation. Expected: uq_courses_0, SQLSTATE 23505.
INSERT INTO portfolio."courses" ("course_id", "course_code", "title")
VALUES (501, 'SYN101', 'Synthetic Duplicate Code');

-- 5. offerings pk violation. Expected: pk_offerings, SQLSTATE 23505.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (301, 202, '2028FA', '2028-09-01', '2028-12-15');

-- 6. offerings unique violation. Expected: uq_offerings_0, SQLSTATE 23505.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (502, 201, '2026FA', '2026-09-02', '2026-12-15');

-- 7. offerings foreign key violation. Expected: fk_offerings_0, SQLSTATE 23503.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (503, 999999, '2028SP', '2028-01-10', '2028-05-20');

-- 8. offerings check violation. Expected: offering_dates_ordered, SQLSTATE 23514.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on")
VALUES (507, 201, '2029FA', '2029-12-16', '2029-09-01');

-- 9. results pk violation. Expected: pk_results, SQLSTATE 23505.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (401, 101, 302, 80, '2027-05-22T09:00:00Z');

-- 10. results unique violation. Expected: uq_results_0, SQLSTATE 23505.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (504, 101, 301, 80, '2026-12-17T09:00:00Z');

-- 11. results student foreign key violation. Expected: fk_results_0, SQLSTATE 23503.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (505, 999999, 302, 80, '2027-05-22T09:00:00Z');

-- 12. results offering foreign key violation. Expected: fk_results_1, SQLSTATE 23503.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (506, 101, 999999, 80, '2027-05-22T09:00:00Z');

-- 13. results check violation. Expected: result_score_range, SQLSTATE 23514.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at")
VALUES (508, 101, 302, 101, '2027-05-22T09:00:00Z');
