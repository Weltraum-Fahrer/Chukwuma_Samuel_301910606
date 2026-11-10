// Run once in mongosh against a fresh exercise database.
// These records are fictional events for the case study.
(async function () {
  db = db.getSiblingDB('portfolio_nosql');
  if ((await db.getCollectionNames()).includes("result_events")) {
    throw new Error('The exercise collection already exists. Use a fresh database.');
  }

  // The validator checks the stable event fields while details can vary.
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
                "bsonType": "string",
                "minLength": 1
            },
            "schemaVersion": {
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
                "bsonType": "string",
                "enum": [
                    "result_recorded",
                    "result_corrected"
                ]
            },
            "occurredAt": {
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
                "bsonType": "object"
            }
        }
    }
},
    validationLevel: 'strict', validationAction: 'error'
  });

  // Insert the four example events and show their IDs.
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
  await db.getCollection("result_events").createIndex({eventType: 1, occurredAt: -1}, {name: 'event_type_time'});

  // 1. Find the first sample event type (up to five documents).
  printjson(await db.getCollection("result_events").find({"eventType":"result_recorded"}).sort({_id:1}).limit(5).toArray());

  // 2. Find events for the first source record using nested key fields (up to five).
  printjson(await db.getCollection("result_events").find({"source.key.result_id":401}).sort({_id:1}).limit(5).toArray());

  // 3. Find events in the sample time range using a MongoDB Date filter (up to five).
  printjson(await db.getCollection("result_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray());

  // 4. Count documents for each event type.
  printjson(await db.getCollection("result_events").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray());

  // A date stored as text should be rejected by the validator.
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

  // Reusing an event ID should be rejected by the unique _id index.
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
