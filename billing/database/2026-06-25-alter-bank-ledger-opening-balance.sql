-- Optional: mark opening-balance rows in bank_ledger (not required for GPay opening balance save)
-- Safe to re-run

SET @db = DATABASE();

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
