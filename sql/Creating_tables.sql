create table users (
id int primary key,
current_age int not null check(current_age between 16 and 120),
retirement_age int check(retirement_age between 18 and 120),
birth_year int check(birth_year > 1906),
gender varchar(6) check(lower(gender) = 'male' or lower(gender) = 'female'),
address text,
latitude decimal(9,6) check(latitude between -90 and 90),
longitude decimal(9,6) check(longitude between -180 and 180),
per_capita_income text,
yearly_income text,
total_debt text,
credit_score int,
num_credit_cards int
);

create table cards (
id int primary key,
client_id int,
constraint fk_client_id foreign key (client_id) references users(id) on delete cascade,
card_brand text not null,
card_type text,
card_number bigint not null unique,
expires varchar(7) ,
cvv int,
has_chip varchar(3) check(lower(has_chip) in ('yes', 'no')),
num_cards_issued int,
credit_limit text,
acct_open_date varchar(7),
year_pin_last_changed int check(year_pin_last_changed >= 1906),
card_on_dark_web varchar(3) check(lower(card_on_dark_web) in ('yes', 'no'))
);

create table transactions(
id int primary key,
date timestamp check(date <= current_timestamp),
card_id int,
constraint fk_card_id foreign key (card_id) references cards(id) on delete cascade,
amount text,
merchant_city text,
merchant_state text,
zip decimal(6,1),
mcc int,
errors text
);



create table frauds(
 transaction_id int not null,
 is_fraud varchar(3) check(lower(is_fraud) in ('no', 'yes')))
 

 
