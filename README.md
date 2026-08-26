# Fraud-Detection-Transaction-Analysis-SQL

## About the Project

This project focuses on analyzing financial transaction data using **PostgreSQL**.

The main objective is to identify patterns associated with fraudulent transactions and explore relationships between transactions, customers, credit cards, and customer financial characteristics.

The project combines data preparation, exploratory data analysis, aggregations, statistical calculations, and window functions to investigate transaction and fraud patterns.

---

## Dataset

The project uses the **Financial Transactions Dataset: Analytics** available on Kaggle.

**Source:** [Kaggle – Transactions & Fraud Datasets](https://www.kaggle.com/datasets/computingvictor/transactions-fraud-datasets)

The dataset contains information about:

- customers
- credit cards
- financial transactions
- fraudulent transactions

The dataset is **not included in this repository due to its size**. It can be downloaded directly from Kaggle.

---

## Database Structure

The analysis uses four main tables:

### `users`

Contains customer information such as:

- age
- gender
- income
- debt
- credit score
- number of credit cards
- geographical information

### `cards`

Contains information about customers' credit cards:

- card brand
- card type
- card number
- expiration date
- chip availability
- credit limit
- account opening date
- dark web status

### `transactions`

Contains individual financial transactions:

- transaction date
- card ID
- transaction amount
- merchant city
- merchant state
- merchant category code (MCC)
- transaction errors

### `frauds`

Contains fraud labels assigned to transactions.

---

## SQL Analysis

### Fraud Analysis

The following questions are investigated:

- What percentage of transactions are fraudulent?
- Are fraudulent transactions associated with higher transaction amounts?
- How are fraudulent transactions distributed between chip and online transactions?
- At what hours do fraudulent transactions occur most frequently?
- Which parts of the day have the highest number of fraudulent transactions?
- Which merchant category codes (MCC) have the highest number of fraudulent transactions?
- Is fraud more common among cards with or without a chip?
- Are customers with lower credit scores more frequently affected by fraud?
- Which customers have the highest number of fraudulent transactions?
- Which states have the highest number of fraudulent transactions?
- Is there a relationship between transaction errors and fraud?
- How much time passes between transactions for cards that experienced fraud?

### Transaction Analysis

Additional analyses examine:

- monthly transaction values
- average transaction value by year
- transaction rankings within merchant cities
- customer spending rankings within states
- cumulative customer spending over time
- average transaction values by transaction type and card brand
- transaction averages over time
- transactions outside the mean ± 3 standard deviation range
- time between consecutive transactions
- time since the last transaction for each card

### Customer Analysis

Customer characteristics are analyzed using:

- age
- gender
- yearly income
- total debt
- credit score
- number of credit cards

The analysis also investigates transaction behavior across different credit score groups.

### Credit Score Segmentation

Customers are divided into three groups based on credit score percentiles:

- **Low**
- **Mid**
- **High**

This allows transaction behavior and fraud frequency to be compared between different credit score levels.

---

## SQL Techniques Used

The project demonstrates the use of:

- `SELECT`
- `WHERE`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `CASE WHEN`
- `JOIN`
- `LEFT JOIN`
- subqueries
- views
- aggregate functions
- conditional aggregation
- date and time functions
- `LAG()`
- `RANK()`
- `DENSE_RANK()`
- window functions
- `PERCENTILE_DISC()`
- standard deviation
- type casting
- data cleaning

---

