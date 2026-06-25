-- Add notes column to gold_trasaction_stock for stock movement description / cancel audit
ALTER TABLE gold_trasaction_stock
    ADD COLUMN notes varchar(255) DEFAULT NULL AFTER user_id;
