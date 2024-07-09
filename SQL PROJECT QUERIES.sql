### OBJECTIVE QUESTIONS ###
select * from customerinfo;
# QUESTION 02:Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year.
SELECT 
    CustomerId,
    EstimatedSalary,
    Bank_DOJ
FROM customerinfo
WHERE QUARTER(STR_TO_DATE(Bank_DOJ, '%Y-%m-%d')) = 4
ORDER BY EstimatedSalary DESC
LIMIT 5;

#-------------------------------------------------------------------------------------------------------------------#

#QUESTION 3:Calculate the average number of products used by customers who have a credit card.
SELECT avg(NumOfProducts) as avg_products_used_by_creditcard_holder
FROM bank_churn
WHERE HasCrCard = 1;

#---------------------------------------------------------------------------------------------------------------------#

#QUESTION 4 : Determine the churn rate by gender for the most recent year in the dataset.

SELECT 
    g.GenderCategory, 
    (COUNT(CASE WHEN bc.exited = 1 THEN 1 END) * 100.0) / COUNT(bc.CustomerId) AS churn_rate
FROM bank_churn bc
JOIN customerinfo c ON bc.CustomerId = c.CustomerId
JOIN gender g ON g.GenderID = c.GenderID
WHERE YEAR(c.bank_DOJ) = 2019
GROUP BY g.GenderCategory;

#---------------------------------------------------------------------------------------------------------------------#

#QUESTION 5:Compare the average credit score of customers who have exited and those who remain.
SELECT
avg(case when Exited = 1 then CreditScore else 0 end) as avg_exited_score,
avg(case when Exited = 0 then CreditScore else 0 end ) as avg_remain_score
FROM bank_churn;

#--------------------------------------------------------------------------------------------------------------------------#

#QUESTION 6: 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?
SELECT 
    IF(c.GenderID = 1, 'Male', 'Female') AS Gender,
    ROUND(AVG(c.EstimatedSalary), 2) AS AvgSalary,
    COUNT(*) AS NumActiveAccounts
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
WHERE b.IsActiveMember = 1
GROUP BY c.GenderID
ORDER BY AvgSalary DESC;

### Alternate way using joins####
select
g.GenderCategory, 
ROUND(AVG(c.EstimatedSalary), 2) AS AvgSalary,
COUNT(*) AS NumActiveAccounts
from customerinfo c
inner join gender g on 
c.GenderID = g.GenderID
inner join bank_churn bc on 
c.CustomerId = bc.CustomerId
where bc.IsActiveMember = 1
group by g.GenderCategory
order by AvgSalary desc;
#--------------------------------------------------------------------------------------------------------------------------#

#QUESTION 7: Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL) 
SELECT 
Credit_segment,
round(avg(Exited)*100,2) as rate_of_exited
from (
select bc.CustomerId,
case
when bc.CreditScore <500 then "Poor Credit"
when bc.CreditScore between 500 and 600 then "Good Credit"
when bc.CreditScore between 600 and 700 then "Very Good Credit"
when bc.CreditScore between 700 and 800 then "Excellent Credit"
else "Super Credit"
end as Credit_segment, bc.Exited
From bank_churn bc
inner join customerinfo cf
on bc.CustomerId = cf.CustomerId
) as segments
group by Credit_segment
order by rate_of_exited desc;

#--------------------------------------------------------------------------------------------------------------------------#

#QUESTION 8: Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT 
g.GeographyID,
g.GeographyLocation,
COUNT(c.CustomerId) AS ActiveCustomers
FROM customerinfo c
INNER JOIN bank_churn bc 
ON c.CustomerId = bc.CustomerId
INNER JOIN geography g 
ON c.GeographyID = g.GeographyID
WHERE bc.IsActiveMember = 1 AND bc.Tenure > 5
GROUP BY g.GeographyLocation,g.GeographyID
ORDER BY ActiveCustomers DESC;

#--------------------------------------------------------------------------------------------------------------------------#

#QUESTION 11 : 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). 
#Prepare the data through SQL and then visualize it.

select year(bank_DOJ) as year, count(c.CustomerId) as Exited_cust_count
from bank_churn bc
inner join customerinfo c ON bc.CustomerId= c.CustomerId
where Exited= 1
group by year(bank_DOJ);

#--------------------------------------------------------------------------------------------------------------------------#

#QUESTION 15:	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. 
# Also, rank the gender according to the average value 
WITH Income as (
SELECT GeographyID,
case when GenderID = 1 then "Male" else "Female" end  as Gender,
round(avg(EstimatedSalary),3) as Avg_Income
from customerinfo
group by GeographyID,Gender)
SELECT
GeographyID, Gender, Avg_Income,
RANK() OVER(PARTITION BY GeographyID ORDER BY Avg_Income DESC) AS gender_wise_rank
FROM Income
ORDER BY GeographyID, gender_wise_rank;

#--------------------------------------------------------------------------------------------------------------------------#

#QUESTION 16 : Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
SELECT 
CASE 
WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
WHEN c.Age BETWEEN 31 AND 50 THEN '31-50' 
ELSE '51+' 
END AS Age_Of_Group,
ROUND(AVG(b.Tenure), 2) AS Avg_Of_Tenure
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
WHERE b.Exited = 1
GROUP BY Age_Of_Group
ORDER BY Age_Of_Group;

#--------------------------------------------------------------------------------------------------------------------------#

# Question 22 : 
select 
c.CustomerId,
c.Surname,concat(c.CustomerId,'__',c.Surname) as CustomerId_Surname
from customerinfo c
join bank_churn bc on c.CustomerId = bc.CustomerId;



#QUESTION 23 : Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
SELECT CustomerId,
CreditScore,
Tenure,
Balance, 
NumOfProducts, 
HasCrCard,
IsActiveMember, 
Exited,
CASE WHEN Exited = 0 THEN 'Not Exit' ELSE 'Exit' END AS ExitCategory
FROM bank_churn;




#QUESTION 25 : Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
SELECT bc.CustomerId,c.Surname,
CASE WHEN bc.IsActiveMember = 1 THEN 'Active' ELSE 'Inactive' END AS ActiveStatus
FROM bank_churn bc
JOIN customerinfo c ON bc.CustomerId = c.CustomerId
WHERE c.Surname LIKE '%on';


#--------------------------------------------------------------------------------------------------------------------------#
###Subjective Question###
#QUESTION 14: In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?
alter table bank_churn
rename column HasCrCard to Has_creditcard;
select * from bank_churn;


alter table bank_churn
rename column Has_creditcard to HasCrCard;

#--------------------------------------------------------------------------------------------------------------------------#
#QUESTION 09 : 9.	Utilize SQL queries to segment customers based on demographics and account details.
 SELECT 
    g.GeographyLocation,
    CASE 
        WHEN c.EstimatedSalary < 50000 THEN 'Low'
        WHEN c.EstimatedSalary < 100000 THEN 'Medium'
        ELSE 'High'
    END AS Income_Segment,
    CASE 
        WHEN c.GenderID = 1 THEN 'Male'
        ELSE 'Female'
    END AS gender,
    c.age,
    COUNT(c.CustomerId) AS Number_of_customers
FROM 
    customerinfo c
JOIN 
    geography g ON c.GeographyID = g.GeographyID
GROUP BY 
    g.GeographyLocation,
    Income_Segment,
    gender,
    c.age
ORDER BY 
    g.GeographyLocation,
    c.age;







    
    
    
    











-- Step 1: Check for valid dates (optional but recommended)
SELECT Bank_DOJ
FROM customerinfo
WHERE STR_TO_DATE(Bank_DOJ, '%Y-%m-%d') IS NULL;

-- Step 2: Update the dates to the correct format
UPDATE customerinfo
SET Bank_DOJ = STR_TO_DATE(Bank_DOJ, '%d-%m-%Y');


-- Step 3: Change the column data type
ALTER TABLE customerinfo
MODIFY COLUMN Bank_DOJ DATE;



SET SQL_SAFE_UPDATES = 0;














