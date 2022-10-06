
SELECT *
FROM Sales_2019


--Change column names
 EXEC sp_rename '[Product_Sales].[dbo].[Sales_2019]."order id"' , 'OrderID', 'COLUMN'
 EXEC sp_rename '[Product_Sales].[dbo].[Sales_2019]."Quantity Ordered"' , 'Quantity', 'COLUMN'
 EXEC sp_rename '[Product_Sales].[dbo].[Sales_2019]."Price each"' , 'Price', 'COLUMN'
 EXEC sp_rename '[Product_Sales].[dbo].[Sales_2019]."Order Date"' , 'Date', 'COLUMN'
 EXEC sp_rename '[Product_Sales].[dbo].[Sales_2019]."Purchase Address"' , 'Address', 'COLUMN'

 --Delete rows that looked like column headers
 DELETE FROM Sales_2019
 WHERE orderid ='order id'

 --Delete empty rows
 DELETE FROM Sales_2019
 WHERE orderid = ''

 --Split Address column into city/state
ALTER TABLE sales_2019
ADD 
	State varchar(50),
	City varchar(50);

Update sales_2019
SET state =  SUBSTRING(PARSENAME(REPLACE(REPLACE(address,' " ',''),',','.'),1),1,3) FROM sales_2019

Update sales_2019
SET city = PARSENAME(REPLACE(REPLACE(address,' " ',''),',','.'),2) FROM sales_2019

ALTER TABLE sales_2019
DROP COLUMN address

--Split date and time into separate columns
ALTER TABLE sales_2019
ADD 
	Time time(0)

Update sales_2019
SET time = PARSENAME(REPLACE(date,' ','.'),1) FROM sales_2019

Update sales_2019
SET date = PARSENAME(REPLACE(date,' ','.'),2) FROM sales_2019


--Add time interval column
ALTER TABLE sales_2019
ADD Time_Interval int;

UPDATE sales_2019
SET Time_Interval = DATEPART(hour,time)


--Which cities were top 3 in sales?

SELECT TOP 3 City, sum(sales) Sales 
FROM sales_2019
GROUP BY city
ORDER BY sales DESC

--What were the top 3 months in sales?

WITH cte AS (
	SELECT *, DATENAME(mm,date) as Month FROM sales_2019
)
SELECT Top 3 Month, sum(Sales) as Sales
FROM cte
GROUP BY month
ORDER BY sales DESC

--What time should we display adverstisement to maximize likelihood of customer's buying product?

--First figure out average sales per hour
With cte AS 
(
SELECT sum(sales) Sales, Time_interval
FROM Sales_2019
GROUP BY time_interval
)
SELECT avg(sales) as Average 
FROM cte

--Then filter for time where sales > average
SELECT sum(sales), Time_Interval  FROM Sales_2019
GROUP BY time_interval
HAVING sum(sales) > 1450000
ORDER BY time_interval

--What products are most often sold together?

WITH cte AS (
SELECT a.Product as Product1, b.Product as Product2, count(*) Times_sold
FROM Sales_2019 a JOIN Sales_2019 b	
ON a.orderid = b.orderid
AND a.product != b.product
GROUP BY a.product, b.product
)
SELECT * FROM cte
WHERE EXISTS (
	SELECT * FROM cte as cte2
	WHERE cte.product1 = cte2.product2
	AND cte.product2 = cte2.product1
	AND cte.product1 < cte2.product1
)
ORDER BY times_sold DESC




