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
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       COUNT(*) 
  FROM fortune500 
 GROUP BY industry2
 ORDER BY COUNT DESC
 LIMIT 1;
 
Coalesce with a self-join
SELECT company_original.name, title, rank
  FROM company AS company_original
	   LEFT JOIN company AS company_parent
       ON company_original.parent_id = company_parent.id 
       INNER JOIN fortune500 
       ON coalesce(company_parent.ticker, 
                   company_original.ticker) = 
             fortune500.ticker
 ORDER BY rank; 


