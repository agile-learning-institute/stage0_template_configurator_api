# Generating Test Data

Using [this schema](./.schemas/TestData.schema.0.1.0.0.json ) that describes a single document. Update [this test data](./configurator/test_data/TestData.0.1.0.0.json) to contains **exactly 15** objects. Each document should conform to the given schema, obeying the following rules:

1. **EJSON encoding** for use with MongoDB
    - Every `_id` value must be wrapped as `{ "$oid": "<24‑byte hex>" }`.
    - Every `date` value must be wrapped as `{ "$date": "<ISO‑8601>" }`.
    - Reference IDs that are not the primary `_id` but still match the 24‑byte hex pattern should also be encoded with `$oid`.
        
2. **Enum values**  
    - When a property is an enum, assign values at random but_ _ensure that every listed enum value appears at least once_ across the generated documents.
    - If special instructions mention a specific enum value(s), obey those rules (e.g., “use only `active`”).
    
3. **Special Instructions**
Create a wide variety of replies - each test data document Should contain at least 15 replies and a variety of sentiment. 

# Advanced Test Data Prompt
That was awesome - now, let's create @mongodb_data/configurator/test_data/Grade.0.1.0.0.json from @mongodb_data/.schemas/Grade.schema.0.1.0.0.json - we need to create a variety of Grades that would be the result of a Test Run. Use the  @mongodb_data/configurator/test_data/TestRun.0.1.0.0.json runs that are running or complete, update them with Grade ID's and Copy the appropriate data from @mongodb_data/configurator/test_data/TestData.0.1.0.0.json for to create a grade. 

# After schema refactor
Ok - and now @mongodb_data/.schemas/Grade.yaml_0.1.0.0_json_schema.json is very different. We will discard the existing file and create a new one. Start with creating a completed test run where the model is "human" - then create Grades documents for that test run. We should have one grade document for every TestData document, the model for all classifications is "human". Then we should create Grades documents for the remaining test runs that have a status of "running" or "complete" - Note that the @mongodb_data/.schemas/TestRun.yaml_0.1.0.0_json_schema.json schema now has an analytics property that you will want to populate for completed or running TestRuns. 