


--------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------DATA AUDIT & Data Cleaning-------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------



--1) Basic row counts for each table

SELECT 'Insurance' AS table_name, COUNT(*) AS row_count FROM insurance_data
UNION ALL
SELECT 'Vendor', COUNT(*) FROM Vendor_data
UNION ALL
SELECT 'Employee', COUNT(*) FROM employee_data;


/* 2) Columns & data types for each table */
-- Insurance table schema
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Insurance_data'


-- Vendor schema
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Vendor_data'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS

-- Employee schema
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee_data'


/* 3) Primary Key Integrity Check*/

select distinct AGENT_ID, count(*)
from employee_data
group by AGENT_ID
having count(*)>1; 
--The Employee table has a Primary key Agent_id.

select distinct VENDOR_ID, count(*)
from vendor_data
group by VENDOR_ID
having count(*)>1; 
-- The VendorID acts as Primary key in the Vendor table

SELECT TRANSACTION_ID, COUNT(*) AS cnt
FROM insurance_data
GROUP BY TRANSACTION_ID
HAVING COUNT(*) > 1
ORDER BY cnt DESC;
-- No duplicate Transaction ID 


--4) Duplicate Customers Check
SELECT CUSTOMER_NAME, ADDRESS_LINE1, ADDRESS_LINE2, CITY, COUNT(*) AS cnt
FROM Insurance_data
GROUP BY CUSTOMER_NAME, ADDRESS_LINE1, ADDRESS_LINE2, CITY
HAVING COUNT(*) > 1;

--5) FK Consistency Check
Select distinct Vendor_id 
from vendor_data
where VENDOR_ID not in ( select VENDOR_ID from vendor_data)
--No orphan VendorID 


Select distinct Agent_ID
from  insurance_data
where AGENT_ID not in (select Agent_ID from employee_data)
-- No orphan AgentID


--6) Distinct counts for high-cardinality columns
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT TRANSACTION_ID) AS distinct_transaction_id,
    COUNT(DISTINCT POLICY_NUMBER) AS distinct_policy_number,
    COUNT(DISTINCT CUSTOMER_ID) AS distinct_customer_id,
    COUNT(DISTINCT VENDOR_ID) AS distinct_vendor_id,
    COUNT(DISTINCT AGENT_ID) AS distinct_agent_id,
    COUNT(DISTINCT CITY) AS distinct_city,
    COUNT(DISTINCT STATE) AS distinct_state
FROM Insurance_data;




--7) Data Timeframe
SELECT 
    MIN(POLICY_EFF_DT) AS min_policy_eff_dt, MAX(POLICY_EFF_DT) AS max_policy_eff_dt,
    MIN(LOSS_DT) AS min_loss_dt, MAX(LOSS_DT) AS max_loss_dt,
    MIN(REPORT_DT) AS min_report_dt, MAX(REPORT_DT) AS max_report_dt
FROM Insurance_data;
--The data corresponds to policies sold within a period of June,2010 to January 2020.

SELECT TRANSACTION_ID, POLICY_EFF_DT, LOSS_DT, REPORT_DT, TENURE
FROM insurance_data
WHERE LOSS_DT IS NULL OR REPORT_DT IS NULL OR POLICY_EFF_DT IS NULL
   OR LOSS_DT > REPORT_DT OR POLICY_EFF_DT > LOSS_DT
ORDER BY LOSS_DT DESC;
--There is no date anomaly in the data.


--8) Null values check and Preprocessing
--i)
select * from Insurance_data where Vendor_id is Null  
--There are 3245 claims in which there is o vendor mentioned

Update Insurance_data 
Set VENDOR_ID = 'No Vendor Alloted'
Where VENDOR_ID is Null

--ii)
select * from Insurance_data where CITY is Null 
--There are 54 customers who have not given their City details.

Update Insurance_data
SEt CITY = 'Others'
where City is NULL

--iii)
select  * from Insurance_data where INCIDENT_CITY is NULL
-- There are 46 claims in which Incident City has not been reported

Update insurance_data
SEt INCIDENT_CITY = 'Unknown'
where INCIDENT_CITY is NULL



--iv)
select * from insurance_data
where ADDRESS_LINE2 is NULL
-- Since the Address Line 2 has 8505 rows as NULL out of total 10000 we can go about Dropping this column from the table

Alter Table Insurance_data
Drop Column Address_Line2


--9) Checking for logical fallacies in the data 

--i) Checking for records in which Policy Effectiveness Date > Loss Date
SELECT COUNT(*) AS Invalid_Loss_Greater_Than_Report_date
FROM insurance_data
WHERE LOSS_DT > REPORT_DT;

--ii) Checking for records in which Report date < Loss Date
SELECT COUNT(*) AS Invalid_Loss_Greater_Than_Report_date
FROM insurance_data
WHERE LOSS_DT > REPORT_DT;

--iii) Tenure is generally defined as time between policy effectiness date and loss date but here tenure is used to represent difference between maturity date & policy effectiveness date.
Select Policy_eff_DT, Loss_DT,Tenure, datediff(month, Policy_eff_DT, Loss_DT)
From insurance_data
where datediff(month, Policy_eff_DT, Loss_DT) != TENURE

--Adding Tenure column based on our definition
ALTER TABLE Insurance_data
ADD TENURE INT;
Update insurance_data
Set TENURE = Datediff(month, POLICY_EFF_DT, LOSS_DT);

--10) Claim Amount Outliers
SELECT 
    TRANSACTION_ID,
    CLAIM_AMOUNT,
    CUME_DIST() OVER (ORDER BY CLAIM_AMOUNT) * 100 AS claim_percentile_100
FROM dbo.insurance_data;
-- We see that there is no abrupt jump even in the 95 to 100 percentile claims amount, so no outliers.




-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Exploratory Data Analysis-----------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--i) Insurance Table

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT TRANSACTION_ID) AS distinct_txn,
  COUNT(DISTINCT CUSTOMER_ID) AS distinct_customers,
  COUNT(DISTINCT Insurance_type) AS Insurance_types,
  COUNT(DISTINCT Vendor_ID) AS Vendor_Count,
( Select count(*) from insurance_data where Vendor_ID != 'No Vendor Alloted') as Claims_with_Vendor,
( Select count(*) from insurance_data where Vendor_ID != 'No Vendor Alloted')*1.00/ (select count(distinct VENDOR_ID) from insurance_data where VENDOR_ID != 'No Vendor Alloted') as Avg_claims_per_vendor,
  COUNT(DISTINCT AGENT_ID) AS Agent_Count,
  Count(*)*1.00/Count(distinct AGENT_ID) AS Avg_claims_per_agent,
  COUNT(DISTINCT STATE) as States_count,
  COUNT(Distinct Incident_State) AS Incident_state_count,
  Count(Distinct Postal_code) AS Customer_PIN_Code_Count,
  MIN(CLAIM_AMOUNT) AS min_claim,
  AVG(CLAIM_AMOUNT) AS avg_claim,
  MAX(CLAIM_AMOUNT) AS max_claim,
  MIN(PREMIUM_AMOUNT) AS min_prem,
  AVG(PREMIUM_AMOUNT) AS avg_prem,
  MAX(PREMIUM_AMOUNT) AS max_prem,
  MIN(TENURE) AS min_tenure,
  AVG(TENURE) AS avg_tenure,
  MAX(TENURE) AS max_tenure,
  MIN(AGE) AS min_age,
  AVG(AGE) AS avg_age,
  MAX(AGE) AS max_age,
  AVG(datediff(day,loss_dt,report_dt)) AS Avg_time_to_report,
  SUM(Claim_Amount) AS Total_claims_amount_filed,
  (SELECT SUM(CLAIM_AMOUNT) from Insurance_data where CLAIM_STATUS = 'A') AS Total_Claims_paid,
 (Select SUM(PREMIUM_AMOUNT * TENURE) from insurance_data where INSURANCE_TYPE <> 'Life') +
 (Select SUM(PREMIUM_AMOUNT * (Datediff(month,POLICY_EFF_DT,LOSS_DT))) from insurance_data where INSURANCE_TYPE = 'Life') AS Total_premium,
 SUM(CLAIM_AMOUNT) *1.00 / SUM(PREMIUM_AMOUNT  * TENURE) AS Loss_ratio,
 COUNT(Distinct ROUTING_NUMBER) AS Bank_IFSC_Count,
 COUNT(Distinct ACCT_NUMBER) AS Bank_Account_Count
FROM Insurance_data


 --Checking on median values
SELECT
   PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY CLAIM_AMOUNT) OVER () AS median_claim,
   PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY PREMIUM_AMOUNT) OVER () AS median_prem,
   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TENURE) OVER () AS median_tenure,
   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY AGE) OVER () AS median_age 
FROM insurance_data




--ii) Employee Table

select
COUNT(Distinct AGENT_ID) AS Agent_count,
COUNT(Distinct State) AS Agent_State_count,
COUNT(Distinct POSTAL_CODE) AS Agent_PIN_Code_count,
(select COUNT(DISTINCT CITY) from employee_data where City is not null) AS Vendor_city_count,
COUNT(Distinct EMP_ROUTING_NUMBER) AS Agent_IFSC_count,
COUNT(Distinct EMP_ACCT_NUMBER) AS Agent_Bank_Account_Count,
MIN(Date_of_Joining) AS First_Agent_Joining_date,
MAX(DATE_OF_JOINING) AS Last_Agent_Joining_date
from employee_data

--iii) Vendor Table
Select
COUNT(Distinct Vendor_ID) AS Vendor_Count,
COUNT(Distinct State) AS Vendor_State_count,
(select COUNT(DISTINCT CITY) from vendor_data where City is not null) AS Vendor_city_count,
COUNT(Distinct POSTAL_CODE) AS Vendor_PIN_Code_count
from vendor_data






--------------------------------------------------------------------------
-----------------------Claim Level Analysis-------------------------------
--------------------------------------------------------------------------

--1) Claim Amount Distribution statistics
SELECT 
    COUNT(*) AS total_claims,
    MIN(CLAIM_AMOUNT) AS min_claim,
    MAX(CLAIM_AMOUNT) AS max_claim,
    AVG(CLAIM_AMOUNT) AS avg_claim
   FROM Insurance_data;

SELECT
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY CLAIM_AMOUNT) OVER() AS p25,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CLAIM_AMOUNT) OVER() AS median_claim,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY CLAIM_AMOUNT) OVER() AS p75,
    PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY CLAIM_AMOUNT) OVER() AS p95,
    PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CLAIM_AMOUNT) OVER() AS p99
 FROM insurance_data


--2) Claim Count distribution and Claim Amount distribution by Insurance Type
 SELECT 
 DISTINCT INSURANCE_TYPE, 
 COUNT(*) AS Claims_Filed,
 SUM(Claim_Amount) AS Total_Claim_Amount,
 SUM(Claim_Amount) *100.00 / (Select SUM(Claim_Amount) from insurance_data) as pct_Claim_Amount,
 AVG(CLAIM_AMOUNT) AS Avg_Claim
 FROM insurance_data
 GROUP BY INSURANCE_TYPE
 ORDER BY Claims_Filed DESC


 --3) Total Premiums by Insurance_types
 SELECT 
 DISTINCT INSURANCE_TYPE,
SUM(Premium_amount*Tenure) AS Total_premium,
SUM(Premium_amount*Tenure)*100.00/ (SELECT SUM(PREMIUM_AMOUNT*TENURE) from insurance_data) as pct_premium
 FROM insurance_data
 Group by INSURANCE_TYPE


--4) Claim-to-Premium Ratio Distribution
with approved_claims as
(SELECT * from insurance_data where CLAIM_STATUS ='A'
) Select
 Distinct Insurance_Type, 
 SUM(Claim_amount) / SUM(Premium_amount*tenure) as Loss_Ratio
 from approved_claims
 group by Insurance_type;

 --5) Time To Report
 with approved_claims as
(SELECT * from insurance_data where CLAIM_STATUS ='A'
)
Select
 distinct DateDiff(day,loss_dt,report_dt) Time_to_report,
 count(*) AS Claims_count,
 avg(claim_amount) AS Avg_Claim_Severity
 from approved_claims
 group by DateDiff(day,loss_dt,report_dt)
 order by DateDiff(day,loss_dt,report_dt) asc


--6) Claim approval percentage by Insurance Type
SELECT 
    INSURANCE_TYPE,
    COUNT(*) AS total_claims,
    SUM(CASE WHEN CLAIM_STATUS = 'A' THEN 1 ELSE 0 END) AS approved_claims,
    SUM(CASE WHEN CLAIM_STATUS = 'D' THEN 1 ELSE 0 END) AS declined_claims,
    CAST(SUM(CASE WHEN CLAIM_STATUS = 'A' THEN 1 ELSE 0 END) * 100.0  / COUNT(*) AS DECIMAL(10,2)) AS approval_rate_pct,
    CAST(SUM(CASE WHEN CLAIM_STATUS = 'D' THEN 1 ELSE 0 END) * 100.0  / COUNT(*) AS DECIMAL(10,2)) AS decline_rate_pct
FROM insurance_data
GROUP BY INSURANCE_TYPE
ORDER BY approval_rate_pct DESC;


 --7) Claims distribution by state
  with approved_claims as
(SELECT * from insurance_data where CLAIM_STATUS ='A'
)
SELECT 
 distinct State, 
 Sum(Claim_amount) as Total_processed_claim_amount,
  Sum(Claim_amount)*100.00 /  (Select SUM(Claim_amount) from insurance_data) as pct_share_Claim_amount,
  Count(*) as Total_processed_claim_count,
  Count(*) *100.00 / (Select Count(*) from insurance_data) as pct_share_Claims_count
 from approved_claims
 group by State 
 order by pct_share_Claims_count desc


--8) Claim Distribution by Incident Hours
Select Distinct INCIDENT_HOUR_OF_THE_DAY,
COUNT(*) as Claim_count,
AVG(CLAIM_AMOUNT) as Avg_Claim_Amount
From insurance_data
group by  INCIDENT_HOUR_OF_THE_DAY 
order by INCIDENT_HOUR_OF_THE_DAY asc




----------------------------------------------------------------------------------------------------
------------------------------Customer Demographics Analysis-----------------------------------------------
----------------------------------------------------------------------------------------------------


--1) Customer Age Fraud Risk Segmentation
SELECT
    CASE 
        WHEN AGE < 30 THEN '18-30'
        WHEN AGE BETWEEN 30 AND 45 THEN '30-45'
        WHEN AGE BETWEEN 45 AND 60 THEN '45-60'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS customers,
    AVG(CLAIM_AMOUNT) AS avg_claim,
    AVG(CLAIM_AMOUNT/(PREMIUM_AMOUNT*Tenure)) AS avg_loss_ratio
FROM insurance_data
GROUP BY 
    CASE 
        WHEN AGE < 30 THEN '18-30'
        WHEN AGE BETWEEN 30 AND 45 THEN '30-45'
        WHEN AGE BETWEEN 45 AND 60 THEN '45-60'
        ELSE '60+'
    END;


    --2) Time Time taken to Claim by Customer

    SELECT
    CASE 
        WHEN  Datediff(month,policy_eff_dt, report_dt)<6 THEN '<6 months'
        WHEN Datediff(month,policy_eff_dt, report_dt) BETWEEN 6 AND 12 THEN '6-12 months'
        WHEN Datediff(month,policy_eff_dt, report_dt) BETWEEN 12 AND 24 THEN '12–24 months'
        WHEN Datediff(month,policy_eff_dt, report_dt) BETWEEN 24 AND 60 THEN '2–5 years'
        ELSE '5+ years'
    END AS tenure_group,
    COUNT(*) AS customers,
    AVG(CLAIM_AMOUNT) AS avg_claim,
    AVG(CLAIM_AMOUNT * 1.0 / (PREMIUM_AMOUNT* Tenure)) AS avg_loss_ratio
FROM insurance_data
GROUP BY
     CASE 
        WHEN  Datediff(month,policy_eff_dt, report_dt)<6 THEN '<6 months'
        WHEN Datediff(month,policy_eff_dt, report_dt) BETWEEN 6 AND 12 THEN '6-12 months'
        WHEN Datediff(month,policy_eff_dt, report_dt) BETWEEN 12 AND 24 THEN '12–24 months'
        WHEN Datediff(month,policy_eff_dt, report_dt) BETWEEN 24 AND 60 THEN '2–5 years'
        ELSE '5+ years'
    END
ORDER BY tenure_group;



    
--3) Avg claim severity and Avg Loss Ratio by Incident_States 

SELECT
    INCIDENT_STATE,
    Count(*) as Claim_count,
    Count(*) *100.00/ (select count(*) from insurance_data) as pct_claim_count,
    AVG(CLAIM_AMOUNT) AS Avg_claim_amount
FROM insurance_data
GROUP BY INCIDENT_STATE
ORDER BY Avg_claim_amount desc


       
----------------------------------------------------------------------------------------------------------------------
------------------------------------------Vendor Level Analysis-------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

--1) Top 10 Vendors with highest avg claim amount 
SELECT 
    VENDOR_ID,
    COUNT(*) AS claim_alloted,
    AVG(CLAIM_AMOUNT) AS avg_claim_amount,
    SUM(CASE WHEN CLAIM_STATUS = 'A' THEN 1 END) * 100.0 / COUNT(*) AS approval_rate,
    SUM(CLAIM_AMOUNT) AS total_payout
FROM insurance_data
GROUP BY VENDOR_ID
ORDER BY avg_claim_amount desc ;

--2) Top 10 vendors by HIGHEST Loss_Ratio
SELECT top 10
    VENDOR_ID,
    SUM(CLAIM_AMOUNT) AS Total_claim_amount,
    AVG(CLAIM_AMOUNT) AS avg_claim_amount,
    SUM(PREMIUM_AMOUNT*TENURE) AS total_premium,
    SUM(CLAIM_AMOUNT)*1.0 / SUM(PREMIUM_AMOUNT*Tenure) AS vendor_loss_ratio
FROM insurance_data
GROUP BY VENDOR_ID
ORDER BY vendor_loss_ratio ASC;

--3) 
SELECT 
    VENDOR_ID,
    AVG(CLAIM_AMOUNT) AS avg_severity,
    MAX(CLAIM_AMOUNT) AS max_severity,
    COUNT(*) AS claim_count
FROM insurance_data
GROUP BY VENDOR_ID
HAVING AVG(CLAIM_AMOUNT) > (SELECT AVG(CLAIM_AMOUNT) FROM insurance_data) + 3000
ORDER BY avg_severity DESC;


--4) Vendors reporting early 
SELECT 
    VENDOR_ID,
    COUNT(*) AS total_claims,
    SUM(CASE WHEN DATEDIFF(day, LOSS_DT, REPORT_DT) <= 1 THEN 1 END) AS early_reports,
    SUM(CASE WHEN DATEDIFF(day, LOSS_DT, REPORT_DT) <= 1 THEN 1 END)*100.0 / COUNT(*) AS early_report_pct
FROM insurance_data
GROUP BY VENDOR_ID
ORDER BY early_report_pct DESC;

--5) 
SELECT
   distinct
   VENDOR_ID,
    STATE,
    COUNT(*) AS claim_count,
    AVG(CLAIM_AMOUNT) AS avg_claim,
    SUM(CLAIM_AMOUNT) AS total_claim
FROM insurance_data
WHERE VENDOR_ID != 'No Vendor Alloted'
GROUP BY VENDOR_ID, STATE
ORDER BY total_claim DESC;



------------------------------------------------------------------------------------------------------------
-----------------------------Vendor-Agent Collusion--------------------------------------------------------
------------------------------------------------------------------------------------------------------------


SELECT 
    VENDOR_ID,
    AGENT_ID,
    COUNT(*) AS claim_count,
    AVG(CLAIM_AMOUNT) AS avg_claim_amount,
    SUM(CLAIM_AMOUNT) AS total_claim,
    SUM(PREMIUM_AMOUNT) AS total_premium,
    SUM(CLAIM_AMOUNT) * 1.0 / SUM(PREMIUM_AMOUNT*Tenure) AS vendor_agent_loss_ratio
FROM insurance_data
WHERE VENDOR_ID != 'No Vendor Alloted' AND AGENT_ID IS NOT NULL
GROUP BY VENDOR_ID, AGENT_ID
ORDER BY claim_count DESC, vendor_agent_loss_ratio desc;


-----------------------------------------------------------------------------------------------------------
-------------------------------------------Employee Level Analysis-----------------------------------------
-----------------------------------------------------------------------------------------------------------

--1) Approval Rate per Agent
With cte1 as
(
SELECT 
    AGENT_ID,
    COUNT(*) AS total_claims,
    SUM(CASE WHEN CLAIM_STATUS = 'A' THEN 1 ELSE 0 END) AS approved_claims,
    SUM(CASE WHEN CLAIM_STATUS = 'D' THEN 1 ELSE 0 END) AS declined_claims,
    SUM(CASE WHEN CLAIM_STATUS = 'A' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS approval_rate_pct
FROM insurance_data
GROUP BY AGENT_ID
)
SELECT
CASE WHEN approval_rate_pct <95 THEN '<95%'
    WHEN approval_rate_pct BETWEEN 95 AND 99.9999 THEN '95% -99%' 
    ELSE '100%' END AS APPROVAL_RATE_CATEGORY,
    COUNT(AGENT_ID) AS AGENT_COUNT,
    COUNT(AGENT_ID) *100.00 / (select COUNT(*) from cte1) AS pct_share
 FROM CTE1
 GROUP BY CASE WHEN approval_rate_pct <95 THEN '<95%'
    WHEN approval_rate_pct BETWEEN 95 AND 99.9999 THEN '95% -99%' 
    ELSE '100%' END ;




--2) 
SELECT 
    AGENT_ID,
    COUNT(*) AS claim_count,
    AVG(Claim_Amount) AS avg_claim_amount,
    Stdev(Claim_Amount) AS std_claim_amount
FROM insurance_data
GROUP BY AGENT_ID
ORDER BY avg_claim_amount DESC;



-------------------------------------------------------------------------------------------------------------------
----------------------------------------------Temporal Analysis----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

--1)
SELECT 
    DATEPART(YEAR, REPORT_DT) AS year,
    DATEPART(MONTH, REPORT_DT) AS month,
    COUNT(*) AS total_claims,
    SUM(CLAIM_AMOUNT) AS total_claim_amount,
    AVG(CLAIM_AMOUNT) AS avg_claim_amount
FROM insurance_data
GROUP BY DATEPART(YEAR,REPORT_DT ), DATEPART(MONTH, REPORT_DT)
ORDER BY year, month;



--2) 
SELECT 
    DATEPART(YEAR, REPORT_DT) AS year,
    DATEPART(MONTH, REPORT_DT) AS month,
    CAST(AVG(Datediff(day,Loss_DT,Report_DT)) AS DECIMAL(18,6)) AS Time_to_report
FROM insurance_data
GROUP BY  DATEPART(YEAR, REPORT_DT) ,DATEPART(MONTH, REPORT_DT) 
ORDER BY DATEPART(YEAR, REPORT_DT) ,DATEPART(MONTH, REPORT_DT)


--3) 
Select
    DATEPART(YEAR, REPORT_DT) AS year,
    DATEPART(MONTH, REPORT_DT) AS month,
    AVG(Datediff(DAY,report_dt,DATEADD(month,Tenure,Policy_eff_dt))) AS Time_left_for_expiry
FROM insurance_data
GROUP BY DATEPART(YEAR, REPORT_DT) ,DATEPART(MONTH, REPORT_DT) 
ORDER BY DATEPART(YEAR, REPORT_DT) ,DATEPART(MONTH, REPORT_DT)


Select 
policy_number,
policy_eff_dt,
TENURE,
Loss_dt,
claim_status,
DATEADD(month,Tenure,Policy_eff_dt) maturity_dt
from insurance_data
where DATEADD(month,Tenure,Policy_eff_dt) < REPORT_DT






