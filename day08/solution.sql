DROP TABLE IF EXISTS day08;
CREATE TABLE IF NOT EXISTS day08 (
  row      SERIAL,
  tree_row TEXT
);

\COPY day08 (tree_row) FROM 'day08/input.txt' WITH (FORMAT 'text');

WITH _unnested_trees AS (
  SELECT
    row,
    unnest(REGEXP_SPLIT_TO_ARRAY(tree_row, ''))::int AS tree
FROM day08
),
unnested_trees AS (
  SELECT
    *,
    row_number() OVER(PARTITION BY row) AS col
  FROM _unnested_trees
),
-- inner_trees AS (
--   SELECT
--     *
--   FROM unnested_trees
--   -- WHERE
--   --   row <> (SELECT max(row) FROM unnested_trees) AND row <> 1
--   --   AND
--   --   col <> (SELECT max(col) FROM unnested_trees) AND col <> 1
-- ),
tree_grid AS (
  SELECT
    row::text || col::text as tree_id,
    row,
    col,
    CASE 
      WHEN 
        row = (SELECT max(row) FROM unnested_trees) OR row = 1
        OR
        col = (SELECT max(col) FROM unnested_trees) OR col = 1
      THEN 'true'
      ELSE 'false'
    END AS "edge",
    tree as height
FROM unnested_trees
),
tree_neighbors AS (
  SELECT
    *,
    string_to_array(
      lag(height::text, -1) OVER(PARTITION BY row ORDER BY col) || ' ' ||
      lag(edge, -1) OVER(PARTITION BY row ORDER BY col),
      ' '
      ) AS tree_right,
    string_to_array(
      lag(height::text, 1) OVER(PARTITION BY row ORDER BY col) || ' ' ||
      lag(edge, 1) OVER(PARTITION BY row ORDER BY col), 
      ' '
     ) AS tree_left,
    string_to_array(
      lag(height::text, -1) OVER(PARTITION BY col ORDER BY row) || ' ' ||
      lag(edge, -1) OVER(PARTITION BY col ORDER BY row), 
      ' '
     ) AS tree_below,
    string_to_array(
      lag(height::text, 1) OVER(PARTITION BY col ORDER BY row) || ' ' ||
      lag(edge, 1) OVER(PARTITION BY col ORDER BY row), 
      ' '
     ) AS tree_above
  FROM tree_grid
  ORDER BY 1, 2
)
SELECT  
  *,
    CASE 
      WHEN (height > tree_right[1]::int AND tree_right[2] = 'true') 
        OR (height > tree_left[1]::int AND tree_left[2] = 'true') 
        OR (height > tree_below[1]::int AND tree_below[2] = 'true')  
        OR (height > tree_above[1]::int AND tree_above[2] = 'true')  
        OR edge = 'true'
      THEN 1 
      ELSE 0
    END
    AS visible
FROM tree_neighbors;
