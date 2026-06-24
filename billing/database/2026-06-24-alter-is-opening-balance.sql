-- Add opening-balance marker for opening balance entries
-- Date: 2026-06-24

ALTER TABLE gold_trasaction_payment
    ADD COLUMN is_opening_balance TINYINT(1) NOT NULL DEFAULT 0 AFTER is_pay_or_collect;

ALTER TABLE gold_trasaction_payment
    ADD INDEX idx_gtp_opening_balance (is_opening_balance);

ALTER TABLE gold_transaction_ledger
    ADD COLUMN is_opening_balance TINYINT(1) NOT NULL DEFAULT 0 AFTER is_pay_or_collect;

ALTER TABLE gold_transaction_ledger
    ADD INDEX idx_gtl_opening_balance (is_opening_balance);

ALTER TABLE bank_ledger
    ADD COLUMN is_opening_balance TINYINT(1) NOT NULL DEFAULT 0 AFTER date_time;

ALTER TABLE bank_ledger
    ADD INDEX idx_bl_opening_balance (is_opening_balance);
