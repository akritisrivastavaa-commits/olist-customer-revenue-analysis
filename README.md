#  Olist E-Commerce Customer & Revenue Analysis

##  Project Overview

This project focuses on analyzing customer purchasing behaviour, retention patterns, revenue distribution, delivery performance, and payment behaviour using the Olist Brazilian E-Commerce dataset.

The objective of this analysis is to identify the key factors influencing customer retention, customer value, operational efficiency, and revenue quality through SQL-based business analysis.

---

##  Business Problem

Although Olist generates significant sales volume, customer retention remains a major challenge.

This project aims to answer:

- Who generates the highest customer value?
- Are revenues concentrated among a small group of customers?
- What differentiates repeat customers from one-time buyers?
- Does delivery performance affect customer retention?
- Are there sources of revenue leakage?
- How do payment behaviours influence purchasing patterns?

---

#  Dataset

**Dataset:** Brazilian E-Commerce Public Dataset by Olist

The analysis uses the following tables:

| Table | Description |
|---|---|
| customers_new | Customer identifiers and unique customer mapping |
| orders | Order status, purchase dates, delivery dates and estimated delivery dates |
| order_items | Product prices and freight values |
| order_payments | Payment methods and installment information |

The analysis primarily focuses on delivered orders to ensure consistency in customer behaviour and revenue calculations.

---

#  Tools Used

- SQL (MySQL)
- Power BI *(dashboard development)*
- DAX *(data modelling and measures)*

---

#  Analysis Performed

## 1. Customer Value Analysis

Explored:

- Customer revenue contribution
- Revenue distribution across customers
- High-value customer segments
- Revenue concentration

Key metrics:

- Revenue per customer
- Order frequency
- Top customer contribution

---

## 2. Customer Retention Analysis

Analyzed:

- One-time vs repeat customers
- Purchase frequency distribution
- Repeat purchase behaviour
- Customer value comparison

Key metrics:

- Repeat customer percentage
- Average revenue per customer
- Average time between purchases

---

## 3. Delivery Performance Analysis

Evaluated:

- On-time vs delayed deliveries
- Average delivery delays
- Impact of delivery experience on customer retention

---

## 4. Payment Behaviour Analysis

Studied:

- Payment methods
- Installment usage
- Relationship between payment behaviour and order value

---

## 5. Revenue Leakage Analysis

Identified:

- Cancelled orders
- Unavailable orders
- Potential lost gross order value

---

#  Key Insights

- Only **~3% of customers made repeat purchases**, showing weak customer retention.

- Approximately **97% of customers purchased only once**, indicating heavy dependence on customer acquisition.

- Repeat customers generated nearly **2× higher revenue per customer** compared to one-time customers.

- The top 10% of customers contributed around **38% of total revenue**, showing revenue concentration among high-value customers.

- Average delivery delay was approximately **8.9 days** among delayed orders.

- Cancelled and unavailable orders created measurable revenue leakage.

---

#  SQL Concepts Demonstrated

This project uses:

- JOIN operations
- Common Table Expressions (CTEs)
- Aggregate functions
- Window functions
- CASE statements
- Customer-level segmentation
- Ranking functions
- Conditional analysis

---

#  Project Structure

Olist-Ecommerce-Analysis/

│
├── SQL/
│ └── olist_analysis.sql
│
├── Documentation/
│ └── Olist_Project_Report.pdf
│
├── Dashboard/
│ └── Olist_Dashboard.pbix
│
└── README.md

---

#  Author

**Akriti**

Aspiring Data Analyst

Skills:
SQL | Power BI | DAX | Python | Data Analytics


