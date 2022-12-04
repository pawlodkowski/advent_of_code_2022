DROP TABLE IF EXISTS day04;
CREATE TABLE day04 (
  id         SERIAL,
  elf_1      TEXT NOT NULL,
  elf_2      TEXT NOT NULL
);

\COPY day04 (elf_1, elf_2) FROM 'day04/input.txt' WITH (FORMAT 'text', DELIMITER ',');

CREATE OR REPLACE FUNCTION generate_array_from_section(anyelement)
  --TODO: curious how I can strictly ensure pg_typeof(anyelement) = TEXT
  RETURNS anyarray
  LANGUAGE SQL
AS $$
    WITH series AS (
      SELECT generate_series(
        split_part($1, '-', 1)::int,
        split_part($1, '-', 2)::int
        )s
    )
    SELECT array_agg(s)
    FROM LATERAL (SELECT s FROM SERIES)q;
$$;

WITH section_arrays AS (
  SELECT 
    generate_array_from_section(elf_1) as elf_1,
    generate_array_from_section(elf_2) as elf_2
  FROM day04
),
part1 AS (
  SELECT
    SUM(
      CASE
        WHEN elf_1 <@ elf_2 OR elf_2 <@ elf_1 THEN 1
        ELSE 0
      END
    ) AS full_containments
  FROM section_arrays
),
part2 AS (
  SELECT
    SUM(
      CASE
        WHEN elf_1 && elf_2 THEN 1
        ELSE 0
      END
    ) AS _overlaps
  FROM section_arrays 
)
SELECT 1 AS "Part", full_containments AS "Solution" FROM part1
UNION ALL
SELECT 2 AS "Part", _overlaps AS "Solution" FROM part2;




