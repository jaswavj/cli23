-- EMI customer and monthly installment schedule
-- Date: 2026-06-25

CREATE TABLE IF NOT EXISTS emi_customer (
  id int unsigned NOT NULL AUTO_INCREMENT,
  customer_name varchar(255) NOT NULL,
  phone_number varchar(20) DEFAULT NULL,
  total_amount decimal(14,2) NOT NULL DEFAULT '0.00',
  emi_type varchar(10) NOT NULL DEFAULT 'borrow',
  dept_type varchar(10) NOT NULL DEFAULT 'normal',
  emi_amount decimal(14,2) NOT NULL DEFAULT '0.00',
  emi_months int unsigned NOT NULL DEFAULT '0',
  interest_per_month decimal(14,2) NOT NULL DEFAULT '0.00',
  due_day tinyint unsigned NOT NULL DEFAULT '1',
  first_due_date date NOT NULL,
  user_id int NOT NULL,
  date_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_closed tinyint(1) NOT NULL DEFAULT '0',
  closed_date datetime DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_emi_customer_closed (is_closed),
  KEY idx_emi_customer_name (customer_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS emi_installment (
  id int unsigned NOT NULL AUTO_INCREMENT,
  emi_customer_id int unsigned NOT NULL,
  installment_no int unsigned NOT NULL,
  due_date date NOT NULL,
  emi_amount decimal(14,2) NOT NULL DEFAULT '0.00',
  paid_amount decimal(14,2) NOT NULL DEFAULT '0.00',
  paid_date datetime DEFAULT NULL,
  paid_user_id int DEFAULT NULL,
  is_paid tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  KEY idx_emi_inst_customer (emi_customer_id),
  KEY idx_emi_inst_due (due_date),
  KEY idx_emi_inst_paid (is_paid),
  KEY idx_emi_inst_customer_no (emi_customer_id, installment_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
