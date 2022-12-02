DROP TABLE IF EXISTS day01;
CREATE TABLE day01 (
  id   SERIAL,
  cals TEXT
);

\COPY day01 (cals) FROM 'day01/input.txt' WITH (FORMAT 'text');

WITH numeric_ordered AS (
  SELECT
    id,
    cast(CASE WHEN cals = '' THEN NULL ELSE cals END AS INTEGER)
  FROM day01
  ORDER BY id
),
elves AS (
  SELECT 
  --the key to the problem; running sum window function
    SUM(CASE WHEN cals is NULL THEN 1 ELSE 0 END) OVER (
      ORDER BY id 
    ) AS elf,
    cals
  FROM numeric_ordered
),
part1 AS (
  SELECT
    elf,
    SUM(cals) as cals
  FROM elves
  GROUP BY 1
)
SELECT 1 as "Part", max(cals) AS "Solution" FROM part1
UNION ALL
SELECT 2 as "Part", sum(top3) AS "Solution" FROM (
  SELECT cals AS top3 FROM part1 ORDER BY cals DESC LIMIT 3
  )q
;

