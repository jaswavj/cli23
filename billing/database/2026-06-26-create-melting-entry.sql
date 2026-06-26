-- Melting entry records
CREATE TABLE IF NOT EXISTS melting_entry (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    entry_date DATE NOT NULL,
    name VARCHAR(120) NOT NULL,
    gram DECIMAL(14,3) NOT NULL DEFAULT 0.000,
    purity DECIMAL(8,3) NOT NULL DEFAULT 0.000,
    bonus DECIMAL(8,3) NOT NULL DEFAULT 0.000,
    total DECIMAL(14,3) NOT NULL DEFAULT 0.000,
    melting VARCHAR(120) DEFAULT NULL,
    notes TEXT,
    user_id INT NOT NULL,
    enter_date_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_melting_entry_date (entry_date),
    KEY idx_melting_entry_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
