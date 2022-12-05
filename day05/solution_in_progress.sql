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
	select
		*,
		row_number() over(partition by row) as col
	from _unnested_crate_rows
),
unnested_crates as (
	select 
		*
	from _unnested_crates
	where mod(col, 4) = 2 
	-- positions of the actual letters -> 2, 6, 10, 14, etc.
),
unnested_crates_parsed as (
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
	select 
		row as row_num,
		crate,
		floor(col/4) as stack_num
	from unnested_crates
),
stack_data as (
	select
		stack_num,
		string_agg(crate, '' order by row_num desc) as stack_contents
	from unnested_crates_parsed
	where crate <> ' '
	group by 1
),
move_vals as (
	select 
		regexp_match(sentence, 'move (\d+) from (\d+) to (\d+)') as vals
	from day05.instructions
),
moves as (
	select 
		vals[1]::int as amount,
		vals[2]::int as origin,
		vals[3]::int as destination
	from move_vals
)
select * from stack_data;

