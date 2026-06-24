-- Add bill_amount support in gold_transaction_ledger
-- Date: 2026-06-24

ALTER TABLE gold_transaction_ledger
    ADD COLUMN bill_amount DECIMAL(14,2) NOT NULL DEFAULT 0.00 AFTER customer_id;

ALTER TABLE gold_transaction_ledger
    ADD INDEX idx_gtl_bill_amount (bill_amount);

-- Backfill old rows from existing movement fields
UPDATE gold_transaction_ledger
SET bill_amount = CASE
    WHEN is_purchase = 1 THEN COALESCE(in_amount, 0)
    WHEN is_sale = 1 THEN COALESCE(out_amount, 0)
    ELSE COALESCE(in_amount, 0) + COALESCE(out_amount, 0)
END
WHERE COALESCE(bill_amount, 0) = 0;
