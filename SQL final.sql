select * from transactions;
select * from customers;

####БЛОК 1




#ЗАДАЧА 1

# создаю временную таблицу с клиентами, которые приобретали беспрерывно ежемесячно товар в течении года
CREATE TEMPORARY TABLE months AS 
SELECT t.ID_client
from transactions as t
group by t.ID_client
HAVING COUNT(DISTINCT MONTH(t.date_new)) = '12';


#ЗАДАЧА 2

#вывожу средний чек за период по клиенту

SELECT t.ID_client, ROUND(SUM(t.Sum_payment)/COUNT(DISTINCT t.Id_check),2) as avg_check
from transactions as t
join months as m on t.ID_client = m.ID_client
where t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
group by t.ID_client
order by avg_check DESC;


#ЗАДАЧА 3

#вывожу среднюю сумму покупок по клиенту в месяц
SELECT m.ID_client, ROUND(SUM(t.Sum_payment)/12,2) as avg_sum_per_month
from transactions as t
join months as m on t.ID_client = m.ID_client
where t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
group by m.ID_client
order by 2 DESC;


#ЗАДАЧА 4

#Количество операций ежемесячно по клиенту за период

SELECT m.ID_client,month(date_new) as month, COUNT(DISTINCT t.Id_check) as operations_cnt
from transactions as t
join months as m on t.ID_client = m.ID_client
where t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
group by m.ID_client,month(date_new)
order by 2 ASC, 3 DESC;





 ####БЛОК 2
 
 #ЗАДАЧА 1
 
 #Cредняя сумма чека за месяц по клиенту в разрезе месяцов 
SELECT m.ID_client,month(t.date_new) as month, ROUND(SUM(t.Sum_payment)/COUNT(DISTINCT t.Id_check),2) as avg_check
from transactions as t
join months as m on t.ID_client = m.ID_client
where t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
group by m.ID_client,month(t.date_new)
order by 2 asc, 3 desc;
 
 
 ##ЗАДАЧА 2
 
#Среднее кол-во операций в месяц по клиенту

SELECT m.ID_client,MONTH(t.date_new) as month,COUNT(DISTINCT t.Id_check) as operations_avg,
ROUND(AVG(COUNT(DISTINCT t.ID_check)) OVER (),2) AS avg_operations_per_month
from transactions as t
join months as m on t.ID_client = m.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
group by m.ID_client, MONTH(t.date_new)
order by 2 ASC,3 DESC;


##ЗАДАЧА 3

#Среднее кол-во клиентов совершивших операцию

SELECT MONTH(t.date_new) AS month, COUNT(DISTINCT t.ID_client) AS clients_cnt, 
		ROUND(AVG(COUNT(DISTINCT t.ID_client)) OVER (),2) AS avg_clients_per_month 
FROM transactions AS t 
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01' 
GROUP BY MONTH(t.date_new) 
ORDER BY month;




##ЗАДАЧА 4

#Доля от общего кол-ва операций в год

SET @total_operations = (SELECT COUNT(*)
						FROM transactions
                        where date_new BETWEEN '2015-06-01' AND '2016-06-01');
                        
SELECT MONTH(date_new) as month, ROUND(COUNT(*)/@total_operations*100,2) as dolya
from transactions as t
where date_new BETWEEN '2015-06-01' AND '2016-06-01'
group by MONTH(date_new)
order by 1 ASC;

## ЗАДАЧА 5

#Доля от общей суммы всех операций 

SET @total_sum = (SELECT SUM(Sum_payment) FROM transactions
                        where date_new BETWEEN '2015-06-01' AND '2016-06-01');

select @total_sum;

SELECT MONTH(date_new) as month, ROUND(SUM(t.Sum_payment)/@total_sum*100,2) as dolya
from transactions as t
where date_new BETWEEN '2015-06-01' AND '2016-06-01'
group by MONTH(date_new)
order by 1 ASC;

## ЗАДАЧА 6

#вывести % соотношение M/F/NA в каждом месяце с их долей затрат
        

SELECT Gender,MONTH(date_new), SUM(Sum_payment), 
		ROUND(SUM(t.Sum_payment) * 100.0 / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY MONTH(t.date_new)), 2) AS dolya
		from transactions as t
        join customers as c on t.ID_client = c.Id_client
        WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
        group by Gender, MONTH(date_new);



												####БЛОК 3

			##ЗАДАЧА 1

#возрастные группы клиентов с шагом 10 лет, отдельно клиентов, у которых нет данной информации  с параметрами сумма и количество операций за весь период
#и поквартально - средние показатели и %.

SELECT CASE WHEN age IS NULL THEN 'NA'
			WHEN age BETWEEN 0 AND 9 THEN '0-9' WHEN age BETWEEN 10 AND 19 THEN '10-19'
			WHEN age BETWEEN 20 AND 29 THEN '20-29' WHEN age BETWEEN 30 AND 39 THEN '30-39' 
            WHEN age BETWEEN 40 AND 49 THEN '40-49' WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69' 
			WHEN age BETWEEN 70 AND 79 THEN '70-79' ELSE '80+' 
            END AS age_group,
 SUM(Sum_payment) AS sum_total, COUNT(Id_check) as operations_cnt, ROUND(SUM(Sum_payment)/COUNT(Id_check),2) as avg_check
from customers as c 
join transactions as t on c.Id_client = t.Id_client 
group by age_group
order by age_group ASC;

SET @total_sum = (SELECT SUM(Sum_payment) FROM transactions);
SET @total_checks = (SELECT COUNT(DISTINCT Id_check) FROM transactions);

SELECT quarter(date_new) as quarter, sum(Sum_payment) as payments_total, 
		count(DISTINCT Id_check) as cheks_total, sum(Sum_payment) / count(DISTINCT Id_check) AS avg_check,
        ROUND(sum(Sum_payment)/@total_sum * 100,2) as dolya_sum, 
                ROUND(count(DISTINCT Id_check) / @total_checks * 100,2) as dolya_checkov
		from transactions as t
        WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
		group by quarter(date_new)
        order by quarter asc


