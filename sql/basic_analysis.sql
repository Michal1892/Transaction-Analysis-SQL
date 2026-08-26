create or replace view users_num as
select id, 
current_age, 
retirement_age,
birth_year, gender, 
address, latitude, 
longitude, 
replace(trim(per_capita_income), '$', '')::int as per_capita_income,
replace(trim(yearly_income), '$', '')::int as yearly_income,
replace(trim(total_debt), '$', '')::int as total_debt,
credit_score, 
num_credit_cards,
birth_month from users;

--podział userów na wiek--

select current_age, count(*) as number_of_users from users_num group by current_age order by current_age;

--sredni yearly_inocme oraz debt--

select round(avg(yearly_income),0) as average_income,
round(avg(total_debt),0) as average_total_debt
from users_num;

-- sredni income wzgledem wieku--
select gender,
round(avg(yearly_income),0) as average_income
from users_num group by gender
order by gender desc;

--sredni income wzgledem wieku dla osob ktorych dlug przekracza sredni dlug--
select gender,
round(avg(yearly_income),0) as average_income
from users_num 
where total_debt >= (select avg(total_debt) from users_num)
group by gender
order by average_income desc;

--ile typow kart wydano dla konkretnej marki karty--
select card_brand,
card_type,
count(*) as number_of_cards,
round(count(*)*100/(select count(*) from cards),2)/100 as percentage_of_whole
from cards cards
group by card_brand, card_type
order by card_brand, card_type desc;


--karty ktore nie maja chipow wraz z procentem kart nie majacych chipu w obrebie danej brand--
select hsn.card_brand,
hsn.number_of_cards,
round(hsn.number_of_cards*100 /ac.all_brand_cards,2)/100 as percentage_no_chip_cards_in_brand 
from (select card_brand,
count(*) as number_of_cards
from cards 
where lower(has_chip) = 'no'
group by card_brand) hsn 
join 
(select card_brand,
count(*) as all_brand_cards from cards
group by card_brand) ac 
on hsn.card_brand = ac.card_brand;  

--średnia kwota transakcji na mcc--
select  mcc,
round(avg(replace(trim(amount), '$', '')::numeric(10,2)),0)
from transactions 
group by mcc;

--suma wartości transakcji nie w USA--
select merchant_state,
round(sum(replace(trim(amount), '$', '')::numeric(10,2)),0) as value_of_transactions
from transactions
group by merchant_state
having merchant_state is not null and length(merchant_state)>2
order by value_of_transactions desc;


--10 klientow z najwieksza iloscia zamowien oraz ich wiek i calkowity dlug--
select u.id, ot.number_of_transactions, u.total_debt, u.current_age  from
(select client_id,
count(*) as number_of_transactions
from transactions 
where use_chip = 'Online Transaction'
group by client_id 
order by  number_of_transactions desc 
limit 10) ot
join users u
on ot.client_id = u.id
order by total_debt desc;



--średnia wartosc transakcji i sredni wiek ze wzgledu na kraj--
select 
case
when length(t.merchant_state) <= 2 then 'US'
when t.merchant_state is null then 'Unknown'
else 'Other countries'
end as country,
round(avg(u.current_age),2) as average_age,
round(avg(replace(trim(t.amount), '$', '')::numeric(10,2)),0) as average_transaction
from transactions t 
join users u
on t.client_id = u.id
group by country
order by average_transaction desc;


select min(credit_score), max(credit_score),  avg(credit_score) from users;
select * from users;

--srednie wydatki transakcyjne ze wzgledu na credit score--
select 
case 
	when u.credit_score <= (select PERCENTILE_DISC(1.0/3) within group(order by u2.credit_score) from users u2)
	then 'Low'
	when u.credit_score <= (select PERCENTILE_DISC(2.0/3) within group(order by u2.credit_score) from users u2)
	then 'Mid'
	else 'High'
end as credit_score_level,
round(sum(replace(trim(t.amount), '$','')::numeric(10,2)),0) as transaction_value,
round(avg(replace(trim(t.amount), '$','')::numeric(10,2)),1) as avg_transaction_value
from users u
join transactions t 
on u.id = t.client_id
group by credit_score_level
order by avg_transaction_value desc;





