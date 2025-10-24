Create database Telco_Churn;
use telco_churn;
show tables;
Describe `telco_customer_churn analysis`;

-- Explore the dataset for empty fields 
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


-- Which countract type has the highest number of churnedcustomers
SELECT 
    contract, COUNT(*) AS `Active Customers`
FROM
    `telco_customer_churn analysis`
WHERE
    `churn value` = 0
        AND `churn label` = 'no'
GROUP BY contract;

-- which gender has the highest number of churn customers ?
SELECT 
    `gender`, COUNT(*) AS `total customers`
FROM
    `telco_customer_churn analysis`
WHERE
    `Churn Label` = 'Yes'
GROUP BY `gender` , `Churn Label`;


--  What is the Count of Churned vs. Active Customers
SELECT 
    `Churn label`, COUNT(*) AS total_customers
FROM
    `telco_customer_churn analysis`
GROUP BY `Churn label`;

--  What is the total CLTV Value for Churn Vs Active Customers
SELECT 
    `Churn label`, SUM(cltv) AS total_CLTV
FROM
    `telco_customer_churn analysis`
WHERE
    CLTV BETWEEN 4000 AND 10000
GROUP BY `Churn label`;

-- What is the Average Tenure of Churn Vs Active Customers
SELECT 
    `churn label`, AVG(`tenure months`) AS `Average Tenure`
FROM
    `telco_customer_churn analysis`
GROUP BY `churn label`;

--  Which contract type has the highest number of churn customers ? 
SELECT 
    `contract`, `churn label`, COUNT(*) AS total_Customers
FROM
    `telco_customer_churn analysis` where `Churn Label` = "Yes"
GROUP BY `contract`
ORDER BY total_customers DESC;

-- Is churn higher for customers with short tenure 
SELECT 
    `tenure months`, `churn label`, COUNT(*) AS total_Customers
FROM
    `telco_customer_churn analysis`
WHERE
    `churn label` = 'yes'
GROUP BY `tenure months` , `churn label`
ORDER BY `tenure months` ASC;

-- Do MonthlyCharges affect churn? 
SELECT 
    `churn value`, AVG(`monthly charges`) AS Monthly_Charges
FROM
    `telco_customer_churn analysis`
GROUP BY `churn value`;

-- What is  the total number of customers who churned because monthly charges was more than average?
   Select COUNT(*) as `Total Customers`
FROM
    `telco_customer_churn analysis`
WHERE
    `churn label` = 'yes' and  `monthly charges` > (SELECT 
            AVG(`monthly charges`)
        FROM
            `telco_customer_churn analysis` );
 
 -- What is the number of customers that churned and the total revenue loss for customers who pay above avg monthly charge 
  SELECT 
    COUNT(*) AS `Total customers`,
    ROUND(SUM(`monthly charges`), 2) AS `Total Revenue loss`
FROM
    `telco_customer_churn analysis`
WHERE
    `Churn value` = 1
        AND `monthly charges` > (SELECT 
            AVG(`monthly charges`)
        FROM
            `telco_customer_churn analysis`);
 
 -- Find avg CLTV 

(SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);           

-- What is  the total revenue loss for customers with CLTV value greater than Average?
SELECT 
 round(SUM(`total Charges`),2) as Total_charges
FROM
    `telco_customer_churn analysis`
WHERE
   `churn label` = 'yes' and `cltv` > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);


-- What number of customers churned  based on  cltv  higher than avg cltv 

SELECT 
 count(*) as Total_customers
FROM
    `telco_customer_churn analysis`
WHERE
   `churn label` = 'yes' and `cltv` > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);
            
-- find the churn Revenue and total number of customers with cltv > avg(Cltv)
SELECT 
 count(*) as Total_customers ,round(sum(`Total Charges`),2) as `Churn Revenue`
FROM
    `telco_customer_churn analysis`
WHERE
   `churn label` = 'yes' and `cltv` > (SELECT 
            AVG(`cltv`)
        FROM
            `telco_customer_churn analysis`);

-- What is the reason behind customer churn and how much revenne was lost?
SELECT 
    `churn reason`, Round(sum(`Total Charges`),2) as `Churn Revenue` ,COUNT(*) AS `Total Customer`
FROM
    `telco_customer_churn analysis` 
GROUP BY `churn reason`
order by `Churn Revenue`desc ;

 
 -- Which of the  contract type has the highest number of churn
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

 -- Duplicate Record  check   
SELECT 
    COUNT(*) AS TotalRows,
    COUNT(*) - COUNT(DISTINCT CustomerID) AS DuplicateCustomers
FROM `telco_customer_churn analysis`;
                                       
select CustomerID ,count(*) as duplicate_customer
from `telco_customer_churn analysis`
group by CustomerID 
Having count(*) >1 ;


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