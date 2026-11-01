-- Net revenue per acquired player, by channel
--
-- Question: which acquisition channel brings players who actually leave
-- money behind — deposits minus withdrawals?
--
-- Two sum(case ...) in one pass instead of two separate joins: both
-- figures come from the same table, split only by transaction type.
--
-- else 0 matters here. Without it a player with no withdrawals would
-- give NULL on the second sum, and the subtraction would return NULL
-- instead of their deposits.
--
-- left join keeps players who never transacted. They contribute 0 and
-- stay in the denominator, so a channel with poor conversion is not
-- flattered by averaging over depositors only.

with player_net as (
    select p.player_id,
           p.acquisition_channel,
           sum(case when t.type = 'deposit' then t.amount else 0 end)
         - sum(case when t.type = 'withdrawal' then t.amount else 0 end) as net
    from players p
    left join transactions t on p.player_id = t.player_id
    group by p.player_id, p.acquisition_channel
)
select acquisition_channel,
       count(*) as players,
       round(sum(net), 2) as net_total,
       round(avg(net), 2) as net_per_player
from player_net
group by acquisition_channel
order by net_per_player desc;
