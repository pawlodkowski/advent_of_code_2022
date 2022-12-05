DROP SCHEMA IF EXISTS day05 CASCADE;
CREATE SCHEMA day05;

CREATE TABLE day05.crates (
  row    SERIAL,
  stacks TEXT
);

CREATE TABLE day05.instructions (
  sentence TEXT
);

--TODO: dynamic numbers for -A and -B commands; currently hacky but it works (just has to be large enough)
\COPY day05.crates (stacks) FROM PROGRAM 'grep -B100 "^[0-9]*$" day05/input.txt | tail -r | tail -n +3 | tail -r';
\COPY day05.instructions    FROM PROGRAM 'grep -A200 "^[0-9]*$" day05/input.txt | tail -n +2';

WITH _unnested_crate_rows AS (
	SELECT 
	  row,
	  unnest(REGEXP_SPLIT_TO_ARRAY(stacks, '')) AS crate
	FROM day05.crates
),
_unnested_crates AS (
	SELECT
		*,
		row_number() OVER(PARTITION BY row) AS col
	FROM _unnested_crate_rows
),
unnested_crates AS (
	SELECT
		*
	FROM _unnested_crates
	WHERE mod(col, 4) = 2 
	-- positions of the actual letters -> 2, 6, 10, 14, etc.
),
unnested_crates_parsed AS (
	--	 row_num | crate | stack_num 
	--	---------+-------+-----------
	--	       1 |       |         0
	--	       1 | D     |         1
	--	       1 |       |         2
	--	       2 | N     |         0
	--	       2 | C     |         1
	--	       2 |       |         2
	--	       3 | Z     |         0
	--	       3 | M     |         1
	--	       3 | P     |         2
	SELECT 
		row AS row_num,
		crate,
		floor(col/4) AS stack_num
	FROM unnested_crates
),
stack_data AS (
	SELECT
		stack_num,
		string_agg(crate, '' ORDER BY row_num DESC) AS stack_contents
	FROM unnested_crates_parsed
	WHERE crate <> ' '
	GROUP BY 1
),
move_vals AS (
	SELECT 
		regexp_match(sentence, 'move (\d+) from (\d+) to (\d+)') AS vals
	FROM day05.instructions
),
moves AS (
	SELECT 
		vals[1]::int AS amount,
		vals[2]::int AS origin,
		vals[3]::int AS destination
	FROM move_vals
)
SELECT * FROM stack_data;

