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
tree_neighbors AS (
  SELECT
    row, 
    col,
    tree,
    CASE 
      WHEN 
        row = (SELECT max(row) FROM unnested_trees) OR row = 1
        OR
        col = (SELECT max(col) FROM unnested_trees) OR col = 1
      THEN TRUE
      ELSE FALSE
    END AS "edge",
    coalesce(lag(tree, -1) OVER(PARTITION BY row ORDER BY col), 0) AS tree_right,
    coalesce(lag(tree,  1) OVER(PARTITION BY row ORDER BY col), 0) AS tree_left,
    coalesce(lag(tree, -1) OVER(PARTITION BY col ORDER BY row), 0) AS tree_below,
    coalesce(lag(tree,  1) OVER(PARTITION BY col ORDER BY row), 0) AS tree_above
  FROM unnested_trees
  ORDER BY 1, 2
)
SELECT  
  *,
    CASE 
      WHEN (tree > tree_right) 
        OR (tree > tree_left) 
        OR (tree > tree_below) 
        OR (tree > tree_above)
        OR edge
      THEN 1 
      ELSE 0
    END
    AS visible
FROM tree_neighbors;
