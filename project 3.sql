-- data quality checking 
-- row counts

WITH source_count as (Select count(*) as total_count from source),
target_count as (Select count(*) as total_count from target)
SELECT
   CASE WHEN 
     (select total_count from source_count) = (select total_count from target_count) 
    THEN True 
    ELSE False
END as valid_row_count
FROM 
  pipe_table_1;
  
  -- Join Validation
WITH join_count AS (
 SELECT
    count(*) AS view_count
 FROM views
 LEFT JOIN clicks ON clicks.view_id = views.id
)
SELECT
CASE 
     WHEN (SELECT view_count FROM join_count) = count(1) 
     THEN True
     ELSE False
END AS valid_join
FROM
views;

-- ensure that the data has been brought in to the database correctly from the ETL layer 
-- assume the expection range is 1000

SELECT 
   count(*), 
   year
FROM
   views a
JOIN date b on a.date_id = b.date_id
GROUP BY 1,2
HAVING count(*) > 1000;

SELECT 
   count(*), 
   year, 
   month
FROM Views a
JOIN date b on a.date_id = b.date_id
GROUP BY 1,2,3
HAVING count(*) > 1000;

--  Validating the number of views should always be greater than the number of clicks
SELECT
  CASE WHEN
    count(a.num_view) >= count(b.num_clicks)
  THEN True 
  ELSE False
  END as click_validation
FROM
views a LEFT JOIN clicks b ON b.click_id = a.click_id


