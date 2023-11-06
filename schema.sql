DROP TABLE IF EXISTS card_holder CASCADE;
DROP TABLE IF EXISTS credit_card CASCADE;
DROP TABLE IF EXISTS merchant CASCADE;
DROP TABLE IF EXISTS merchant_category CASCADE;
DROP TABLE IF EXISTS transaction CASCADE;

CREATE TABLE card_holder (
	cardholder_id INT PRIMARY KEY,
	cardholder_name VARCHAR(255)
);

CREATE TABLE credit_card (
	credit_card_number BIGINT PRIMARY KEY,
	cardholder_id INT,
	FOREIGN KEY (cardholder_id) REFERENCES card_holder(cardholder_id)
);

CREATE TABLE merchant_category (
	merchant_category_id INT PRIMARY KEY,
	merchant_type VARCHAR(255)
);

CREATE TABLE merchant (
	merchant_id INT PRIMARY KEY,
	merchant_name VARCHAR(255),
	merchant_category_id INT,
	FOREIGN KEY (merchant_category_id) REFERENCES merchant_category(merchant_category_id)
);

CREATE TABLE transaction (
	transaction_id INT PRIMARY KEY,
	transaction_time TIMESTAMP,
	transaction_amount NUMERIC(11,2),
	credit_card_number BIGINT,
	FOREIGN KEY (credit_card_number) REFERENCES credit_card(credit_card_number),
	merchant_id INT,
	FOREIGN KEY (merchant_id) REFERENCES merchant(merchant_id)
);