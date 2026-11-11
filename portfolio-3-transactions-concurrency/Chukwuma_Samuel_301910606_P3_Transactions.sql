-- ============================================================================
-- SECTION 1: Schema Extension for Transaction Testing
-- ============================================================================

-- Appending a temporary tracking column exclusively for this exercise prevents modification of the core Portfolio 1 schema logic. 
-- Setting 'NOT NULL DEFAULT 0' ensures predictable mathematical operations (+1 increments) without requiring complex NULL handling logic.
ALTER TABLE portfolio."results" ADD COLUMN "p3_processed_count" integer NOT NULL DEFAULT 0;

-- Implementing a CHECK constraint establishes a strict data integrity rule at the database level. This specific constraint (>= 0) is  intentionally introduced here to intentionally trigger a transaction failure 
-- later in the script.
ALTER TABLE portfolio."results" ADD CONSTRAINT "p3_count_nonnegative" CHECK ("p3_processed_count" >= 0);


-- ============================================================================
-- SECTION 2: Successful Atomic Transaction
-- ============================================================================

-- Explicitly defining 'READ COMMITTED' ensures the transaction operates under standard PostgreSQL visibility rules, preventing dirty reads.
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Utilizing an in-place atomic increment ("p3_processed_count" + 1) prevents race conditions that would occur if we read the value to application 
-- memory and wrote it back. 'RETURNING' yields the new state immediately, saving a round-trip SELECT query.
UPDATE portfolio."results" SET "p3_processed_count" = "p3_processed_count" + 1 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Committing finalizes the atomic block, writing the increment to disk and making it visible to other database sessions.
COMMIT;

-- Retrieving the final state outside the transaction boundary verifies that the commit successfully persisted the data.
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401;


-- ============================================================================
-- SECTION 3: Transaction Failure and Rollback Demonstration
-- ============================================================================

BEGIN ISOLATION LEVEL READ COMMITTED;

-- Executing a valid update first sets up a scenario where partial work has been done within the transaction. This validates that rollbacks undo *all* steps, not just the failed ones.
UPDATE portfolio."results" SET "p3_processed_count" = "p3_processed_count" + 10 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Disabling 'ON_ERROR_STOP' allows the psql script to continue running even after the upcoming intentional constraint violation. 
-- Enabling verbose output ensures the exact constraint failure details are logged as expected.
\set ON_ERROR_STOP off
\set VERBOSITY verbose

-- Intentionally setting the count to -1 violates the "p3_count_nonnegative" CHECK constraint. This forces the current transaction 
-- block into an aborted state to demonstrate database-level error handling.
UPDATE portfolio."results" SET "p3_processed_count" = -1 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Attempting a simple SELECT query while the transaction is in an aborted state proves that PostgreSQL strictly rejects all subsequent commands until the broken transaction is properly resolved.
SELECT 1;

-- Issuing a ROLLBACK safely clears the aborted transaction state. Crucially, this undoes the successful "+10" update executed earlier in the block, preserving the fundamental atomicity of the database.
ROLLBACK;

-- Restoring standard error handling behavior for the remainder of the session.
\set ON_ERROR_STOP on

-- Final verification query confirms that the data remained entirely untouched by the failed transaction, acting as if the entire BEGIN/ROLLBACK block never occurred.
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401;
