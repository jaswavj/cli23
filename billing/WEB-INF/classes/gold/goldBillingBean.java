package gold;

import java.sql.*;
import java.util.Vector;

public class goldBillingBean {

    public goldBillingBean() {}

    private Connection getConn() throws SQLException {
        return util.DBConnectionManager.getConnectionFromPool();
    }

    // ═══════════════════════════════════════════════════
    // GOLD RATE
    // ═══════════════════════════════════════════════════

    /** Insert a new gold rate entry and return the inserted id. */
    public int insertGoldRate(double rate, int userId) throws Exception {
        Connection con = null;
        Statement st = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();

            // Ensure table exists in the intended schema.
            st = con.createStatement();
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS gold.gold_rate ("
              + " id INT UNSIGNED NOT NULL AUTO_INCREMENT,"
              + " rate DECIMAL(10,2) NOT NULL,"
              + " entered_by INT NOT NULL,"
              + " entered_dt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,"
              + " PRIMARY KEY (id)"
              + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            ps = con.prepareStatement(
                "INSERT INTO gold.gold_rate (rate, entered_by, entered_dt) VALUES (?, ?, NOW())",
                Statement.RETURN_GENERATED_KEYS);
            ps.setDouble(1, rate);
            ps.setInt(2, userId);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            int insertedId = rs.next() ? rs.getInt(1) : -1;
            con.commit();
            return insertedId;
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ex) {}
            throw e;
        } finally {
            if (st != null) try { st.close(); } catch (Exception e) {}
            close(rs, ps, con);
        }
    }

    /**
     * Get the latest gold rate.
     * Returns Vector: [id, rate, entered_by, entered_dt]
     */
    public Vector getLatestGoldRate() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();
            ps = con.prepareStatement(
                "SELECT id, rate, entered_by, entered_dt FROM gold.gold_rate ORDER BY id DESC LIMIT 1");
            rs = ps.executeQuery();
            Vector v = new Vector();
            if (rs.next()) {
                v.addElement(rs.getString("id"));
                v.addElement(rs.getString("rate"));
                v.addElement(rs.getString("entered_by"));
                v.addElement(rs.getString("entered_dt"));
            }
            return v;
        } finally {
            close(rs, ps, con);
        }
    }

    // ═══════════════════════════════════════════════════
    // SAVE BILL (master + items + ledger in one transaction)
    // ═══════════════════════════════════════════════════

    /**
     * Save a complete gold bill.
     *
     * @param customerId    customer id (0 for walk-in)
     * @param customerName  customer name
     * @param customerPhone customer phone
     * @param idProofNo     id proof number
     * @param addrProofNo   address proof number
     * @param goldRate      gold rate used
     * @param grossAmount   total gross amount
     * @param margin        margin deducted
     * @param netAmount     gross - margin
     * @param releaseAmount release amount
     * @param amountPaid    net - release
     * @param billDate      bill date (yyyy-MM-dd)
     * @param billTime      bill time (HH:mm)
     * @param userId        logged-in user id
     * @param items         Vector of Vectors: each inner = [ornament_type, gross_wt, stone_wax, net_wt, purity, gross_amount]
     * @return generated bill id, or -1 on failure
     */
    public int saveBill(
            int customerId, String customerName, String customerPhone,
            String idProofNo, String addrProofNo,
            double goldRate,
            double grossAmount, double margin, double netAmount,
            double releaseAmount, double amountPaid,
            String billDate, String billTime,
            int userId,
            Vector items) throws Exception {

        Connection con = null;
        PreparedStatement psMaster = null;
        PreparedStatement psItem   = null;
        PreparedStatement psLedger = null;
        ResultSet rs = null;
        try {
            con = getConn();
            con.setAutoCommit(false);

            // ── 1. Insert bill master ──────────────────
            psMaster = con.prepareStatement(
                "INSERT INTO gold_bill " +
                "(customer_id, customer_name, customer_phone, id_proof_no, addr_proof_no, " +
                " gold_rate, gross_amount, margin, net_amount, release_amount, amount_paid, " +
                " bill_date, bill_time, entered_by, entered_dt, is_cancelled) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 0)",
                Statement.RETURN_GENERATED_KEYS);

            if (customerId > 0) psMaster.setInt(1, customerId);
            else                psMaster.setNull(1, Types.INTEGER);
            psMaster.setString(2,  customerName);
            psMaster.setString(3,  customerPhone);
            psMaster.setString(4,  idProofNo);
            psMaster.setString(5,  addrProofNo);
            psMaster.setDouble(6,  goldRate);
            psMaster.setDouble(7,  grossAmount);
            psMaster.setDouble(8,  margin);
            psMaster.setDouble(9,  netAmount);
            psMaster.setDouble(10, releaseAmount);
            psMaster.setDouble(11, amountPaid);
            psMaster.setString(12, billDate);
            psMaster.setString(13, billTime);
            psMaster.setInt(14,    userId);
            psMaster.executeUpdate();

            rs = psMaster.getGeneratedKeys();
            if (!rs.next()) { con.rollback(); return -1; }
            int billId = rs.getInt(1);
            rs.close(); rs = null;

            // Update bill_no = id
            PreparedStatement psbn = con.prepareStatement(
                "UPDATE gold_bill SET bill_no = ? WHERE id = ?");
            psbn.setInt(1, billId);
            psbn.setInt(2, billId);
            psbn.executeUpdate();
            psbn.close();

            // ── 2. Insert items ────────────────────────
            psItem = con.prepareStatement(
                "INSERT INTO gold_bill_item " +
                "(bill_id, ornament_type, gross_wt, stone_wax, net_wt, purity, gross_amount) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)");

            for (int i = 0; i < items.size(); i++) {
                Vector item = (Vector) items.elementAt(i);
                psItem.setInt(1,    billId);
                psItem.setString(2, (String) item.elementAt(0)); // ornament_type
                psItem.setDouble(3, parseD(item.elementAt(1)));  // gross_wt
                psItem.setDouble(4, parseD(item.elementAt(2)));  // stone_wax
                psItem.setDouble(5, parseD(item.elementAt(3)));  // net_wt
                psItem.setDouble(6, parseD(item.elementAt(4)));  // purity
                psItem.setDouble(7, parseD(item.elementAt(5)));  // gross_amount
                psItem.addBatch();
            }
            psItem.executeBatch();

            // ── 3. Ledger entry ────────────────────────
            // Get current closing balance for this customer
            double openingBalance = 0;
            if (customerId > 0) {
                PreparedStatement psLbal = con.prepareStatement(
                    "SELECT closing_balance FROM gold_ledger WHERE customer_id = ? ORDER BY id DESC LIMIT 1");
                psLbal.setInt(1, customerId);
                ResultSet rsLbal = psLbal.executeQuery();
                if (rsLbal.next()) openingBalance = rsLbal.getDouble(1);
                rsLbal.close(); psLbal.close();
            }
            double closingBalance = openingBalance + amountPaid;

            psLedger = con.prepareStatement(
                "INSERT INTO gold_ledger " +
                "(customer_id, customer_name, bill_id, txn_type, opening_balance, amount, closing_balance, " +
                " description, txn_date, txn_time, entered_by, entered_dt) " +
                "VALUES (?, ?, ?, 'BILL', ?, ?, ?, ?, ?, ?, ?, NOW())");

            if (customerId > 0) psLedger.setInt(1, customerId);
            else                psLedger.setNull(1, Types.INTEGER);
            psLedger.setString(2, customerName);
            psLedger.setInt(3,    billId);
            psLedger.setDouble(4, openingBalance);
            psLedger.setDouble(5, amountPaid);
            psLedger.setDouble(6, closingBalance);
            psLedger.setString(7, "Gold Bill #" + billId);
            psLedger.setString(8, billDate);
            psLedger.setString(9, billTime);
            psLedger.setInt(10,   userId);
            psLedger.executeUpdate();

            con.commit();
            return billId;

        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ex) {}
            throw e;
        } finally {
            close(rs, psMaster, null);
            close(null, psItem, null);
            close(null, psLedger, con);
        }
    }

    // ═══════════════════════════════════════════════════
    // GET BILL FOR PRINT
    // ═══════════════════════════════════════════════════

    /**
     * Get bill master for print.
     * Returns Vector: [id, bill_no, customer_name, customer_phone, id_proof_no,
     *                  addr_proof_no, gold_rate, gross_amount, margin, net_amount,
     *                  release_amount, amount_paid, bill_date, bill_time, entered_dt]
     */
    public Vector getBillById(int billId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();
            ps = con.prepareStatement(
                "SELECT id, bill_no, customer_id, customer_name, customer_phone, id_proof_no, addr_proof_no, " +
                "gold_rate, gross_amount, margin, net_amount, release_amount, amount_paid, " +
                "bill_date, bill_time, entered_dt " +
                "FROM gold_bill WHERE id = ? AND is_cancelled = 0");
            ps.setInt(1, billId);
            rs = ps.executeQuery();
            Vector v = new Vector();
            if (rs.next()) {
                for (int i = 1; i <= 16; i++) v.addElement(rs.getString(i));
            }
            return v;
        } finally {
            close(rs, ps, con);
        }
    }

    /**
     * Get items for a bill.
     * Returns Vector of Vectors: [ornament_type, gross_wt, stone_wax, net_wt, purity, gross_amount]
     */
    public Vector getBillItems(int billId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();
            ps = con.prepareStatement(
                "SELECT ornament_type, gross_wt, stone_wax, net_wt, purity, gross_amount " +
                "FROM gold_bill_item WHERE bill_id = ? ORDER BY id");
            ps.setInt(1, billId);
            rs = ps.executeQuery();
            Vector rows = new Vector();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                rows.addElement(row);
            }
            return rows;
        } finally {
            close(rs, ps, con);
        }
    }

    // ═══════════════════════════════════════════════════
    // CANCEL BILL
    // ═══════════════════════════════════════════════════

    public boolean cancelBill(int billId, int userId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConn();
            ps = con.prepareStatement(
                "UPDATE gold_bill SET is_cancelled = 1, cancelled_by = ?, cancelled_dt = NOW() " +
                "WHERE id = ? AND is_cancelled = 0");
            ps.setInt(1, userId);
            ps.setInt(2, billId);
            return ps.executeUpdate() > 0;
        } finally {
            close(null, ps, con);
        }
    }

    // ═══════════════════════════════════════════════════
    // LEDGER REPORT
    // ═══════════════════════════════════════════════════

    /**
     * Returns Vector of rows:
     * [id, txn_date, txn_time, customer_id, customer_name, bill_id, txn_type,
     *  opening_balance, amount, closing_balance, entered_by, entered_dt, description]
     */
    public Vector getLedgerReport(String fromDate, String toDate, int customerId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT id, txn_date, txn_time, customer_id, customer_name, bill_id, txn_type, ");
            sql.append("opening_balance, amount, closing_balance, entered_by, entered_dt, description ");
            sql.append("FROM gold_ledger WHERE 1=1 ");
            if (fromDate != null && !fromDate.trim().isEmpty()) sql.append("AND txn_date >= ? ");
            if (toDate != null && !toDate.trim().isEmpty())     sql.append("AND txn_date <= ? ");
            if (customerId > 0)                                 sql.append("AND customer_id = ? ");
            sql.append("ORDER BY txn_date ASC, txn_time ASC, id ASC");

            ps = con.prepareStatement(sql.toString());
            int idx = 1;
            if (fromDate != null && !fromDate.trim().isEmpty()) ps.setString(idx++, fromDate.trim());
            if (toDate != null && !toDate.trim().isEmpty())     ps.setString(idx++, toDate.trim());
            if (customerId > 0)                                 ps.setInt(idx++, customerId);

            rs = ps.executeQuery();
            Vector rows = new Vector();
            while (rs.next()) {
                Vector r = new Vector();
                r.addElement(rs.getString("id"));
                r.addElement(rs.getString("txn_date"));
                r.addElement(rs.getString("txn_time"));
                r.addElement(rs.getString("customer_id"));
                r.addElement(rs.getString("customer_name"));
                r.addElement(rs.getString("bill_id"));
                r.addElement(rs.getString("txn_type"));
                r.addElement(rs.getString("opening_balance"));
                r.addElement(rs.getString("amount"));
                r.addElement(rs.getString("closing_balance"));
                r.addElement(rs.getString("entered_by"));
                r.addElement(rs.getString("entered_dt"));
                r.addElement(rs.getString("description"));
                rows.addElement(r);
            }
            return rows;
        } finally {
            close(rs, ps, con);
        }
    }

    /**
     * Get opening balance sum from gold_ledger where is_open_balance_entry = 1
     * for the given date range
     */
    public double getOpeningBalance(String fromDate, String toDate, int customerId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT COALESCE(SUM(amount), 0) as total FROM gold_ledger ");
            sql.append("WHERE is_open_balance_entry = 1 ");
            if (fromDate != null && !fromDate.trim().isEmpty()) sql.append("AND txn_date >= ? ");
            if (toDate != null && !toDate.trim().isEmpty())     sql.append("AND txn_date <= ? ");
            if (customerId > 0)                                 sql.append("AND customer_id = ? ");

            ps = con.prepareStatement(sql.toString());
            int idx = 1;
            if (fromDate != null && !fromDate.trim().isEmpty()) ps.setString(idx++, fromDate.trim());
            if (toDate != null && !toDate.trim().isEmpty())     ps.setString(idx++, toDate.trim());
            if (customerId > 0)                                 ps.setInt(idx++, customerId);

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("total");
            }
            return 0.0;
        } finally {
            close(rs, ps, con);
        }
    }

    // ═══════════════════════════════════════════════════
    // BILL REPORT (DATE RANGE + CUSTOMER NAME/PHONE)
    // ═══════════════════════════════════════════════════

    /**
     * Returns Vector of rows:
     * [id, bill_no, bill_date, bill_time, customer_id, customer_name, customer_phone,
     *  gold_rate, gross_amount, margin, net_amount, release_amount, amount_paid, entered_by, entered_dt]
     */
    public Vector getBillReport(String fromDate, String toDate, String searchText) throws Exception {
        return getBillReport(fromDate, toDate, searchText, null, false);
    }

    /**
     * @param fromDate      optional from bill_date
     * @param toDate        optional to bill_date
     * @param searchText    customer search text
     * @param searchBy      null/'both' or 'name' or 'phone'
     * @param ignoreDate    true => ignore from/to filters (customer-only mode)
     */
    public Vector getBillReport(String fromDate, String toDate, String searchText, String searchBy, boolean ignoreDate) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT id, bill_no, bill_date, bill_time, customer_id, customer_name, customer_phone, ");
            sql.append("gold_rate, gross_amount, margin, net_amount, release_amount, amount_paid, entered_by, entered_dt ");
            sql.append("FROM gold_bill WHERE is_cancelled = 0 ");
            if (!ignoreDate && fromDate != null && !fromDate.trim().isEmpty()) sql.append("AND bill_date >= ? ");
            if (!ignoreDate && toDate != null && !toDate.trim().isEmpty())     sql.append("AND bill_date <= ? ");
            if (searchText != null && !searchText.trim().isEmpty()) {
                String by = (searchBy == null ? "both" : searchBy.trim().toLowerCase());
                if ("name".equals(by)) {
                    sql.append("AND LOWER(customer_name) LIKE ? ");
                } else if ("phone".equals(by)) {
                    sql.append("AND customer_phone LIKE ? ");
                } else {
                    sql.append("AND (LOWER(customer_name) LIKE ? OR customer_phone LIKE ?) ");
                }
            }
            sql.append("ORDER BY bill_date DESC, bill_time DESC, id DESC");

            ps = con.prepareStatement(sql.toString());
            int idx = 1;
            if (!ignoreDate && fromDate != null && !fromDate.trim().isEmpty()) ps.setString(idx++, fromDate.trim());
            if (!ignoreDate && toDate != null && !toDate.trim().isEmpty())     ps.setString(idx++, toDate.trim());
            if (searchText != null && !searchText.trim().isEmpty()) {
                String by = (searchBy == null ? "both" : searchBy.trim().toLowerCase());
                String like = "%" + searchText.trim().toLowerCase() + "%";
                String phoneLike = "%" + searchText.trim() + "%";
                if ("name".equals(by)) {
                    ps.setString(idx++, like);
                } else if ("phone".equals(by)) {
                    ps.setString(idx++, phoneLike);
                } else {
                    ps.setString(idx++, like);
                    ps.setString(idx++, phoneLike);
                }
            }

            rs = ps.executeQuery();
            Vector rows = new Vector();
            while (rs.next()) {
                Vector r = new Vector();
                r.addElement(rs.getString("id"));
                r.addElement(rs.getString("bill_no"));
                r.addElement(rs.getString("bill_date"));
                r.addElement(rs.getString("bill_time"));
                r.addElement(rs.getString("customer_id"));
                r.addElement(rs.getString("customer_name"));
                r.addElement(rs.getString("customer_phone"));
                r.addElement(rs.getString("gold_rate"));
                r.addElement(rs.getString("gross_amount"));
                r.addElement(rs.getString("margin"));
                r.addElement(rs.getString("net_amount"));
                r.addElement(rs.getString("release_amount"));
                r.addElement(rs.getString("amount_paid"));
                r.addElement(rs.getString("entered_by"));
                r.addElement(rs.getString("entered_dt"));
                rows.addElement(r);
            }
            return rows;
        } finally {
            close(rs, ps, con);
        }
    }

    // ═══════════════════════════════════════════════════
    // GOLD TRANSACTION (master + details + payment + stock + account + bank ledger)
    // ═══════════════════════════════════════════════════

    /**
     * Save a gold transaction in one DB transaction.
     * If any table insert/update fails, all DB changes are rolled back.
     *
     * @param customerId customer id
     * @param userId logged in user id
     * @param billDate yyyy-MM-dd
     * @param billTime HH:mm or HH:mm:ss
     * @param total grand total
     * @param paid total paid
     * @param balance due/balance amount
     * @param isSale sale flag
     * @param isPurchase purchase flag
     * @param items Vector of rows: [particular, qty_gram, rate, total]
     * @param payments Vector of rows: [payment_mode, payment_bank, amount]
     * @return generated bill id
     */
    public int saveGoldTransaction(
            int customerId,
            int userId,
            String billDate,
            String billTime,
            double total,
            double paid,
            double balance,
            boolean isSale,
            boolean isPurchase,
            Vector items,
            Vector payments) throws Exception {

        Connection con = null;
        PreparedStatement psMaster = null;
        PreparedStatement psDetails = null;
        PreparedStatement psPayment = null;
        PreparedStatement psStock = null;
        PreparedStatement psBankLedger = null;
        PreparedStatement psTxnLedger = null;
        PreparedStatement psUpdateMasterBal = null;
        ResultSet rs = null;

        try {
            con = getConn();
            con.setAutoCommit(false);

            Timestamp txnTs = parseTxnTimestamp(billDate, billTime);

            // 1) Insert master
            psMaster = con.prepareStatement(
                "INSERT INTO gold_trasaction " +
                "(customer_id, user_id, bill_date, bill_time, enter_date_time, total, paid, balance, current_balance, " +
                " is_sale, is_purchase, is_cancelled, cancel_user, cancel_date_time) " +
                "VALUES (?, ?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?, 0, NULL, NULL)",
                Statement.RETURN_GENERATED_KEYS);

            if (customerId > 0) psMaster.setInt(1, customerId);
            else                psMaster.setNull(1, Types.INTEGER);
            psMaster.setInt(2, userId);
            psMaster.setString(3, billDate);
            psMaster.setString(4, billTime);
            psMaster.setDouble(5, total);
            psMaster.setDouble(6, paid);
            psMaster.setDouble(7, balance);
            psMaster.setDouble(8, 0.0); // updated after customer_account update
            psMaster.setInt(9, isSale ? 1 : 0);
            psMaster.setInt(10, isPurchase ? 1 : 0);
            psMaster.executeUpdate();

            rs = psMaster.getGeneratedKeys();
            if (!rs.next()) {
                throw new Exception("Failed to generate gold_trasaction bill id");
            }
            int billId = rs.getInt(1);
            rs.close();
            rs = null;

            // 2) Insert details
            psDetails = con.prepareStatement(
                "INSERT INTO gold_trasaction_details " +
                "(bill_id, particular, qty_gram, rate, total) VALUES (?, ?, ?, ?, ?)");

            // 3) Insert stock movement rows
            psStock = con.prepareStatement(
                "INSERT INTO gold_trasaction_stock " +
                "(bill_id, in_qty, out_qty, customer_id, rate, total, txn_date_time, user_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

            for (int i = 0; i < items.size(); i++) {
                Vector item = (Vector) items.elementAt(i);
                String particular = String.valueOf(item.elementAt(0));
                double qty = parseD(item.elementAt(1));
                double rate = parseD(item.elementAt(2));
                double lineTotal = parseD(item.elementAt(3));

                psDetails.setInt(1, billId);
                psDetails.setString(2, particular);
                psDetails.setDouble(3, qty);
                psDetails.setDouble(4, rate);
                psDetails.setDouble(5, lineTotal);
                psDetails.addBatch();

                double inQty = isPurchase ? qty : 0.0;
                double outQty = isSale ? qty : 0.0;
                psStock.setInt(1, billId);
                psStock.setDouble(2, inQty);
                psStock.setDouble(3, outQty);
                if (customerId > 0) psStock.setInt(4, customerId);
                else                psStock.setNull(4, Types.INTEGER);
                psStock.setDouble(5, rate);
                psStock.setDouble(6, lineTotal);
                psStock.setTimestamp(7, txnTs);
                psStock.setInt(8, userId);
                psStock.addBatch();
            }

            psDetails.executeBatch();
            psStock.executeBatch();

            // 4) Insert payments
            psPayment = con.prepareStatement(
                "INSERT INTO gold_trasaction_payment (bill_id, payment_mode, payment_bank, amount) VALUES (?, ?, ?, ?)");

            // 5) Insert bank ledger (only for bank-based payments)
            psBankLedger = con.prepareStatement(
                "INSERT INTO bank_ledger " +
                "(bill_id, bank_id, in_amount, out_amount, notes, user_id, date_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)");

            for (int i = 0; i < payments.size(); i++) {
                Vector pay = (Vector) payments.elementAt(i);
                String paymentMode = String.valueOf(pay.elementAt(0));
                int paymentBank = Integer.parseInt(String.valueOf(pay.elementAt(1)));
                double amount = parseD(pay.elementAt(2));

                if (amount <= 0) {
                    continue;
                }

                psPayment.setInt(1, billId);
                psPayment.setString(2, paymentMode);
                if (paymentBank > 0) psPayment.setInt(3, paymentBank);
                else                psPayment.setNull(3, Types.INTEGER);
                psPayment.setDouble(4, amount);
                psPayment.addBatch();

                if (paymentBank > 0) {
                    double inAmount = isSale ? amount : 0.0;
                    double outAmount = isPurchase ? amount : 0.0;
                    psBankLedger.setInt(1, billId);
                    psBankLedger.setInt(2, paymentBank);
                    psBankLedger.setDouble(3, inAmount);
                    psBankLedger.setDouble(4, outAmount);
                    psBankLedger.setString(5, "Gold transaction #" + billId + " (" + (isSale ? "SALE" : "PURCHASE") + ")");
                    psBankLedger.setInt(6, userId);
                    psBankLedger.setTimestamp(7, txnTs);
                    psBankLedger.addBatch();
                }
            }

            psPayment.executeBatch();
            psBankLedger.executeBatch();

            // 6) Insert gold transaction ledger summary row
            psTxnLedger = con.prepareStatement(
                "INSERT INTO gold_transaction_ledger " +
                "(bill_id, customer_id, in_amount, out_amount, notes, date_time, user_id, is_sale, is_purchase, is_cancelled) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0)");

            psTxnLedger.setInt(1, billId);
            if (customerId > 0) psTxnLedger.setInt(2, customerId);
            else                psTxnLedger.setNull(2, Types.INTEGER);
            psTxnLedger.setDouble(3, isPurchase ? total : 0.0);
            psTxnLedger.setDouble(4, isSale ? total : 0.0);
            psTxnLedger.setString(5, "Gold transaction #" + billId + " (" + (isSale ? "SALE" : "PURCHASE") + ")");
            psTxnLedger.setTimestamp(6, txnTs);
            psTxnLedger.setInt(7, userId);
            psTxnLedger.setInt(8, isSale ? 1 : 0);
            psTxnLedger.setInt(9, isPurchase ? 1 : 0);
            psTxnLedger.executeUpdate();

            // 7) Update customer_account and compute current_balance
            double currentBalance = updateCustomerAccountForTransaction(con, customerId, balance, isSale, isPurchase);

            psUpdateMasterBal = con.prepareStatement(
                "UPDATE gold_trasaction SET current_balance = ? WHERE id = ?");
            psUpdateMasterBal.setDouble(1, currentBalance);
            psUpdateMasterBal.setInt(2, billId);
            psUpdateMasterBal.executeUpdate();

            con.commit();
            return billId;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { ; }
            }
            throw e;
        } finally {
            close(rs, psMaster, null);
            close(null, psDetails, null);
            close(null, psPayment, null);
            close(null, psStock, null);
            close(null, psBankLedger, null);
            close(null, psTxnLedger, null);
            close(null, psUpdateMasterBal, con);
        }
    }

    private Timestamp parseTxnTimestamp(String billDate, String billTime) {
        try {
            String date = billDate == null ? "" : billDate.trim();
            String time = billTime == null ? "" : billTime.trim();
            if (date.length() == 0) {
                return new Timestamp(System.currentTimeMillis());
            }
            if (time.length() == 5) {
                time = time + ":00";
            }
            if (time.length() == 0) {
                time = "00:00:00";
            }
            return Timestamp.valueOf(date + " " + time);
        } catch (Exception e) {
            return new Timestamp(System.currentTimeMillis());
        }
    }

    private double updateCustomerAccountForTransaction(
            Connection con,
            int customerId,
            double balance,
            boolean isSale,
            boolean isPurchase) throws Exception {

        if (customerId <= 0) {
            return 0.0;
        }

        // Keep existing balance if there is no due/advance update needed.
        boolean needsUpdate = balance > 0 && (isSale || isPurchase);

        boolean hasDueColumn = true;
        double advance = 0.0;
        double due = 0.0;
        boolean rowExists = false;

        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            try {
                ps = con.prepareStatement("SELECT advance, due FROM customer_account WHERE customer_id=? FOR UPDATE");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    rowExists = true;
                    advance = rs.getDouble(1);
                    due = rs.getDouble(2);
                }
            } catch (SQLException dueEx) {
                hasDueColumn = false;
                close(rs, ps, null);
                rs = null;
                ps = con.prepareStatement("SELECT advance, balance FROM customer_account WHERE customer_id=? FOR UPDATE");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    rowExists = true;
                    advance = rs.getDouble(1);
                    due = rs.getDouble(2);
                }
            }
        } finally {
            close(rs, ps, null);
        }

        if (!rowExists) {
            PreparedStatement psIns = null;
            try {
                if (hasDueColumn) {
                    psIns = con.prepareStatement("INSERT INTO customer_account (customer_id, advance, due) VALUES (?, 0, 0)");
                } else {
                    psIns = con.prepareStatement("INSERT INTO customer_account (customer_id, advance, balance) VALUES (?, 0, 0)");
                }
                psIns.setInt(1, customerId);
                psIns.executeUpdate();
            } finally {
                close(null, psIns, null);
            }
            advance = 0.0;
            due = 0.0;
        }

        if (needsUpdate) {
            if (isSale) {
                due = due + balance;
            } else if (isPurchase) {
                advance = advance + balance;
            }

            PreparedStatement psUpd = null;
            try {
                if (hasDueColumn) {
                    psUpd = con.prepareStatement("UPDATE customer_account SET advance=?, due=? WHERE customer_id=?");
                } else {
                    psUpd = con.prepareStatement("UPDATE customer_account SET advance=?, balance=? WHERE customer_id=?");
                }
                psUpd.setDouble(1, advance);
                psUpd.setDouble(2, due);
                psUpd.setInt(3, customerId);
                psUpd.executeUpdate();
            } finally {
                close(null, psUpd, null);
            }
        }

        return due - advance;
    }

    // ═══════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════

    private double parseD(Object o) {
        try { return Double.parseDouble(o.toString()); }
        catch (Exception e) { return 0; }
    }

    private void close(ResultSet rs, Statement ps, Connection con) {
        if (rs  != null) try { rs.close();  } catch (Exception e) {}
        if (ps  != null) try { ps.close();  } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
