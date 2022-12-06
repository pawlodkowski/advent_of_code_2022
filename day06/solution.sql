DROP TABLE IF EXISTS day06;
CREATE TABLE day06 (
  stream TEXT
);

\COPY day06 FROM 'day06/input.txt' WITH (FORMAT 'text');

CREATE OR REPLACE FUNCTION get_marker_position(TEXT, INTEGER)
  RETURNS INTEGER
  LANGUAGE SQL
  AS $$
    WITH stream AS (
      SELECT
        *,
        row_number() OVER() AS char_num,
        array_agg(stream) OVER(ROWS BETWEEN $2-1 PRECEDING AND CURRENT ROW) AS last_n
      FROM (SELECT unnest(REGEXP_SPLIT_TO_ARRAY($1, '')) as stream)q
    ),
    marker_positions AS (
      SELECT
        char_num,
        count(DISTINCT chars) AS distinct_chars
      FROM (
        SELECT
          char_num,
          unnest(last_n) AS chars FROM stream
      )q
      GROUP BY 1
    )
    SELECT 
      char_num
    FROM marker_positions
    WHERE distinct_chars = $2
    FETCH FIRST 1 ROWS ONLY;
$$;

SELECT 1 AS "Part", get_marker_position((select stream from day06), 4) AS "Solution"
UNION ALL
SELECT 1 AS "Part", get_marker_position((select stream from day06), 14) AS "Solution";
