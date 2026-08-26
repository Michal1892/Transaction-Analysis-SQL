--srednia kwota tranzakcji miesiecznie--
select extract(month from date) as month,
sum(replace(trim(amount), '$','')::numeric(10,2))
from transactions
group by month;

--srednia kwota tranzakcji rocznie--
select extract (year from date) as year,
avg(replace(trim(amount), '$','')::numeric(10,2))
from transactions
group by year;


select merchant_city, amount,
dense_rank() over(partition by merchant_city
			order by replace(trim(amount),'$','')::numeric(10,2)) as biggest_order
from transactions;

--ranking klientow wedlug sumy wydatkow w obrebie kazdego stanu--
select merchant_state,
client_id,
sum(replace(trim(amount),'$','')::numeric(10,2)) as sum_of_transactions,
dense_rank() over(partition by merchant_state 
					order by sum(replace(trim(amount),'$','')::numeric(10,2)) desc)
from transactions 
group by merchant_state, client_id;


--srednia kroczaca wydatkow dla wybranyc klientow--
select client_id, 
date,
replace(trim(amount),'$','')::numeric(10,2) as value,
sum(replace(trim(amount),'$','')::numeric(10,2)) over (
partition by client_id
order by date 
)
from transactions
where client_id in (1556, 561, 1129)
order by client_id;

--ranking wedlug srednich wydatkow wzgledem chip z podzialem na card_brand--
select t.use_chip,
c.card_brand,
round(avg(replace(trim(t.amount),'$','')::numeric(10,2)),1) as average_spent,
dense_rank() over(
partition by t.use_chip
order by avg(replace(trim(t.amount),'$','')::numeric(10,2)) desc) as chip_ranking
from transactions t 
join cards c on t.card_id = c.id  
group by t.use_chip , c.card_brand ;


--srednia kroczaca wzgledem daty z podziałem na card_brand--
select c.card_brand,
t.date,
replace(trim(t.amount), '$','')::numeric(10,2) as amount,
round(avg(replace(trim(t.amount), '$','')::numeric(10,2)) over(
partition by card_brand
order by date
),2) as average_over_time
from transactions t
join cards c
on t.card_id =c.id ;

--tranzakcje nie mieszczace sie w przedziale srednia +- 3*odchylenie standardowe--
select client_id,
card_id,
replace(trim(amount), '$','')::numeric(10,2)
from transactions
where replace(trim(amount), '$','')::numeric(10,2) not between
	(select avg(replace(trim(amount), '$','')::numeric(10,2)) from transactions)- 
	3*(select stddev(replace(trim(amount), '$','')::numeric(10,2)) from transactions)
and
	(select avg(replace(trim(amount), '$','')::numeric(10,2)) from transactions)+
	3*(select stddev(replace(trim(amount), '$','')::numeric(10,2)) from transactions);

--dzien poprzedzajacych transakcji dla danej karty--
select card_id,
date, 
last_transaction,
case 
	when last_transaction is null then null
	else (date-last_transaction)
end as days_from_last_transaction
from
(select date,
card_id,
lag(date) over(
partition by card_id
order by date) as last_transaction
from transactions);

--ile minelo miedzy ostatnim platnosciami dla danej karty--
select  card_id ,
max(date),
max(last_transaction),
extract(day from max(date) - max(last_transaction)) as days_from_last_transaction
from 
(select card_id,
date,
lag(date) over(
partition by card_id
order by date) as last_transaction
from transactions)
group by card_id;

--ile dni minelo od ostatniej tranzakcji--
select card_id,
extract(day from current_timestamp- max(date)) as days_from_last_transaction
from  transactions
group by card_id ;




