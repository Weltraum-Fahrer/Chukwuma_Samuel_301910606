-- Initializing this in a transaction block so we don't end up with a half-deployed, broken schema if one of the tables or constraints fails to build.
BEGIN;

-- Forcing standard string behavior locally so we don't run into weird backslash escape bugs depending on how the host server is configured.
SET LOCAL standard_conforming_strings = on;

-- Putting this in its own schema to keep things organized and avoid cluttering the default public namespace.
CREATE SCHEMA portfolio;

-- Using bigint for all IDs right out of the gate[cite: 12]. It's much easier to future-proof the size now than try to migrate from standard integers when the tables get huge.
CREATE TABLE portfolio."students" (
  "student_id" bigint NOT NULL,
  "enrolled_on" date NOT NULL,
  "active" boolean NOT NULL,
  CONSTRAINT "pk_students" PRIMARY KEY ("student_id")
);

-- Adding a unique constraint on course_code because the business rules dictate that natural keys (like 'SYN101') can never be duplicated, even though we use course_id for internal database relations.
CREATE TABLE portfolio."courses" (
  "course_id" bigint NOT NULL,
  "course_code" text NOT NULL,
  "title" text NOT NULL,
  CONSTRAINT "pk_courses" PRIMARY KEY ("course_id"),
  CONSTRAINT "uq_courses_0" UNIQUE ("course_code")
);

-- The composite unique constraint here (course_id, term_code) makes sure we can't accidentally schedule the exact same course twice in the same semester.
CREATE TABLE portfolio."offerings" (
  "offering_id" bigint NOT NULL,
  "course_id" bigint NOT NULL,
  "term_code" text NOT NULL,
  "starts_on" date NOT NULL,
  "ends_on" date NOT NULL,
  CONSTRAINT "pk_offerings" PRIMARY KEY ("offering_id"),
  CONSTRAINT "uq_offerings_0" UNIQUE ("course_id", "term_code")
);

-- Going with numeric(18,2) for the score because floating-point types always introduce weird rounding issues, and timestamptz is a must so our audit trails don't break across different timezones.
-- The composite unique key stops accidental double-entry of a grade for a single student in a specific course offering.
CREATE TABLE portfolio."results" (
  "result_id" bigint NOT NULL,
  "student_id" bigint NOT NULL,
  "offering_id" bigint NOT NULL,
  "score" numeric(18,2) NOT NULL,
  "recorded_at" timestamptz NOT NULL,
  CONSTRAINT "pk_results" PRIMARY KEY ("result_id"),
  CONSTRAINT "uq_results_0" UNIQUE ("student_id", "offering_id")
);

-- Applying all foreign keys with ALTER TABLE down here so we don't have to worry about the order we create our tables in or deal with annoying cyclical dependency errors during the build.
ALTER TABLE portfolio."offerings" ADD CONSTRAINT "fk_offerings_0" FOREIGN KEY ("course_id") REFERENCES portfolio."courses" ("course_id");
ALTER TABLE portfolio."results" ADD CONSTRAINT "fk_results_0" FOREIGN KEY ("student_id") REFERENCES portfolio."students" ("student_id");
ALTER TABLE portfolio."results" ADD CONSTRAINT "fk_results_1" FOREIGN KEY ("offering_id") REFERENCES portfolio."offerings" ("offering_id");

-- Baking these check constraints directly into the database engine so bad date logic and out-of-bounds grades get rejected even if someone bypasses the app's frontend validation.
ALTER TABLE portfolio."offerings" ADD CONSTRAINT "offering_dates_ordered" CHECK ("ends_on" > "starts_on");
ALTER TABLE portfolio."results" ADD CONSTRAINT "result_score_range" CHECK (("score" >= 0) AND ("score" <= 100));

-- Saving it all.
COMMIT;
