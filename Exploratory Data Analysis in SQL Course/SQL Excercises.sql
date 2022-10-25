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

Create a temp table
#Task 12
DROP TABLE IF EXISTS profit80;
CREATE TEMP TABLE profit80 AS
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    FROM fortune500 
   GROUP BY sector;

SELECT title, fortune500.sector, 
       profits, profits/pct80 AS ratio
  FROM fortune500 
       LEFT JOIN profit80
       ON fortune500.sector = profit80.sector 
WHERE profits > pct80;

Create a temp table to simplify a query
#Task 13
DROP TABLE IF EXISTS startdates;

CREATE TEMP TABLE startdates AS
SELECT tag, min(date) AS mindate
  FROM stackoverflow
 GROUP BY tag;
 
SELECT startdates.tag, 
       mindate, 
       dajso_min.question_count AS min_date_question_count,
       so_max.question_count AS max_date_question_count,
       so_max.question_count - so_min.question_count AS change
  FROM startdates
       INNER JOIN stackoverflow AS so_min
          ON startdates.tag = so_min.tag
         AND startdates.mindate = so_min.date
       INNER JOIN stackoverflow AS so_max
          ON startdates.tag = so_max.tag
         AND so_max.date = '2018-09-25';
	 
Insert into a temp table
#Task 14
DROP TABLE IF EXISTS correlations;
CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'profits_change'::varchar AS measure,
       corr(profits_change, profits) AS profits,
       corr(profits_change, profits_change) AS profits_change,
       corr(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       corr(revenues_change, profits) AS profits,
       corr(revenues_change, profits_change) AS profits_change,
       corr(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;

SELECT measure, 
       round(profits::numeric, 2) AS profits,
       round(profits_change::numeric, 2) AS profits_change,
       round(revenues_change::numeric, 2) AS revenues_change
  FROM correlations;
  
Shorten long strings
#Task 15
SELECT CASE WHEN length(description) > 50
            THEN left(description, 50) || '...'
       ELSE description
       END
  FROM evanston311
 -- limit to descriptions that start with the word I
 WHERE description LIKE 'I %'
 ORDER BY description;
 
Group and recode values
#Task 16
-- Code from previous step
DROP TABLE IF EXISTS recode;
CREATE TEMP TABLE recode AS
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
  FROM evanston311;
UPDATE recode SET standardized='Trash Cart' 
 WHERE standardized LIKE 'Trash%Cart';
UPDATE recode SET standardized='Snow Removal' 
 WHERE standardized LIKE 'Snow%Removal%';
UPDATE recode SET standardized='UNUSED' 
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart', 
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash', 'NO LONGER IN USE');

-- Select the recoded categories and the count of each
SELECT standardized, COUNT(*)
-- From the original table and table with recoded values
  FROM evanston311 
       LEFT JOIN recode 
       -- What column do they have in common?
       ON evanston311.category = recode.category 
 -- What do you need to group by to count?
 GROUP BY standardized
 -- Display the most common val values first
 ORDER BY COUNT(standardized) DESC;
 
 


