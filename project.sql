
-- Table for buyers
CREATE TABLE Buyers (
    buyer_id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL, 
    country VARCHAR(100) NOT NULL
);
INSERT INTO Buyers (buyer_id, first_name, last_name, email, address, city, country)
SELECT DISTINCT buyer_id, first_name, last_name, email, address, city, country
FROM denormalized_orders;

-- Table for sellers
CREATE TABLE Sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(255) NOT NULL,
    seller_country VARCHAR(100) NOT NULL
);

INSERT INTO Sellers (seller_id, seller_name, seller_country)
SELECT DISTINCT seller_id, seller_name, seller_country
FROM denormalized_orders;

-- Table for products
CREATE TABLE Products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_price INT NOT NULL,
    seller_id INT NOT NULL,
    FOREIGN KEY (seller_id) REFERENCES Sellers(seller_id)
);

INSERT INTO Products (product_id, product_name, product_price, seller_id)
SELECT DISTINCT product_id, product_name, product_price, seller_id
FROM denormalized_orders;

-- Table for CC 
CREATE TABLE CC_info(
    cc_id INT AUTO_INCREMENT PRIMARY KEY,
    cc_number VARCHAR(16), 
    buyer_id INT NOT NULL,
    cc_exp VARCHAR(7) NOT NULL, 
    FOREIGN KEY (buyer_id) REFERENCES Buyers(buyer_id)
);

INSERT INTO CC_info (cc_number, buyer_id, cc_exp)
SELECT DISTINCT cc_number, buyer_id, cc_exp
FROM denormalized_orders;

-- Table for orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY, 
    buyer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_quantity INT NOT NULL,
    order_date DATE NOT NULL, 
    FOREIGN KEY (buyer_id) REFERENCES Buyers(buyer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Orders (order_id, buyer_id, product_id, order_quantity, order_date)
SELECT DISTINCT order_id, buyer_id, product_id, order_quantity, order_date
FROM denormalized_orders;

-- Table for reviews
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    order_id INT NOT NULL, 
    buyer_id INT NOT NULL,
    review TEXT NOT NULL,
    rating INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (buyer_id) REFERENCES Buyers(buyer_id)
);

INSERT INTO Reviews (product_id, order_id, buyer_id, review, rating)
SELECT DISTINCT product_id, order_id, buyer_id, review, rating
FROM denormalized_orders;

-- Query 1
DELIMITER //
CREATE PROCEDURE top_ten_for_country(IN in_country VARCHAR(100))
BEGIN 
    SELECT 
        b.buyer_id, 
        b.first_name, 
        b.last_name, 
        CONCAT('$',CONVERT(SUM(product_price * order_quantity) / 100.0,DECIMAL(20, 2)))  AS total_amount_spent
    FROM Buyers b
    INNER JOIN Orders o ON o.buyer_id = b.buyer_id
    INNER JOIN Products p ON p.product_id = o.product_id
    WHERE b.country = in_country
    GROUP BY b.buyer_id
    ORDER BY SUM(p.product_price * o.order_quantity) DESC
    LIMIT 10;
END//
DELIMITER ;


-- Query 2 
CREATE VIEW top_rated_products 
AS
SELECT 
    p.product_id, 
    p.product_name,
    CONCAT('$', FORMAT(p.product_price / 100, 2)) AS product_price,
    AVG(r.rating)AS avg_rating,
    COUNT(r.rating)AS rating_count
FROM Products p
JOIN Reviews r ON r.product_id = p.product_id
GROUP BY p.product_id
HAVING rating_count >= 20
ORDER BY avg_rating DESC
LIMIT 10;


-- Query 3
DELIMITER //
CREATE PROCEDURE buyer_for_date(IN first_name VARCHAR(100), IN last_name VARCHAR(100), IN order_date DATE)
BEGIN 
    SELECT o.order_id, o.order_quantity, p.product_name, o.order_date
    FROM Products p
    JOIN Orders o ON o.product_id = p.product_id
    JOIN Buyers b ON b.buyer_id = o.buyer_id
    WHERE b.first_name = first_name AND b.last_name = last_name AND o.order_date = order_date
    ORDER BY o.order_date;
END//
DELIMITER ;


-- Query 4
CREATE VIEW top_five_buyer_cities 
AS
SELECT 
    b.city, 
    CONCAT('$', CONVERT(SUM(p.product_price * o.order_quantity) /100.0,DECIMAL(20, 2))) AS total_amount_spent
FROM Buyers b
JOIN Orders o ON o.buyer_id = b.buyer_id
JOIN Products p ON p.product_id = o.product_id
GROUP BY b.city
ORDER BY SUM(product_price * order_quantity) DESC
LIMIT 5;


-- Query 5
DELIMITER //
CREATE PROCEDURE sales_for_month (IN in_month_and_year DATE)
BEGIN
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month_and_year,
        CONCAT('$', FORMAT(SUM(o.order_quantity * p.product_price)/100,2)) AS total_sales
    FROM Orders o
    INNER JOIN Products p ON p.product_id = o.product_id
    WHERE MONTH(o.order_date) = MONTH(in_month_and_year) AND YEAR(o.order_date) = YEAR(in_month_and_year)
    GROUP BY month_and_year;
END  //
DELIMITER ;


-- Query 6
CREATE VIEW seller_sales_tiers 
AS
SELECT 
    s.seller_id,
    s.seller_name,
    CONCAT('$', FORMAT(SUM(o.order_quantity * p.product_price) / 100, 2)) AS total_sales,
    CASE
        WHEN SUM(o.order_quantity * p.product_price) >= 10000000 THEN 'High'
        WHEN SUM(o.order_quantity * p.product_price) >= 1000000 THEN 'Medium'
        ELSE 'Low'
    END AS sales_tier
FROM Sellers AS s
INNER JOIN Products AS p ON p.seller_id = s.seller_id
INNER JOIN Orders AS o ON o.product_id = p.product_id
GROUP BY s.seller_id, s.seller_name
ORDER BY SUM(o.order_quantity * p.product_price) DESC;


-- Query 7
DELIMITER //
CREATE PROCEDURE top_products_for_seller(IN seller_name VARCHAR(45))
BEGIN
    SELECT 
    s.seller_id,
    p.product_id,
    p.product_name,
    CONCAT('$',FORMAT(SUM(o.order_quantity * p.product_price / 100),2)) AS total_sales
    FROM Orders o
    JOIN Products p ON p.product_id = o.product_id
    JOIN Sellers s ON s.seller_id = p.seller_id
    WHERE s.seller_name = seller_name
    GROUP BY seller_id, product_id, product_name
    ORDER BY SUM(o.order_quantity * p.product_price / 100) DESC;
END //
DELIMITER ;

-- Query 8
DELIMITER //
CREATE PROCEDURE seller_running_totals(IN seller_name VARCHAR(100))
BEGIN
    SELECT 
        s.seller_id,
        o.order_id,
        o.order_date,
        CONCAT('$', FORMAT((p.product_price * o.order_quantity) / 100.0, 2)) AS order_total,
        CONCAT('$', FORMAT(SUM((p.product_price * o.order_quantity) / 100.0)
               OVER (PARTITION BY s.seller_id ORDER BY o.order_date, o.order_id), 2)) AS running_total
    FROM Sellers s
    JOIN Products p ON p.seller_id = s.seller_id
    JOIN Orders o ON o.product_id = p.product_id
    WHERE s.seller_name = seller_name
    ORDER BY o.order_date, o.order_id;
END //
DELIMITER ;

-- indexes 
ALTER TABLE Buyers 
    ADD INDEX country_index(country);

ALTER TABLE Products
    ADD INDEX product_name_index(product_name);

ALTER TABLE Sellers
    ADD INDEX seller_name_index(seller_name);

ALTER TABLE Buyers
    ADD INDEX buyer_name_index(first_name,last_name);

ALTER TABLE Buyers 
    ADD INDEX city_index(city);

ALTER TABLE CC_info
    ADD INDEX cc_number_index(cc_number);

ALTER TABLE Reviews
    ADD INDEX rating_index(rating);

ALTER TABLE Orders
    ADD INDEX order_date_index(order_date);