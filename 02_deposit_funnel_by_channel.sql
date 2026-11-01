-- Deposit funnel by acquisition channel
--
-- Question: where do players drop off between registration and a third
-- deposit, and does the ranking of channels change along the way?
--
-- The funnel is cumulative: a player with three deposits counts at every
-- stage, so the conditions use >= rather than =.
--
-- left join keeps players who never deposited, so they stay in the
-- denominator of the conversion rate.

with dep_count as (
    select p.player_id,
           p.acquisition_channel,
           count(t.transaction_id) as deposits
    from players p
    left join transactions t on p.player_id = t.player_id and t.type = 'deposit'
    group by p.player_id, p.acquisition_channel
)
select acquisition_channel,
       count(*) as registered,
       count(case when deposits >= 1 then 1 end) as first_dep,
       count(case when deposits >= 2 then 1 end) as second_dep,
       count(case when deposits >= 3 then 1 end) as third_dep,
       round(count(case when deposits >= 1 then 1 end) * 100.0 / count(*), 1) as pct_to_first
from dep_count
group by acquisition_channel
order by pct_to_first desc;
