-- Cohort retention by registration month
--
-- Question: what share of each registration cohort comes back with a
-- deposit in the first and second month after signing up?
--
-- timestampdiff(month, ...) gives the distance between registration and
-- each deposit: 0 is the signup month, 1 the next, and so on.
--
-- count(distinct ... player_id ...) rather than count(... 1 ...): a player
-- with two deposits in the same month must still count once.
--
-- Note on the output: cohorts from April to December 2022 return zero in
-- both columns because those players have almost no deposits in this
-- dataset, and 2023 cohorts have an incomplete observation window — the
-- data ends 21 May 2023. See README.

select date_format(p.registration_date, '%Y-%m') as cohort,
       count(distinct p.player_id) as registered,
       round(count(distinct case when timestampdiff(month, p.registration_date, t.transaction_date) = 1
                                 then p.player_id end) * 100.0
             / count(distinct p.player_id), 1) as pct_m1,
       round(count(distinct case when timestampdiff(month, p.registration_date, t.transaction_date) = 2
                                 then p.player_id end) * 100.0
             / count(distinct p.player_id), 1) as pct_m2
from players p
left join transactions t on p.player_id = t.player_id and t.type = 'deposit'
group by cohort
order by cohort;
