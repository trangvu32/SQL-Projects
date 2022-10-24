Count missing values
#Task 1
-- Select the count of industry, 
-- subtract from total number of rows, and alias as missing
SELECT COUNT(*) - COUNT(industry) AS missing
FROM fortune500;
Join tables
#Task 2
SELECT company.name
-- Table(s) to select from
  FROM company
       INNER JOIN fortune500
       ON company.ticker = fortune500.ticker;
