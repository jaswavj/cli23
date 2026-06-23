-- Add is_expense column to gold_ledger table
-- This column identifies expense entries in the ledger
-- 0 = regular transaction (bills, payments, opening balance)
-- 1 = expense entry

ALTER TABLE `gold_ledger` 
ADD COLUMN `is_expense` tinyint(1) NOT NULL DEFAULT 0 AFTER `entered_dt`;

-- Add EXPENSE to the txn_type enum
ALTER TABLE `gold_ledger` 
MODIFY COLUMN `txn_type` enum('BILL','PAYMENT','OPENING','EXPENSE') NOT NULL DEFAULT 'BILL';

-- Create index for better performance when filtering expenses
CREATE INDEX idx_is_expense ON gold_ledger(is_expense);
