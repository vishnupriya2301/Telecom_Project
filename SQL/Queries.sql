SQL queries :

Basic Select & Filtering

1.Get all call records for customers who used a Postpaid plan.
 query : select * from Customer_Data where Plan_Type = 'Postpaid';

2.Find all calls made from London that lasted more than 10 minutes.
query : select * from Customer_Data where Location = 'London' and Call_Duration_Mins > 10;
--------------------------------------------------------------------------
Aggregations & Grouping

3.Calculate the total call duration and total call cost per CallType.
query : select sum(Call_Duration_Mins) as 'Total Call Duration' ,sum(call_cost) as 'Total Call Cost' from Customer_Data group by Plan_Type;

4.Find the average data usage per customer plan type (Prepaid vs Postpaid).
query :select avg(Data_Usage_MB) as 'Average Data Usage' from Customer_Data group by Plan_Type;

5. Count the number of calls per location.
query: select location,count(Customer_ID) as 'Number of Calls' from Customer_Data group by location;
-----------------------------------------------------------------------------------
Sorting & Limiting 

6.List the top 10 customers who have the highest total call cost.
query :select Customer_ID as 'Top 10 customers',sum(call_cost) as Total_Cost from Customer_Data group by Customer_ID order by Total_Cost desc limit 10;

7.how the 5 longest calls in the dataset.
query : select * from Customer_data order by Call_Duration_Mins Desc limit 5;

------------------------------------------------------------------------------------

Date Functions

8. Find the number of calls made each month in 2025.
query : select substr(Call_Date,4,2) as Month, count(*) as CallCount from Customer_Data Where substr(Call_Date, 7, 4) = '2025' 
Group By Month Order By Month;

9. Calculate the tenure (in years) of each customer based on the CustomerSince date.
query : Select Customer_ID,Round((Julianday(substr(Customer_Tenure, 7, 4) || '-' || substr(Customer_Tenure, 4, 2) || '-' || substr(Customer_Tenure, 1, 2)
          ) - Julianday('2025-08-01')) / -365.0, 2
       ) as TenureYears From Customer_Data Group by Customer_ID;
-------------------------------------------------------------------------------------

Conditional Aggregation

10. Calculate the total call cost separately for Local, International, and Roaming calls per plan type.
query : Select Plan_Type,
       Sum(Case When Call_Type = 'Local' Then Call_Cost Else 0 End) As LocalCost,
       Sum(Case When Call_Type = 'International' Then Call_Cost Else 0 End) As InternationalCost,
       Sum(Case When Call_Type = 'Roaming' Then Call_Cost Else 0 End) As RoamingCost
From Customer_Data
Group By Plan_Type;

11. Find the percentage of calls that are International for each location.
query : Select Location,
       Count(*) AS TotalCalls,
       Sum(Case When Call_Type = 'International' Then 1 Else 0 End) AS IntlCalls,
       Round(100.0 * Sum(Case When Call_Type = 'International' Then 1 Else 0 End) / Count(*), 2) AS IntlCallPercentage
From Customer_Data
Group By Location;

--------------------------------------------------------------------------------------
Window Functions

12: Show each customer’s call records along with a running total of call duration ordered by CallDate.
query : Select Customer_ID, Call_Date, Call_Duration_Mins,
       Sum(Call_Duration_Mins) Over (Partition By Customer_ID Order by Call_Date Rows Between UNBOUNDED Preceding And Current row) AS RunningTotalDuration
From Customer_Data;

13. Find the rank of customers based on their total data usage.
query : Select Customer_ID, 
       Sum(Data_Usage_MB) AS TotalDataUsage,
       Rank() Over (Order By Sum(Data_Usage_MB) Desc) AS UsageRank
FROM Customer_Data
GROUP BY Customer_ID;
-----------------------------------------------------------------------------------------

Complex Filtering & Subqueries

14. List customers who have made calls only in one call type (e.g., only Local calls).
query : SELECT Customer_ID
FROM Customer_Data
GROUP BY Customer_ID
Having Count(Distinct Call_Type) = 1;

15. Find customers whose total data usage exceeds the average data usage of all customers.
query : Select Customer_ID, 
       Sum(Data_Usage_MB) As TotalUsage
FROM Customer_Data
Group By Customer_ID
Having Sum(Data_Usage_MB) > (
    Select Avg(CustomerTotal)
    From (
        Select Sum(Data_Usage_MB) As CustomerTotal
        FROM Customer_data
        GROUP BY Customer_ID
    )
);

-----------------------------------------------------------------------------------------

Joins 

16.Show each customer’s name, city, and their total call cost.
Query : Select c.Customer_Name, c.City, Sum(t.Call_Cost) AS TotalCost
From Customer_Data t
Join customer c ON t.Customer_ID = c.Customer_ID
Group By c.Customer_Name, c.City
Order By TotalCost DESC;

17. Find customers who made international calls and show their plan type & total call duration.
query : Select c.Customer_Name, t.Plan_Type, Sum(t.Call_Duration_Mins) AS TotalMinutes
From Customer_data t
Join customer c ON t.Customer_ID = c.Customer_ID
Where t.Call_Type = 'International'
Group By c.Customer_Name, t.Plan_Type
Order By TotalMinutes DESC;


18.Show the top 5 customers by data usage along with their gender & city.
Query : Select c.Customer_Name, c.Gender, c.City, SUM(t.Data_Usage_MB) AS TotalData
FROM Customer_data t
Join customer c ON t.Customer_ID = c.Customer_ID
Group By c.Customer_Name, c.Gender, c.City
Order By TotalData Desc
Limit 5;
---------------------------------------------------
