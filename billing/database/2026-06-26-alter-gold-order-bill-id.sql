-- Link billed TM orders to gold transaction
ALTER TABLE gold_order
    ADD COLUMN bill_id INT UNSIGNED NULL AFTER is_billed;
