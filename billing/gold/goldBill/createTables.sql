-- -------------------------------------------------------
-- GOLD MODULE TABLES  (run once)
-- Database: gold
-- -------------------------------------------------------

USE `gold`;

-- --- 1. Gold Rate History -------------------------------
CREATE TABLE IF NOT EXISTS `gold_rate` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `rate`       DECIMAL(10,2) NOT NULL,
  `entered_by` INT NOT NULL COMMENT 'user id',
  `entered_dt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --- 2. Gold Bill Master --------------------------------
CREATE TABLE IF NOT EXISTS `gold_bill` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bill_no`         INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'display bill id, set in application code',
  `customer_id`     INT DEFAULT NULL COMMENT 'NULL for walk-in',
  `customer_name`   VARCHAR(255) NOT NULL,
  `customer_phone`  VARCHAR(20)  DEFAULT NULL,
  `id_proof_no`     VARCHAR(100) DEFAULT NULL,
  `addr_proof_no`   VARCHAR(100) DEFAULT NULL,
  `gold_rate`       DECIMAL(10,2) NOT NULL,
  `gross_amount`    DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `margin`          DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `net_amount`      DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `release_amount`  DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `amount_paid`     DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `bill_date`       DATE NOT NULL,
  `bill_time`       TIME NOT NULL,
  `entered_by`      INT NOT NULL COMMENT 'user id',
  `entered_dt`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_cancelled`    TINYINT NOT NULL DEFAULT '0',
  `cancelled_by`    INT DEFAULT NULL,
  `cancelled_dt`    DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --- 3. bill_no handling ---------------------------------
-- NOTE: Do NOT use an AFTER INSERT trigger that updates gold_bill itself.
-- MySQL throws: "Can't update table 'gold_bill' in stored function/trigger..."
-- bill_no is set in application code right after insert (goldBillingBean.saveBill).
DROP TRIGGER IF EXISTS `gold_bill_set_bill_no`;

-- --- 4. Gold Bill Items ---------------------------------
CREATE TABLE IF NOT EXISTS `gold_bill_item` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bill_id`       INT UNSIGNED NOT NULL,
  `ornament_type` VARCHAR(255) NOT NULL,
  `gross_wt`      DECIMAL(10,3) NOT NULL DEFAULT '0.000',
  `stone_wax`     DECIMAL(10,3) NOT NULL DEFAULT '0.000',
  `net_wt`        DECIMAL(10,3) NOT NULL DEFAULT '0.000',
  `purity`        DECIMAL(6,2)  NOT NULL DEFAULT '0.00',
  `gross_amount`  DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `bill_id` (`bill_id`),
  CONSTRAINT `fk_gold_bill_item_bill`
    FOREIGN KEY (`bill_id`) REFERENCES `gold_bill`(`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --- 5. Customer Ledger ---------------------------------
CREATE TABLE IF NOT EXISTS `gold_ledger` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id`     INT DEFAULT NULL,
  `customer_name`   VARCHAR(255) NOT NULL,
  `bill_id`         INT UNSIGNED DEFAULT NULL,
  `txn_type`        ENUM('BILL','PAYMENT','OPENING') NOT NULL DEFAULT 'BILL',
  `opening_balance` DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `amount`          DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `closing_balance` DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `description`     VARCHAR(255) DEFAULT NULL,
  `txn_date`        DATE NOT NULL,
  `txn_time`        TIME NOT NULL,
  `entered_by`      INT NOT NULL,
  `entered_dt`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `bill_id` (`bill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
