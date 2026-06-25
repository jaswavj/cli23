-- Add total_amount and emi_type to emi_customer
-- Run once on live DB

ALTER TABLE emi_customer
    ADD COLUMN total_amount DECIMAL(14,2) NOT NULL DEFAULT 0.00 AFTER phone_number;

ALTER TABLE emi_customer
    ADD COLUMN emi_type VARCHAR(10) NOT NULL DEFAULT 'borrow' AFTER total_amount;
