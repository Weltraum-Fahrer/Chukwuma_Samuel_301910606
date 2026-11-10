# University/Student Result Portal — database design

My case study records students, courses, offerings, results.

## Users

- Students reviewing their recorded results
- Academic staff recording and correcting results

## Main operations

- Record a student's result for a course offering
- Review results by student, course, and term
- Summarize result counts and average scores

## Entities

| Entity | Information stored |
| --- | --- |
| students | Stores a synthetic student surrogate key and minimal enrollment status, without names or real-world identifiers. |
| courses | Stores catalog details shared by term-specific offerings. |
| offerings | Represents a course scheduled for a specific term, keeping term and date details separate from catalog course data. |
| results | Stores one student's outcome for an offering; score and recording time belong here, while student, offering, and course attributes are not duplicated. |

## students

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| student_id | BIGINT | PK | Yes |
| enrolled_on | DATE |  | Yes |
| active | BOOLEAN |  | Yes |


## courses

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| course_id | BIGINT | PK | Yes |
| course_code | TEXT | Unique | Yes |
| title | TEXT |  | Yes |
- Unique key: (course_code).

## offerings

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| offering_id | BIGINT | PK | Yes |
| course_id | BIGINT | FK | Yes |
| term_code | TEXT |  | Yes |
| starts_on | DATE |  | Yes |
| ends_on | DATE |  | Yes |
- course_id → courses.course_id
- Unique key: (course_id, term_code).

## results

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| result_id | BIGINT | PK | Yes |
| student_id | BIGINT | FK | Yes |
| offering_id | BIGINT | FK | Yes |
| score | NUMERIC(18,2) |  | Yes |
| recorded_at | TIMESTAMPTZ |  | Yes |
- student_id → students.student_id
- offering_id → offerings.offering_id
- Unique key: (student_id, offering_id).

## Relationships and business rules

- Each course code identifies at most one catalog course.
- Every offering references an existing course through course_id.
- Every result references an existing student through student_id.
- Every result references an existing offering through offering_id.
- An offering's start date must be on or before its end date.
- A recorded result score must be between 0 and 100 inclusive.
- A student may have at most one result for an offering, including when concurrent submissions occur.

## Assumptions

- Student names and real student identifiers are intentionally absent; student_id is a synthetic surrogate key.
- Each course has a unique course code.
- A course has at most one offering per term.
- A student has at most one result per offering.
- Scores use a 0 to 100 scale, and offering start dates cannot be later than end dates.

