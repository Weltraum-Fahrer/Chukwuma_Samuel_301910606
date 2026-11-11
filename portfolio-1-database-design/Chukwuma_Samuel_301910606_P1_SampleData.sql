--Wrapping the initial data seed in a transaction block
BEGIN;

-- Inducing standard string conformity locally for this transaction to prevent any backslash escape warnings with our text inputs
SET LOCAL standard_conforming_strings = on;

-- Pre-seeding baseline student profiles. 
-- Using explicit 100-series IDs (101 and 102) here rather than relying on auto-increment so our related tables can predictably reference them
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active") 
VALUES (101, '2025-09-01', TRUE);

-- Populating the course catalog with foundational subjects. 
-- Grouping these under 200-series IDs with standard alphanumeric course codes ('SYN101', 'SYN102') to mimic a real academic registry
INSERT INTO portfolio."students" ("student_id", "enrolled_on", "active") 
VALUES (102, '2026-01-15', TRUE);

INSERT INTO portfolio."courses" ("course_id", "course_code", "title") 
VALUES (201, 'SYN101', 'Synthetic Foundations');

INSERT INTO portfolio."courses" ("course_id", "course_code", "title") 
VALUES (202, 'SYN102', 'Synthetic Data Methods');

-- Scheduling the course offerings for specific terms (Fall 2026 and Spring 2027). 
-- 300-series IDs map our catalog courses to actual semester date boundaries to ensure our temporal check constraints hold up.
INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on") 
VALUES (301, 201, '2026FA', '2026-09-01', '2026-12-15');

INSERT INTO portfolio."offerings" ("offering_id", "course_id", "term_code", "starts_on", "ends_on") 
VALUES (302, 202, '2027SP', '2027-01-10', '2027-05-20');

-- Logging sample grades into the junction table to prove the relationships work end-to-end. 
-- Using 400-series IDs and ISO 8601 timestamps (Z and +00:00) to verify the timestamptz data type behaves correctly across timezones.
INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at") 
VALUES (401, 101, 301, 88.5, '2026-12-16T10:30:00Z');

INSERT INTO portfolio."results" ("result_id", "student_id", "offering_id", "score", "recorded_at") 
VALUES (402, 102, 302, 93, '2027-05-21T14:00:00+00:00');

-- Committing the atomic block to finalize the schema state
COMMIT;
