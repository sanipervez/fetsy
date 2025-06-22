## Fetsy Ecommerce Database Project
In this project, I transformed a large denormalized dataset of 400,000 ecommerce order records into a fully normalized MySQL database following Third Normal Form (3NF) principles. This restructuring improved data integrity, minimized redundancy, and optimized query performance for the Fetsy ecommerce platform.

# Database Design & Normalization
- Normalized the original denormalized table into multiple related tables, ensuring all data adhered to 3NF rules.
- Carefully analyzed the cardinality between entities (1:1, 1:many, many:many) by running queries on the raw data to understand relationships, such as buyers to addresses or products to sellers.
- Maintained original column names from the denormalized table to preserve consistency.
- Applied appropriate data types, constraints, and foreign keys to enforce referential integrity across tables.

# Indexing & Performance Optimization
- Added indexes strategically based on query patterns.
- Used the EXPLAIN statement to analyze query execution plans before and after indexing.
- Documented decisions when indexes would not improve performance, demonstrating a clear understanding of optimization.

# Stored Procedures & Views
Implemented multiple stored procedures and views to enable efficient data retrieval and reporting, including:
- top_ten_for_country: Accepts a country parameter and returns the top 10 buyers by total amount spent in that country.

- top_rated_products (View): Displays the top 10 products with the highest average ratings (minimum 20 ratings), including product details and rating statistics.

- buyer_for_date: Returns all orders for buyers matching a given first name, last name, and order date.

- top_five_buyer_cities (View): Lists the top 5 buyer cities ranked by total spending in descending order.

- sales_for_month: Summarizes total sales for a specified month and year.

- seller_sales_tiers (View): Categorizes sellers into sales tiers (High, Medium, Low) based on their total sales, along with detailed sales information.

- top_products_for_seller: Provides sales data for all products sold by a specific seller, ordered by total sales descending.

- seller_running_totals: Returns each seller’s order history with a running total of sales over time using window functions.


This project demonstrated my ability to apply database normalization principles, optimize query performance, and create complex SQL procedures and views to support real-world ecommerce analytics and reporting needs.
