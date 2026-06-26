-- Reserved TM order stock on gold_stock (prods_id = 1)
-- Run once on live DB

ALTER TABLE gold_stock
    ADD COLUMN purchase_order_stock DECIMAL(14,3) NOT NULL DEFAULT 0.000 AFTER stock;

ALTER TABLE gold_stock
    ADD COLUMN sale_order_stock DECIMAL(14,3) NOT NULL DEFAULT 0.000 AFTER purchase_order_stock;
