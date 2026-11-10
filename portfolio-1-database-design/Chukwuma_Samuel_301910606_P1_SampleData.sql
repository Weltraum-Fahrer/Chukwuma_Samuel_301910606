-- Fictional sample records for University/Student Result Portal.
BEGIN;
SET LOCAL standard_conforming_strings = on;
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active") VALUES (101, '2025-09-01', TRUE);
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active") VALUES (102, '2026-01-15', TRUE);
INSERT INTO portfolio."courses" ("course_id", "course_code", "title") VALUES (201, 'SYN101', 'Synthetic Foundations');
INSERT INTO portfolio."courses" ("course_id", "course_code", "title") VALUES (202, 'SYN102', 'Synthetic Data Methods');
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on") VALUES (301, 201, '2026FA', '2026-09-01', '2026-12-15');
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on") VALUES (302, 202, '2027SP', '2027-01-10', '2027-05-20');
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at") VALUES (401, 101, 301, 88.5, '2026-12-16T10:30:00Z');
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at") VALUES (402, 102, 302, 93, '2027-05-21T14:00:00+00:00');
COMMIT;
