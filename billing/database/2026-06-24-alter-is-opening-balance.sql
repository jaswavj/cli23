-- Add opening-balance marker for opening balance entries
-- Date: 2026-06-24
-- Safe to re-run on live DB (skips columns/indexes that already exist)

SET @db = DATABASE();

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'gold_trasaction_payment' AND COLUMN_NAME = 'is_opening_balance') = 0,
  'ALTER TABLE gold_trasaction_payment ADD COLUMN is_opening_balance TINYINT(1) NOT NULL DEFAULT 0 AFTER is_pay_or_collect',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
   WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'gold_trasaction_payment' AND INDEX_NAME = 'idx_gtp_opening_balance') = 0,
  'ALTER TABLE gold_trasaction_payment ADD INDEX idx_gtp_opening_balance (is_opening_balance)',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'gold_transaction_ledger' AND COLUMN_NAME = 'is_opening_balance') = 0,
  'ALTER TABLE gold_transaction_ledger ADD COLUMN is_opening_balance TINYINT(1) NOT NULL DEFAULT 0 AFTER is_pay_or_collect',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
   WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'gold_transaction_ledger' AND INDEX_NAME = 'idx_gtl_opening_balance') = 0,
  'ALTER TABLE gold_transaction_ledger ADD INDEX idx_gtl_opening_balance (is_opening_balance)',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'bank_ledger' AND COLUMN_NAME = 'is_opening_balance') = 0,
  'ALTER TABLE bank_ledger ADD COLUMN is_opening_balance TINYINT(1) NOT NULL DEFAULT 0 AFTER date_time',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
   WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'bank_ledger' AND INDEX_NAME = 'idx_bl_opening_balance') = 0,
  'ALTER TABLE bank_ledger ADD INDEX idx_bl_opening_balance (is_opening_balance)',
  'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
