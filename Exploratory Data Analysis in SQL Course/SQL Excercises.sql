Count missing values
#Task 1
SELECT COUNT(*) - COUNT(industry) AS missing
FROM fortune500;

Join tables
#Task 2
SELECT company.name
  FROM company
       INNER JOIN fortune500
       ON company.ticker = fortune500.ticker;
       
Inner Join
#Task 3
SELECT company.name, tag_type.tag, tag_type.type
  FROM company
       INNER JOIN tag_company 
       ON company.id = tag_company.company_id
       INNER JOIN tag_type
       ON tag_company.tag = tag_type.tag
  WHERE type='cloud';

Coalesce Function
#Task 4
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       COUNT(*) 
  FROM fortune500 
 GROUP BY industry2
 ORDER BY COUNT DESC
 LIMIT 1;
 
Coalesce with a self-join
#Task 5
SELECT company_original.name, title, rank
  FROM company AS company_original
	   LEFT JOIN company AS company_parent
       ON company_original.parent_id = company_parent.id 
       INNER JOIN fortune500 
       ON coalesce(company_parent.ticker, 
                   company_original.ticker) = 
             fortune500.ticker
 	ORDER BY rank; 
 
 CASTing with () and ::
 #Task 6
 SELECT profits_change, 
       CAST(profits_change AS integer) AS profits_change_int
  FROM fortune500;
  
-- Cast 10 as numeric and divide by 3
 SELECT 10/3, 
       10::numeric/3;
 
 -- Select the count of each revenues_change integer value
SELECT revenues_change::integer, count(*) 

Explore with division
#Task 7 
SELECT unanswered_count/question_count::numeric AS computed_pct, 
       -- What are you comparing the above quantity to?
       unanswered_pct
  FROM stackoverflow
 -- Select rows where question_count is not 0
 WHERE question_count != 0
 LIMIT 10;
  FROM fortune500
 GROUP BY revenues_change::integer 
 -- order by the values of revenues_change
 ORDER BY revenues_change;

Summarize group statistics
#Task 8
SELECT stddev(maxval),
       min(maxval),
       max(maxval),
       avg(maxval)
FROM (SELECT max(question_count) AS maxval
         FROM stackoverflow
         GROUP BY tag) AS max_results; 
	 
Truncate
#Task 9 
 -- Truncate employees
SELECT trunc(employees, -4) AS employee_bin,
       count(*)
  FROM fortune500
 WHERE employees < 100000
 GROUP BY employee_bin
 ORDER BY employee_bin;
 
Generate series
#Task 10
--use generate_series() to create bins of size 50 from 2200 to 3100.
WITH bins AS (
      SELECT generate_series(2200, 3050, 50) AS lower,
             generate_series(2250, 3100, 50) AS upper),
     -- Subset stackoverflow to just tag dropbox (Step 1)
     dropbox AS (
      SELECT question_count 
        FROM stackoverflow
       WHERE tag='dropbox') 
-- Select columns for result
-- What column are you counting to summarize?
SELECT lower, upper, count(question_count) 
  FROM bins  -- Created above
       -- Join to dropbox (created above), 
       -- keeping all rows from the bins table in the join
       LEFT JOIN dropbox
       -- Compare question_count to lower and upper
         ON  question_count >= lower 
        AND  question_count < upper
 -- Group by lower and upper to count values in each bin
 GROUP BY lower, upper
 -- Order by lower to put bins in order
 ORDER BY lower;
 
Correlation
#Task 11
SELECT corr(revenues, profits) AS rev_profits,
       corr(revenues, assets) AS rev_assets,
       corr(revenues, equity) AS rev_equity 
  FROM fortune500;
  
SELECT sector,
       avg(assets) AS mean,
  percentile_disc(0.5) WITHIN GROUP (ORDER BY assets) AS median
  FROM fortune500
 GROUP BY sector
 ORDER BY AVG(assets);



