DROP TABLE IF EXISTS day02;
CREATE TABLE day02 (
  p1   text,
  p2   text
);

\COPY day02 FROM 'day02/input.txt' WITH (FORMAT 'text', DELIMITER ' ');

--rename to R (Rock), P (Paper), S(Scissors) for my own sanity
WITH 
p1(old, new) AS (
  VALUES ('A', 'R'),
         ('B', 'P'), 
         ('C', 'S')
  ),
p2(old, new) AS (
  VALUES ('X', 'R'), 
         ('Y', 'P'), 
         ('Z', 'S')
  ),
renamed AS (
  SELECT
    p1.new AS p1,
    p2.new AS p2
  FROM day02
  JOIN p1 ON day02.p1 = p1.old
  JOIN p2 ON day02.p2 = p2.old
),
points AS (
  SELECT
    CASE
      WHEN p2 = 'R' THEN 1
      WHEN p2 = 'P' THEN 2
      WHEN p2 = 'S' THEN 3
    END AS shape_points,
    CASE
      --draw
      WHEN p1 = p2 THEN 3 
      --loss
      WHEN p1 = 'R' AND p2 = 'S' THEN 0
      WHEN p1 = 'P' AND p2 = 'R' THEN 0
      WHEN p1 = 'S' AND p2 = 'P' THEN 0
      --win
      WHEN p1 = 'R' AND p2 = 'P' THEN 6
      WHEN p1 = 'P' AND p2 = 'S' THEN 6
      WHEN p1 = 'S' AND p2 = 'R' THEN 6
    END AS outcome_points
  FROM renamed
),
part1 AS (
  SELECT
    sum(total) AS total
  FROM (SELECT shape_points + outcome_points AS total FROM points)q
),
--different logic based on description in part2
p2_alt(old, new) AS (
  VALUES ('X', 0), --loss
         ('Y', 3), --draw
         ('Z', 6)  --win
  ),
renamed_alt AS (
  SELECT
    p1.new AS p1,
    p2_alt.new AS outcome_points
  FROM day02
  JOIN p1     ON day02.p1 = p1.old
  JOIN p2_alt ON day02.p2 = p2_alt.old
),
points_alt AS (
  SELECT
    CASE
      --win
      WHEN outcome_points = 6 AND p1 = 'R' THEN 2 --play paper
      WHEN outcome_points = 6 AND p1 = 'P' THEN 3 --play scissors
      WHEN outcome_points = 6 AND p1 = 'S' THEN 1 --play rock
      --draw
      WHEN outcome_points = 3 AND p1 = 'R' THEN 1 
      WHEN outcome_points = 3 AND p1 = 'P' THEN 2 
      WHEN outcome_points = 3 AND p1 = 'S' THEN 3 
      --loss
      WHEN outcome_points = 0 AND p1 = 'R' THEN 3 
      WHEN outcome_points = 0 AND p1 = 'P' THEN 1 
      WHEN outcome_points = 0 AND p1 = 'S' THEN 2
    END AS shape_points,
    outcome_points
  FROM renamed_alt
),
part2 AS (
  SELECT
    sum(total) AS total
  FROM (SELECT shape_points + outcome_points AS total FROM points_alt)q
)
SELECT 1 as "Part", total AS "Solution" FROM part1
UNION ALL
SELECT 2 as "Part", total AS "Solution" FROM part2
;

