-- Balance collection support for credit settle flow
-- Date: 2026-06-24

-- 1) Allow payment rows without bill_id and track balance-collection metadata
ALTER TABLE gold_trasaction_payment
    MODIFY COLUMN bill_id INT UNSIGNED NULL,
    ADD COLUMN customer_id INT NULL AFTER bill_id,
    ADD COLUMN user_id INT NULL AFTER customer_id,
    ADD COLUMN bill_date DATE NULL AFTER amount,
    ADD COLUMN bill_time TIME NULL AFTER bill_date,
    ADD COLUMN date_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER bill_time,
    ADD COLUMN is_balance_collection TINYINT(1) NOT NULL DEFAULT 0 AFTER date_time;

ALTER TABLE gold_trasaction_payment
    ADD INDEX idx_gtp_customer (customer_id),
    ADD INDEX idx_gtp_user (user_id),
    ADD INDEX idx_gtp_balance_collection (is_balance_collection),
    ADD INDEX idx_gtp_datetime (date_time);

-- 2) Mark ledger rows that are direct balance collections (without bill_id)
ALTER TABLE gold_transaction_ledger
    ADD COLUMN is_balance_collection TINYINT(1) NOT NULL DEFAULT 0 AFTER is_cancelled;

ALTER TABLE gold_transaction_ledger
    ADD INDEX idx_gtl_balance_collection (is_balance_collection);
