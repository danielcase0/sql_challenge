-- Data Analysis Part 1
-- Question: How can you isolate (or group) the transactions of each cardholder?
-- Answer: The following query generates a variety of summary information about each card number
-- The result is ordered in descending order by standard deviation, which highlights anomalous account activity
select t.credit_card_number
	, CAST(count(t.transaction_id) as INT) as number_of_transactions
	, CAST(avg(t.transaction_amount) as NUMERIC(11,2)) as average_transaction_amount
	, CAST(stddev(t.transaction_amount) as NUMERIC(11,2)) as transaction_standard_deviation
	, min(t.transaction_amount) as minimum_transaction_amount
	, max(t.transaction_amount) as maximum_transaction_amount
from transaction t
group by 1,2
order by 4 desc;

-- Question: Count the transactions that are less than $2.00 per cardholder.
-- Answer: The following query counts the number of transactions for each card that are less than $2.00
select t.credit_card_number
	, CAST(count(t.transaction_id) as INT) as number_of_transactions
from transaction t
where t.transaction_amount < 2
group by 1
order by 2 desc;

-- Question: What are the top 100 highest transactions made between 7:00 am and 9:00 am?
-- Answer: The following query retrieves the 100 largest transactions made between 7 and 9 AM on any day
select t.*
	, m.merchant_name
	, mc.merchant_type
from transaction t
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where cast(t.transaction_time as time) between '07:00:00' and '09:00:00'
order by 3 desc
limit 100;

-- Investigating specific card numbers
select t.*
	, m.merchant_name
	, mc.merchant_type
	, cast(t.transaction_time as time) as time_of_day
from transaction t
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where credit_card_number =
	4761049645711555811
	--5570600642865857
	--4319653513507
	--376027549341849
	--584226564303
order by 2 asc;

-- Question: Is there a higher number of fraudulent transactions made during this time frame versus the rest of the day?
-- Answer: Not really.  Large purchases are made throughout the day, and the only evidence that they're fraudulent is that they're made at odd hours for certain types of merchants.
select t.*
	, m.merchant_name
	, mc.merchant_type
	, cast(t.transaction_time as time) as time_of_day
from transaction t
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where t.transaction_amount > 500
order by 8 asc;

-- Relating small purchases to large purchases:
select t.credit_card_number
	, t.transaction_amount as large_transaction_amount
	, t.transaction_time as large_transaction_time
	, m.merchant_name as large_transaction_merchant
	, mc.merchant_type as large_transaction_merchant_type
	, t2.transaction_amount as small_transaction_amount
	, t2.transaction_time as small_transaction_time
	, m2.merchant_name as small_transaction_merchant
	, mc2.merchant_type as small_transaction_merchant_type
from transaction t
inner join transaction t2
	on t2.transaction_id =
		(Select subq.transaction_id
		 from transaction subq
		 where subq.credit_card_number = t.credit_card_number
		 	and subq.transaction_amount < 2
-- 		 	and subq.merchant_id = t.merchant_id
-- 		 	and subq.transaction_time < t.transaction_time
		 	and (subq.transaction_time between (t.transaction_time - interval '7 days') and t.transaction_time)
		 order by subq.transaction_time desc
		 limit 1
		)
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
left join merchant m2
	on m2.merchant_id = t2.merchant_id
left join merchant_category mc2
	on mc2.merchant_category_id = m2.merchant_category_id
where t.transaction_amount > 1000;

-- Question: What are the top 5 merchants prone to being hacked using small transactions?
-- Answer: This query returns the number of small transactions (<$2) by merchant
select m.merchant_name
	, mc.merchant_type
	, CAST(count(t.transaction_id) as INT) as number_of_small_transactions
from transaction t
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where t.transaction_amount < 2
group by 1, 2
order by 3 desc;

-- Create Views for each of the queries:
DROP VIEW IF EXISTS card_summary;

CREATE VIEW card_summary as
select t.credit_card_number
	, CAST(count(t.transaction_id) as INT) as number_of_transactions
	, CAST(avg(t.transaction_amount) as NUMERIC(11,2)) as average_transaction_amount
	, CAST(stddev(t.transaction_amount) as NUMERIC(11,2)) as transaction_standard_deviation
	, min(t.transaction_amount) as minimum_transaction_amount
	, max(t.transaction_amount) as maximum_transaction_amount
from transaction t
group by 1
order by 4 desc;

DROP VIEW IF EXISTS small_transactions_by_card_number;

CREATE VIEW small_transactions_by_card_number as
select t.credit_card_number
	, CAST(count(t.transaction_id) as INT) as number_of_transactions
from transaction t
where t.transaction_amount < 2
group by 1
order by 2 desc;

DROP VIEW IF EXISTS largest_transactions_between_seven_and_nine_am;

CREATE VIEW  largest_transactions_between_seven_and_nine_am as
select t.*
	, m.merchant_name
	, mc.merchant_type
from transaction t
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where cast(t.transaction_time as time) between '07:00:00' and '09:00:00'
order by 3 desc
limit 100;

DROP VIEW IF EXISTS largest_transactions_throughout_the_day;

CREATE VIEW largest_transactions_throughout_the_day as
select t.*
	, m.merchant_name
	, mc.merchant_type
	, cast(t.transaction_time as time) as time_of_day
from transaction t
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where t.transaction_amount > 500
order by 8 asc;

DROP VIEW IF EXISTS small_transactions_by_merchant;

CREATE VIEW small_transactions_by_merchant as
select m.merchant_name
	, mc.merchant_type
	, CAST(count(t.transaction_id) as INT) as number_of_small_transactions
from transaction t
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where t.transaction_amount < 2
group by 1, 2
order by 3 desc;



-- Data Analysis Part 2
-- Transactions for cardholder 2
-- Note that cardholder 2 has two credit cards
Select cc.cardholder_id
	, t.*
	, m.merchant_name
	, mc.merchant_type
from credit_card cc
left join transaction t
	on t.credit_card_number = cc.credit_card_number
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where cc.cardholder_id = 2
-- 	and credit_card_number = 4866761290278198714
-- 	and credit_card_number = 675911140852
order by 3 asc;

-- Transactions for cardholder 18
-- Note that cardholder 18 has two credit cards
Select cc.cardholder_id
	, t.*
	, m.merchant_name
	, mc.merchant_type
from credit_card cc
left join transaction t
	on t.credit_card_number = cc.credit_card_number
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where cc.cardholder_id = 18
-- 	and credit_card_number = 4498002758300
-- 	and credit_card_number = 344119623920892
order by 3 asc;

-- Transactions for cardholder 25
-- Note that cardholder 25 has two credit cards
Select cc.cardholder_id
	, t.*
	, m.merchant_name
	, mc.merchant_type
from credit_card cc
left join transaction t
	on t.credit_card_number = cc.credit_card_number
left join merchant m
	on m.merchant_id = t.merchant_id
left join merchant_category mc
	on mc.merchant_category_id = m.merchant_category_id
where cc.cardholder_id = 25
-- 	and credit_card_number = 4319653513507
-- 	and credit_card_number = 372414832802279
order by 3 asc;