-- Show related results, students, offerings, courses records (up to 20).
SELECT t0."result_id" AS "results_result_id",
       t0."score" AS "results_score",
       t1."student_id" AS "students_student_id",
       t1."enrolled_on" AS "students_enrolled_on",
       t2."offering_id" AS "offerings_offering_id",
       t2."term_code" AS "offerings_term_code",
       t3."course_id" AS "courses_course_id",
       t3."course_code" AS "courses_course_code"
FROM portfolio."results" t0
JOIN portfolio."students" t1 ON t0."student_id" = t1."student_id"
JOIN portfolio."offerings" t2 ON t0."offering_id" = t2."offering_id"
JOIN portfolio."courses" t3 ON t2."course_id" = t3."course_id"
ORDER BY t0."result_id", t1."student_id", t2."offering_id", t3."course_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT t0."result_id" AS "results_result_id",
       t0."score" AS "results_score",
       t1."student_id" AS "students_student_id",
       t1."enrolled_on" AS "students_enrolled_on",
       t2."offering_id" AS "offerings_offering_id",
       t2."term_code" AS "offerings_term_code",
       t3."course_id" AS "courses_course_id",
       t3."course_code" AS "courses_course_code"
FROM portfolio."results" t0
JOIN portfolio."students" t1 ON t0."student_id" = t1."student_id"
JOIN portfolio."offerings" t2 ON t0."offering_id" = t2."offering_id"
JOIN portfolio."courses" t3 ON t2."course_id" = t3."course_id"
ORDER BY t0."result_id", t1."student_id", t2."offering_id", t3."course_id"
LIMIT 20;

-- Find results records where offering_id matches 301 (up to 20).
SELECT * FROM portfolio."results"
WHERE "offering_id" IS NOT DISTINCT FROM 301
ORDER BY "result_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."results"
WHERE "offering_id" IS NOT DISTINCT FROM 301
ORDER BY "result_id"
LIMIT 20;

-- Count results records for each student_id (up to 20 groups).
SELECT "student_id", count(*) AS record_count
FROM portfolio."results"
GROUP BY "student_id"
ORDER BY record_count DESC, "student_id" NULLS LAST
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT "student_id", count(*) AS record_count
FROM portfolio."results"
GROUP BY "student_id"
ORDER BY record_count DESC, "student_id" NULLS LAST
LIMIT 20;
