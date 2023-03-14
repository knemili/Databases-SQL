
# of times product purchased
SELECT B.Product_Name, COUNT(A.Product_HSN_Code) AS "No. of times Purchased/Sold" 
FROM purchasebill_product A
LEFT JOIN product B
ON A.Product_HSN_Code = B.Product_HSN_Code
GROUP BY B.Product_Name
ORDER BY COUNT(A.Product_HSN_Code) DESC
LIMIT 3;

# Categories:
SELECT DISTINCT Category FROM category

# Most Purchased Product (Understanding which product was purchased the most, suggestion can be given to say so and so category code and HSN can be stocked up)
SELECT B.Product_Name, COUNT(A.Product_HSN_Code) AS "No. of times Purchased/Sold" 
FROM purchasebill_product A
LEFT JOIN product B
ON A.Product_HSN_Code = B.Product_HSN_Code
GROUP BY B.Product_Name
ORDER BY COUNT(A.Product_HSN_Code) DESC
LIMIT 1;

# Most Purchased product in each category (Understanding which product was purchased the most, suggestion can be given to say so and so category code and HSN can be stocked up)
SELECT * FROM 
(SELECT C.Category, A.Product_Name, COUNT(B.Product_HSN_Code) AS "No. of times Purchased/Sold",
ROW_NUMBER() OVER (PARTITION BY C.Category ORDER BY COUNT(B.Product_HSN_Code) DESC) AS Rank_No 
FROM product A
LEFT JOIN purchasebill_product B
ON A.Product_HSN_Code = B.Product_HSN_Code
LEFT JOIN category C
ON A.Category_Code = C.Category_Code
GROUP BY C.Category, A.Product_Name) C
WHERE C.Rank_No = 1;

# Most Purchased from which dealer
SELECT B.Dealer_Name, COUNT(DISTINCT(A.Purchase_BillNo)) AS "No. of bills", 
SUM(A.Net_Value) AS "Total purchase value", 
SUM(A.Net_Value)/COUNT(DISTINCT(A.Purchase_BillNo)) AS "Average Purchase Value"
FROM purchasebill_product A
LEFT JOIN dealer B
ON A.Dealer_TIN = B.Dealer_TIN
GROUP BY A.Dealer_TIN
ORDER BY SUM(A.Net_Value)/COUNT(DISTINCT(A.Purchase_BillNo)) DESC;

# Total Purchase from each dealer
SELECT B.Dealer_Name, SUM(A.Net_Value) AS "Total purchase value" 
FROM purchasebill_product A
LEFT JOIN dealer B
ON A.Dealer_TIN = B.Dealer_TIN
GROUP BY A.Dealer_TIN
ORDER BY SUM(A.Net_Value) DESC;

# Avg purchases from each dealer
SELECT B.Dealer_Name, SUM(A.Net_Value)/COUNT(DISTINCT(A.Purchase_BillNo)) AS "Average Purchase Value" 
FROM purchasebill_product A
LEFT JOIN dealer B
ON A.Dealer_TIN = B.Dealer_TIN
GROUP BY A.Dealer_TIN
ORDER BY SUM(A.Net_Value)/COUNT(DISTINCT(A.Purchase_BillNo)) DESC;

# Category purchased the most
SELECT C.Category, COUNT(*) AS "No. of times Purchased/Sold"
FROM product A
LEFT JOIN purchasebill_product B
ON A.Product_HSN_Code = B.Product_HSN_Code
LEFT JOIN category C
ON A.Category_Code = C.Category_Code
GROUP BY C.Category;

# Vehicle type mostly used for transportation
SELECT B.Vehicle_Type, COUNT(DISTINCT(A.Purchase_BillNo)) AS "No. of drops/pickups" 
FROM purchasebill_product A
LEFT JOIN transportation B
ON A.Vehicle_No = B.Vehicle_No
GROUP BY B.Vehicle_Type
ORDER BY COUNT(DISTINCT(A.Purchase_BillNo)) DESC;

# Vehicle mostly used for transportation
SELECT A.Vehicle_No, B.Vehicle_Type, COUNT(DISTINCT(A.Purchase_BillNo)) AS "No. of drops/pickups" 
FROM purchasebill_product A
LEFT JOIN transportation B
ON A.Vehicle_No = B.Vehicle_No
GROUP BY B.Vehicle_Type, A.Vehicle_No
ORDER BY COUNT(DISTINCT(A.Purchase_BillNo)) DESC;

# Which dealer gave the best and worst price for each category across months
SELECT DISTINCT DATE_FORMAT(D.Purchase_Date, "%M-%Y") AS "Month", c.Category, E.Dealer_Name, (B.Price_per_kg) AS "Price Per Kg"
FROM product A
LEFT JOIN purchasebill_product B
ON A.Product_HSN_Code = B.Product_HSN_Code
LEFT JOIN category C
ON A.Category_Code = C.Category_Code
LEFT JOIN PurchaseBill D
ON B.Purchase_BillNo = D.Purchase_BillNo
LEFT JOIN dealer E
ON B.Dealer_TIN = E.Dealer_TIN
GROUP BY C.Category, month(D.Purchase_Date), B.Dealer_TIN
ORDER BY month(D.Purchase_Date), C.Category, (B.Price_per_kg) DESC;

# Profit Per Month
SELECT SUM(A.Net_Value) AS Purchase, SUM(B.Net_Value) AS Sales, 
SUM(B.Net_Value) - SUM(A.Net_Value) AS Profit, 
ROUND(((SUM(B.Net_Value) - SUM(A.Net_Value))/SUM(A.Net_Value))*100,2) AS "Profit %"
FROM purchasebill_product A, salesbill_product B

# total number of customers
SELECT DISTINCT Customer_TIN, Customer_Name
FROM Customer

# total number of dealers
SELECT DISTINCT Dealer_TIN, Dealer_Name
FROM dealer

# Most sold to which customer
SELECT B.Customer_Name, COUNT(DISTINCT(A.Sales_BillNo)) AS "No. of bills",
SUM(A.Net_Value)  AS "Total purchase value",
SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) AS "Average purchase value" 
FROM salesbill_product A
LEFT JOIN Customer B
ON A.Customer_TIN = B.Customer_TIN
GROUP BY A.Customer_TIN
ORDER BY SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) DESC;

# Total sold to which customer
SELECT B.Customer_Name, SUM(A.Net_Value)  AS "Total purchase value" 
FROM salesbill_product A
LEFT JOIN Customer B
ON A.Customer_TIN = B.Customer_TIN
GROUP BY A.Customer_TIN
ORDER BY SUM(A.Net_Value) DESC;

# Avg sold to which customer
SELECT B.Customer_Name, SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) AS "Average purchase value" 
FROM salesbill_product A
LEFT JOIN Customer B
ON A.Customer_TIN = B.Customer_TIN
GROUP BY A.Customer_TIN
ORDER BY SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) DESC;

# General CGST %, SGST %
SELECT CONCAT(ROUND((AVG(CGST/Product_Value)*100),2), '%') AS "Average CGST %", 
CONCAT(ROUND((AVG(SGST/Product_Value)*100),2), '%') AS "Average SGST %"
FROM purchasebill_product

# Which Mode of Billing was done the most
SELECT Mode_of_Bill, COUNT(*) AS "No of bills"
FROM salesbill
GROUP BY Mode_of_Bill
ORDER BY COUNT(*) DESC

# Average value of bill for EWay vs Normal
SELECT B.Mode_of_Bill, SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) AS "Average purchase value" 
FROM salesbill_product A
LEFT JOIN salesbill B
ON A.Sales_BillNo = B.Sales_BillNo
GROUP BY B.Mode_of_Bill
ORDER BY SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) DESC

# Which customers bills were most for EWay and Least for Eway
SELECT B.Mode_of_Bill, C.Customer_Name, SUM(A.Net_Value) AS "Total Purchase Value", 
COUNT(DISTINCT(A.Sales_BillNo)) AS "No. of bills", 
SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) AS "Average purchase value"
FROM salesbill_product A
LEFT JOIN salesbill B
ON A.Sales_BillNo = B.Sales_BillNo
LEFT JOIN customer C
ON A.Customer_TIN = C.Customer_TIN
GROUP BY B.Mode_of_Bill, C.Customer_Name
ORDER BY SUM(A.Net_Value)/COUNT(DISTINCT(A.Sales_BillNo)) DESC