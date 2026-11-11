-- ============================================================================
-- CONCURRENCY LAB: SESSION A (Transaction Isolation & Row Locking Demonstration) by using two psql terminals connected to the same exercise database.
-- ============================================================================

-- Explicitly setting the transaction isolation level to READ COMMITTED establishes standard PostgreSQL concurrency behavior, thus allowing us to demonstrate typical race conditions and update anomalies.
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Performing an initial read fetches the current state and establishes a snapshot baseline, intentionally leaving the row unlocked so that concurrent sessions can modify it and trigger a race condition.
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401;

-- Writing a value derived from the earlier read without a lock creates vulnerability to lost updates if another session modified the row in the interim. RETURNING outputs the final JSON state for verification.
UPDATE portfolio."results" SET "p3_processed_count" = 2 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Committing finalizes the transaction, releasing locks and by so doing making the updated state visible to other concurrent database sessions.
COMMIT;

-- Executing an independent reset update outside active transaction blocks restores the record to a deterministic baseline state before testing pessimistic concurrency controls.
UPDATE portfolio."results" SET "p3_processed_count" = 1 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Starting a new transaction under READ COMMITTED isolation.
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Appending the 'FOR UPDATE' clause implements pessimistic locking. This immediately acquires an exclusive row-level lock, forcing any concurrent session attempting to modify the same row to queue and wait.
SELECT "result_id", "p3_processed_count" FROM portfolio."results" WHERE "result_id" IS NOT DISTINCT FROM 401 FOR UPDATE;

-- Performing the update safely under the protection of the row lock, ensuring no concurrent modifications can overwrite our changes.
UPDATE portfolio."results" SET "p3_processed_count" = 2 WHERE "result_id" IS NOT DISTINCT FROM 401 RETURNING json_build_object('processed_count',"p3_processed_count");

-- Committing the transaction releases the exclusive row lock, thus allowing any queued concurrent sessions to proceed with their operations.
COMMIT;
