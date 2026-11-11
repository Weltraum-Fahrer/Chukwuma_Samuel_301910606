University / Student Result Portal

Entity-Relationship (ER) Diagram


erDiagram
    direction LR
    
    %% Entity Definitions
    students {
        bigint student_id PK
        date enrolled_on
        boolean active
    }
    
    courses {
        bigint course_id PK
        text course_code UK
        text title
    }
    
    offerings {
        bigint offering_id PK
        bigint course_id FK
        text term_code
        date starts_on
        date ends_on
    }
    
    results {
        bigint result_id PK
        bigint student_id FK
        bigint offering_id FK
        numeric score
        timestamptz recorded_at
    }
    
    %% Relationship Definitions
    courses ||--o{ offerings : "course_id"
    students ||--o{ results : "student_id"
    offerings ||--o{ results : "offering_id"

    PK identifies a record; FK links to another table; UK marks a single-field unique value. The relationship ends show exactly one, zero or one, or zero or many records. Composite unique keys and conditional rules are listed in the schema and design.

[Diagram image](../images/Chukwuma_Samuel_301910606_ERDiagram.png)
