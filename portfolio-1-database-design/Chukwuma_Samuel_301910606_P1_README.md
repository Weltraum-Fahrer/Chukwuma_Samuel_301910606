# Portfolio 1 — Database Design and Modelling

I organised the data into students, courses, offerings, results. The design document explains the fields, keys, relationships and business rules. The normalisation document shows the sample tables at 1NF, 2NF and 3NF.

## Database checks

| Table | Rows |
| --- | --- |
| students | 2 |
| courses | 2 |
| offerings | 2 |
| results | 2 |

The 13 invalid inserts were rejected at their expected constraints, and the valid sample rows remained unchanged.

## Files

- [Design](Chukwuma_Samuel_301910606_P1_Design.md)
- [ER diagram](Chukwuma_Samuel_301910606_P1_ERDiagram.md)
- [Normalisation](Chukwuma_Samuel_301910606_P1_Normalisation.md)
- [Schema](Chukwuma_Samuel_301910606_P1_Schema.sql)
- [Sample data](Chukwuma_Samuel_301910606_P1_SampleData.sql)
- [Constraint tests](Chukwuma_Samuel_301910606_P1_ConstraintTests.sql)
- [Table and constraint evidence](screenshots/Chukwuma_Samuel_301910606_P1_DatabaseResults.png)

## Run the SQL

Create a fresh PostgreSQL database. Run the schema first, then the sample data. Run the deliberately invalid statements in ConstraintTests.sql individually outside a transaction; each is expected to produce an error.

## References

- [PostgreSQL — constraints](https://www.postgresql.org/docs/17/ddl-constraints.html)

