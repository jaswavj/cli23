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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `bank_ledger` */

insert  into `bank_ledger`(`id`,`bill_id`,`bank_id`,`in_amount`,`out_amount`,`notes`,`user_id`,`date_time`) values 
(1,0,3,500000.00,0.00,'opening balance',1,'2026-06-26 11:16:27'),
(2,1,3,0.00,100000.00,'Gold transaction #1 (PURCHASE)',1,'2026-06-26 11:20:00'),
(3,0,3,0.00,1500.00,'test',1,'2026-06-26 11:32:06');

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
  `balance` decimal(14,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

/*Data for the table `configure_bank_details` */

insert  into `configure_bank_details`(`id`,`name`,`is_blocked`,`balance`) values 
(1,'SBI BANK',0,0.00),
(2,'CANARA BANK',0,0.00),
(3,'AXIS BANK',0,398500.00),
(4,'IOB BANK',0,0.00),
(5,'DFG',0,0.00);

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
(1,1,0.00,0.00),
(2,2,0.00,0.00),
(3,3,0.00,188000.00);

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

/*Table structure for table `emi_customer` */

DROP TABLE IF EXISTS `emi_customer`;

CREATE TABLE `emi_customer` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `total_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `emi_type` varchar(10) NOT NULL DEFAULT 'borrow',
  `dept_type` varchar(10) NOT NULL DEFAULT 'normal',
  `emi_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `emi_months` int unsigned NOT NULL DEFAULT '0',
  `interest_per_month` decimal(14,2) NOT NULL DEFAULT '0.00',
  `due_day` tinyint unsigned NOT NULL DEFAULT '1',
  `first_due_date` date NOT NULL,
  `user_id` int NOT NULL,
  `date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_closed` tinyint(1) NOT NULL DEFAULT '0',
  `closed_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_emi_customer_closed` (`is_closed`),
  KEY `idx_emi_customer_name` (`customer_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `emi_customer` */

insert  into `emi_customer`(`id`,`customer_name`,`phone_number`,`total_amount`,`emi_type`,`dept_type`,`emi_amount`,`emi_months`,`interest_per_month`,`due_day`,`first_due_date`,`user_id`,`date_time`,`is_closed`,`closed_date`) values 
(1,'testing','99999999999',100000.00,'borrow','normal',11000.00,10,0.00,26,'2026-06-26',1,'2026-06-26 11:34:35',0,NULL),
(2,'jas','222222',100000.00,'borrow','interest',2000.00,0,2000.00,1,'2026-07-01',1,'2026-06-26 14:49:17',1,'2026-06-26 14:50:05'),
(3,'zz','677',100000.00,'borrow','interest',2000.00,0,2000.00,26,'2026-06-26',1,'2026-06-26 16:50:52',1,'2026-06-26 16:51:10');

/*Table structure for table `emi_installment` */

DROP TABLE IF EXISTS `emi_installment`;

CREATE TABLE `emi_installment` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `emi_customer_id` int unsigned NOT NULL,
  `installment_no` int unsigned NOT NULL,
  `due_date` date NOT NULL,
  `emi_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `paid_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `paid_date` datetime DEFAULT NULL,
  `paid_user_id` int DEFAULT NULL,
  `is_paid` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_emi_inst_customer` (`emi_customer_id`),
  KEY `idx_emi_inst_due` (`due_date`),
  KEY `idx_emi_inst_paid` (`is_paid`),
  KEY `idx_emi_inst_customer_no` (`emi_customer_id`,`installment_no`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `emi_installment` */

insert  into `emi_installment`(`id`,`emi_customer_id`,`installment_no`,`due_date`,`emi_amount`,`paid_amount`,`paid_date`,`paid_user_id`,`is_paid`) values 
(1,1,1,'2026-06-26',11000.00,11000.00,'2026-06-26 11:35:22',1,1),
(2,1,2,'2026-07-26',11000.00,0.00,NULL,NULL,0),
(3,1,3,'2026-08-26',11000.00,0.00,NULL,NULL,0),
(4,1,4,'2026-09-26',11000.00,0.00,NULL,NULL,0),
(5,1,5,'2026-10-26',11000.00,0.00,NULL,NULL,0),
(6,1,6,'2026-11-26',11000.00,0.00,NULL,NULL,0),
(7,1,7,'2026-12-26',11000.00,0.00,NULL,NULL,0),
(8,1,8,'2027-01-26',11000.00,0.00,NULL,NULL,0),
(9,1,9,'2027-02-26',11000.00,0.00,NULL,NULL,0),
(10,1,10,'2027-03-26',11000.00,0.00,NULL,NULL,0),
(11,2,1,'2026-07-01',2000.00,2000.00,'2026-06-26 14:49:28',1,1),
(12,2,2,'2026-08-01',2000.00,2000.00,'2026-06-26 14:49:40',1,1),
(14,3,1,'2026-06-26',2000.00,2000.00,'2026-06-26 16:50:57',1,1),
(15,3,2,'2026-07-26',2000.00,2000.00,'2026-06-26 16:51:00',1,1),
(16,3,3,'2026-08-26',2000.00,2000.00,'2026-06-26 16:51:06',1,1);

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
(1,1,'tea',15.00,'ss','2026-06-26 11:35:00','2026-06-26 11:35:49',1,1);

/*Table structure for table `expense_type` */

DROP TABLE IF EXISTS `expense_type`;

CREATE TABLE `expense_type` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(255) NOT NULL,
  `is_active` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `expense_type` */

insert  into `expense_type`(`id`,`type`,`is_active`) values 
(1,'TEA',1),
(2,'EXPENSE',1);

/*Table structure for table `gold_order` */

DROP TABLE IF EXISTS `gold_order`;

CREATE TABLE `gold_order` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `is_billed` tinyint(1) NOT NULL DEFAULT '0',
  `bill_id` int unsigned DEFAULT NULL,
  `order_date_time` datetime NOT NULL,
  `user_id` int NOT NULL,
  `is_cancelled` tinyint(1) NOT NULL DEFAULT '0',
  `qty` decimal(14,3) NOT NULL DEFAULT '0.000',
  `type` tinyint unsigned NOT NULL COMMENT '1=purchase, 2=sale',
  `enter_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_gold_order_customer` (`customer_id`),
  KEY `idx_gold_order_type` (`type`),
  KEY `idx_gold_order_billed` (`is_billed`),
  KEY `idx_gold_order_cancelled` (`is_cancelled`),
  KEY `idx_gold_order_date` (`order_date_time`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_order` */

insert  into `gold_order`(`id`,`customer_id`,`is_billed`,`bill_id`,`order_date_time`,`user_id`,`is_cancelled`,`qty`,`type`,`enter_date_time`) values 
(1,3,1,4,'2026-06-26 00:00:00',1,0,2.000,2,'2026-06-26 15:17:57'),
(2,1,0,NULL,'2026-06-26 00:00:00',1,0,10.000,1,'2026-06-26 16:10:40'),
(3,2,0,NULL,'2026-06-26 00:00:00',1,0,5.000,2,'2026-06-26 16:10:54'),
(4,3,1,5,'2026-06-26 00:00:00',1,0,10.000,2,'2026-06-26 16:49:48');

/*Table structure for table `gold_stock` */

DROP TABLE IF EXISTS `gold_stock`;

CREATE TABLE `gold_stock` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `prods_id` int unsigned NOT NULL,
  `stock` decimal(14,3) NOT NULL DEFAULT '0.000',
  `purchase_order_stock` decimal(14,3) NOT NULL DEFAULT '0.000',
  `sale_order_stock` decimal(14,3) NOT NULL DEFAULT '0.000',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_gold_stock_prods_id` (`prods_id`),
  KEY `idx_gold_stock_prods_id` (`prods_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_stock` */

insert  into `gold_stock`(`id`,`prods_id`,`stock`,`purchase_order_stock`,`sale_order_stock`,`updated_at`) values 
(1,1,5.000,10.000,5.000,'2026-06-26 16:50:22');

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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_transaction_ledger` */

insert  into `gold_transaction_ledger`(`id`,`bill_id`,`customer_id`,`bill_amount`,`in_amount`,`out_amount`,`notes`,`date_time`,`user_id`,`is_sale`,`is_purchase`,`is_cancelled`,`is_balance_collection`,`is_pay_or_collect`,`is_opening_balance`,`cancel_user`,`cancel_date_time`) values 
(1,NULL,NULL,500000.00,500000.00,0.00,'Opening Balance','2026-06-26 11:16:05',1,0,0,0,0,0,1,NULL,NULL),
(2,1,1,240000.00,0.00,200000.00,'Gold transaction #1 (PURCHASE)','2026-06-26 11:20:00',1,0,1,0,0,0,0,NULL,NULL),
(3,NULL,1,40000.00,0.00,40000.00,'Credit settlement (PAY)','2026-06-26 11:20:30',1,0,0,0,1,1,0,NULL,NULL),
(4,2,2,32000.00,30000.00,0.00,'Gold transaction #2 (SALE)','2026-06-26 11:21:03',1,1,0,0,0,0,0,NULL,NULL),
(5,NULL,2,2000.00,2000.00,0.00,'Credit settlement (COLLECT)','2026-06-26 11:21:22',1,0,0,0,1,2,0,NULL,NULL),
(6,4,3,28000.00,0.00,0.00,'Gold transaction #4 (SALE)','2026-06-26 16:08:26',1,1,0,0,0,0,0,NULL,NULL),
(7,5,3,160000.00,0.00,0.00,'Gold transaction #5 (SALE)','2026-06-26 16:50:21',1,1,0,0,0,0,0,NULL,NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction` */

insert  into `gold_trasaction`(`id`,`customer_id`,`user_id`,`bill_date`,`bill_time`,`enter_date_time`,`total`,`paid`,`balance`,`current_balance`,`is_sale`,`is_purchase`,`is_cancelled`,`cancel_user`,`cancel_date_time`) values 
(1,1,1,'2026-06-26','11:20:00','2026-06-26 11:20:00',240000.00,200000.00,40000.00,-40000.00,0,1,0,NULL,NULL),
(2,2,1,'2026-06-26','11:21:03','2026-06-26 11:21:04',32000.00,30000.00,2000.00,2000.00,1,0,0,NULL,NULL),
(4,3,1,'2026-06-26','16:08:26','2026-06-26 16:08:26',28000.00,0.00,28000.00,28000.00,1,0,0,NULL,NULL),
(5,3,1,'2026-06-26','16:50:21','2026-06-26 16:50:22',160000.00,0.00,160000.00,188000.00,1,0,0,NULL,NULL);

/*Table structure for table `gold_trasaction_cancel` */

DROP TABLE IF EXISTS `gold_trasaction_cancel`;

CREATE TABLE `gold_trasaction_cancel` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ledger_id` int unsigned DEFAULT NULL,
  `bill_id` int unsigned DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `cancel_type` varchar(30) NOT NULL COMMENT 'SALE, PURCHASE, OPENING, PAY, COLLECT',
  `bill_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `in_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `out_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `notes` varchar(255) DEFAULT NULL,
  `txn_date_time` datetime DEFAULT NULL,
  `is_sale` tinyint(1) NOT NULL DEFAULT '0',
  `is_purchase` tinyint(1) NOT NULL DEFAULT '0',
  `is_opening_balance` tinyint(1) NOT NULL DEFAULT '0',
  `is_balance_collection` tinyint(1) NOT NULL DEFAULT '0',
  `is_pay_or_collect` tinyint(1) NOT NULL DEFAULT '0',
  `cancel_user` int NOT NULL,
  `cancel_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cancel_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_gtc_bill` (`bill_id`),
  KEY `idx_gtc_ledger` (`ledger_id`),
  KEY `idx_gtc_customer` (`customer_id`),
  KEY `idx_gtc_cancel_type` (`cancel_type`),
  KEY `idx_gtc_cancel_dt` (`cancel_date_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction_cancel` */

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction_details` */

insert  into `gold_trasaction_details`(`id`,`bill_id`,`particular`,`qty_gram`,`rate`,`total`) values 
(1,1,'gold',24.000,10000.00,240000.00),
(2,2,'gold',2.000,16000.00,32000.00),
(4,4,'TM Order #1',2.000,14000.00,28000.00),
(5,5,'TM Order #4',10.000,16000.00,160000.00);

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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction_payment` */

insert  into `gold_trasaction_payment`(`id`,`bill_id`,`customer_id`,`user_id`,`payment_mode`,`payment_bank`,`amount`,`bill_date`,`bill_time`,`date_time`,`is_balance_collection`,`is_pay_or_collect`,`is_opening_balance`) values 
(1,NULL,NULL,1,'cash',NULL,500000.00,'2026-06-26','11:16:05','2026-06-26 11:16:05',0,0,1),
(2,1,NULL,NULL,'cash',NULL,100000.00,NULL,NULL,'2026-06-26 11:20:00',0,0,0),
(3,1,NULL,NULL,'gpay',3,100000.00,NULL,NULL,'2026-06-26 11:20:00',0,0,0),
(4,1,NULL,NULL,'balance',NULL,40000.00,NULL,NULL,'2026-06-26 11:20:00',0,0,0),
(5,NULL,1,1,'cash',NULL,20000.00,'2026-06-26','11:20:30','2026-06-26 11:20:30',1,1,0),
(6,NULL,1,1,'gpay',3,20000.00,'2026-06-26','11:20:30','2026-06-26 11:20:30',1,1,0),
(7,2,NULL,NULL,'cash',NULL,30000.00,NULL,NULL,'2026-06-26 11:21:04',0,0,0),
(8,2,NULL,NULL,'balance',NULL,2000.00,NULL,NULL,'2026-06-26 11:21:04',0,0,0),
(9,NULL,2,1,'gpay',3,2000.00,'2026-06-26','11:21:22','2026-06-26 11:21:22',1,2,0),
(11,4,NULL,NULL,'balance',NULL,28000.00,NULL,NULL,'2026-06-26 16:08:26',0,0,0),
(12,5,NULL,NULL,'balance',NULL,160000.00,NULL,NULL,'2026-06-26 16:50:22',0,0,0);

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
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_gts_bill` (`bill_id`),
  KEY `idx_gts_customer` (`customer_id`),
  KEY `idx_gts_datetime` (`txn_date_time`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gold_trasaction_stock` */

insert  into `gold_trasaction_stock`(`id`,`bill_id`,`in_qty`,`out_qty`,`customer_id`,`rate`,`total`,`txn_date_time`,`user_id`,`notes`) values 
(1,1,24.000,0.000,1,10000.00,240000.00,'2026-06-26 11:20:00',1,'Gold transaction #1 (PURCHASE)'),
(2,2,0.000,2.000,2,16000.00,32000.00,'2026-06-26 11:21:03',1,'Gold transaction #2 (SALE)'),
(4,4,0.000,2.000,3,14000.00,28000.00,'2026-06-26 16:08:26',1,'Gold transaction #4 (SALE)'),
(5,5,0.000,10.000,3,16000.00,160000.00,'2026-06-26 16:50:21',1,'Gold transaction #5 (SALE)');

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

/*Table structure for table `melting_entry` */

DROP TABLE IF EXISTS `melting_entry`;

CREATE TABLE `melting_entry` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entry_date` date NOT NULL,
  `name` varchar(120) NOT NULL,
  `gram` decimal(14,3) NOT NULL DEFAULT '0.000',
  `purity` decimal(8,3) NOT NULL DEFAULT '0.000',
  `bonus` decimal(8,3) NOT NULL DEFAULT '0.000',
  `total` decimal(14,3) NOT NULL DEFAULT '0.000',
  `melting` varchar(120) DEFAULT NULL,
  `notes` text,
  `user_id` int NOT NULL,
  `enter_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_melting_entry_date` (`entry_date`),
  KEY `idx_melting_entry_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `melting_entry` */

insert  into `melting_entry`(`id`,`entry_date`,`name`,`gram`,`purity`,`bonus`,`total`,`melting`,`notes`,`user_id`,`enter_date_time`) values 
(2,'2026-06-26','dd',200.000,91.000,0.200,182.400,'ww','www\nsss',1,'2026-06-26 16:44:03'),
(3,'2026-06-26','ss',200.000,91.000,0.200,182.400,'dd','dddd',1,'2026-06-26 16:51:27');

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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

/*Data for the table `user_modules` */

insert  into `user_modules`(`id`,`module_name`) values 
(1,'Gold Transaction'),
(2,'Gold Transaction Report'),
(3,'Bank Management'),
(4,'EMI Entry'),
(5,'Master'),
(6,'Melting'),
(7,'Expense'),
(8,'Admin');

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
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=latin1;

/*Data for the table `user_permission` */

insert  into `user_permission`(`id`,`module_id`,`uid`,`date`,`time`) values 
(70,1,1,'2025-09-19','11:43:23'),
(71,2,1,'2025-09-19','11:43:23'),
(72,3,1,'2025-09-19','11:43:23'),
(73,4,1,'2025-09-19','11:43:23'),
(74,5,1,'2025-09-19','11:43:23'),
(75,6,1,'2025-09-19','11:43:23'),
(121,7,1,'2025-09-19','11:43:23'),
(122,8,1,'2025-09-19','11:43:23');

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
