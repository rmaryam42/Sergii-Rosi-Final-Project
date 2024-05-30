
#### 
SELECT      c.Officer_id, SUM(`Balance 01.05`) AS Balance_05, SUM(`Balance 01.08`) AS Balance_08, `May_Collections`
FROM        `cleaned_data_with_salesofficers` AS c 
JOIN        `staff_effectivness` AS s     
ON          c.Officer_id = s.Officer_id 
GROUP BY    c.Officer_id, `Mar_Collections`, `Apr_Collections`, `May_Collections`;

#### Attempt to calculate the effectivness of the staff in June and July using 2 portfolios
SELECT      c.Officer_id,      
            (SUM(`Balance 01.05`) - SUM(`Balance 01.08`)) AS MayJunJulCollections, SUM(`Balance 01.05`) AS Balance_05, SUM(`Balance 01.08`) AS Balance_08, COUNT(`ClNumber`) AS Credits_in_portfolio, SUM(`OverdueInstallmentsAmount 01.05`) AS OV_AM_05, SUM(`OverdueInstallmentsAmount 01.07`) AS OV_AM_08,   
            `Mar_Collections` AS MarCollections,      
            `Apr_Collections` AS AprCollections,      
            `May_Collections` AS MayCollections  
FROM        `cleaned_data_with_salesofficers` AS c 
JOIN        `staff_effectivness` AS s     
ON          c.Officer_id = s.Officer_id 
GROUP BY    c.Officer_id, `Mar_Collections`, `Apr_Collections`, `May_Collections`;

#### Analyse of the existing portfolios assigned to the Officers
SELECT `Officer_ID`, COUNT(`ClNumber`) AS Credits_in_portfolio, SUM(`OverdueInstallmentsAmount 01.05`) AS OV_AM_05, SUM(`OverdueInstallmentsAmount 01.07`) AS OV_AM_08
FROM  `cleaned_data_with_salesofficers`
group by Officer_ID;

#### Results of the Sales Managers disbursment activities in the past
SELECT      
    c.`SalesMan_ID`, 
    c.`Branch`,     
    CASE 
        WHEN CAST(MAX(s.`Officer_ID`) AS CHAR) = c.`SalesMan_ID` THEN 'WORKS AS OFFICER'
        ELSE 'WORKS NOT AS OFFICER'
    END AS Current_Position,     
    SUM(c.`InitialCreditAmount`) AS Total_Disbursed_Amount,      
    COUNT(c.`ClNumber`) AS Total_Disbursed_Number,     
    SUM(c.`Balance 01.08`) AS Total_Current_Amount,     
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`ClNumber` END) AS Total_Current_Number,     
    SUM(CASE WHEN c.`DaysOverdue 01.08` > 0 THEN c.`Balance 01.08` END) AS Total_NPL_AMOUNT,     
    (SUM(CASE WHEN c.`DaysOverdue 01.08` > 0 THEN c.`Balance 01.08` END) / SUM(c.`InitialCreditAmount`)) AS NPL_Share_BY_AMOUNT,     
    COUNT(CASE WHEN c.`DaysOverdue 01.08` > 0 THEN c.`ClNumber` END) AS Number_of_NPL_Loans,     
    (COUNT(CASE WHEN c.`DaysOverdue 01.08` > 0 THEN c.`ClNumber` END) / COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`ClNumber` END)) AS NPL_Share_BY_NUMBER,     
    COUNT(CASE WHEN c.`DaysOverdue 01.08` = 0 AND c.`Balance 01.08` > 0 THEN c.`ClNumber` END) AS Number_of_PERFORMED_Loans,     
    COUNT(CASE WHEN c.`DaysOverdue 01.08` = 0 AND c.`Balance 01.08` = 0 THEN c.`ClNumber` END) AS Number_of_CLOSED_Loans 
FROM       
    `cleaned_data_with_salesofficers` AS c
LEFT JOIN
    `staff_effectivness` AS s
ON
    CAST(s.`Officer_ID` AS CHAR) = c.`SalesMan_ID`
GROUP BY      
    c.`SalesMan_ID`, c.`Branch`;
    
#### Creating a table to discribe the risk areas correlated to the Sales Manageers
CREATE TABLE risk_area AS
SELECT 
    `SalesMan_ID`, `Branch`,
   
    SUM(`InitialCreditAmount`) AS Total_Disbursed_Amount, 
    COUNT(ClNumber) AS Total_Disbursed_Number,
    SUM(`Balance 01.08`) AS Total_Current_Amount,
    COUNT(CASE WHEN `Balance 01.08` > 0 THEN ClNumber END) AS Total_Current_Number,
    SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) AS Total_NPL_AMOUNT,
    (SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) / SUM(`InitialCreditAmount`)) AS NPL_Share_BY_AMOUNT,
    COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END) AS Number_of_NPL_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END)/COUNT(ClNumber)) AS NPL_Share_BY_NUMBER,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` > 0 THEN ClNumber END) AS Number_of_PERFORMED_Loans,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN ClNumber END) AS Number_of_CLOSED_Loans
FROM  
    `cleaned_data_with_salesofficers`
GROUP BY 
    `SalesMan_ID`, `Branch`;
    
SELECT s.`Officer_ID`, s.`Mar_Collections`
FROM `staff_effectivness` AS s
JOIN `risk_area` AS o ON s.`Officer_ID` = o.`SalesMan_ID`;


### First part of the portfolio analyses (split by Sales Managers)
SELECT `SalesMan_ID`, `Branch`, Total_NPL_AMOUNT, Total_Disbursed_Amount, NPL_Share_BY_AMOUNT, NPL_Share_BY_NUMBER, Total_Disbursed_Number, Number_of_NPL_Loans,
(Total_Disbursed_Amount/Total_Disbursed_Number) AS AV_DISB_AMOUNT
FROM risk_area
WHERE NPL_Share_BY_AMOUNT > (SELECT AVG(NPL_Share_BY_AMOUNT) FROM risk_area) AND NPL_Share_BY_NUMBER > (SELECT AVG(NPL_Share_BY_NUMBER)FROM risk_area) AND Total_NPL_AMOUNT>1000
ORDER BY Total_NPL_AMOUNT DESC
LIMIT 0, 200;

#### Second part of the portfolio analyses (split by Branch)
SELECT `Branch`, 
	SUM(`InitialCreditAmount`) AS Total_Disbursed_Amount, 
    COUNT(ClNumber) AS Total_Disbursed_Number,
    SUM(`Balance 01.08`) AS Total_Current_Amount,
    COUNT(CASE WHEN `Balance 01.08` > 0 THEN ClNumber END) AS Total_Current_Number,
    SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) AS Total_NPL_AMOUNT,
    (SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) / SUM(`InitialCreditAmount`)) AS NPL_Share_BY_AMOUNT,
    COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END) AS Number_of_NPL_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END)/COUNT(ClNumber)) AS NPL_Share_BY_NUMBER,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` > 0 THEN ClNumber END) AS Number_of_PERFORMED_Loans,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN ClNumber END) AS Number_of_CLOSED_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` =  0 THEN ClNumber END)/COUNT(ClNumber)) AS Performed_Share_BY_NUMBER,
	(SUM(`InitialCreditAmount`)/COUNT(ClNumber)) AS AV_DISB_AMOUNT
FROM `cleaned_data_with_salesofficers`
GROUP BY 
    `Branch`
ORDER BY 
    `Branch`
LIMIT 0, 200;


#### Fraud analisys (split by Sales Managers)
SELECT SalesMan_ID,
    SUM(`InitialCreditAmount`) AS Total_Disbursed_Amount,
    COUNT(ClNumber) AS Total_Disbursed_Number,
    SUM(`Balance 01.08`) AS Total_Current_Amount,
    COUNT(CASE WHEN `Balance 01.08` > 0 THEN ClNumber END) AS Total_Current_Number,
    SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) AS Total_NPL_AMOUNT,
    (SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) / SUM(`InitialCreditAmount`)) AS NPL_Share_BY_AMOUNT,
    COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END) AS Number_of_NPL_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END)/COUNT(ClNumber)) AS NPL_Share_BY_NUMBER,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` > 0 THEN ClNumber END) AS Number_of_PERFORMED_Loans,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN ClNumber END) AS Number_of_CLOSED_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` =  0 THEN ClNumber END)/COUNT(ClNumber)) AS Performed_Share_BY_NUMBER,
    (SUM(`InitialCreditAmount`)/COUNT(ClNumber)) AS AV_DISB_AMOUNT
FROM `cleaned_data_with_salesofficers`
GROUP BY 
    SalesMan_ID, `CreateDate`
ORDER BY 
    `CreateDate`
LIMIT 0, 200;

#### Analisys of the clients actuality (split by Recovery officers)
SELECT 
    Officer_ID,
    COUNT(`ClNumber`) AS Total_portfolio_NUMBER,
    COUNT(CASE WHEN Contact_updated_Code = 1 THEN 1 END) AS PhoneNum_real,
    COUNT(CASE WHEN Current_address_updated_Code = 1 THEN 1 END) AS Address_real,
    COUNT(CASE WHEN Client_willing_and_capable_to_pay_Code = 1 THEN 1 END) AS Willing_to_pay
    
FROM 
    cleaned_data_with_salesofficers
GROUP BY 
    Officer_ID
ORDER BY Total_portfolio_NUMBER DESC
LIMIT 0, 200;

#### Portfolio analisys (split by the product type)
SELECT ProductMix,
	SUM(`InitialCreditAmount`) AS Total_Disbursed_Amount, 
    COUNT(ClNumber) AS Total_Disbursed_Number,
    SUM(`Balance 01.08`) AS Total_Current_Amount,
    COUNT(CASE WHEN `Balance 01.08` > 0 THEN ClNumber END) AS Total_Current_Number,
    SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) AS Total_NPL_AMOUNT,
    (SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) / SUM(`InitialCreditAmount`)) AS NPL_Share_BY_AMOUNT,
    COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END) AS Number_of_NPL_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END)/COUNT(ClNumber)) AS NPL_Share_BY_NUMBER,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` > 0 THEN ClNumber END) AS Number_of_PERFORMED_Loans,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN ClNumber END) AS Number_of_CLOSED_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` =  0 THEN ClNumber END)/COUNT(ClNumber)) AS Performed_Share_BY_NUMBER,
	(SUM(`InitialCreditAmount`)/COUNT(ClNumber)) AS AV_DISB_AMOUNT
    
FROM 
    cleaned_data_with_salesofficers

GROUP BY 
    ProductMix
LIMIT 0, 200;

#### Portfolio analisys (split by the case category)
SELECT Category,
	SUM(`InitialCreditAmount`) AS Total_Disbursed_Amount, 
    COUNT(ClNumber) AS Total_Disbursed_Number,
    SUM(`Balance 01.08`) AS Total_Current_Amount,
    COUNT(CASE WHEN `Balance 01.08` > 0 THEN ClNumber END) AS Total_Current_Number,
    SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) AS Total_NPL_AMOUNT,
    (SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) / SUM(`InitialCreditAmount`)) AS NPL_Share_BY_AMOUNT,
    COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END) AS Number_of_NPL_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END)/COUNT(ClNumber)) AS NPL_Share_BY_NUMBER,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` > 0 THEN ClNumber END) AS Number_of_PERFORMED_Loans,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN ClNumber END) AS Number_of_CLOSED_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` =  0 THEN ClNumber END)/COUNT(ClNumber)) AS Performed_Share_BY_NUMBER,
	(SUM(`InitialCreditAmount`)/COUNT(ClNumber)) AS AV_DISB_AMOUNT
    
FROM 
    cleaned_data_with_salesofficers

GROUP BY 
    Category
    
LIMIT 0, 200;

#### Portfolio analisys (the share of the portfolio created by Sales Managers who are Officers at the moment)
SELECT Officer_ID,
	SUM(CASE WHEN `Category` = 'Fraud or Audit Issues' THEN `InitialCreditAmount` END) AS Total_Disbursed_Amount, 
    COUNT(CASE WHEN `Category` = 'Fraud or Audit Issues' THEN ClNumber END) AS Total_Disbursed_Number,
    SUM(CASE WHEN `Category` = 'Fraud or Audit Issues' AND `Balance 01.08` > 0 THEN `Balance 01.08` END) AS Total_Current_Amount,
    COUNT(CASE WHEN `Category` = 'Fraud or Audit Issues' AND `Balance 01.08` > 0 THEN ClNumber END) AS Total_Current_Number


FROM 
    cleaned_data_with_salesofficers

GROUP BY 
    Officer_ID
ORDER BY Officer_ID
    
LIMIT 0, 200;

#### Portfolio overview
SELECT 
	SUM(`InitialCreditAmount`) AS Total_Disbursed_Amount, 
    COUNT(ClNumber) AS Total_Disbursed_Number,
    SUM(`Balance 01.08`) AS Total_Current_Amount,
    COUNT(CASE WHEN `Balance 01.08` > 0 THEN ClNumber END) AS Total_Current_Number,
    SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) AS Total_NPL_AMOUNT,
    (SUM(CASE WHEN `DaysOverdue 01.08` > 0 THEN `Balance 01.08` END) / SUM(`InitialCreditAmount`)) AS NPL_Share_BY_AMOUNT,
    COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END) AS Number_of_NPL_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` > 0 THEN ClNumber END)/COUNT(ClNumber)) AS NPL_Share_BY_NUMBER,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` > 0 THEN ClNumber END) AS Number_of_PERFORMED_Loans,
    COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN ClNumber END) AS Number_of_CLOSED_Loans,
    SUM(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN `InitialCreditAmount` END) AS Amount_of_CLOSED_Loans,
    (COUNT(CASE WHEN `DaysOverdue 01.08` =  0  AND `Balance 01.08` > 0 THEN ClNumber END)/COUNT(ClNumber)) AS Performed_Share_BY_NUMBER,
    (SUM(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN `InitialCreditAmount` END)/SUM(`InitialCreditAmount`)) AS CLosed_Share_BY_AMOUNT,
    (COUNT(CASE WHEN `DaysOverdue 01.08` = 0 AND `Balance 01.08` = 0 THEN ClNumber END)/COUNT(ClNumber)) AS CLosed_Share_BY_NUMBER,
	(SUM(`InitialCreditAmount`)/COUNT(ClNumber)) AS AV_DISB_AMOUNT
FROM 
    cleaned_data_with_salesofficers
LIMIT 0, 200;

CREATE TABLE productivity_by_officers AS
SELECT
    c.Officer_ID,

    (CASE WHEN c.Officer_ID IN (SELECT SalesMan_ID FROM cleaned_data_with_salesofficers) THEN 1 ELSE 0 END) AS Former_Sales,
    SUM(c.`Balance 01.08`) AS AssignedPortfolio_Amount,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) AS AssignedPortfolio_Number,
    MAX(s.Mar_Collections) AS Productivity_Mar,
    MAX(s.Apr_Collections) AS Productivity_Apr,
    MAX(s.May_Collections) AS Productivity_May,
    SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) AS Productivity_May_Jun_Jul,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jun,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jul,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) AS Clients_in_contact,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 AS Time_for_calls,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4 AS Time_for_visits,
    (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4) AS Total_time,
    (22 * 8 / (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4)) AS Possibility_to_KPI
FROM
    cleaned_data_with_salesofficers AS c
JOIN
    staff_effectivness AS s ON c.`Officer_ID` = s.`Officer_ID`
GROUP BY
    c.Officer_ID
LIMIT
    0, 200;
    
#### Analisys of the staff productivity
CREATE TABLE productivity_by_officers AS
SELECT
    c.SalesMan_ID,

    (CASE WHEN c.SalesMan_ID IN (SELECT Officer_ID FROM cleaned_data_with_salesofficers) THEN 1 ELSE 0 END) AS Former_Sales,
    SUM(c.`Balance 01.08`) AS AssignedPortfolio_Amount,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) AS AssignedPortfolio_Number,
    MAX(s.Mar_Collections) AS Productivity_Mar,
    MAX(s.Apr_Collections) AS Productivity_Apr,
    MAX(s.May_Collections) AS Productivity_May,
    SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) AS Productivity_May_Jun_Jul,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jun,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jul,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) AS Clients_in_contact,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 AS Time_for_calls,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4 AS Time_for_visits,
    (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4) AS Total_time,
    (22 * 8 / (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4)) AS Possibility_to_KPI
FROM
    cleaned_data_with_salesofficers AS c
JOIN
    staff_effectivness AS s ON c.`Officer_ID` = s.`Officer_ID`
GROUP BY
	c.SalesMan_ID
LIMIT
    0, 20000;
    

### To create a separate table for the portfolio created by Officers when thses were SalesMan
CREATE TABLE portfolio_created_by_officers AS
SELECT *	
FROM
    cleaned_data_with_salesofficers 
WHERE Officer_ID IN (SELECT SalesMan_ID FROM cleaned_data_with_salesofficers) 

LIMIT
    0, 200000;
 
 ### The list of credits issued and currently served by the same oerson
SELECT *
FROM portfolio_created_by_officers
WHERE Officer_ID = SalesMan_ID;

#### creaet an understanding of if the officer who was salesman and create a portfolio cuurently working in the same branch
SELECT
    Officer_ID,
    Branch,
    COUNT(CASE WHEN `Balance 01.08` > 0 AND `DaysOverdue 01.08` > 0 THEN ClNumber ELSE NULL END) AS Disb_overd_Port_NUMBER,
    SUM(CASE WHEN `Balance 01.08` > 0 AND `DaysOverdue 01.08` > 0 THEN InitialCreditAmount ELSE 0 END) AS Disb_overd_Port_AMOUNT,
    SUM(CASE WHEN `Balance 01.08` > 0 AND `DaysOverdue 01.08` > 0 THEN `Balance 01.08` ELSE 0 END) AS Current_overd_Port_AMOUNT
    
FROM
    portfolio_created_by_officers
GROUP BY
    Officer_ID, Branch
ORDER BY
    Branch
LIMIT 0, 200;

CREATE TABLE salesman_activity_outcome AS
SELECT
    c.SalesMan_ID AS Former_Sales,
    c.Branch,
    COUNT(ClNumber) AS Total_Disb_Port_NUMBER,
    SUM(InitialCreditAmount) AS Total_Disb_Port_AMOUNT,
    COUNT(CASE WHEN `Balance 01.08` > 0 AND `DaysOverdue 01.08` > 0 THEN ClNumber ELSE NULL END) AS Disb_overd_Port_NUMBER,
    SUM(CASE WHEN `Balance 01.08` > 0 AND `DaysOverdue 01.08` > 0 THEN InitialCreditAmount ELSE 0 END) AS Disb_overd_Port_AMOUNT,
    SUM(CASE WHEN `Balance 01.08` > 0 AND `DaysOverdue 01.08` > 0 THEN `Balance 01.08` ELSE 0 END) AS Current_overd_Port_AMOUNT,
    SUM(c.`Balance 01.08`) AS AssignedPortfolio_Amount,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) AS AssignedPortfolio_Number,
    MAX(s.Mar_Collections) AS Productivity_Mar,
    MAX(s.Apr_Collections) AS Productivity_Apr,
    MAX(s.May_Collections) AS Productivity_May,
    SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) AS Productivity_May_Jun_Jul,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jun,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jul,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) AS Clients_in_contact,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 AS Time_for_calls,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4 AS Time_for_visits,
    (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4) AS Total_time,
    (22 * 8 / (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.`Balance 01.08` END) * 4)) AS Possibility_to_KPI
FROM
    cleaned_data_with_salesofficers AS c
JOIN
    staff_effectivness AS s ON c.Officer_ID = s.Officer_ID
WHERE
    c.SalesMan_ID IN (SELECT Officer_ID FROM cleaned_data_with_salesofficers)
GROUP BY
    c.SalesMan_ID, c.Branch;

 DROP TABLE IF EXISTS salesman_activity_outcome;

CREATE TABLE salesman_activity_outcome (
    Former_Sales INT,
    Branch VARCHAR(255),
    Total_Disb_Port_NUMBER INT,
    Total_Disb_Port_AMOUNT DECIMAL(15,2),
    Disb_overd_Port_NUMBER INT,
    Disb_overd_Port_AMOUNT DECIMAL(15,2),
    Current_overd_Port_AMOUNT DECIMAL(15,2),
    AssignedPortfolio_Amount DECIMAL(15,2),
    AssignedPortfolio_Number INT,
    Productivity_Mar DECIMAL(15,2),
    Productivity_Apr DECIMAL(15,2),
    Productivity_May DECIMAL(15,2),
    Productivity_May_Jun_Jul DECIMAL(15,2),
    Productivity_Jun DECIMAL(15,2),
    Productivity_Jul DECIMAL(15,2),
    Clients_in_contact INT,
    Time_for_calls DECIMAL(15,2),
    Time_for_visits DECIMAL(15,2),
    Total_time DECIMAL(15,2),
    Possibility_to_KPI DECIMAL(15,2)
);

INSERT INTO salesman_activity_outcome
SELECT
    c.SalesMan_ID AS Former_Sales,
    c.Branch,
    COUNT(c.ClNumber) AS Total_Disb_Port_NUMBER,
    SUM(c.InitialCreditAmount) AS Total_Disb_Port_AMOUNT,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 AND c.`DaysOverdue 01.08` > 0 THEN c.ClNumber ELSE NULL END) AS Disb_overd_Port_NUMBER,
    SUM(CASE WHEN c.`Balance 01.08` > 0 AND c.`DaysOverdue 01.08` > 0 THEN c.InitialCreditAmount ELSE 0 END) AS Disb_overd_Port_AMOUNT,
    SUM(CASE WHEN c.`Balance 01.08` > 0 AND c.`DaysOverdue 01.08` > 0 THEN c.`Balance 01.08` ELSE 0 END) AS Current_overd_Port_AMOUNT,
    SUM(c.`Balance 01.08`) AS AssignedPortfolio_Amount,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.ClNumber ELSE NULL END) AS AssignedPortfolio_Number,
    MAX(s.Mar_Collections) AS Productivity_Mar,
    MAX(s.Apr_Collections) AS Productivity_Apr,
    MAX(s.May_Collections) AS Productivity_May,
    SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) AS Productivity_May_Jun_Jul,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jun,
    (SUM(CASE WHEN c.`Balance 01.08` > 0 THEN (c.`Balance 01.08` - c.`Balance 01.05`) END) - MAX(s.May_Collections))/2 AS Productivity_Jul,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) AS Clients_in_contact,
    COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 AS Time_for_calls,
    COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.ClNumber ELSE NULL END) * 4 AS Time_for_visits,
    (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.ClNumber ELSE NULL END) * 4) AS Total_time,
    (22 * 8 / (COUNT(CASE WHEN c.`Contact updated` = 'yes' THEN c.`Contact updated` END) * 5 * 10 / 60 + COUNT(CASE WHEN c.`Balance 01.08` > 0 THEN c.ClNumber ELSE NULL END) * 4)) AS Possibility_to_KPI
FROM
    cleaned_data_with_salesofficers AS c
JOIN
    staff_effectivness AS s ON c.Officer_ID = s.Officer_ID
WHERE
    c.SalesMan_ID IN (SELECT Officer_ID FROM cleaned_data_with_salesofficers)
GROUP BY
    c.SalesMan_ID, c.Branch
LIMIT
    0, 20000;

SELECT Former_Sales, 
       Branch, 
       Total_Disb_Port_NUMBER, 
       Total_Disb_Port_AMOUNT, 
       Disb_overd_Port_NUMBER, 
       Disb_overd_Port_AMOUNT, 
       Current_overd_Port_AMOUNT, 
       AssignedPortfolio_Amount, 
       AssignedPortfolio_Number, 
       Productivity_Mar, 
       Productivity_Apr, 
       Productivity_May, 
       Productivity_May_Jun_Jul, 
       Productivity_Jun, 
       Productivity_Jul, 
       Clients_in_contact, 
       Time_for_calls, 
       Time_for_visits, 
       Total_time, 
       Possibility_to_KPI
FROM salesman_activity_outcome
WHERE Current_overd_Port_AMOUNT > 0
GROUP BY Former_Sales, 
         Branch, 
         Total_Disb_Port_NUMBER, 
         Total_Disb_Port_AMOUNT, 
         Disb_overd_Port_NUMBER, 
         Disb_overd_Port_AMOUNT, 
         Current_overd_Port_AMOUNT, 
         AssignedPortfolio_Amount, 
         AssignedPortfolio_Number, 
         Productivity_Mar, 
         Productivity_Apr, 
         Productivity_May, 
         Productivity_May_Jun_Jul, 
         Productivity_Jun, 
         Productivity_Jul, 
         Clients_in_contact, 
         Time_for_calls, 
         Time_for_visits, 
         Total_time, 
         Possibility_to_KPI
ORDER BY Current_overd_Port_AMOUNT DESC;

SELECT * FROM portfolio_created_by_officers;

SELECT * FROM salesman_activity_outcome;