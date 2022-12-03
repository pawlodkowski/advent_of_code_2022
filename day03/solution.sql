DROP TABLE IF EXISTS day03;
CREATE TABLE day03 (
  id         SERIAL,
  contents   TEXT
);

\COPY day03 (contents) FROM 'day03/input.txt' WITH (FORMAT 'text', DELIMITER ' ');

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
),
_elf_group_contents AS (
  SELECT 
    --similar trick from day01 👌
    SUM(CASE WHEN MOD(id - 1, 3) = 0 THEN 1 ELSE 0 END) OVER (
        ORDER BY (id - 1)
    ) as eg,
    contents
  FROM day03
),
elf_group_contents AS (
  SELECT 
    eg,
    string_to_array(string_agg(contents, ','), ',') as contents
  FROM _elf_group_contents
  GROUP BY 1
),
shared_chars_per_group AS (
  SELECT 
    eg,
    array_intersect(
      array_intersect(string_to_array(contents[1], NULL),
                      string_to_array(contents[2], NULL)
                      ),
      string_to_array(contents[3], NULL)
    ) AS chars
  FROM elf_group_contents
  ORDER BY 1 ASC
),
part2 AS (
  SELECT 
    sum(prio) as total
  FROM shared_chars_per_group sc
  LEFT JOIN char_priorities cp
  ON sc.chars[1] = cp.c
)
SELECT 1 as "Part", total AS "Solution" FROM part1
UNION ALL
SELECT 2 as "Part", total AS "Solution" FROM part2
;
