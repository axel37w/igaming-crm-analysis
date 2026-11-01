-- RFM segmentation
--
-- Question: which depositors are worth a personal campaign, and which
-- have lapsed while still being valuable?
--
-- R — recency of the last deposit, F — number of deposits, M — total
-- deposited. ntile(4) splits players into quartiles on each; desc puts
-- the best players in group 1, so 1-1-1 is the strongest profile and
-- 4-1-1 a valuable player who has gone quiet.
--
-- The window functions run after group by, so they rank the aggregated
-- rows — one per player — not the raw transactions.

select player_id,
       ntile(4) over (order by max(transaction_date) desc) as R,
       max(transaction_date) as last_deposit,
       ntile(4) over (order by count(*) desc) as F,
       count(*) as deposits,
       ntile(4) over (order by sum(amount) desc) as M,
       sum(amount) as deposits_total
from transactions
where type = 'deposit'
group by player_id
order by R, F, M;


-- Rollup: how many players land in each combination.
--
-- The scores have to be computed in a CTE first: window functions are
-- evaluated at select time, so they cannot be grouped by in the same query.

with rfm as (
    select player_id,
           ntile(4) over (order by max(transaction_date) desc) as R,
           ntile(4) over (order by count(*) desc) as F,
           ntile(4) over (order by sum(amount) desc) as M
    from transactions
    where type = 'deposit'
    group by player_id
)
select R, F, M, count(*) as players
from rfm
group by R, F, M
order by R, F, M;
