use ecomm;

## Data Cleaning

-- 1. Handling Missing Values and Outliers

--  Impute mean for the following columns

-- WarehouseToHome
select round(avg(WarehouseToHome)) as mean
from customer_churn
where WarehouseToHome is not null;

-- mean is 16.
update customer_churn
set WarehouseToHome = (
select mean
from (select round(avg(WarehouseToHome)) as mean
from customer_churn
where WarehouseToHome is not null) as mean)
where WarehouseToHome is null;

-- HourSpendOnApp
select round(avg(HourSpendOnApp)) as mean
from customer_churn
where HourSpendOnApp is not null;

-- mean is 3. 
update customer_churn
set HourSpendOnApp = (
select mean
from (select round(avg(HourSpendOnApp)) as mean
from customer_churn
where HourSpendOnApp is not null) as mean)
where HourSpendOnApp is null;

-- OrderAmountHikeFromlastYear
select round(avg(OrderAmountHikeFromlastYear)) as mean
from customer_churn where OrderAmountHikeFromlastYear is not null;
 
 -- mean is 16. 
 update customer_churn
 set OrderAmountHikeFromlastYear = 
 (select mean from 
 (select round(avg(OrderAmountHikeFromlastYear)) as mean
from customer_churn where OrderAmountHikeFromlastYear is not null) as mean)
where OrderAmountHikeFromlastYear is null;


-- DaySinceLastOrder
select round(avg(DaySinceLastOrder)) as mean 
from customer_churn where DaySinceLastOrder is not null;

-- mena is 5.
update customer_churn
set DaySinceLastOrder = (select mean from(
select round(avg(DaySinceLastOrder)) as mean 
from customer_churn where DaySinceLastOrder is not null) as mean)
where DaySinceLastOrder is null;

-- Impute mode for the following columns

-- Tenure
select tenure as mo_de, count(*) as Tenure_Count from customer_churn 
where tenure is not null group by tenure 
order by Tenure_Count desc limit 1;

update customer_churn
set tenure = 
(select mo_de from 
(select tenure as mo_de, count(*) as Tenure_Count from customer_churn
where tenure is not null group by tenure order by Tenure_Count desc limit 1) as mo_de)
where tenure is null;

-- CouponUsed
select CouponUsed as mo_de, count(*) as Coupon_Count from customer_churn 
where CouponUsed is not null group by CouponUsed 
order by Coupon_Count desc limit 1;

update customer_churn
set CouponUsed = 
(select mo_de from 
(select CouponUsed as mo_de, count(*) as Coupon_Count from customer_churn
where CouponUsed is not null group by CouponUsed order by Coupon_Count desc limit 1) as mo_de)
where CouponUsed is null;

-- OrderCount
select OrderCount as mo_de, count(*) as Order_Counts from customer_churn
where OrderCount is not null group by OrderCount order by Order_Counts desc limit 1;

update customer_churn
set OrderCount = 
(select mo_de from 
(select OrderCount as mo_de, count(*) as Order_Counts from customer_churn
where OrderCount is not null group by OrderCount order by Order_Counts desc limit 1) as mo_de)
where OrderCount is null;

-- Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100.
delete from customer_churn
where WarehouseToHome > 100;

-- 2. Dealing with Inconsistencies

-- Replace occurrences from followong columns

-- PreferredLoginDevice
update customer_churn
set PreferredLoginDevice = 'Mobile Phone'
where PreferredLoginDevice = 'Phone';

-- PreferedOrderCat
update customer_churn
set PreferedOrderCat = ' Mobile Phone'
where PreferedOrderCat = 'Mobile';

update customer_churn
set PreferedOrderCat = 'Mobile Phone'
where PreferedOrderCat = ' Mobile Phone';

-- PreferredPaymentMode
update customer_churn
set PreferredPaymentMode = 'Cash on Delivery'
where PreferredPaymentMode = 'COD';

update customer_churn
set PreferredPaymentMode = 'Credit Card'
where PreferredPaymentMode = 'CC';

## Data Transformation

-- 1. Column Renaming

alter table customer_churn rename column PreferedOrderCat to PreferredOrderCat;
alter table customer_churn rename column HourSpendOnApp to HoursSpentOnApp;

-- 2. Creating New Columns

alter table customer_churn add
ComplaintReceived varchar (10) check (ComplaintReceived in ('Yes', 'No'));

update customer_churn
set ComplaintReceived = 'Yes'
where Complain = 1;

update customer_churn
set ComplaintReceived = 'No'
where Complain = 0;

alter table customer_churn add
ChurnStatus varchar (10) check (ChurnStatus in ('Churned', 'Active'));

update customer_churn
set ChurnStatus = 'Churned'
where Churn = 1;

update customer_churn
set ChurnStatus = 'Active'
where Churn = 0;

-- Column Dropping

alter table customer_churn drop Churn;
alter table customer_churn drop Complain;

## Data Exploration and Analysis

-- 1. Retrieve the count of churned and active customers from the dataset.
select ChurnStatus, count(*) as Churn_Count
from customer_churn
group by ChurnStatus;

-- 2. Display the average tenure and total cashback amount of customers who churned.
select round(avg(tenure)) as Avg_Tenure, sum(CashbackAmount) as Total_Cashback
from customer_churn where ChurnStatus = 'Churned'; 

-- 3. Determine the percentage of churned customers who complained.
select count(*) as Count from customer_churn
where ChurnStatus = 'Churned' and ComplaintReceived = 'Yes';

select (select count(*) from customer_churn
where ChurnStatus = 'Churned' and ComplaintReceived = 'Yes')/
(select count(*) from customer_churn
where ChurnStatus = 'Churned') *100 as Percentage;


-- 4. Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory.
select CityTier, count(*) as Churn_Count from customer_churn
where ChurnStatus = 'Churned' and PreferredOrderCat = 'Laptop & Accessory'
group by CityTier order by Churn_Count desc limit 1;

-- 5. Identify the most preferred payment mode among active customers.
select PreferredPaymentMode, count(*) as Payment_Count from customer_churn
where ChurnStatus = 'Active' 
group by PreferredPaymentMode order by Payment_Count desc limit 1;

-- 6. Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering
select sum(OrderAmountHikeFromlastYear) as Total_Hike from customer_churn
where MaritalStatus = 'Single' and PreferredOrderCat = 'Mobile Phone';

-- 7. Find the average number of devices registered among customers who used UPI as their preferred payment mode.
select round(avg(NumberOfDeviceRegistered)) as Average_Device_Number from customer_churn
where PreferredPaymentMode = 'upi';

-- 8. Determine the city tier with the highest number of customers.
select CityTier, count(*) as Customer_Count from customer_churn
group by CityTier order by Customer_Count desc limit 1;

-- 9. Identify the gender that utilized the highest number of coupons.
select Gender, count(*) as Coupon_Count from customer_churn
group by Gender order by Coupon_Count desc limit 1;

-- 10. List the number of customers and the maximum hours spent on the app in each preferred order category.
select PreferredOrderCat, count(*) as Customer_Count, max(HoursSpentOnApp) as Maximum_Hours from customer_churn
group by PreferredOrderCat;

-- 11. Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score.
select sum(OrderCount)
from customer_churn
where PreferredPaymentMode = 'Credit Card'
and SatisfactionScore = (select max(SatisfactionScore) from customer_churn);

-- 12. What is the average satisfaction score of customers who have complained?
select round(avg(SatisfactionScore)) as Avg_Satisfaction_Score from customer_churn
where ComplaintReceived = 'yes';

-- 13.  List the preferred order category among customers who used more than 5 coupons.
select distinct PreferredOrderCat from customer_churn
where CouponUsed > 5;

-- 14. List the top 3 preferred order categories with the highest average cashback amount.
select PreferredOrderCat, round(avg(CashbackAmount)) as Average_Cashback from customer_churn 
group by PreferredOrderCat
order by Average_Cashback desc limit 3;

-- 15. Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders
select PreferredPaymentMode from customer_churn
group by PreferredPaymentMode
having round(avg(Tenure)) = 10 and sum(OrderCount) > 500;

-- 16. Categorize customers based on their distance from the warehouse to home such as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km, 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the churn status breakdown for each distance category
-- creating a new column to existing table
alter table customer_churn
add distance_category varchar(50);

select * from customer_churn;

update customer_churn
set distance_category = 'Very Close Distance'
where WarehouseToHome between 0 and 5;

update customer_churn
set distance_category = 'Close Distance'
where WarehouseToHome between 6 and 10;

update customer_churn
set distance_category = 'Moderate Distance'
where WarehouseToHome between 11 and 15;

update customer_churn
set distance_category = 'Far Distance'
where WarehouseToHome between 16 and 100;

select ChurnStatus, distance_category, count(CustomerID) as Customers
from customer_churn
group by ChurnStatus, distance_category order by ChurnStatus, Customers desc;

-- 17. List the customer’s order details who are married, live in City Tier-1, and their order counts are more than the average number of orders placed by all customers.
select avg(OrderCount) from customer_churn;
select * from customer_churn
where MaritalStatus = 'Married'
and CityTier = 1 
and OrderCount > (select avg(OrderCount) from customer_churn);

-- creating a new table - customer_returns
create table customer_returns(
ReturnID int primary key,
CustomerID int, foreign key (CustomerID) references customer_churn(CustomerID),
ReturnDate date,
RefundAmount INT
);

insert into customer_returns 
(ReturnID, CustomerID, ReturnDate, RefundAmount)
values
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

select * from customer_returns;

select * from customer_returns as cr
left join customer_churn as cc
on cr.CustomerID = cc.CustomerID
where cc.ChurnStatus = 'Churned' and cc.ComplaintReceived = 'Yes';

