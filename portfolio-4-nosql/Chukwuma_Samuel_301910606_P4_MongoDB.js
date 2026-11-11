// These records represent a simulated event-sourced architecture for the case study.
(async function () {
  // Explicitly switching to 'portfolio_nosql' isolates this document workload from any relational data, avoiding accidental cross-contamination.
  db = db.getSiblingDB('portfolio_nosql');
  
  // Implementing a fail-fast mechanism to guarantee a clean slate. If the collection already exists, we abort to prevent appending duplicate 
  // test data which would upset our later aggregation results.
  if ((await db.getCollectionNames()).includes("result_events")) {
    throw new Error('The exercise collection already exists. Use a fresh database.');
  }

  // MongoDB is schema-less by default, but by applying a JSON Schema Validator provides critical data governance. This ensures all documents strictly 
  // adhere to our event-sourcing contract (e.g; strict enums, mandatory source features).
  await db.createCollection("result_events", {
    validator: {
    "$jsonSchema": {
        "bsonType": "object",
        "required": [
            "_id",
            "schemaVersion",
            "simulation",
            "eventType",
            "occurredAt",
            "source",
            "embedded",
            "references",
            "details"
        ],
        "properties": {
            "_id": {
                // Enforcing a string ID instead of ObjectId to support custom event IDs.
                "bsonType": "string",
                "minLength": 1
            },
            "schemaVersion": {
                // Locking schemaVersion to '1' enables future schema migrations.
                "enum": [
                    1
                ]
            },
            "simulation": {
                "enum": [
                    true
                ]
            },
            "eventType": {
                // Restricting events to known business domain actions.
                "bsonType": "string",
                "enum": [
                    "result_recorded",
                    "result_corrected"
                ]
            },
            "occurredAt": {
                // Forcing BSON date type prevents silent bugs caused by string-based timestamps.
                "bsonType": "date"
            },
            "source": {
                "bsonType": "object",
                "required": [
                    "entity",
                    "key",
                    "snapshot"
                ],
                "properties": {
                    "entity": {
                        "enum": [
                            "results"
                        ]
                    },
                    "key": {
                        "bsonType": "object",
                        "required": [
                            "result_id"
                        ]
                    },
                    "snapshot": {
                        "bsonType": "object"
                    }
                }
            },
            "embedded": {
                "bsonType": "object"
            },
            "references": {
                "bsonType": "object"
            },
            "details": {
                // 'details' is left as an unstructured object to allow flexible, 
                // event-specific metadata (like UI channels or rubric notes) to evolve.
                "bsonType": "object"
            }
        }
    }
},
    // Setting validation to strict/error blocks invalid writes at the database layer.
    validationLevel: 'strict', validationAction: 'error'
  });

  // Using insertMany for bulk ingestion minimizes network round-trips. The document structure embraces NoSQL denormalization: embedding related 'offerings' 
  // and 'students' directly into the event payload eliminates the need for expensive joins on read.
  printjson(await db.getCollection("result_events").insertMany([
    {
        "_id": "event_000001",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "result_recorded",
        "occurredAt": ISODate("2030-01-01T10:00:00Z"),
        "source": {
            "entity": "results",
            "key": {
                "result_id": 401
            },
            "snapshot": {
                "result_id": 401,
                "student_id": 101,
                "offering_id": 301,
                "score": 88.5,
                "recorded_at": "2026-12-16T10:30:00Z"
            }
        },
        "embedded": {
            "offerings": [
                {
                    "key": {
                        "offering_id": 301
                    },
                    "snapshot": {
                        "offering_id": 301,
                        "course_id": 201,
                        "term_code": "2026FA",
                        "starts_on": "2026-09-01",
                        "ends_on": "2026-12-15"
                    },
                    "via": [
                        "results.offering_id → offerings"
                    ]
                }
            ]
        },
        "references": {
            "students": [
                {
                    "key": {
                        "student_id": 101
                    },
                    "via": [
                        "results.student_id → students"
                    ]
                }
            ]
        },
        "details": {
            "channel": "web"
        }
    },
    {
        "_id": "event_000002",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "result_corrected",
        "occurredAt": ISODate("2030-01-01T10:01:00Z"),
        "source": {
            "entity": "results",
            "key": {
                "result_id": 401
            },
            "snapshot": {
                "result_id": 401,
                "student_id": 101,
                "offering_id": 301,
                "score": 88.5,
                "recorded_at": "2026-12-16T10:30:00Z"
            }
        },
        "embedded": {
            "offerings": [
                {
                    "key": {
                        "offering_id": 301
                    },
                    "snapshot": {
                        "offering_id": 301,
                        "course_id": 201,
                        "term_code": "2026FA",
                        "starts_on": "2026-09-01",
                        "ends_on": "2026-12-15"
                    },
                    "via": [
                        "results.offering_id → offerings"
                    ]
                }
            ]
        },
        "references": {
            "students": [
                {
                    "key": {
                        "student_id": 101
                    },
                    "via": [
                        "results.student_id → students"
                    ]
                }
            ]
        },
        "details": {
            "channel": "mobile",
            "note": "Illustrative event-specific metadata",
            "examples": {
                "correction_reason": "illustrative correction_reason",
                "rubric_notes": "illustrative rubric_notes",
                "event_metadata": "illustrative event_metadata"
            }
        }
    },
    {
        "_id": "event_000003",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "result_recorded",
        "occurredAt": ISODate("2030-01-01T10:02:00Z"),
        "source": {
            "entity": "results",
            "key": {
                "result_id": 402
            },
            "snapshot": {
                "result_id": 402,
                "student_id": 102,
                "offering_id": 302,
                "score": 93,
                "recorded_at": "2027-05-21T14:00:00+00:00"
            }
        },
        "embedded": {
            "offerings": [
                {
                    "key": {
                        "offering_id": 302
                    },
                    "snapshot": {
                        "offering_id": 302,
                        "course_id": 202,
                        "term_code": "2027SP",
                        "starts_on": "2027-01-10",
                        "ends_on": "2027-05-20"
                    },
                    "via": [
                        "results.offering_id → offerings"
                    ]
                }
            ]
        },
        "references": {
            "students": [
                {
                    "key": {
                        "student_id": 102
                    },
                    "via": [
                        "results.student_id → students"
                    ]
                }
            ]
        },
        "details": {
            "channel": "web"
        }
    },
    {
        "_id": "event_000004",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "result_corrected",
        "occurredAt": ISODate("2030-01-01T10:03:00Z"),
        "source": {
            "entity": "results",
            "key": {
                "result_id": 402
            },
            "snapshot": {
                "result_id": 402,
                "student_id": 102,
                "offering_id": 302,
                "score": 93,
                "recorded_at": "2027-05-21T14:00:00+00:00"
            }
        },
        "embedded": {
            "offerings": [
                {
                    "key": {
                        "offering_id": 302
                    },
                    "snapshot": {
                        "offering_id": 302,
                        "course_id": 202,
                        "term_code": "2027SP",
                        "starts_on": "2027-01-10",
                        "ends_on": "2027-05-20"
                    },
                    "via": [
                        "results.offering_id → offerings"
                    ]
                }
            ]
        },
        "references": {
            "students": [
                {
                    "key": {
                        "student_id": 102
                    },
                    "via": [
                        "results.student_id → students"
                    ]
                }
            ]
        },
        "details": {
            "channel": "mobile",
            "note": "Illustrative event-specific metadata",
            "examples": {
                "correction_reason": "illustrative correction_reason",
                "rubric_notes": "illustrative rubric_notes",
                "event_metadata": "illustrative event_metadata"
            }
        }
    }
]));

  // Creating a compound index optimizes the most common chronological event stream queries. Sorting eventType ascending and occurredAt descending allows 
  // us to quickly pull "the most recent events of a specific type".
  await db.getCollection("result_events").createIndex({eventType: 1, occurredAt: -1}, {name: 'event_type_time'});

  // Using '.limit(5)' in all test queries defensively prevents cursor exhaustion and excessive memory consumption if the dataset grows.
  
  // 1. Find the first sample event type. Demonstrates basic equality filtering.
  printjson(await db.getCollection("result_events").find({"eventType":"result_recorded"}).sort({_id:1}).limit(5).toArray());

  // 2. Querying "source.key.result_id" demonstrates NoSQL's native capability 
  // to index and filter across deeply nested object properties using dot notation.
  printjson(await db.getCollection("result_events").find({"source.key.result_id":401}).sort({_id:1}).limit(5).toArray());

  // 3. Time-boxing via $gte and $lt operators enables efficient historical window retrieval.
  printjson(await db.getCollection("result_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray());

  // 4. Utilizing the Aggregation Framework ($group) serves as the NoSQL equivalent 
  // of a SQL GROUP BY, enabling server-side telemetry metrics (counting by eventType).
  printjson(await db.getCollection("result_events").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray());


  // ============================================================================
  // NEGATIVE TESTING (Proving our constraints work)
  // ============================================================================

  // We intentionally inject a string ('not-a-date') into a Date field.
  // This verifies our strict JSON Schema actually rejects bad data payloads instead 
  // of silently corrupting the database.
  try {
    await db.getCollection("result_events").insertOne({...{
    "_id": "event_000001",
    "schemaVersion": 1,
    "simulation": true,
    "eventType": "result_recorded",
    "occurredAt": ISODate("2030-01-01T10:00:00Z"),
    "source": {
        "entity": "results",
        "key": {
            "result_id": 401
        },
        "snapshot": {
            "result_id": 401,
            "student_id": 101,
            "offering_id": 301,
            "score": 88.5,
            "recorded_at": "2026-12-16T10:30:00Z"
        }
    },
    "embedded": {
        "offerings": [
            {
                "key": {
                    "offering_id": 301
                },
                "snapshot": {
                    "offering_id": 301,
                    "course_id": 201,
                    "term_code": "2026FA",
                    "starts_on": "2026-09-01",
                    "ends_on": "2026-12-15"
                },
                "via": [
                    "results.offering_id → offerings"
                ]
            }
        ]
    },
    "references": {
        "students": [
            {
                "key": {
                    "student_id": 101
                },
                "via": [
                    "results.student_id → students"
                ]
            }
        ]
    },
    "details": {
        "channel": "web"
    }
}, _id: 'invalid_date_example', occurredAt: 'not-a-date'});
  } catch (error) { print('Invalid date error: ' + error.code); }

  // Attempting to insert a pre-existing '_id' verifies that 
  // MongoDB's implicit primary key uniqueness constraint successfully blocks duplicates.
  try { await db.getCollection("result_events").insertOne({
    "_id": "event_000001",
    "schemaVersion": 1,
    "simulation": true,
    "eventType": "result_recorded",
    "occurredAt": ISODate("2030-01-01T10:00:00Z"),
    "source": {
        "entity": "results",
        "key": {
            "result_id": 401
        },
        "snapshot": {
            "result_id": 401,
            "student_id": 101,
            "offering_id": 301,
            "score": 88.5,
            "recorded_at": "2026-12-16T10:30:00Z"
        }
    },
    "embedded": {
        "offerings": [
            {
                "key": {
                    "offering_id": 301
                },
                "snapshot": {
                    "offering_id": 301,
                    "course_id": 201,
                    "term_code": "2026FA",
                    "starts_on": "2026-09-01",
                    "ends_on": "2026-12-15"
                },
                "via": [
                    "results.offering_id → offerings"
                ]
            }
        ]
    },
    "references": {
        "students": [
            {
                "key": {
                    "student_id": 101
                },
                "via": [
                    "results.student_id → students"
                ]
            }
        ]
    },
    "details": {
        "channel": "web"
    }
}); }
  catch (error) { print('Duplicate ID error: ' + error.code); }

  print('Document count: ' + await db.getCollection("result_events").countDocuments());
})().catch(error => { print(error.stack || String(error)); quit(1); });
