# E-Commerce Customer Churn Analysis (SQL)

## Overview
In the realm of e-commerce, businesses face the challenge of understanding customer
churn patterns to ensure customer satisfaction and sustained profitability. This project
aims to delve into the dynamics of customer churn within an e-commerce domain,
utilizing historical transactional data to uncover underlying patterns and drivers of
churn. By analyzing customer attributes such as tenure, preferred payment modes,
satisfaction scores, and purchase behavior, the project seeks to investigate and
understand the dynamics of customer attrition and their propensity to churn. The
ultimate objective is to equip e-commerce enterprises with actionable insights to
implement targeted retention strategies and mitigate churn, thereby fostering long-term
customer relationships and ensuring business viability in a competitive landscape.


## Objectives
1.	Analyse overall churn rate
2.	Identify patterns in customer behaviour leading to churn
3.	Evaluate the impact of engagement, satisfaction, and transactions
4.	Generate actionable insights for improving customer retention

## Dataset Description

Table 1 - customer_churn
This dataset contains detailed customer-level information, including:
ColumnName	-	DataType
CustomerID	-	INT
Churn	-	BIT
Tenure	-	INT
PreferredLoginDevice	-	VARCHAR(20)
CityTier	-	INT
WarehouseToHome	-	INT
PreferredPaymentMode	-	VARCHAR(20)
Gender	-	ENUM('Male','Female')
HourSpendOnApp	-	INT
NumberOfDeviceRegistered	-	INT
PreferedOrderCat	-	VARCHAR(20)
SatisfactionScore	-	INT
MaritalStatus	-	VARCHAR(10)
NumberOfAddress	-	INT
Complain	-	BIT
OrderAmountHikeFromlastYear	-	INT
CouponUsed	-	INT
OrderCount	-	INT
DaySinceLastOrder	-	INT
CashbackAmount	-	INT

Table 2 - customer_returns
Column Name	-	DataType
ReturnID	-	INT
CustomerID	-	INT
ReturnDate	-	DATE
RefundAmount	-	INT

## Project Steps

### 1️. Database Setup

Created database ecomm
Created customer_churn table with appropriate data types
Inserted structured dataset

### 2️. Data Cleaning

Performed multiple cleaning operations, including:

Handling NULL values in the following columns:
Tenure, HourSpendOnApp, WarehouseToHome, OrderAmountHikeFromlastYear, DaySinceLastOrder

Standardising categorical values:
Payment modes (CC as Credit Card)
Device types (Phone vs Mobile Phone)
Checking inconsistencies and duplicates
Outlier removal
Preparing cleansed dataset for analysis

### 3️. Data Analysis

Explored customer churn across multiple dimensions:

Demographics
Customer engagement
Transaction behaviour
Satisfaction and complaints

## Key Analysis Queries

### -- 1. Retrieve the count of churned and active customers from the dataset.
select ChurnStatus, count(*) as Churn_Count
from customer_churn
group by ChurnStatus;

### -- 2. Determine the percentage of churned customers who complained.
select count(*) as Count from customer_churn
where ChurnStatus = 'Churned' and ComplaintReceived = 'Yes';

select (select count(*) from customer_churn
where ChurnStatus = 'Churned' and ComplaintReceived = 'Yes')/
(select count(*) from customer_churn
where ChurnStatus = 'Churned') *100 as Percentage;

### -- 3. What is the average satisfaction score of customers who have complained?
select round(avg(SatisfactionScore)) as Avg_Satisfaction_Score from customer_churn
where ComplaintReceived = 'yes';

### -- 4. Identify if the customers making returns are your most expensive customers in terms of the cashback they receive.
select 
    cc.CustomerID, 
    cc.ChurnStatus, 
    cr.RefundAmount,
    cc.CashbackAmount as Recovered_Cashback,
    (cr.RefundAmount - cc.CashbackAmount) as Net_Company_Outflow
from customer_churn cc
inner join customer_returns cr on cc.CustomerID = cr.CustomerID;

### -- 5. Identify the gender that utilized the highest number of coupons.
select Gender, count(*) as Coupon_Count from customer_churn
group by Gender order by Coupon_Count desc limit 1;

### -- 6. Identify which product categories are the most "unstable" by calculating the return rate per category.
select 
    cc.PreferredOrderCat,
    count(cc.CustomerID) as Total_Customers,
    count(cr.ReturnID) as Total_Returns,
    round(count(cr.ReturnID) / count(cc.CustomerID) * 100, 2) as Return_Rate_Percentage
from customer_churn cc
left join customer_returns cr on cc.CustomerID = cr.CustomerID
group by cc.PreferredOrderCat
order by Return_Rate_Percentage desc;

## Insights

1. Distance Affects Retention: Customers living in the "Far Distance" category show a higher tendency to churn, likely due to longer delivery times or higher shipping costs.
2. Fashion has Highest Returns: Among customers who returned fashion has returnded by more customers.
3. Geographic Churn rate: City tier 1 more customers churned
4. Complaints Drive Churn: Around 508 churned customers already given the complaint, which is 54%.
5. Average Tenure : The average tenure of the customers churned is 3 months

## Conclusion

This project highlights that customer churn is not random; it is closely tied to service quality and logistics efficiency. 
The analysis shows that unresolved complaints and long delivery distances are the primary reasons customers leave the platform within their first three months. 
By improving the complaint resolution process and optimizing delivery for distant regions, 
the company can significantly improve its long-term customer retention and reduce the financial losses caused by high return rates in categories like Fashion and Others.
