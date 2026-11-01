-- Churn by segment
--
-- Question: how many players stopped depositing after November 2022,
-- and how much revenue did they represent while they were active?
--
-- Churn is sized in money, not headcount: one lapsed High Value player
-- is worth more than ten Low Value ones.

with churned as (
    select p.player_id,
           p.segment,
           sum(t.amount) as deposits_total
    from players p
    join transactions t on p.player_id = t.player_id and t.type = 'deposit'
    group by p.player_id, p.segment
    having max(t.transaction_date) < '2022-12-01'
)
select segment,
       count(*) as churned_players,
       sum(deposits_total) as revenue_lost
from churned
group by segment
order by revenue_lost desc;
