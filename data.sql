/*
SQLyog Community v13.3.1 (64 bit)
MySQL - 8.4.7 : Database - shivprasad
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`shivprasad` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `shivprasad`;

/*Table structure for table `bank_ledger` */

DROP TABLE IF EXISTS `bank_ledger`;

CREATE TABLE `bank_ledger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned NOT NULL,
  `bank_id` int NOT NULL,
  `in_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `out_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `notes` varchar(255) DEFAULT NULL,
  `user_id` int NOT NULL,
  `date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_bl_bill` (`bill_id`),
  KEY `idx_bl_bank` (`bank_id`),
  KEY `idx_bl_datetime` (`date_time`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `bank_ledger` */

insert  into `bank_ledger`(`id`,`bill_id`,`bank_id`,`in_amount`,`out_amount`,`notes`,`user_id`,`date_time`) values 
(1,3,1,5000.00,0.00,'Gold transaction #3 (SALE)',1,'2026-06-24 22:31:26');

/*Table structure for table `company_details` */

DROP TABLE IF EXISTS `company_details`;

CREATE TABLE `company_details` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `address` text,
  `gstin` varchar(255) DEFAULT NULL,
  `print_type` int NOT NULL DEFAULT '0',
  `printer_name` varchar(255) DEFAULT NULL,
  `bank_details` varchar(255) DEFAULT NULL,
  `barcode_printer` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `company_details` */

insert  into `company_details`(`id`,`shop_name`,`address`,`gstin`,`print_type`,`printer_name`,`bank_details`,`barcode_printer`) values 
(2,'THIRUMALA GOLD BUYERS','HONEST VALUE !!! INSTANT CASH !!! THIRUMALA GOLD PROMISE\r\n\r\n#119/71, GOPAL NAGAR, M.T.H ROAD, PADI, CH-50 PH - 8778630760','33AAZFT0635P1ZF',2,'','Bank Details','AP4909');

/*Table structure for table `configure_bank_details` */

DROP TABLE IF EXISTS `configure_bank_details`;

CREATE TABLE `configure_bank_details` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_blocked` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

/*Data for the table `configure_bank_details` */

insert  into `configure_bank_details`(`id`,`name`,`is_blocked`) values 
(1,'SBI BANK',0),
(2,'CANARA BANK',0),
(3,'AXIS BANK',0),
(4,'IOB BANK',0);

/*Table structure for table `configure_payment_type` */

DROP TABLE IF EXISTS `configure_payment_type`;

CREATE TABLE `configure_payment_type` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_blocked` int unsigned NOT NULL DEFAULT '0',
  `type_id` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

/*Data for the table `configure_payment_type` */

insert  into `configure_payment_type`(`id`,`name`,`is_blocked`,`type_id`) values 
(1,'Cash',0,1),
(2,'BANK',0,2);

/*Table structure for table `customer_account` */

DROP TABLE IF EXISTS `customer_account`;

CREATE TABLE `customer_account` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `advance` decimal(10,2) NOT NULL DEFAULT '0.00',
  `balance` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `customer_account` */

insert  into `customer_account`(`id`,`customer_id`,`advance`,`balance`) values 
(1,1,50000.00,0.00),
(2,2,0.00,0.00),
(3,3,0.00,5000.00);

/*Table structure for table `customers` */

DROP TABLE IF EXISTS `customers`;

CREATE TABLE `customers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `is_eligible_for_commission` tinyint DEFAULT '1',
  `is_active` int DEFAULT '1',
  `gstin` varchar(255) DEFAULT NULL,
  `is_gst` int DEFAULT '0',
  `salesman` int DEFAULT NULL,
  `area` int DEFAULT NULL,
  `credit_limit` double(10,2) NOT NULL DEFAULT '0.00',
  `local` int DEFAULT '1',
  `exchange_point` double(10,3) DEFAULT '0.000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `customers` */

insert  into `customers`(`id`,`name`,`phone_number`,`address`,`date`,`time`,`is_eligible_for_commission`,`is_active`,`gstin`,`is_gst`,`salesman`,`area`,`credit_limit`,`local`,`exchange_point`) values 
(1,'JASWA VIJAY','9597451419','assaaaaaaaaaaaa\r\n sdddddddddddddddddddddddddddd dsds','2026-06-10','21:47:48',0,1,'',0,NULL,NULL,0.00,1,0.000),
(2,'JEBS','9898989898','no 10, Joseph colony, Thittuvaila,kanyakumari dist, Tamilnadi','2026-06-10','22:20:38',0,1,'',0,NULL,NULL,0.00,1,0.000),
(3,'KRISH','23232332232332','wdsssssssss\r\nsfsfsfsf','2026-06-20','13:52:27',0,1,'',0,NULL,NULL,0.00,1,0.000);

/*Table structure for table `expense_entry` */

DROP TABLE IF EXISTS `expense_entry`;

CREATE TABLE `expense_entry` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `exp_type` int NOT NULL,
  `content` varchar(255) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text,
  `exc_date_time` datetime DEFAULT NULL,
  `entry_date_time` datetime DEFAULT NULL,
  `is_active` int DEFAULT '1',
  `uid` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type` (`exp_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `expense_entry` */

insert  into `expense_entry`(`id`,`exp_type`,`content`,`amount`,`description`,`exc_date_time`,`entry_date_time`,`is_active`,`uid`) values 
(1,1,'d',15.00,'dd','2026-06-20 15:41:00','2026-06-20 15:42:00',1,1);

/*Table structure for table `expense_type` */

DROP TABLE IF EXISTS `expense_type`;

CREATE TABLE `expense_type` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(255) NOT NULL,
  `is_active` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `expense_type` */

insert  into `expense_type`(`id`,`type`,`is_active`) values 
(1,'TEA',1);

/*Table structure for table `gold_bill` */

DROP TABLE IF EXISTS `gold_bill`;

CREATE TABLE `gold_bill` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_no` int unsigned NOT NULL DEFAULT '0' COMMENT 'display bill id, set in application code',
  `customer_id` int DEFAULT NULL COMMENT 'NULL for walk-in',
  `customer_name` varchar(255) NOT NULL,
  `customer_phone` varchar(20) DEFAULT NULL,
  `id_proof_no` varchar(100) DEFAULT NULL,
  `addr_proof_no` varchar(100) DEFAULT NULL,
  `gold_rate` decimal(10,2) NOT NULL,
  `gross_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `margin` decimal(12,2) NOT NULL DEFAULT '0.00',
  `net_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `release_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `amount_paid` decimal(12,2) NOT NULL DEFAULT '0.00',
  `bill_date` date NOT NULL,
  `bill_time` time NOT NULL,
  `entered_by` int NOT NULL COMMENT 'user id',
  `entered_dt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_cancelled` tinyint NOT NULL DEFAULT '0',
  `cancelled_by` int DEFAULT NULL,
  `cancelled_dt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_bill` */

insert  into `gold_bill`(`id`,`bill_no`,`customer_id`,`customer_name`,`customer_phone`,`id_proof_no`,`addr_proof_no`,`gold_rate`,`gross_amount`,`margin`,`net_amount`,`release_amount`,`amount_paid`,`bill_date`,`bill_time`,`entered_by`,`entered_dt`,`is_cancelled`,`cancelled_by`,`cancelled_dt`) values 
(1,1,1,'JASWA VIJAY','9597451419','11111111111111','222222222222222',5980.00,212230.00,100.00,212130.00,100.00,212030.00,'2026-06-20','15:36:00',1,'2026-06-20 15:37:22',0,NULL,NULL);

/*Table structure for table `gold_bill_item` */

DROP TABLE IF EXISTS `gold_bill_item`;

CREATE TABLE `gold_bill_item` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned NOT NULL,
  `ornament_type` varchar(255) NOT NULL,
  `gross_wt` decimal(10,3) NOT NULL DEFAULT '0.000',
  `stone_wax` decimal(10,3) NOT NULL DEFAULT '0.000',
  `net_wt` decimal(10,3) NOT NULL DEFAULT '0.000',
  `purity` decimal(6,2) NOT NULL DEFAULT '0.00',
  `gross_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `bill_id` (`bill_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_bill_item` */

insert  into `gold_bill_item`(`id`,`bill_id`,`ornament_type`,`gross_wt`,`stone_wax`,`net_wt`,`purity`,`gross_amount`) values 
(1,1,'neck',21.000,0.000,21.000,91.00,114278.00),
(2,1,'coi',20.000,1.000,19.000,78.00,97952.00);

/*Table structure for table `gold_ledger` */

DROP TABLE IF EXISTS `gold_ledger`;

CREATE TABLE `gold_ledger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int DEFAULT NULL,
  `customer_name` varchar(255) NOT NULL,
  `bill_id` int unsigned DEFAULT NULL,
  `txn_type` enum('BILL','PAYMENT','OPENING') NOT NULL DEFAULT 'BILL',
  `opening_balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `closing_balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `description` varchar(255) DEFAULT NULL,
  `txn_date` date NOT NULL,
  `txn_time` time NOT NULL,
  `entered_by` int NOT NULL,
  `entered_dt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_open_balance_entry` tinyint(1) NOT NULL DEFAULT '0',
  `is_expense` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `bill_id` (`bill_id`),
  KEY `idx_is_open_balance_entry` (`is_open_balance_entry`,`txn_date`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_ledger` */

insert  into `gold_ledger`(`id`,`customer_id`,`customer_name`,`bill_id`,`txn_type`,`opening_balance`,`amount`,`closing_balance`,`description`,`txn_date`,`txn_time`,`entered_by`,`entered_dt`,`is_open_balance_entry`,`is_expense`) values 
(1,NULL,'OPENING BALANCE',NULL,'OPENING',0.00,500000.00,0.00,'Opening Balance','2026-06-20','15:36:42',1,'2026-06-20 15:36:42',1,0),
(2,1,'JASWA VIJAY',1,'BILL',0.00,212030.00,212030.00,'Gold Bill #1','2026-06-20','15:36:48',1,'2026-06-20 15:37:22',0,0),
(3,NULL,'EXPENSE',NULL,'PAYMENT',0.00,15.00,0.00,'d','2026-06-20','15:41:00',1,'2026-06-20 15:42:00',0,0);

/*Table structure for table `gold_rate` */

DROP TABLE IF EXISTS `gold_rate`;

CREATE TABLE `gold_rate` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `rate` decimal(10,2) NOT NULL,
  `entered_by` int NOT NULL COMMENT 'user id',
  `entered_dt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_rate` */

insert  into `gold_rate`(`id`,`rate`,`entered_by`,`entered_dt`) values 
(1,5980.00,1,'2026-06-20 15:24:08');

/*Table structure for table `gold_stock` */

DROP TABLE IF EXISTS `gold_stock`;

CREATE TABLE `gold_stock` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `prods_id` int unsigned NOT NULL,
  `stock` decimal(14,3) NOT NULL DEFAULT '0.000',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_gold_stock_prods_id` (`prods_id`),
  KEY `idx_gold_stock_prods_id` (`prods_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_stock` */

insert  into `gold_stock`(`id`,`prods_id`,`stock`,`updated_at`) values 
(1,1,8.000,'2026-06-24 22:31:27');

/*Table structure for table `gold_transaction_ledger` */

DROP TABLE IF EXISTS `gold_transaction_ledger`;

CREATE TABLE `gold_transaction_ledger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `bill_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `in_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `out_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `notes` varchar(255) DEFAULT NULL,
  `date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int NOT NULL,
  `is_sale` tinyint(1) NOT NULL DEFAULT '0',
  `is_purchase` tinyint(1) NOT NULL DEFAULT '0',
  `is_cancelled` tinyint(1) NOT NULL DEFAULT '0',
  `is_balance_collection` tinyint(1) NOT NULL DEFAULT '0',
  `is_pay_or_collect` tinyint(1) NOT NULL DEFAULT '0',
  `is_opening_balance` tinyint(1) NOT NULL DEFAULT '0',
  `cancel_user` int DEFAULT NULL,
  `cancel_date_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_gtl_bill` (`bill_id`),
  KEY `idx_gtl_customer` (`customer_id`),
  KEY `idx_gtl_date` (`date_time`),
  KEY `idx_gtl_balance_collection` (`is_balance_collection`),
  KEY `idx_gtl_bill_amount` (`bill_amount`),
  KEY `idx_gtl_pay_collect` (`is_pay_or_collect`),
  KEY `idx_gtl_opening_balance` (`is_opening_balance`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_transaction_ledger` */

insert  into `gold_transaction_ledger`(`id`,`bill_id`,`customer_id`,`bill_amount`,`in_amount`,`out_amount`,`notes`,`date_time`,`user_id`,`is_sale`,`is_purchase`,`is_cancelled`,`is_balance_collection`,`is_pay_or_collect`,`is_opening_balance`,`cancel_user`,`cancel_date_time`) values 
(1,NULL,NULL,500000.00,500000.00,0.00,'Opening Balance','2026-06-24 22:20:27',1,0,0,0,0,0,1,NULL,NULL),
(2,1,1,100000.00,0.00,0.00,'Gold transaction #1 (PURCHASE)','2026-06-24 22:22:41',1,0,1,0,0,0,0,NULL,NULL),
(3,NULL,1,50000.00,0.00,50000.00,'Credit settlement (PAY)','2026-06-24 22:30:00',1,0,0,0,1,1,0,NULL,NULL),
(4,2,2,20000.00,20000.00,0.00,'Gold transaction #2 (SALE)','2026-06-24 22:30:43',1,1,0,0,0,0,0,NULL,NULL),
(5,3,3,25000.00,5000.00,0.00,'Gold transaction #3 (SALE)','2026-06-24 22:31:26',1,1,0,0,0,0,0,NULL,NULL),
(6,NULL,3,15000.00,15000.00,0.00,'Credit settlement (COLLECT)','2026-06-24 22:31:40',1,0,0,0,1,2,0,NULL,NULL);

/*Table structure for table `gold_trasaction` */

DROP TABLE IF EXISTS `gold_trasaction`;

CREATE TABLE `gold_trasaction` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  `bill_date` date NOT NULL,
  `bill_time` time NOT NULL,
  `enter_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `paid` decimal(14,2) NOT NULL DEFAULT '0.00',
  `balance` decimal(14,2) NOT NULL DEFAULT '0.00',
  `current_balance` decimal(14,2) NOT NULL DEFAULT '0.00',
  `is_sale` tinyint(1) NOT NULL DEFAULT '0',
  `is_purchase` tinyint(1) NOT NULL DEFAULT '0',
  `is_cancelled` tinyint(1) NOT NULL DEFAULT '0',
  `cancel_user` int DEFAULT NULL,
  `cancel_date_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_gt_customer` (`customer_id`),
  KEY `idx_gt_user` (`user_id`),
  KEY `idx_gt_bill_date` (`bill_date`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction` */

insert  into `gold_trasaction`(`id`,`customer_id`,`user_id`,`bill_date`,`bill_time`,`enter_date_time`,`total`,`paid`,`balance`,`current_balance`,`is_sale`,`is_purchase`,`is_cancelled`,`cancel_user`,`cancel_date_time`) values 
(1,1,1,'2026-06-24','22:22:41','2026-06-24 22:22:42',100000.00,0.00,100000.00,-100000.00,0,1,0,NULL,NULL),
(2,2,1,'2026-06-24','22:30:43','2026-06-24 22:30:44',20000.00,20000.00,0.00,0.00,1,0,0,NULL,NULL),
(3,3,1,'2026-06-24','22:31:26','2026-06-24 22:31:27',25000.00,5000.00,20000.00,20000.00,1,0,0,NULL,NULL);

/*Table structure for table `gold_trasaction_details` */

DROP TABLE IF EXISTS `gold_trasaction_details`;

CREATE TABLE `gold_trasaction_details` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned NOT NULL,
  `particular` varchar(255) NOT NULL,
  `qty_gram` decimal(14,3) NOT NULL DEFAULT '0.000',
  `rate` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total` decimal(14,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `idx_gtd_bill` (`bill_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction_details` */

insert  into `gold_trasaction_details`(`id`,`bill_id`,`particular`,`qty_gram`,`rate`,`total`) values 
(1,1,'gold',10.000,10000.00,100000.00),
(2,2,'gol',1.000,20000.00,20000.00),
(3,3,'gols',1.000,25000.00,25000.00);

/*Table structure for table `gold_trasaction_payment` */

DROP TABLE IF EXISTS `gold_trasaction_payment`;

CREATE TABLE `gold_trasaction_payment` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `payment_mode` varchar(50) NOT NULL,
  `payment_bank` int DEFAULT NULL,
  `amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `bill_date` date DEFAULT NULL,
  `bill_time` time DEFAULT NULL,
  `date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_balance_collection` tinyint(1) NOT NULL DEFAULT '0',
  `is_pay_or_collect` tinyint(1) NOT NULL DEFAULT '0',
  `is_opening_balance` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_gtp_bill` (`bill_id`),
  KEY `idx_gtp_bank` (`payment_bank`),
  KEY `idx_gtp_customer` (`customer_id`),
  KEY `idx_gtp_user` (`user_id`),
  KEY `idx_gtp_balance_collection` (`is_balance_collection`),
  KEY `idx_gtp_datetime` (`date_time`),
  KEY `idx_gtp_pay_collect` (`is_pay_or_collect`),
  KEY `idx_gtp_opening_balance` (`is_opening_balance`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction_payment` */

insert  into `gold_trasaction_payment`(`id`,`bill_id`,`customer_id`,`user_id`,`payment_mode`,`payment_bank`,`amount`,`bill_date`,`bill_time`,`date_time`,`is_balance_collection`,`is_pay_or_collect`,`is_opening_balance`) values 
(1,NULL,NULL,1,'cash',NULL,500000.00,'2026-06-24','22:20:27','2026-06-24 22:20:27',0,0,1),
(2,1,NULL,NULL,'balance',NULL,100000.00,NULL,NULL,'2026-06-24 22:22:42',0,0,0),
(3,NULL,1,1,'cash',NULL,50000.00,'2026-06-24','22:30:00','2026-06-24 22:30:00',1,1,0),
(4,2,NULL,NULL,'cash',NULL,20000.00,NULL,NULL,'2026-06-24 22:30:44',0,0,0),
(5,3,NULL,NULL,'gpay',1,5000.00,NULL,NULL,'2026-06-24 22:31:27',0,0,0),
(6,3,NULL,NULL,'balance',NULL,20000.00,NULL,NULL,'2026-06-24 22:31:27',0,0,0),
(7,NULL,3,1,'cash',NULL,15000.00,'2026-06-24','22:31:40','2026-06-24 22:31:40',1,2,0);

/*Table structure for table `gold_trasaction_stock` */

DROP TABLE IF EXISTS `gold_trasaction_stock`;

CREATE TABLE `gold_trasaction_stock` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned NOT NULL,
  `in_qty` decimal(14,3) NOT NULL DEFAULT '0.000',
  `out_qty` decimal(14,3) NOT NULL DEFAULT '0.000',
  `customer_id` int DEFAULT NULL,
  `rate` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `txn_date_time` datetime NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_gts_bill` (`bill_id`),
  KEY `idx_gts_customer` (`customer_id`),
  KEY `idx_gts_datetime` (`txn_date_time`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction_stock` */

insert  into `gold_trasaction_stock`(`id`,`bill_id`,`in_qty`,`out_qty`,`customer_id`,`rate`,`total`,`txn_date_time`,`user_id`) values 
(1,1,10.000,0.000,1,10000.00,100000.00,'2026-06-24 22:22:41',1),
(2,2,0.000,1.000,2,20000.00,20000.00,'2026-06-24 22:30:43',1),
(3,3,0.000,1.000,3,25000.00,25000.00,'2026-06-24 22:31:26',1);

/*Table structure for table `gstin` */

DROP TABLE IF EXISTS `gstin`;

CREATE TABLE `gstin` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `gstin` varchar(255) NOT NULL,
  `shop_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gstin` */

/*Table structure for table `heading` */

DROP TABLE IF EXISTS `heading`;

CREATE TABLE `heading` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `head1` varchar(255) DEFAULT NULL,
  `head2` varchar(255) DEFAULT NULL,
  `head3` varchar(255) DEFAULT NULL,
  `active` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `heading` */

insert  into `heading`(`id`,`head1`,`head2`,`head3`,`active`) values 
(1,'Category','Brand','Product',200);

/*Table structure for table `prod_batch` */

DROP TABLE IF EXISTS `prod_batch`;

CREATE TABLE `prod_batch` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `product_id` int NOT NULL,
  `cost` double(10,3) DEFAULT '0.000',
  `mrp` double(10,3) DEFAULT '0.000',
  `commission` double(10,3) DEFAULT '0.000',
  `stock` decimal(10,2) NOT NULL,
  `disc_type` int DEFAULT '0' COMMENT '1=rs 2=%',
  `discount` double(10,3) DEFAULT '0.000',
  `date` date DEFAULT NULL,
  `time` time DEFAULT '00:00:00',
  `added_stock` decimal(10,2) NOT NULL,
  `uid` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `prod` (`product_id`),
  KEY `disc` (`disc_type`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `prod_batch` */

insert  into `prod_batch`(`id`,`name`,`product_id`,`cost`,`mrp`,`commission`,`stock`,`disc_type`,`discount`,`date`,`time`,`added_stock`,`uid`) values 
(1,'Z101',1,160.000,360.000,0.000,4.00,0,0.000,'2026-06-10','21:46:59',0.00,1);

/*Table structure for table `prod_units` */

DROP TABLE IF EXISTS `prod_units`;

CREATE TABLE `prod_units` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `convertion_unit` varchar(255) DEFAULT NULL,
  `convertion_calculation` decimal(10,2) DEFAULT NULL,
  `is_active` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `prod_units` */

insert  into `prod_units`(`id`,`name`,`convertion_unit`,`convertion_calculation`,`is_active`) values 
(1,'NOS',NULL,NULL,1),
(2,'Gram',NULL,NULL,1),
(3,'KG',NULL,NULL,1),
(4,'Meter',NULL,NULL,1),
(5,'length','Feet',20.00,1);

/*Table structure for table `user_modules` */

DROP TABLE IF EXISTS `user_modules`;

CREATE TABLE `user_modules` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `module_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

/*Data for the table `user_modules` */

insert  into `user_modules`(`id`,`module_name`) values 
(1,'Gold buy entry'),
(2,'Gold buy report'),
(3,'Ledger'),
(4,'Customer'),
(5,'Expense'),
(6,'Admin');

/*Table structure for table `user_permission` */

DROP TABLE IF EXISTS `user_permission`;

CREATE TABLE `user_permission` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int NOT NULL,
  `uid` int NOT NULL,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mod` (`module_id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=latin1;

/*Data for the table `user_permission` */

insert  into `user_permission`(`id`,`module_id`,`uid`,`date`,`time`) values 
(70,1,1,'2025-09-19','11:43:23'),
(71,2,1,'2025-09-19','11:43:23'),
(72,3,1,'2025-09-19','11:43:23'),
(73,4,1,'2025-09-19','11:43:23'),
(74,5,1,'2025-09-19','11:43:23'),
(75,6,1,'2025-09-19','11:43:23');

/*Table structure for table `user_special_permission` */

DROP TABLE IF EXISTS `user_special_permission`;

CREATE TABLE `user_special_permission` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `content_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `user_special_permission` */

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `is_active` int DEFAULT '1',
  `fullName` varchar(255) DEFAULT NULL,
  `disc_per` int DEFAULT '100',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;

/*Data for the table `users` */

insert  into `users`(`id`,`user_name`,`password`,`is_active`,`fullName`,`disc_per`) values 
(1,'admin','aecbf9a63cec1e93327dfc212f31acdb31c4f5d10bedccf8fbb8b042a6f0f39155797bdd04517905ae5d98b69fdc452cdb61b018e10939740ec96f36e133d639',1,'admin',50);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
