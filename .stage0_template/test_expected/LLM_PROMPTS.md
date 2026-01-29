# Generating Test Data

Using [this schema](.link_here) that describes a single document. Update [this test data](.test_data_file) to contains **exactly 15** objects. Each document should conform to the given schema, obeying the following rules:

1. **EJSON encoding** for use with MongoDB
    - Every `_id` value must be wrapped as `{ "$oid": "<24‑byte hex>" }`.
    - Every `date` value must be wrapped as `{ "$date": "<ISO‑8601>" }`.
    - Reference IDs that are not the primary `_id` but still match the 24‑byte hex pattern should also be encoded with `$oid`.
        
2. **Enum values**  
    - When a property is an enum, assign values at random but_ _ensure that every listed enum value appears at least once_ across the generated documents.
    - If special instructions mention a specific enum value(s), obey those rules (e.g., “use only `active`”).
    
3. **Special Instructions**
Create a wide variety of replies - each test data document Should contain at least 15 replies and a variety of sentiment. 
