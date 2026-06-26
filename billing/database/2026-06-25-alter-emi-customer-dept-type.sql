-- Add dept type (normal / interest) and interest per month to emi_customer
-- Run once on live DB

ALTER TABLE emi_customer
    ADD COLUMN dept_type VARCHAR(10) NOT NULL DEFAULT 'normal' AFTER emi_type;

ALTER TABLE emi_customer
    ADD COLUMN interest_per_month DECIMAL(14,2) NOT NULL DEFAULT 0.00 AFTER emi_months;

ALTER TABLE emi_customer
    ADD COLUMN closed_date DATETIME NULL AFTER is_closed;
