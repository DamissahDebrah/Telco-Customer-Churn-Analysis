Create database Telco_Churn;
use telco_churn;
show tables;

SELECT contract,
count(*)  as `Total Churn`
FROM
    `telco_customer_churn analysis` 
WHERE
    `churn value` = 0
        AND `churn label` = 'no'
        AND cltv BETWEEN 5000 AND 10000
GROUP BY contract;

Describe `telco_customer_churn analysis`;

select gender, Avg(CLTV) from `telco_customer_churn analysis` group by gender;

select * from `telco_customer_churn analysis` ;

-- 1. Count of Churned vs. Active Customers
SELECT `Churn label`, COUNT(*) AS total_customers
FROM `telco_customer_churn analysis`
GROUP BY`Churn label`;

-- 2 What is the total CLTV Value for Churn Vs Active Customers
SELECT `Churn label`, sum(cltv) AS total_CLTV
FROM `telco_customer_churn analysis`
where CLTV between 4000 and 10000
GROUP BY`Churn label`;

-- 3.Average Tenure of Churn Vs Active Customers
select `churn label`, avg(`tenure months`) as `Average Tenure`
from `telco_customer_churn analysis`
group by `churn label`;

-- 4 Which contract type has the highest churn? ( Tells us the contract type that resulted in the highest volume of churn )
Select `contract`,`churn label`, count(*) as total_Customers 
from `telco_customer_churn analysis`
group by `contract`, `churn label`
order by total_customers desc;

-- 5. Is churn higher for customers with short tenure (Gives an idea how long the customer stayed before leaving)
Select `tenure months`,`churn label`, count(*) as total_Customers 
from `telco_customer_churn analysis`
where `churn label`= 'yes'
group by `tenure months`, `churn label`
order by `tenure months`asc;

-- 6.Do MonthlyCharges affect churn? (checks if paying more each month leads to more people quitting.)
select `churn value`, avg(`monthly charges`) as Monthly_Charges
from `telco_customer_churn analysis`
group by `churn value`;


-- 7 find the total number of customers who churned as a result of monthly charges beyond average.
SELECT 
    COUNT(*)
FROM
    `telco_customer_churn analysis`
WHERE
    `churn label` = 'yes' and  `monthly charges` > (SELECT 
            AVG(`monthly charges`)
        FROM
            `telco_customer_churn analysis` );
 
 -- Find numbers of customers churned  and  total revenue loss for customers who pay above avg monthly charge who has churned
  SELECT count(*) as `Total customers`,
  ROUND(SUM(`monthly charges`), 2) as `Total Revenue loss`
FROM
    `telco_customer_churn analysis`
WHERE
   `Churn value` = 1 and  `monthly charges` > (SELECT 
            AVG(`monthly charges`)
        FROM
            `telco_customer_churn analysis`);
  
  
  -- 8  Total charges for customer with cltv values grater than 4000         
   SELECT 
    `cltv`, round(SUM(`total charges`), 2) AS total_charge
FROM `telco_customer_churn analysis`
WHERE
    cltv > 4000
GROUP BY `cltv`
Order by Cltv desc ;


-- 9 Find the total revenue loss  when cltv value is greater than AVG CLTV value 
SELECT 
 round(SUM(`total Charges`),2) as Total_charges
FROM
    `telco_customer_churn analysis`
WHERE
   `churn label` = 'yes' and `cltv` > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);

-- Find the avg CLTV 

(SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);


-- find the total number of cltv  higher than avg cltv value that churned

SELECT 
 count(*) as Total_customers
FROM
    `telco_customer_churn analysis`
WHERE
   `churn label` = 'yes' and `cltv` > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);
            
-- find the churn Revenue for customers with cltv > avg(Cltv)
SELECT 
 count(*) as Total_customers ,round(sum(`Total Charges`),2) as `Churn Revenue`
FROM
    `telco_customer_churn analysis`
WHERE
   `churn label` = 'yes' and `cltv` > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);


-- find the total number of customer that churn,the corresponding revenue loss and reason they churned.
SELECT 
    `churn reason`, Round(sum(`Total Charges`),2) as `Churn Revenue` ,COUNT(*) AS `Total Customer`
FROM
    `telco_customer_churn analysis` where `churn value` = 1
GROUP BY `churn reason`
order by `churn revenue`desc ;

-- find the total number of customer, the corresponding revenue loss and reason they churned.This helps the telco company 
-- know which areas to focus a retention strategy  based on the volume of revenue lost to churn and reason for the loss.
SELECT 
    `churn reason`, Round(sum(`Total Charges`),2) as `Churn Revenue` ,COUNT(*) AS `Total Customer`
FROM
    `telco_customer_churn analysis` 
GROUP BY `churn reason`
order by `Churn Revenue`desc ;



-- Used To detect the different kinds of empty values in the data set 
SELECT 
    SUM(CASE WHEN `churn reason` IS NULL THEN 1 ELSE 0 END) as null_count,
    SUM(CASE WHEN TRIM(`churn reason`) = '' THEN 1 ELSE 0 END) as empty_string_count,
    SUM(CASE WHEN `churn reason` = ' ' THEN 1 ELSE 0 END) as space_only_count,
    COUNT(*) as `total_rows` 
FROM `telco_customer_churn analysis`; 

--  Update the empty strings rows with "Unknown"
UPDATE `telco_customer_churn analysis`
SET `churn reason` = 'Unknown'
WHERE 
    (`churn reason` IS NULL
     OR TRIM(`churn reason`) = ''
     OR `churn reason` = ' ')
    AND `customerID` IS NOT NULL;

-- Temporarily disable Safe Update Mode so as to be able to update my dataset
SET SQL_SAFE_UPDATES = 0;

-- re-enable safety turn on back
SET SQL_SAFE_UPDATES = 1;
 
 -- Checking Updates.
 select count(*) as `Total rows` from `telco_customer_churn analysis` where `churn reason` = "Unknown" ;
 
 -- Find out the contract type with the highest number of churn
 SELECT 
    `Contract`, COUNT(*) AS `Total customers`
FROM
    `telco_customer_churn analysis`
WHERE
    `churn value` = 1
        AND cltv > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`)
            group by `Contract`
            order by `Total customers` desc;

 
 select * from `telco_customer_churn analysis`;
    
SELECT 
    COUNT(*) AS TotalRows,
    COUNT(*) - COUNT(DISTINCT CustomerID) AS DuplicateCustomers
FROM `telco_customer_churn analysis`; ----- Checks for duplicate records on the data set and subtracts the duplicate record identify
									   ------ from the Total no of rows
                                       
select CustomerID ,count(*) as duplicate_customer
from `telco_customer_churn analysis`
group by CustomerID 
Having count(*) >1 ; -- Having clause is used to filter tru group 
					 -- Where clause is used to filter tru the rows in the dataset before grouping


-- Identify Customers with cltv greater than avg cltv likely to churn
SELECT 
    customerID, cltv
FROM
    `telco_customer_churn analysis`
WHERE
    `contract` ='Month-to-Month' and `churn Value` = 1
        AND cltv > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);