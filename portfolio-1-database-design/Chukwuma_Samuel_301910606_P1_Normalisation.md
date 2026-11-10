# University/Student Result Portal — normalisation

The example uses the saved sample records. The full set of fields is in the design and schema.

## Starting grouped records

| student_id | results records (list) |
| --- | --- |
| 101 | [401] |
| 102 | [402] |


The record IDs are grouped in a list. In 1NF, each record has its own row and each cell holds one value.

## 1NF: one value per cell

| results.result_id | results.student_id | results.offering_id | students.student_id | offerings.offering_id | offerings.course_id | offerings.term_code | courses.course_id |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 401 | 101 | 301 | 101 | 301 | 201 | 2026FA | 201 |
| 402 | 102 | 302 | 102 | 302 | 202 | 2027SP | 202 |

Key: result_id.

## 2NF: depend on the whole key

results: student_id is a proper part of candidate key (student_id, offering_id), and determines students details. results: offering_id is a proper part of candidate key (student_id, offering_id), and determines offerings details. offerings: course_id is a proper part of candidate key (course_id, term_code), and determines courses details.

## students_example

| students.student_id |
| --- |
| 101 |
| 102 |

## courses_example

| courses.course_id |
| --- |
| 201 |
| 202 |

## offerings_example

| offerings.offering_id | offerings.course_id | offerings.term_code |
| --- | --- | --- |
| 301 | 201 | 2026FA |
| 302 | 202 | 2027SP |

## results_example

| results.result_id | results.student_id | results.offering_id |
| --- | --- | --- |
| 401 | 101 | 301 |
| 402 | 102 | 302 |

## 3NF: store each entity’s details once

The entity keys determine their own descriptions. Related records keep foreign keys rather than repeating those descriptions.

## students

| student_id | enrolled_on | active |
| --- | --- | --- |
| 101 | 2025-09-01 | true |
| 102 | 2026-01-15 | true |

## courses

| course_id | course_code | title |
| --- | --- | --- |
| 201 | SYN101 | Synthetic Foundations |
| 202 | SYN102 | Synthetic Data Methods |

## offerings

| offering_id | course_id | term_code | starts_on | ends_on |
| --- | --- | --- | --- | --- |
| 301 | 201 | 2026FA | 2026-09-01 | 2026-12-15 |
| 302 | 202 | 2027SP | 2027-01-10 | 2027-05-20 |

## results

| result_id | student_id | offering_id | score | recorded_at |
| --- | --- | --- | --- | --- |
| 401 | 101 | 301 | 88.5 | 2026-12-16T10:30:00+00:00 |
| 402 | 102 | 302 | 93 | 2027-05-21T14:00:00+00:00 |

## Dependencies

- students: (student_id) → enrolled_on, active
- courses: (course_id) → course_code, title
- offerings: (offering_id) → course_id, term_code, starts_on, ends_on
- results: (result_id) → student_id, offering_id, score, recorded_at

Joining the decomposed sample tables reproduces the original 2 example rows. The design assumes the declared keys describe the relevant business dependencies.
