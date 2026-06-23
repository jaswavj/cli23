-- Add is_open_balance_entry column to gold_ledger table
-- This column identifies opening balance entries
-- 0 = regular transaction (bills, payments, expenses)
-- 1 = opening balance entry for the day

ALTER TABLE `gold_ledger` 
ADD COLUMN `is_open_balance_entry` tinyint(1) NOT NULL DEFAULT 0 AFTER `entered_dt`;

-- Create index for better performance when checking opening balance
CREATE INDEX idx_is_open_balance_entry ON gold_ledger(is_open_balance_entry, txn_date);
