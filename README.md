# Sergii-Rosi-Final-Project

# FINAL-PROJECT

![Data Analytics Projects](https://financialcrimeacademy.org/wp-content/uploads/2022/05/1-46.jpg)

---
Final Bootcamp Project done by [Rosi Maryam](https://github.com/rmaryam42) and  [Sergii](s.lebed@yahoo.com).

## Overview

The objective of this project was to analyze the existing credit portfolio of a company primarily selling technical equipment for home use. At the time of data collection, a significant portion of the current portfolio was overdue, causing the company issues with payments on external loans. The ultimate goal of this research is to determine the likelihood of fraudulent activities by the company's clients or employees using the available information.

## Data Collection and Anonymization

The initial information on the credit portfolio was entirely original and included clients' names, employees' names, client and branch addresses, phone numbers, and other confidential data. For project use, these original data files were significantly altered to protect commercially sensitive information. Unfortunately, due to confidentiality reasons, the stages of data cleaning for parts of the database containing confidential information are not reflected in the project and cannot be provided for review. Specifically, the data cleaning included:

Identifying and replacing all full names with standardized alphanumeric values considering the likelihood of name matches.
Adjusting debt amounts using a conversion factor.
Renaming the company's product lines.
Implementing an algorithm to change the unique client number, among other steps.


## Data Issues and Analysis
Since all parts of the credit portfolio information were manually collected, involving numerous employees, both the original and the processed data for the project contain numerous discrepancies, which is acceptable in such processes. Some of the information obtained is unsuitable for analysis despite its importance.

## First Database
For initiating the actual research, the cleaned databases containing the following information were used:

1. **CreateDate**: Represents the date of order registration by the client in the company's internal records (data type - datetime64[ns])
2. **InvoiceDate**: Represents the date of invoice creation in the company's internal records (data type - datetime64[ns])
3. **ClNumber**: Represents the unique client identifier
4. **Portfolio**: Represents the source of credit funding
5. **Total**: Represents the total cost of the equipment purchased by the client
6. **Downpayment**: Represents the amount of the initial down payment made by the client with their own funds
7. **Subsidy**: Represents the amount subsidized to the client by external organizations
8. **InitialCreditAmount**: Represents the amount the company provided to the client as a loan
9. **Balance 01.05**: Represents the client's remaining loan balance as of May 1st
10. **ProductMix**: Represents the type of equipment purchased by the client
11. **Branch**: Represents the unique identifier of the company branch where the client was granted the loan
12. **DaysOverdue 01.05**: Represents the number of days the client has overdue payments as of May 1st
13. **OverdueInstallmentsAmount 01.05**: Represents the amount of overdue installments by the client as of May 1st
14. **OverdueInstallments 01.05**: Represents the number of overdue installments by the client
15. **DaysTillNextPayment 01.05**: Represents the number of days until the next loan payment
16. **Balance 01.08**: Represents the client's remaining loan balance as of August 1st
17. **DaysOverdue 01.08**: Represents the number of days the client has overdue payments as of August 1st
18. **OverdueInstallmentsAmount 01.07**: Represents the amount of overdue installments by the client as of August 1st
19. **Manager**: Unique code of the responsible manager
20. **Contact updated**: Represents the current status of the client's contact information
21. **Current address updated**: Represents the current status of the client's address information
22. **System located at indicated address**: Represents the status of the equipment's location at the indicated address
23. **Client knows he has a debt**: Represents whether the client is aware of their debt
24. **Client knows the amount of a debt**: Represents whether the client knows the amount of their debt
25. **Client willing and capable to pay**: Represents whether the client is willing and capable of repaying the loan
26. **Amount a client can pay this month**: Represents the amount the client can pay this month
27. **Last payment date**: Represents the date of the last payment made by the client as reported
28. **Last payment amount**: Represents the amount of the last payment made by the client as reported
29. **Last payment method**: Represents the method of the last payment made by the client as reported
30. **Client knows the options of paying**: Represents whether the client knows the payment options
31. **The system is working**: Represents the current status of the equipment purchased on credit
32. **Date of the last contact by staff**: Represents the date of the last contact with company staff as reported by the client
33. **SalesMan_ID**: Represents the unique identifier of the responsible employee who prepared the documents and collected the information necessary for making the loan decision

## Second Database
Additional information for analyzing the effectiveness of working with the overdue portfolio was contained in and included the following columns:
1. **Officer ID** – reflects the unique number of the debt collection department employee;
2. **Mar Collections** – reflects the amount of payments received during the corresponding month from clients in the respective employee's portfolio;
3. **Apr_Collections** – reflects the amount of payments received during the corresponding month from clients in the respective employee's portfolio;
4. **May_Collections** – reflects the amount of payments received during the corresponding month from clients in the respective employee's portfolio;

## Fraud Analysis
To determine the likelihood of fraudulent actions by company personnel, a comparative analysis of the current state of the credit portfolio and the credit portfolio at the time of loan issuance was conducted across:

- Employees who prepared the documents and collected the information necessary for making the loan decision
- Company branches
- Types of equipment offered to clients
- Responsible employees
- Migration of employees from the sales department to the current client services department

## Predicting Last Payment Amount
To predict the "Last payment amount" using a trained Random Forest Regressor model, follow these steps:


1. **Data Preprocessing:**
    - Handle missing values if any.
    - Encode categorical variables.
    - Normalize the features.
    - Handle class imbalance using SMOTE (Synthetic Minority Over-sampling Technique).

2. **Model Training and Evaluation:**
    - Split the data into training and testing sets.
    - Train multiple regressors:
        - Decision Tree
        - Random Forest
        - Gradient Boosting
        - Support Vector Machine
    - Evaluate the models using MSE and R-squares.
  
## Conclusion
Mean Squared Error (MSE): This metric measures the average squared difference between the actual and predicted values. In your case, the MSE value of approximately 74 billion indicates the average squared difference between the actual and predicted "Last payment amount" values. A lower MSE indicates better model performance, meaning that the model's predictions are closer to the actual values on average.

R-squared Score: Also known as the coefficient of determination, this metric measures the proportion of the variance in the target variable that is predictable from the features. It ranges from 0 to 1, where 1 indicates a perfect fit. In your case, the R-squared score of approximately 0.27 indicates that around 27% of the variance in the "Last payment amount" can be explained by the features used in the model.

## Interpreting these metrics

The MSE value suggests that the model's predictions have a relatively high average squared error, indicating that there is room for improvement in reducing the prediction errors.
The R-squared score indicates that the model explains only about 27% of the variance in the "Last payment amount," suggesting that there may be other factors or features not included in the model that could improve its performance.


## Recommendations
Based on the insights from the models, businesses can:
- Implement fraud detection systems to flag suspicious transactions in real-time.
- Improve fraud prevention strategies by understanding patterns in fraudulent transactions.
- Explore additional features that may have predictive power or engineer new features from the additional dataframe that provide more information about the target variable to get higher R-squares score.
    
## Presentation
| Folder  | File |
| Pitch Presentation | https://www.canva.com/design/DAGF2LC9nwo/ZTkoOgxFjVs7-EZSt1YFeQ/edit?utm_content=DAGF2LC9nwo&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton |
| Final Presentation  | https://www.canva.com/design/DAGGngkI7Yo/VbspjdZoRSCylSSok6oQ9A/edit?utm_content=DAGGngkI7Yo&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton |
| Project Management  | [File](https://rosi-maryam.atlassian.net/jira/core/projects/FA/board) |
