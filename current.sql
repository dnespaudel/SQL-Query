Create table scores (id int, score decimal);

Insert into scores values
(1, 3.50),
(2, 3.65),
(3, 4.00),
(4, 3.85),
(5, 4.00),
(6, 3.65);

Select * from scores;

Select s1.score, count(distinct s2.score) as score_rank from scores s1 inner join scores s2
on s1.score <= s2.score 
group by s1.id, s1.score
order by 1 desc;

Create table employee (id int, pay_month int, salary int);

Insert into employee values
(1, 1, 20),
(2, 1, 20),
(1, 2, 30),
(2, 2, 30),
(3, 2, 40),
(1, 3, 40),
(3, 3, 60),
(1, 4, 60),
(3, 4, 70);

Select * from employee order by id, pay_month;

With cte as (Select *, rank() over (partition by id order by pay_month desc) as month_rank from employee)
Select id, pay_month, salary, sum(salary) over (partition  by id order by month_rank desc) from cte 
where month_rank != 1 and month_rank <= 4 
order by 1, 2;

Create table teams (team_id int, team_name char(50));

Insert into teams values
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

Select * from matches;

With cte as (Select *, (case when host_goals > guest_goals then 3 when host_goals = guest_goals then 1 else 0 end) as host_points,
			(case when guest_goals > host_goals then 3 when guest_goals = host_goals then 1 else 0 end) as guest_points
			from matches)
Select t.team_name, a.host_points + b.guest_points as total_points from teams t 
inner join cte a
on t.team_id = a.host_team
join cte b
on t.team_id = b.guest_team order by 2 desc, 1 asc;

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

Select distinct id, name from orders o
inner join customers c on 
o.customer_id = c.id
where customer_id in (select customer_id from orders where product_name = 'A')
and customer_id in (select customer_id from orders where product_name = 'B')
and customer_id not in (select customer_id from orders where product_name = 'C')
order by 1;

Create table stations (id int, city char(50), state char(50), latitude decimal, longitude decimal);

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

With cte as (Select *, row_number() over (partition by state order by latitude asc) as latitude_rank,
count(*) over (partition by state) as state_count from stations)
Select state, round(avg(latitude):: decimal, 2) as median_latitude from cte
where latitude_rank >= 1.0 * state_count/2
and latitude_rank <= 1.0 * state_count/2 + 1
group by 1;

Create table users (user_id int, join_date date, invited_by int);

Insert into users values 
(1, '01-01-20', 0), 
(2, '01-10-20', 1), 
(3, '02-05-20', 2), 
(4, '02-12-20', 3), 
(5, '02-25-20', 2), 
(6, '03-01-20', 0), 
(7, '03-01-20', 4),
(8, '03-04-20', 7);

Select * from users;

With cte as (Select cast (extract (month from u2.join_date) as int) as month, 
u1.join_date - u2.join_date as cycle_time from users u1 inner join users u2 on u1.invited_by = u2.user_id order by 1)
Select month, round(avg(cycle_time):: decimal, 1) as avg_cycle_time from cte group by 1 order by 1;

Create table attendence (event_date date, visitors int);

Insert into attendence values 
('01-01-20', 10), 
('01-04-20', 109), 
('01-05-20', 150), 
('01-06-20', 99), 
('01-07-20', 145), 
('01-08-20', 1455), 
('01-11-20', 199),
('01-12-20', 188);

With cte as (Select *, row_number() over (order by event_date) as day_num from attendence),
cte2 as (Select * from cte where visitors > 100),
cte3 as (Select event_date, visitors,
(case when lead (day_num, 1) over (order by day_num) = day_num + 1
 and lead (day_num, 2) over (order by day_num) = day_num + 2
 then 'YES'
 when lag (day_num, 1) over (order by day_num) = day_num - 1
 and lag (day_num, 2) over (order by day_num) = day_num - 2
 then 'YES'
 else 'NO' end) as decision from cte2)
Select event_date, visitors from cte3 where decision = 'YES';

Create table salary (month int, salary int);

Insert into salary values 
(1, 2000),
(2, 3000),
(3, 5000),
(4, 4000),
(5, 2000),
(6, 1000),
(7, 2000),
(8, 4000),
(9, 5000);

Select s1.month, sum(s2.salary) as salary_3mos from salary s1 inner join salary s2
on s1.month <= s2.month
and s1.month > s2.month - 3
group by 1
having s1.month < 7 
order by 1;

Create table trips (trip_id int, rider_id int, driver_id int, status char(50), request_date date);

Insert into trips values
(1, 1, 10, 'completed', '2020-10-01'),
(2, 2, 11, 'cancelled_by_driver', '2020-10-01'),
(3, 3, 12, 'completed', '2020-10-01'),
(4, 4, 10, 'cancelled_by_rider', '2020-10-02'),
(5, 1, 11, 'completed', '2020-10-02'),
(6, 2, 12, 'completed', '2020-10-02'),
(7, 3, 11, 'completed', '2020-10-03');

Create table users (user_id int, banned char(20), type char(20));

Insert into users values
(1, 'no', 'rider'),
(2, 'yes', 'rider'),
(3, 'no', 'rider'),
(4, 'no', 'rider'),
(10, 'no', 'driver'),
(11, 'no', 'driver'),
(12, 'no', 'driver');

Select request_date, round(sum(case when status <> 'completed' then 1 else 0 end)/count(*)::decimal, 2) as cancel_rate from trips
where rider_id not in (Select user_id from users where banned = 'yes')
and driver_id not in (Select user_id from users where banned = 'yes')
group by request_date;