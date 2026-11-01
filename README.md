# iGaming CRM Analysis

SQL analysis of player behaviour for a CRM team: who churns, which acquisition channel pays off, how cohorts retain, and which players are worth a personal campaign.

**Data:** synthetic iGaming dataset — 50 players, 85 transactions, 78 daily activity records, January 2022 to May 2023. Built for practice, so the numbers illustrate the method rather than a real operation. Limitations are listed at the bottom.

**Stack:** MySQL 8.

---

## Dataset

| Table | Grain | Key columns |
|---|---|---|
| `players` | one row per player | registration_date, country, acquisition_channel, segment |
| `transactions` | one row per transaction | transaction_date, amount, type (deposit / withdrawal) |
| `activity` | one row per player per day | sessions, bets_placed, total_bet_amount, total_win_amount |

Setup script: [`schema.sql`](schema.sql).

---

## Findings

### 1. Churn is concentrated in three people

[`01_churn_by_segment.sql`](01_churn_by_segment.sql)

Players whose last deposit falls before December 2022, by segment.

| Segment | Churned players | Revenue lost |
|---|---|---|
| High Value | 3 | €13,200 |
| Mid Value | 4 | €2,575 |
| Low Value | 8 | €660 |

Low Value accounts for more than half the churned players and 4% of the lost revenue. High Value is three people and 80% of it.

**For a CRM team:** size the reactivation campaign by money, not by headcount. A personal approach to three High Value players is worth the effort; a mass send to eight Low Value players averaging €82 each is not.

### 2. First-deposit conversion says nothing about channel quality

[`02_deposit_funnel_by_channel.sql`](02_deposit_funnel_by_channel.sql)

| Channel | Registered | 1st deposit | 2nd | 3rd | % to 1st |
|---|---|---|---|---|---|
| Organic | 16 | 12 | 4 | 4 | 75.0 |
| Email | 9 | 5 | 5 | 4 | 55.6 |
| Paid Search | 15 | 7 | 6 | 2 | 46.7 |
| Affiliate | 10 | 4 | 4 | 3 | 40.0 |

Organic leads the first step and collapses at the second: 12 depositors, 4 of them deposit again. Email is the opposite — fewer players convert, but every one who deposits once deposits twice.

**For a CRM team:** a channel judged on first-deposit conversion looks nothing like the same channel judged two steps later.

### 3. Revenue per acquired player varies 5.5x

[`05_net_revenue_by_channel.sql`](05_net_revenue_by_channel.sql)

Deposits minus withdrawals, averaged across everyone the channel brought in — including players who never deposited.

| Channel | Players | Net total | Net per player |
|---|---|---|---|
| Email | 9 | €7,190 | €798.89 |
| Affiliate | 10 | €6,620 | €662.00 |
| Organic | 16 | €5,240 | €327.50 |
| Paid Search | 15 | €2,190 | €146.00 |

This confirms finding 2 in money. Organic brings the most paying players and ranks third on value per player. Email brings fewer and ranks first.

**Caveat:** without acquisition cost this is revenue, not ROI. Paid Search costs money per player and Organic nearly nothing, so the ranking could change once CAC is included.

### 4. Two independent methods agree on the same three players

[`04_rfm_segmentation.sql`](04_rfm_segmentation.sql)

RFM splits depositors into quartiles by recency, frequency and monetary value. The 28 depositors spread across 19 combinations, so most cells hold one to three people — quartiles blur distinctions on a base this small.

One cell is worth reading anyway. **R3-F1-M1** — three players who sit in the top quartile for both frequency and spend but have not deposited recently — turns out to be players 1, 4 and 7: exactly the three High Value churners from finding 1. Their deposit totals (€3,400 + €4,400 + €5,400) reconstruct the €13,200 in that table.

Two different approaches, a date cutoff and quartile ranking, landed on the same people and reconciled to the euro.

**On the method:** RFM quartiles are relative, so a player can move groups without any real change in behaviour. On a production base, absolute thresholds — no deposit in 30/60/90 days, deposit above €500 — are usually more stable.

### 5. Cohort retention: the data says no

[`03_cohort_retention.sql`](03_cohort_retention.sql)

Share of each registration cohort that deposits again in month 1 and month 2.

The query runs, but the output is not usable, and that is the finding:

- Cohorts from April to December 2022 return 0% in both columns — nine consecutive months. Those players have almost no deposits in the dataset at all, so this is a gap in the generated data, not a retention collapse.
- 2023 cohorts have an incomplete observation window. A player registered in March needs a May deposit to count for month 2, and the data ends on 21 May 2023.
- Cohort sizes are one to four players, so a single person moves the rate by 25–33 points.

Reported as-is rather than dropped: checking whether the data can support the question is part of the work.

---

## Data limitations

- Synthetic data, 50 players. Percentages move several points per player; treat them as illustrations of method.
- Deposit activity is sparse between April and December 2022.
- No acquisition cost, so channel comparisons are revenue, not ROI.
- The observation window ends 21 May 2023, which truncates the most recent cohorts.

## Files

| File | What it does |
|---|---|
| [`schema.sql`](schema.sql) | creates and populates the three tables |
| [`01_churn_by_segment.sql`](01_churn_by_segment.sql) | churned players and lost revenue by segment |
| [`02_deposit_funnel_by_channel.sql`](02_deposit_funnel_by_channel.sql) | registration to third deposit, by channel |
| [`03_cohort_retention.sql`](03_cohort_retention.sql) | month-1 and month-2 return rate by registration cohort |
| [`04_rfm_segmentation.sql`](04_rfm_segmentation.sql) | RFM scores per player, plus a rollup by combination |
| [`05_net_revenue_by_channel.sql`](05_net_revenue_by_channel.sql) | net revenue per acquired player, by channel |
