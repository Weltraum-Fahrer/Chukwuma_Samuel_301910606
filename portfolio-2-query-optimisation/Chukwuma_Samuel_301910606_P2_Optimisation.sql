-- ============================================================================
-- SECTION 1: Sandbox Isolation & Simulated Data Setup
-- ============================================================================

-- Creating a dedicated schema isolates performance benchmarks from production schemas, preventing unintended side effects or constraint violations.
CREATE SCHEMA query_lab;

-- Cloning the exact column type from the production table ('results.offering_id') with 'WITH NO DATA' ensures type fidelity without copying bulk production records or foreign key constraints into the test bed.
CREATE TABLE query_lab."results" AS
SELECT "offering_id", 0::bigint AS "lab_row_id" FROM portfolio."results" WITH NO DATA;

-- Generating 20,000 simulated rows using a modulus calculation ((g % 1000)::bigint) creates a predictable, controlled cardinality and data distribution, enabling consistent and repeatable selectivity measurements.
INSERT INTO query_lab."results" ("offering_id", "lab_row_id")
SELECT (g % 1000)::bigint, g FROM generate_series(1, 20000) AS g;

-- Forcing an ANALYZE pass immediately after data population ensures the query planner has up-to-date distribution statistics for cost estimation.
ANALYZE query_lab."results";


-- ============================================================================
-- SECTION 2: Pre-Index Baseline Performance Measurement
-- ============================================================================

-- Executing an initial unmeasured query warms up internal memory buffers, ensuring cold-cache I/O variance does not skew the formal benchmark runs.
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";

-- Running three sequential EXPLAIN (ANALYZE, BUFFERS) iterations takes note of accurate execution times and buffer hit metrics under a sequential scan baseline.
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";

EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";

EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";


-- ============================================================================
-- SECTION 3: Index Introduction
-- ============================================================================

-- Building a B-tree index specifically on the filter key ('offering_id') introduces an alternative access path to test if the query optimizer shifts from a full table sequential scan to a more efficient index-assisted scan.
CREATE INDEX p2_filter_idx ON query_lab."results" USING btree ("offering_id");


-- ============================================================================
-- SECTION 4: Post-Index Performance Validation
-- ============================================================================

-- Re-running the warm-up query after index creation primes the cache with the newly built index structures to ensure fair measurement conditions.
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";

-- Repeating the triple EXPLAIN (ANALYZE, BUFFERS) block allows discrete comparison against the baseline to quantitatively verify performance improvements (such as reduced execution duration and lower buffer hits) due to the index.
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";

EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";

EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "offering_id"
FROM query_lab."results"
WHERE "offering_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";
