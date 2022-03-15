Create Table users (user_id int, action char(20), date char(50)); 

INSERT INTO users (user_id, action, date) 
VALUES 
(1,'start', '01-01-20'), 
(1,'cancel', '01-02-20'), 
(2,'start', '01-03-20'), 
(2,'publish', '01-04-20'), 
(3,'start', '01-05-20' ), 
(3,'cancel', '01-06-20' ), 
(1,'start', '01-07-20' ), 
(1,'publish', '01-08-20');

SELECT * FROM users;

With cte as( SELECT user_id,
Sum(case when action = 'start' then 1 else 0 end) As starts,
Sum(case when action = 'cancel' then 1 else 0 end) As cancels,
Sum(case when action = 'publish'then 1 else 0 end) AS publishes
From users
Group by user_id
Order by user_id)
Select user_id, 
Round(1.0*publishes/starts::decimal, 2) as publish_rate,
Round(1.0*cancels/starts::decimal, 2) as cancel_rates from cte;

Create table transactions (sender int, receiver int, amount int, transaction_date varchar(25));

Insert into transactions Values
(5, 2, 10, '2-12-20'),
(1, 3, 15, '2-13-20'), 
(2, 1, 20, '2-13-20'), 
(2, 3, 25, '2-14-20'), 
(3, 1, 20, '2-15-20'), 
(3, 2, 15, '2-15-20'), 
(1, 4, 5, '2-16-20');

Select * From transactions;

With debits as( Select sender, sum(amount) as debited
From transactions
Group by sender),

credits as ( Select receiver, sum(amount) as credited
From transactions
Group by receiver)

Select coalesce(sender, receiver) as user,
coalesce(credited, 0) - coalesce(debited, 0) as net_change
From debits d
Full join credits c
On d.sender = c.receiver
Order by net_change desc;

Create table items(date char(50), item char(20));

Insert into items(date, item) Values
('01-01-20','apple'), 
('01-01-20','apple'), 
('01-01-20','pear'), 
('01-01-20','pear'), 
('01-02-20','pear'), 
('01-02-20','pear'), 
('01-02-20','pear'), 
('01-02-20','orange');

With cte as (Select *, count(*) as item_count from items
group by date, item
order by date),
cte2 as( Select *, rank() over (partition by date order by item_count desc) as date_rank from cte)
Select date, item from cte2 where date_rank = 1;

Create table users(users_id int, action char(25), action_date date);

Insert into users (users_id, action, action_date) Values
(1, 'start', '2-12-20'), 
(1, 'cancel', '2-13-20'), 
(2, 'start', '2-11-20'), 
(2, 'publish', '2-14-20'), 
(3, 'start', '2-15-20'), 
(3, 'cancel', '2-15-20'), 
(4, 'start', '2-18-20'), 
(1, 'publish', '2-19-20');

With cte as (Select *, row_number() over (partition by users_id order by action_date desc) as date_rank from users),
cte2 as (Select * from cte where date_rank = 1),
cte3 as (Select * from cte where date_rank = 2)
Select cte2.users_id, (cte2.action_date - cte3.action_date) as days_elapsed from cte2 
left join cte3 on cte2.users_id = cte3.users_id;

Create table users(user_id int, product_id int, transaction_date date);

Insert into users(user_id, product_id, transaction_date) values
(1, 101, '2-12-20'), 
(2, 105, '2-13-20'), 
(1, 111, '2-14-20'), 
(3, 121, '2-15-20'), 
(1, 101, '2-16-20'), 
(2, 105, '2-17-20'),
(4, 101, '2-16-20'), 
(3, 105, '2-15-20');

With cte as (Select *, row_number() over (partition by user_id order by transaction_date asc) as transaction_number from users),

cte2 as (Select user_id, transaction_date from cte where transaction_number = 2),

cte3 as (select distinct user_id from users)

Select cte3.user_id, transaction_date as superuser_date from cte3 left join cte2 on cte3.user_id = cte2.user_id order by transaction_date;

Create Table friends (user_id int, friend int);

Insert into friends (user_id, friend) values
(1, 2), (1, 3), (1, 4), (2, 1), (3, 1), (3, 4), (4, 1), (4, 3);

Create Table likes (user_id int, page_likes char(1));

Insert into likes (user_id, page_likes) values
(1, 'A'), (1, 'B'), (1, 'C'), (2, 'A'), (3, 'B'), (3, 'C'), (4, 'B');

With cte as (Select l.user_id, l.page_likes, f.friend from likes l inner join friends f on l.user_id = f.user_id),
cte2 as (Select cte.user_id, cte.page_likes, cte.friend, l.page_likes as friend_likes from cte left join likes l
on cte.friend = l.user_id and cte.page_likes = l.page_likes)
Select distinct friend as user_id, page_likes as recommended_page from cte2 where friend_likes is null order by friend;

Create table mobile (user_id int, page_url char(1));

Insert into mobile (user_id, page_url) values
(1, 'A'), (2, 'B'), (3, 'C'), (4, 'A'), (9, 'B'), (2, 'C'), (10, 'B');

Create table web (user_id int, page_url char(1));

Insert into web (user_id, page_url) values
(6, 'A'), (2, 'B'), (3, 'C'), (7, 'A'), (4, 'B'), (8, 'C'), (5, 'B');

With cte as (Select distinct m.user_id as mobile_user, w.user_id as web_user from mobile m full join web w on m.user_id = w.user_id),
cte2 as (Select sum (case when mobile_user is not null and web_user is null then 1 else 0 end) as n_mobile,
		sum (case when web_user is not null and mobile_user is null then 1 else 0 end) as n_web,
		sum(case when web_user is not null and mobile_user is not null then 1 else 0 end) as n_both,
		count(*) as n_total from cte)
Select round(1.0* n_mobile/n_total::decimal, 2) as mobile_fraction,
round(1.0* n_web/n_total::decimal, 2) as web_fraction,
round(1.0* n_both/n_total::decimal, 2) as both_fraction from cte2;

Create table friends(user1 int, user2 int);

Insert into friends (user1, user2) values
(1, 2), (1, 3), (1, 4), (2, 3);

With cte as (Select user1 as user_id from friends union all
Select user2 as user_id from friends)
Select user_id, count(*) as friend_count from cte group by user_id order by user_id;

Create table users (user_id int, name char(20), join_date date);

Insert into users (user_id, name, join_date) values
(1, 'Jon', '2-14-20'), 
(2, 'Jane', '2-14-20'), 
(3, 'Jill', '2-15-20'), 
(4, 'Josh', '2-15-20'), 
(5, 'Jean', '2-16-20'), 
(6, 'Justin', '2-17-20'),
(7, 'Jeremy', '2-18-20');

Create table events (user_id int, type varchar(3), access_date date);

Insert into events (user_id, type, access_date) values
(1, 'F1', '3-1-20'), 
(2, 'F2', '3-2-20'), 
(2, 'P', '3-12-20'),
(3, 'F2', '3-15-20'), 
(4, 'F2', '3-15-20'), 
(1, 'P', '3-16-20'), 
(3, 'P', '3-22-20');

Select * from events;

Select user_id, type, access_date as F2_date from events where type = 'F2';

Select user_id, type, access_date as F2_date from events where type = 'P';

With cte as (Select user_id, type, access_date as F2_date from events where type = 'F2'),
cte2 as (Select user_id, type, access_date as P_date from events where type = 'P'),
cte3 as (Select (cte2.P_date - users.join_date) as upgrade_time from users
		 inner join cte on users.user_id = cte.user_id
		 left join cte2 on users.user_id = cte2.user_id)
Select round (1.0 * sum (case when upgrade_time < 30 then 1 else 0 end)/count(*)::decimal, 2) as upgrade_rate from cte3;

Create table projects (task_id int, start_date date, end_date date);

Insert into projects (task_id, start_date, end_date) values
(1, '10-01-20', '10-02-20'), 
(2, '10-02-20', '10-03-20'), 
(3, '10-03-20', '10-04-20'), 
(4, '10-13-20', '10-14-20'), 
(5, '10-14-20', '10-15-20'), 
(6, '10-28-20', '10-29-20'), 
(7, '10-30-20', '10-31-20');

With cte as (Select start_date from projects where start_date not in (Select end_date from projects)),
cte2 as (Select end_date from projects where end_date not in (Select start_date from projects)),
cte3 as (Select start_date, min(end_date) as end_date from cte, cte2 where start_date < end_date group by start_date)
Select *, (end_date - start_date) as project_duration from cte3 order by project_duration, start_date;

Create table attendence (student_id int, school_date date, attendence integer);

Insert into attendence (student_id, school_date, attendence) values
(1, '2020-04-03', 0),
(2, '2020-04-03', 1),
(3, '2020-04-03', 1), 
(1, '2020-04-04', 1), 
(2, '2020-04-04', 1), 
(3, '2020-04-04', 1), 
(1, '2020-04-05', 0), 
(2, '2020-04-05', 1), 
(3, '2020-04-05', 1), 
(4, '2020-04-05', 1);

Create table students (student_id int, school_id int, grade_level int, date_of_birth date);

Insert into students (student_id, school_id, grade_level, date_of_birth) values
(1, 2, 5, '2012-04-03'),
(2, 1, 4, '2013-04-04'),
(3, 1, 3, '2014-04-05'),
(4, 2, 4, '2013-04-03');

With cte as (Select * from attendence inner join students on attendence.student_id = students.student_id
			and extract (month from school_date) = extract (month from date_of_birth)
			and extract (day from school_date) = extract (day from date_of_birth))
Select round (1.0 * sum (attendence)/count(*):: decimal, 2) as birthday_attendence from cte;

Create table hackers (hacker_id int, name char(20));

Insert into hackers (hacker_id, name) values
(1, 'John'),
(2, 'Jane'),
(3, 'Joe'),
(4, 'Jim');

Create table submissions (submission_id int, hacker_id int, challenge_id int, score int);

Insert into submissions (submission_id, hacker_id, challenge_id, score) values
(101, 1, 1, 10),
(102, 1, 1, 12),
(103, 2, 1, 11),
(104, 2, 1, 9),
(105, 2, 2, 13),
(106, 3, 1, 9),
(107, 3, 2, 12),
(108, 3, 2, 15),
(109, 4, 1, 0);

With cte as (Select hacker_id, challenge_id, max(score) as max_score from submissions 
group by hacker_id, challenge_id order by hacker_id, challenge_id)

Select cte.hacker_id, hackers.name, sum (max_score) as total_score from cte 
inner join hackers on cte.hacker_id = hackers.hacker_id group by cte.hacker_id, hackers.name
having sum(max_score) > 0
order by total_score desc, hacker_id asc;

Create table scores (id int, score decimal);

Insert into scores (id, score) values
(1, 3.50),
(2, 3.65),
(3, 4.00),
(4, 3.85),
(5, 4.00),
(6, 3.65);

Select s1.score, count(Distinct s2.score) as score_rank from scores s1 
inner join scores s2 on s1.score  <= s2.score
group by s1.id, s1.score
order by s1.score desc;

Create table employee (id int, pay_month int, salary int);

Insert into employee (id, pay_month, salary) values
(1, 1, 20),
(2, 1, 20),
(1, 2, 30),
(2, 2, 30),
(3, 2, 40),
(1, 3, 40),
(3, 3, 60),
(1, 4, 60),
(3, 4, 70);

Select * from employee;

Select *, rank() over (partition by id order by pay_month desc) as month_rank from employee;

With cte as (Select *, rank() over (partition by id order by pay_month desc) as month_rank from employee)
Select id, pay_month, salary, sum (salary) over (partition by id order by month_rank desc) as cumulative_sum from cte
where month_rank != 1 and month_rank <= 4
order by id, pay_month;

Create table teams (team_id int, team_name char(30));

Insert into teams (team_id, team_name) values
(1, 'New York'),
(2, 'Atlanta'),
(3, 'Chicago'),
(4, 'Toronto'),
(5, 'Los Angeles'),
(6, 'Seattle');

Create table matches (match_id int, host_team int, guest_team int, host_goals int, guest_goals int);

Insert into matches values
(1, 1, 2, 3, 0),
(2, 2, 3, 2, 4),
(3, 3, 4, 4, 3),
(4, 4, 5, 1, 1),
(5, 5, 6, 2, 1),
(6, 6, 1, 1, 2);

With cte as (Select *, (case when host_goals > guest_goals then 3
			   when host_goals = guest_goals then 1
			   else 0 end) as host_points,
		(case when guest_goals > host_goals then 3
			 when guest_goals = host_goals then 1
			 else 0 end) as guest_points from matches)
Select t.team_name, (a.host_points + b.guest_points) as total_points from teams t
inner join cte a on t.team_id = a.host_team
inner join cte b on t.team_id = b.guest_team
order by total_points desc, team_name asc;

Create table customers (id int, name char(20));

Insert into customers values
(1, 'Daniel'),
(2, 'Diana'),
(3, 'Elizabeth'),
(4, 'John');

Create table orders (order_id int, customer_id int, product_name char(1));

Insert into orders values
(1, 1, 'A'),
(2, 1, 'B'),
(3, 2, 'A'),
(4, 2, 'B'),
(5, 2, 'C'),
(6, 3, 'A'), 
(7, 3, 'A'),
(8, 3, 'B'),
(9, 3, 'D');

Select distinct id, name from orders o inner join customers c on o.customer_id = c.id
where customer_id in (select customer_id from orders where product_name = 'A') 
and customer_id in (select customer_id from orders where product_name = 'B') 
and customer_id not in (select customer_id from orders where product_name = 'C')
order by id;

Create table stations (id int, city char(50), state char(50), latitude numeric, longitude numeric);

Insert into stations values
(1, 'Asheville', 'North Carolina', 35.6, 82.6),
(2, 'Burlington', 'North Carolina', 36.1, 79.4),
(3, 'Chapel Hill', 'North Carolina', 35.9, 79.1),
(4, 'Davidson', 'North Carolina', 35.5, 80.8),
(5, 'Elizabeth City', 'North Carolina', 36.3, 76.3),
(6, 'Fargo', 'North Dakota', 46.9, 96.8),
(7, 'Grand Forks', 'North Dakota', 47.9, 97.0),
(8, 'Hettinger', 'North Dakota', 46.0, 102.6),
(9, 'Inkster', 'North Dakota', 48.2, 97.6);

Select * from stations;

With cte as (Select *, row_number() over (partition by state order by latitude asc) as latitude_number,
count(*) over (partition by state) as latitude_count from stations)

Select state, round(avg(latitude):: decimal, 2) as median_latitude from cte 
where latitude_number >= 1.0 * latitude_count/2
and latitude_number <= 1.0 *latitude_count/2 + 1
group by state;

