DROP TABLE IF EXISTS day03;
CREATE TABLE day03 (
  contents   text
);

\COPY day03 FROM 'day03/input.txt' WITH (FORMAT 'text', DELIMITER ' ');

CREATE OR REPLACE FUNCTION array_intersect(anyarray, anyarray)
  RETURNS anyarray
  language sql
as $FUNCTION$
    SELECT ARRAY(
        SELECT UNNEST($1)
        INTERSECT
        SELECT UNNEST($2)
    );
$FUNCTION$;

WITH char_priorities_lower(c, prio) AS (
  --I'm sure there's a better way to do this with some underlying char encoding (e.g. ASCII)
  VALUES ('a', 1),
         ('b', 2), 
         ('c', 3), 
         ('d', 4), 
         ('e', 5),
         ('f', 6),
         ('g', 7),
         ('h', 8),
         ('i', 9),
         ('j', 10),
         ('k', 11),         
         ('l', 12),
         ('m', 13),
         ('n', 14),
         ('o', 15),
         ('p', 16),
         ('q', 17),
         ('r', 18),
         ('s', 19),
         ('t', 20),
         ('u', 21),
         ('v', 22),
         ('w', 23),
         ('x', 24),
         ('y', 25),
         ('z', 26)
  ),
char_priorities AS (
  SELECT * FROM char_priorities_lower
  UNION ALL
  SELECT
    upper(c) as c,
    prio + 26 as prio 
  FROM char_priorities_lower
),
compartments AS (
  SELECT 
    substring(contents, 0, length(contents)/2 + 1) AS comp_1,
    substring(contents, length(contents)/2 + 1, length(contents)) AS comp_2
  FROM day03
),
shared_chars AS (
  SELECT 
    array_intersect(
      string_to_array(comp_1, NULL),
      string_to_array(comp_2, NULL)
      ) AS chars
  FROM compartments
),
part1 AS (
  SELECT 
    sum(prio) as total
  FROM shared_chars sc
  LEFT JOIN char_priorities cp
  ON sc.chars[1] = cp.c
)
SELECT 1 as "Part", total AS "Solution" FROM part1;


