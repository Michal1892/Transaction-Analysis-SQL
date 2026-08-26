create or replace view with_frauds as (
select t.id,
t.date,
t.card_id,
replace(trim(t.amount),'$', '')::numeric(10,2) as amount,
t.merchant_city,
t.merchant_state,
t.mcc,
t.errors,
t.client_id,
t.use_chip,
t.merchant_id,
f.is_fraud
from transactions t left join frauds f
on t.id = f.transaction_id);

--procent fraudow w zbiorze--
select is_fraud,
count(*) how_many,
round((count(*)::numeric(10,2)/(select count(*) from with_frauds)::numeric(10,2)),2) as percentage
from with_frauds
group by is_fraud;

--czy dla fraudow tranzakcje byly na wieksza kwote--
select is_fraud,
round(avg(amount),1) as average
from with_frauds
group by is_fraud;

--ile fraudow dla chipow--
select use_chip,
is_fraud,
count(*)
from with_frauds
group by use_chip, is_fraud
having use_chip in ('Online Transaction', 'Chip Transaction');

select 
extract (hour from date) as hour,
count(*)
from with_frauds
where is_fraud = 'Yes' 
group by 1;


--o jakiej porze dnia jest najwięcej fraudow--
select 
case 
	when extract (hour from date) in (22,23,0,1,2,3,4,5) then 'Night'
	when extract (hour from date) between 6 and 10 then 'Morning'
	when extract (hour from date) between 11 and 13 then 'Noon'
	when extract (hour from date) between 14 and 17 then 'Afternoon'
	else 'Evening'
end as day_time,
extract (hour from date) as hour,
count(*),
rank() over(
partition by case 
	when extract (hour from date) in (22,23,0,1,2,3,4,5) then 'Night'
	when extract (hour from date) between 6 and 10 then 'Morning'
	when extract (hour from date) between 11 and 13 then 'Noon'
	when extract (hour from date) between 14 and 17 then 'Afternoon'
	else 'Evening'
end
order by count(*) desc) as rank_by_time_of_day,
rank() over(
order by count(*) desc) as global_rank
from with_frauds
group by 1,2
order by hour;


--czy istnieją mcc szczegolnie narazone na fraud--
select mcc,
count(*)
from with_frauds
where is_fraud = 'Yes'
group by mcc
order by count(*) desc;

--rozklad ile jest fraudow w kartach bez chipa i z chipem--
select  two.has_chip, 
two.is_fraud,
round(two.chip_if_fraud::numeric(10,2)/one.all_chips::numeric(10,2),5)*100 as fraud_percentage_in_chip_category
from
(select  c.has_chip,
f.is_fraud,
count(*) as chip_if_fraud
from with_frauds f
join cards c
on f.card_id = c.id 
where f.is_fraud in ('No', 'Yes')
group by c.has_chip, f.is_fraud) two
join 
(select c.has_chip,
count(*) as all_chips
from cards c
join with_frauds f
on c.id = f.card_id
group by has_chip) one
on one.has_chip = two.has_chip;


--klienci o jakim score sa najczesciej ofiarami fraudow--
select 
case 
	when u.credit_score <= (select percentile_disc(1.0/3) within group (order by u2.credit_score) from users u2)
	then 'Low'
	when u.credit_score <= (select percentile_disc(2.0/3) within group (order by u2.credit_score) from users u2)
	then 'Mid'
	else 'High'
end as credit_score_category,
count(*) 
from with_frauds f 
join users u
on u.id = f.client_id
where is_fraud = 'Yes'
group by 1
order by 2 desc;

--10 klientow z najwieksza liczba fraudow--
select client_id,
count(*) number_of_frauds
from with_frauds
where is_fraud = 'Yes'
group by client_id
having count(*) >= 2
order by count(*) desc
limit 10;

--rozklad liczby fraudow wzgledem stanow--
select merchant_state,
count(*) number_of_frauds
from with_frauds
where is_fraud = 'Yes' and length(merchant_state) <= 2
group by merchant_state
order by count(*) desc;

select
is_fraud,
sum(case
	when errors is null then 0
	else 1
end) as sum_of_errors,
round(sum(case
	when errors is null then 0
	else 1
end)::numeric(10,2)*100/count(*)::numeric(10,2),1) as percentage_of_errors
from with_frauds
group by is_fraud
order by 2 desc;

--srednia ilosc dni miedzy tranzakcjami dla kart dla ktorych wystapił co najmniej raz fraud--
select 
is_fraud,
round(avg(extract(day from (date-last_operation))),2) as avg_days_between_transactions
from
(select card_id,
date,
is_fraud,
lag(date) over(
	partition by card_id
	order by date) as last_operation
from with_frauds) one
join 
(select
sum(case
	when is_fraud = 'Yes' then 1
	when is_fraud = 'No' then 0
	else 0
end) as sum_of_frauds_for_card,
card_id
from with_frauds
group by card_id) two
on one.card_id = two.card_id
where sum_of_frauds_for_card !=0
group by is_fraud;


--dla danej karty liczba dni od ostaniej operacji--
select card_id,
extract(day from date-last_operation) as days_from_last_operation,
is_fraud
from(
select card_id,
date,
is_fraud,
lag(date) over(
	partition by card_id
	order by date) as last_operation
from with_frauds);