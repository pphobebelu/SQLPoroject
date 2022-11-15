
-- preparation for the cohort analysis 
-- we get the minimum order date of each customer. The order date of each customer is recorded on the <Sales> table which will be joined to the <customers> table

SELECT 
        b.CustomerID AS CustomerID,
		SUM(a.Sales) AS Sales,
		b.CustomerName AS CustomerName,
		MIN(a.OrderDate) AS MinOrderDate
    FROM
        Sales AS a INNER JOIN customers AS b 
    ON a.CustomerID = b.CustomerID
    WHERE YEAR(OrderDate) = 2017
    GROUP BY CustomerName;
    
-- expand our query to put our customers in their respective cohorts.  this cohort to be recorded in the <Sales> table.

SELECT d.OrderID AS OrderID,
    d.OrderDate AS OrderDate,
    c.CustomerName AS CustomerName,
    d.Sales AS SalesAmount,
    c.CustomerID,
    DATE_FORMAT(c.FirstOrderDate, '%M %Y') AS Cohort 
FROM
    Sales AS d
        INNER JOIN
           (
            SELECT 
            b.CustomerID AS CustomerID,
            SUM(a.Sales) AS Sales,
            b.CustomerName AS CustomerName,
            MIN(a.OrderDate) AS FirstOrderDate
            
            FROM
              Sales AS a
            INNER JOIN
              customers AS b 
            ON
              a.CustomerID = b.CustomerID
            WHERE
              YEAR(OrderDate) = 2017
            GROUP BY CustomerName
            ) AS c 
         ON d.CustomerID = c.CustomerID
WHERE
    YEAR(d.OrderDate) = 2017
ORDER BY 
    OrderDate ASC;

-- prepare for the retetion analysis
-- how many of them returned per month over the rest of the year?

SELECT Year(transaction_date),
       Month(transaction_date), count (cust_id) AS number
FROM dataset
WHERE year(transaction_date)=2016
AND cust_id in 
(
      SELECT DISTINCT cust_id
      FROM            dataset
      WHERE           month(transaction_date)=1
      AND             year(transaction_date)=2016)
GROUP BY 1,2;

-- create a table where each user’s visits are logged by month

with Visit_log AS
(SELECT cust_id,
       datediff(month, ‘2000–01–01’, transaction_date) AS visit_month
FROM dataset
GROUP BY 1,
         2
ORDER BY 1),

Time_lapse AS (SELECT cust_id,
           visit_month, lead(visit_month, 1) over (partition BY cust_id ORDER BY cust_id, visit_month) 
    FROM visit_log),
    
    Time_diff_calculated AS
    (SELECT cust_id,
           visit_month,
           lead(visit_month, 1) over (partition BY cust_id ORDER BY cust_id, visit_month) as num1,
          lead(visit_month, 1) over (partition BY cust_id ORDER BY cust_id, visit_month) - visit_month AS time_diff
    FROM time_lapse),
Custs_categorized AS
(SELECT cust_id,
       visit_month,
       CASE WHEN time_diff = 1 THEN ‘retained’
             WHEN time_diff>1 THEN ‘lagger’
             WHEN time_diff IS NULL THEN ‘lost’
       END AS cust_type
FROM time_diff_calculated)

SELECT visit_month,
       count(cust_id where cust_type=’retained’)/count(cust_id) AS retention
FROM custs_categorized
GROUP BY 1;


--  what proportion of our visitors in any given month are retained, how many are returning, and how many are new.

with Time_lapse_2 AS
    (SELECT cust_id,
           Visit_month,
           lag(visit_month, 1) over (partition BY cust_id ORDER BY cust_id, visit_month)
     FROM visit_log),
Time_diff_calculated_2 AS
    ( SELECT cust_id,
           visit_month,
            lag(visit_month, 1) over (partition BY cust_id ORDER BY cust_id, visit_month),
           visit_month- lag(visit_month, 1) over (partition BY cust_id ORDER BY cust_id, visit_month) AS time_diff
     FROM time_lapse_2),
Custs_categorized AS
    (SELECT cust_id,
           visit_month,
           CASE
                    WHEN time_diff=1 THEN ‘retained’
                    WHEN time_diff>1 THEN ‘returning’
                    WHEN time_diff IS NULL THEN ‘new’
           END AS cust_type
FROM time_diff_calculated_2)

SELECT visit_month,
       cust_type,
       Count(cust_id)
FROM custs_categorized
GROUP BY 1,
         2



    
    
    

    

    
    
    
    


    