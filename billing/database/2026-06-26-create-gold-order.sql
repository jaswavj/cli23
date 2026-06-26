-- TM (order) entries — purchase / sale orders before billing
-- Run once on live DB

CREATE TABLE IF NOT EXISTS gold_order (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    is_billed TINYINT(1) NOT NULL DEFAULT 0,
    bill_id INT UNSIGNED NULL,
    order_date_time DATETIME NOT NULL,
    user_id INT NOT NULL,
    is_cancelled TINYINT(1) NOT NULL DEFAULT 0,
    qty DECIMAL(14,3) NOT NULL DEFAULT 0.000,
    type TINYINT UNSIGNED NOT NULL COMMENT '1=purchase, 2=sale',
    enter_date_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_gold_order_customer (customer_id),
    KEY idx_gold_order_type (type),
    KEY idx_gold_order_billed (is_billed),
    KEY idx_gold_order_cancelled (is_cancelled),
    KEY idx_gold_order_date (order_date_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
