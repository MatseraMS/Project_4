--Стоимость включенных в полёт билетов
with amounts as(
select
    flight_id,
    sum(amount) amount_sum,
    count(case when tf.fare_conditions = 'Business' then tf.flight_id end) Business_count,
    count(case when tf.fare_conditions = 'Economy' then tf.flight_id end) Economy_count
from dst_project.ticket_flights tf
group by flight_id
),
--Расход топлива в минуту для различных самолётов
rate as
(
SELECT 
    1700.0/60 as rate_minute,
    'SU9' as aircraft_code
    union
SELECT 
    2400.0/60 as rate_minute,
    '733' as aircraft_code
),
--Стоимость килограмма топлива в разные месяцы
fuel_cost as
(
--январь
SELECT   
    flight_id,
    41435.0/1000 as cost
FROM
    dst_project.flights as f
where f.departure_airport = 'AAQ' and (date_trunc('month', f.scheduled_departure) in ('2017-01-01')) and f.status not in ('Cancelled')
union all
--февраль
SELECT   
    flight_id,
    39553.0/1000 as cost
FROM
    dst_project.flights as f
where f.departure_airport = 'AAQ' and (date_trunc('month', f.scheduled_departure) in ('2017-02-01')) and f.status not in ('Cancelled')
union all
--декабрь
SELECT   
    flight_id,
    38867.0/1000 as cost
FROM
    dst_project.flights as f
where f.departure_airport = 'AAQ' and (date_trunc('month', f.scheduled_departure) in ('2016-12-01')) and f.status not in ('Cancelled')
),
--Число минут в полёте
air_minutes as(
select 
    date_part('minute',actual_arrival - actual_departure) + 60*date_part('hour',actual_arrival-  actual_departure) minutes_count,
    f.flight_id
from
    dst_project.flights as f
where departure_airport = 'AAQ'
  AND (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2016-12-01'))
  AND status not in ('Cancelled')
)


SELECT
    *
FROM dst_project.flights f
    JOIN amounts a on f.flight_id = a.flight_id
    JOIN fuel_cost fc on fc.flight_id = f.flight_id
    JOIN rate as r on r.aircraft_code = f.aircraft_code
    JOIN air_minutes am on am.flight_id = f.flight_id
WHERE departure_airport = 'AAQ'
  AND (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2016-12-01'))
  AND status not in ('Cancelled')
order by amount_sum asc