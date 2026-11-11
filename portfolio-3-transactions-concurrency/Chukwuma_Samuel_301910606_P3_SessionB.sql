-- ============================================================================
-- CONCURRENCY LAB: SESSION B (Race Condition & Pessimistic Lock Resolution) by using two psql terminals connected to the same exercise database.
-- ============================================================================

-- Initiating a parallel transaction under READ COMMITTED to simulate simultaneous user activity and create an overlapping read window.
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Reading the target row concurrently before Session A commits its write. This captures an identical baseline value, setting up the typical lost-update concurrency anomaly.
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401;

-- Writing an update based on stale read data. Because Session A already committed an update, this execution overwrites and loses Session A's increment, demonstrating the vulnerability of unmanaged concurrent writes.
UPDATE portfolio."results" SET "p3_processed_count" = 2 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Committing Session B's write to finalize the transaction.
COMMIT;

-- Querying the final state to inspect the resulting data loss (showing that the final count remained 2 instead of correctly incrementing twice).
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401;

-- Starting a new transaction block to test pessimistic locking behavior.
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Attempting to acquire a row lock using 'FOR UPDATE'. Because Session A currently holds the lock on this row, this statement will pause and wait transparently until Session A commits and releases its lock.
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401 FOR UPDATE;

-- Once unblocked, this SELECT safely reflects the updated value committed by Session A. We then apply the second sequential increment (to 3), preventing any data loss.
UPDATE portfolio."results" SET "p3_processed_count" = 3 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Committing the transaction to release the lock and finalize the correctly incremented value.
COMMIT;

-- Final verification query to confirm the record correctly reflects the accumulated updates without any lost increments.
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401;
