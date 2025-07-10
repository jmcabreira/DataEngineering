# What make a pipeline not idempotent

1. INSERT INTO without TRUNCATE
- Use MERGE or INSERT OVERWRITE every time
2. Using Start_date > without a corresponding end_date<
3. Not using  a full set of partition sensors
- Pipeline might run when there is no/partial partition data 
4. Not using **depends_on_past** for cumulative pipelines
5. Rely on the latest partition of a not properly modeled SCD table 
- DAILY DIMENSIONS AND latest partition is a bad idea 
- Cumulative table design AMPLIFIES this bug
6. Rely on the latest partition of anything else

# The pain of not having idempotent pipelines
1. Backfilling causes inconsistencies between  the old and restated data
2. Very hard to troubleshoot bugs
3. Unit test cannot replicate the production behavior
4. Silent Failures