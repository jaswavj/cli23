-- Add pay/collect marker for balance settlement rows
-- Mapping: pay = 1, collect = 2
-- Date: 2026-06-24

ALTER TABLE gold_trasaction_payment
    ADD COLUMN is_pay_or_collect TINYINT(1) NOT NULL DEFAULT 0 AFTER is_balance_collection;

ALTER TABLE gold_trasaction_payment
    ADD INDEX idx_gtp_pay_collect (is_pay_or_collect);

ALTER TABLE gold_transaction_ledger
    ADD COLUMN is_pay_or_collect TINYINT(1) NOT NULL DEFAULT 0 AFTER is_balance_collection;

ALTER TABLE gold_transaction_ledger
    ADD INDEX idx_gtl_pay_collect (is_pay_or_collect);
