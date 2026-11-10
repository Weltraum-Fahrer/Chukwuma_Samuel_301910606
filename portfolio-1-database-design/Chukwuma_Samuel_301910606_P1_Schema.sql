-- University/Student Result Portal: tables, keys and business constraints.
-- Run once in a fresh PostgreSQL database.
BEGIN;
SET LOCAL standard_conforming_strings = on;
CREATE SCHEMA portfolio;
CREATE TABLE portfolio."students" (
  "student_id" bigint NOT NULL,
  "enrolled_on" date NOT NULL,
  "active" boolean NOT NULL,
  CONSTRAINT "pk_students" PRIMARY KEY ("student_id")
);
CREATE TABLE portfolio."courses" (
  "course_id" bigint NOT NULL,
  "course_code" text NOT NULL,
  "title" text NOT NULL,
  CONSTRAINT "pk_courses" PRIMARY KEY ("course_id"),
  CONSTRAINT "uq_courses_0" UNIQUE ("course_code")
);
CREATE TABLE portfolio."offerings" (
  "offering_id" bigint NOT NULL,
  "course_id" bigint NOT NULL,
  "term_code" text NOT NULL,
  "starts_on" date NOT NULL,
  "ends_on" date NOT NULL,
  CONSTRAINT "pk_offerings" PRIMARY KEY ("offering_id"),
  CONSTRAINT "uq_offerings_0" UNIQUE ("course_id", "term_code")
);
CREATE TABLE portfolio."results" (
  "result_id" bigint NOT NULL,
  "student_id" bigint NOT NULL,
  "offering_id" bigint NOT NULL,
  "score" numeric(18,2) NOT NULL,
  "recorded_at" timestamptz NOT NULL,
  CONSTRAINT "pk_results" PRIMARY KEY ("result_id"),
  CONSTRAINT "uq_results_0" UNIQUE ("student_id", "offering_id")
);
ALTER TABLE portfolio."offerings" ADD CONSTRAINT "fk_offerings_0" FOREIGN KEY ("course_id") REFERENCES portfolio."courses" ("course_id");
ALTER TABLE portfolio."results" ADD CONSTRAINT "fk_results_0" FOREIGN KEY ("student_id") REFERENCES portfolio."students" ("student_id");
ALTER TABLE portfolio."results" ADD CONSTRAINT "fk_results_1" FOREIGN KEY ("offering_id") REFERENCES portfolio."offerings" ("offering_id");
ALTER TABLE portfolio."offerings" ADD CONSTRAINT "offering_dates_ordered" CHECK ("ends_on" > "starts_on");
ALTER TABLE portfolio."results" ADD CONSTRAINT "result_score_range" CHECK (("score" >= 0) AND ("score" <= 100));
COMMIT;
