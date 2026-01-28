---
description: Generate a {COLLECTION}{VERSION} JSON Test Data file
repo:
  - /.schemas/{COLLECTION}.{VERSION}.json
  - /configurator/test_data/{COLLECTION}.{VERSION}.json
  - /tasks/TestDataInstructions.md
environment:
  - COLLECTION
  - VERSION
outputs:
  - /configurator/test_data/{COLLECTION}.{VERSION}.json
guarantees:
  - Follows json format rules
  - Test Data complies with provided schema.
  - Follows instructions provided.
---

Using the schema provided which describes a single document. Update the test_data json file as instructed in the TestDataInstructions. Each document should conform to the given schema, obeying the following rules:

1. **EJSON encoding** for use with MongoDB
    - Every `_id` value must be wrapped as `{ "$oid": "<24‑byte hex>" }`.
    - Every `date` value must be wrapped as `{ "$date": "<ISO‑8601>" }`.
    - Reference IDs that are not the primary `_id` but still match the 24‑byte hex pattern should also be encoded with `$oid`.
        
2. **Enum values**  
    - When a property is an enum, assign values at random but _ensure that every listed enum value appears at least once_ across the generated documents.
    - If special instructions mention a specific enum value(s), obey those rules (e.g., “use only `active`”).
    