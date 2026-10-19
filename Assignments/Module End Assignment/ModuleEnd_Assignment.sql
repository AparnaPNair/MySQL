use ecomm;
select * from customer_churn;  
desc customer_churn;
-- Handling Missing Values and Outliers:
-- Impute mean for the following columns, and round off to the nearest integer if required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder.
SET SQL_SAFE_UPDATES = 0;
SET @WarehouseToHome_Mean = (SELECT ROUND(AVG(WarehouseToHome)) FROM customer_churn);
SET @HourSpendOnApp_Mean = (SELECT ROUND(AVG(HourSpendOnApp)) FROM customer_churn);
SET @OrderAmountHikeFromlastYear_Mean = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) FROM customer_churn);
SET @DaySinceLastOrder_Mean = (SELECT ROUND(AVG(DaySinceLastOrder)) FROM customer_churn);
 
UPDATE customer_churn
SET  WarehouseToHome=  @WarehouseToHome_Mean
WHERE WarehouseToHome IS NULL;

UPDATE customer_churn
SET  HourSpendOnApp=  @HourSpendOnApp_Mean
WHERE HourSpendOnApp IS NULL;

UPDATE customer_churn
SET  OrderAmountHikeFromlastYear=  @OrderAmountHikeFromlastYear_Mean
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn
SET  DaySinceLastOrder= @DaySinceLastOrder_Mean
WHERE DaySinceLastOrder IS NULL;
 
-- Impute mode for the following columns: Tenure, CouponUsed, OrderCount.
 SET @ModeTenure = (SELECT Tenure FROM customer_churn
WHERE Tenure IS NOT NULL 
GROUP BY Tenure
ORDER BY COUNT(*) DESC
LIMIT 1);
 SET @ModeCouponUsed = (SELECT CouponUsed FROM customer_churn
WHERE CouponUsed IS NOT NULL 
GROUP BY CouponUsed
ORDER BY COUNT(*) DESC
LIMIT 1);
 SET @ModeOrderCount = (SELECT OrderCount FROM customer_churn
WHERE OrderCount IS NOT NULL 
GROUP BY OrderCount
ORDER BY COUNT(*) DESC
LIMIT 1);

UPDATE customer_churn SET 
Tenure= @ModeTenure
WHERE Tenure IS NULL;
 
UPDATE customer_churn SET  
CouponUsed=@ModeCouponUsed
WHERE CouponUsed IS NULL;

UPDATE customer_churn SET  
OrderCount=@ModeOrderCount
WHERE OrderCount IS NULL; 

-- Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100.
DELETE FROM customer_churn 
WHERE WarehouseToHome>100;

-- Dealing with Inconsistencies:
-- Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure uniformity.

UPDATE customer_churn 
SET PreferredLoginDevice='Mobile Phone' 
WHERE PreferredLoginDevice='Phone';

UPDATE customer_churn 
SET PreferedOrderCat='Mobile Phone' 
WHERE PreferedOrderCat='Mobile';

-- Standardize payment mode values: Replace "COD" with "Cash on Delivery" and "CC" with "Credit Card" in the PreferredPaymentMode column.
UPDATE customer_churn 
SET PreferredPaymentMode='Cash on Delivery' 
WHERE PreferredPaymentMode='COD';
     
UPDATE customer_churn 
SET PreferredPaymentMode='Credit Card' 
WHERE PreferredPaymentMode='CC';

-- Column Renaming:
-- Rename the column "PreferedOrderCat" to "PreferredOrderCat".
ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;

-- Rename the column "HourSpendOnApp" to "HoursSpentOnApp".
ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

-- Creating New Columns:
-- Create a new column named ‘ComplaintReceived’ with values "Yes" if the corresponding value in the ‘Complain’ is 1, and "No" otherwise.
ALTER TABLE customer_churn ADD COLUMN ComplaintReceived ENUM('Yes','No');
UPDATE customer_churn 
SET ComplaintReceived= case when Complain=1 then 'Yes' else 'No' end;

-- Create a new column named 'ChurnStatus'. Set its value to “Churned” if the corresponding value in the 'Churn' column is 1, else assign “Active”.
ALTER TABLE customer_churn ADD COLUMN ChurnStatus VARCHAR(50);
UPDATE customer_churn 
SET ChurnStatus= case when Churn=1 then 'Churned' else 'Active' end;

-- Column Dropping:
-- Drop the columns "Churn" and "Complain" from the table.
ALTER TABLE customer_churn DROP COLUMN Churn;
ALTER TABLE customer_churn DROP COLUMN Complain;

-- Data Exploration and Analysis
-- Retrieve the count of churned and active customers from the dataset. 
SELECT ChurnStatus, COUNT(*) AS CustCount
FROM customer_churn
GROUP BY ChurnStatus;

-- Display the average tenure and total cashback amount of customers who churned.
SELECT AVG(Tenure) AS Avg_Tenure,
SUM(CashbackAmount)AS Total_Cashback
FROM customer_churn
WHERE ChurnStatus='Churned';

-- Determine the percentage of churned customers who complained.
SELECT  
(COUNT(CASE WHEN ComplaintReceived = 'Yes' THEN 1 END)/COUNT(*)) * 100 as Percentage
FROM customer_churn
WHERE ChurnStatus='Churned';

-- Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory.
SELECT CityTier ,COUNT(*)AS churned_count
FROM customer_churn
WHERE PreferredOrderCat='Laptop & Accessory'
AND ChurnStatus='Churned'
GROUP BY CityTier
ORDER BY churned_count DESC
LIMIT 1;

-- Identify the most preferred payment mode among active customers.
SELECT COUNT(*) AS PaymentMode_Count,PreferredPaymentMode
FROM customer_churn
WHERE ChurnStatus='Active'
GROUP BY PreferredPaymentMode
ORDER BY PaymentMode_Count DESC
LIMIT 1;

-- Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering.
SELECT SUM(OrderAmountHikeFromlastYear)AS Total_Amount
FROM customer_churn
WHERE MaritalStatus='Single' AND
PreferredLoginDevice='Mobile Phone';

-- Find the average number of devices registered among customers who used UPI as their preferred payment mode.
SELECT AVG(NumberOfDeviceRegistered)AS Avg_Devices
FROM  customer_churn
WHERE PreferredPaymentMode='UPI';

-- Determine the city tier with the highest number of customers.
SELECT CityTier,COUNT(*) AS Total_Count
FROM  customer_churn
GROUP BY  CityTier
ORDER BY Total_Count DESC
LIMIT 1;

-- Identify the gender that utilized the highest number of coupons.
SELECT Gender,SUM(CouponUsed) AS Total_Count
FROM  customer_churn
GROUP BY  Gender
ORDER BY Total_Count DESC
LIMIT 1;

-- List the number of customers and the maximum hours spent on the app in each preferred order category.
SELECT COUNT(*)AS CustCount,MAX(HoursSpentOnApp) AS MaxHourSpend,PreferredOrderCat
FROM  customer_churn
GROUP BY PreferredOrderCat;

-- Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score.
SELECT SUM(OrderCount) AS  Total_Order_Count 
FROM customer_churn
WHERE PreferredPaymentMode='Credit Card' 
AND SatisfactionScore=(SELECT MAX(SatisfactionScore)FROM customer_churn);

-- What is the average satisfaction score of customers who have complained?
SELECT AVG(SatisfactionScore)
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- List the preferred order category among customers who used more than 5 coupons
SELECT DISTINCT PreferredOrderCat
FROM customer_churn
WHERE CouponUsed>5;

-- List the top 3 preferred order categories with the highest average cashback amount.
SELECT DISTINCT PreferredOrderCat,AVG(CashbackAmount) AS Avg_Cashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY Avg_Cashback DESC
limit 3;

-- Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders.
SELECT PreferredPaymentMode
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING ROUND(AVG(Tenure))=10
AND SUM(OrderCount)>500;
 
-- Categorize customers based on their distance from the warehouse to home such as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km, 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the churn status breakdown for each distance category.

SELECT ChurnStatus,CASE
 WHEN WarehouseToHome<=5 THEN 'Very Close Distance'
 WHEN WarehouseToHome<=10 THEN 'Close Distance'
 WHEN WarehouseToHome<=15 THEN 'Moderate Distance'
 ELSE 'Far Distance'
END AS DistanceType ,
COUNT(*) AS CustCount
FROM customer_churn
GROUP BY ChurnStatus,DistanceType
ORDER BY ChurnStatus DESC;

-- List the customer’s order details who are married, live in City Tier-1, and their order counts are more than the average number of orders placed by all customers.
SELECT * 
FROM customer_churn
WHERE MaritalStatus='Married' 
AND CityTier=1  
AND OrderCount>(SELECT AVG(OrderCount)FROM customer_churn);

-- Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the following data:
CREATE TABLE customer_returns (
ReturnID INT  PRIMARY KEY,
CustomerID INT,
ReturnDate DATE,
RefundAmount INT,
FOREIGN KEY (CustomerID) REFERENCES customer_churn(CustomerID));
DESC customer_returns;
INSERT INTO customer_returns VALUES
(1001,50022,'2023-01-01',2130),
(1002,50316,'2023-01-23',2000),
(1003,51099,'2023-02-14',2290),
(1004,52321,'2023-03-08',2510),
(1005,52928,'2023-03-20',3000),
(1006,53749,'2023-04-17',1740),
(1007,54206,'2023-04-21',3250),
(1008,54838,'2023-04-30',1990);
SELECT * FROM  customer_returns;
SELECT * FROM  customer_churn;

-- Display the return details along with the customer details of those who have churned and have made complaints.
SELECT * 
FROM customer_churn 
INNER JOIN customer_returns ON
customer_churn.CustomerID=customer_returns.CustomerID
WHERE ChurnStatus='Churned'
AND ComplaintReceived = 'Yes';
 