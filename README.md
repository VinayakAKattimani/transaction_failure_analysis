Transaction Failure Analytics Project

This project focuses on identifying key failure patterns and business risks in a transaction dataset containing 20,000 credit card transactions. Using SQL (PostgreSQL), the goal was to extract actionable insights related to revenue loss, user behavior, system failures, and potential fraud.

The analysis was done through five real-world case studies, each targeting a different business problem commonly faced by payment platforms and fintech companies.

Dataset Overview

The dataset contains realistic transaction records and includes the following relational tables:

users — user_id, name, city

merchants — merchant_id, name, category

banks — bank_id, bank_name, server_status

transactions — txn_id, user_id, merchant_id, bank_id, txn_time, amount, status, failure_reason

The transactions table is the core of the analysis and includes fields such as timestamps, amount, status (success or failed), and the reason for failure.

Case Studies

High Failure Rate During Peak Hours
Analysis revealed that failure rates spiked between 7 PM and 9 PM. This pattern suggested system overloads or high concurrency issues during peak user activity. Identifying this helped recommend improvements in load balancing and system optimization.

Bank-Specific Failures
Certain partner banks consistently showed higher failure rates compared to others. The analysis included breakdowns by failure reason and bank name. This insight was used to flag underperforming banks for SLA reviews and technical escalations.

Failure-Prone Merchants
Merchants like Flipkart and BigBasket had failure rates above 15%. These were tied to issues in payment flow integrations and session expiries. The outcome of this case study led to collaborative debugging efforts with merchant tech teams and API upgrades.

Revenue Loss from Non-Retried Failures
Many users did not retry after facing a failed payment. A large share of failed transactions had no subsequent retry attempt, even though retrying often resulted in success. The result highlighted measurable revenue loss and led to changes in user interface flow encouraging retries.

Detecting Possible Fraud Patterns
Certain users were found making multiple high-value failed transactions across different merchants and banks within a short time span. This behavior was flagged as potential fraud (such as card testing or abuse). The case study included logic to detect and flag such behavior for manual review or automatic blocking.

