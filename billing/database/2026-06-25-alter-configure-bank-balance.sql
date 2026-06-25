-- Bank running balance for GPay/Bank payments
ALTER TABLE configure_bank_details
    ADD COLUMN balance decimal(14,2) NOT NULL DEFAULT 0.00 AFTER is_blocked;
