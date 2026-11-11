-- ============================================================================
-- QUERY 1: Multi-Table Relational Retrieval & Performance Profiling
-- ============================================================================

-- Using compact table aliases (t0-t3) minimizes syntactic noise across extensive multi-schema joins while maintaining clear lineage.
SELECT t0."result_id" AS "results_result_id",
       t0."score" AS "results_score",
       t1."student_id" AS "students_student_id",
       t1."enrolled_on" AS "students_enrolled_on",
       t2."offering_id" AS "offerings_offering_id",
       t2."term_code" AS "offerings_term_code",
       t3."course_id" AS "courses_course_id",
       t3."course_code" AS "courses_course_code"
FROM portfolio."results" t0
       
-- Inner joins are chosen because performance benchmarks requires complete relational matches across students, offerings, and courses.
JOIN portfolio."students" t1 ON t0."student_id" = t1."student_id"
JOIN portfolio."offerings" t2 ON t0."offering_id" = t2."offering_id"
JOIN portfolio."courses" t3 ON t2."course_id" = t3."course_id"

-- Multi-column sorting covering every join key guarantees deterministic row ordering, preventing unstable results across repeated benchmark runs.
ORDER BY t0."result_id", t1."student_id", t2."offering_id", t3."course_id"

-- Capping at 20 rows keeps memory overhead and payload size minimal while still providing enough depth for execution plan analysis.
LIMIT 20;

-- ANALYZE executes the query to capture real runtime metrics, 
-- BUFFERS tracks cache hits/misses, and FORMAT JSON enables programmatic parsing.
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


-- ============================================================================
-- QUERY 2: Filtered Index Lookup & Null-Safety
-- ============================================================================

SELECT * FROM portfolio."results"
-- 'IS NOT DISTINCT FROM' is used inplace of the standard '=' operator to ensure null-safe evaluation. This prevents edge-case logic bugs if offering_id can contain NULL values, treating NULL as a comparable value.
WHERE "offering_id" IS NOT DISTINCT FROM 301
       
-- Primary sorting by result_id ensures stable deterministic sequencing when pagination limits truncate the scanned dataset.
ORDER BY "result_id"
LIMIT 20;

-- Capturing execution stats via EXPLAIN to evaluate to what degree the underlying index isolates the target offering_id filter.
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."results"
WHERE "offering_id" IS NOT DISTINCT FROM 301
ORDER BY "result_id"
LIMIT 20;


-- ============================================================================
-- QUERY 3: Aggregation, Distribution Analysis, and Tie-Breaking
-- ============================================================================

SELECT "student_id", count(*) AS record_count
FROM portfolio."results"
-- Grouping by student_id isolates workload concentration per student to identify performance skew or data distribution anomalies.
GROUP BY "student_id"
-- Sorting by record_count DESC surfaces the heaviest student records first. Adding 'NULLS LAST' prevents sorting exceptions or ambiguous placement if unassigned/null student records exist in the aggregation scope.
ORDER BY record_count DESC, "student_id" NULLS LAST
LIMIT 20;

-- Profiling the aggregation pipeline cost, memory allocation for hash/sort operations, and buffer behaviors under grouping load.
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT "student_id", count(*) AS record_count
FROM portfolio."results"
GROUP BY "student_id"
ORDER BY record_count DESC, "student_id" NULLS LAST
LIMIT 20;
