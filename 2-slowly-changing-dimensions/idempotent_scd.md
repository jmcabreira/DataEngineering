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


# Slowly Changing Dimaation 
1. **Type 0**
* Aren't  actually slowly changing ( e.g birth date)
* Is idempotent because the values are unchanging
2. **Type 1**
* You only care about the latest value 
    * You should not use this type since it makes your pipeline not idempotent anymore. ( for analytics )
* Not idempotent
3. **Type 2**
* You care about what value was from "start_date" to "end_date"
* Current values usually have either an end_date that is:
    * NULL
    * Far into the future like 9999-12-31
* Hard to use:
    * Since there's more than 1 row per dimension, you need to be careful about filtering on time
* **THE ONLY TYPE OF SCD THAT IS PURELY IDEMPOTENT**
    * Is idempotent but you need to be careful with how you use the **start_date** and **end_date**
4.**TYPE 3**
* You only care about "original" and "current"
* Benefits:
    * You only have 1 row per dimension
* Drawbacks:
    * You lose the history in between original and current 
* Its not idempotent