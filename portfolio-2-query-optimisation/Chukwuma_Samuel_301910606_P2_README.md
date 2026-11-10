# University/Student Result Portal — SQL queries

## 1. Show related results, students, offerings, courses records (up to 20).

```sql
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
```

| results_result_id | results_score | students_student_id | students_enrolled_on | offerings_offering_id | offerings_term_code | courses_course_id | courses_course_code |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 401 | 88.5 | 101 | 2025-09-01 | 301 | 2026FA | 201 | SYN101 |
| 402 | 93 | 102 | 2026-01-15 | 302 | 2027SP | 202 | SYN102 |

## 2. Find results records where offering_id matches 301 (up to 20).

```sql
SELECT * FROM portfolio."results"
WHERE "offering_id" IS NOT DISTINCT FROM 301
ORDER BY "result_id"
LIMIT 20;
```

| result_id | student_id | offering_id | score | recorded_at |
| --- | --- | --- | --- | --- |
| 401 | 101 | 301 | 88.5 | 2026-12-16T10:30:00+00:00 |

## 3. Count results records for each student_id (up to 20 groups).

```sql
SELECT "student_id", count(*) AS record_count
FROM portfolio."results"
GROUP BY "student_id"
ORDER BY record_count DESC, "student_id" NULLS LAST
LIMIT 20;
```

| student_id | record_count |
| --- | --- |
| 101 | 1 |
| 102 | 1 |


## Index comparison

| Phase | Median (ms) | Three runs (ms) | Plan nodes | Buffer hits |
| --- | --- | --- | --- | --- |
| Before index | 0.944 | 0.944, 0.977, 0.941 | Sort → Seq Scan | 112 |
| After index | 0.181 | 0.181, 0.169, 0.246 | Sort → Bitmap Heap Scan → Bitmap Index Scan | 25 |

The median execution time changed from 0.944 ms to 0.181 ms. The measured plan used p2_filter_idx. The results matched in both phases. An index adds storage and write-maintenance costs; timings depend on the selected lookup and environment.

## Execution plans

### Before index, run 1

```text
Sort (actual time=0.918..0.92 rows=20 loops=1)
  Seq Scan on results (actual time=0.014..0.883 rows=20 loops=1)
Planning Time: 0.327 ms
Execution Time: 0.944 ms
```

### Before index, run 2

```text
Sort (actual time=0.95..0.952 rows=20 loops=1)
  Seq Scan on results (actual time=0.015..0.913 rows=20 loops=1)
Planning Time: 0.371 ms
Execution Time: 0.977 ms
```

### Before index, run 3

```text
Sort (actual time=0.915..0.917 rows=20 loops=1)
  Seq Scan on results (actual time=0.015..0.879 rows=20 loops=1)
Planning Time: 0.426 ms
Execution Time: 0.941 ms
```

### After index, run 1

```text
Sort (actual time=0.127..0.128 rows=20 loops=1)
  Bitmap Heap Scan on results (actual time=0.025..0.082 rows=20 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.013..0.013 rows=20 loops=1)
Planning Time: 0.53 ms
Execution Time: 0.181 ms
```

### After index, run 2

```text
Sort (actual time=0.117..0.119 rows=20 loops=1)
  Bitmap Heap Scan on results (actual time=0.025..0.081 rows=20 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.013..0.013 rows=20 loops=1)
Planning Time: 0.494 ms
Execution Time: 0.169 ms
```

### After index, run 3

```text
Sort (actual time=0.173..0.175 rows=20 loops=1)
  Bitmap Heap Scan on results (actual time=0.037..0.119 rows=20 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.018..0.019 rows=20 loops=1)
Planning Time: 1.181 ms
Execution Time: 0.246 ms
```

## Reproduce

Use a fresh database with the Portfolio 1 schema and sample data. Run Chukwuma_Samuel_301910606_P2_Queries.sql, then Chukwuma_Samuel_301910606_P2_Optimisation.sql. The optimisation script creates a separate performance table and runs EXPLAIN (ANALYZE, BUFFERS).

[Query screenshot](screenshots/Chukwuma_Samuel_301910606_P2_QueryResults.png) · [Index comparison](screenshots/Chukwuma_Samuel_301910606_P2_IndexComparison.png)

## References

- [PostgreSQL — EXPLAIN](https://www.postgresql.org/docs/17/using-explain.html)

