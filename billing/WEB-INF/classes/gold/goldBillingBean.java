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
        PreparedStatement psGoldStock = null;
        PreparedStatement psStockCheck = null;
        ResultSet rs = null;

        try {
            con = getConn();
            con.setAutoCommit(false);

            Timestamp txnTs = parseTxnTimestamp(billDate, billTime);

            double totalQty = 0.0;
            for (int i = 0; i < items.size(); i++) {
                Vector item = (Vector) items.elementAt(i);
                totalQty += parseD(item.elementAt(1));
            }

            if (isSale && totalQty > 0) {
                psStockCheck = con.prepareStatement(
                    "SELECT COALESCE(stock, 0) AS stock FROM gold_stock WHERE prods_id = ? FOR UPDATE");
                psStockCheck.setInt(1, 1);
                rs = psStockCheck.executeQuery();
                double currentStock = 0.0;
                if (rs.next()) {
                    currentStock = rs.getDouble("stock");
                }
                rs.close();
                rs = null;
                psStockCheck.close();
                psStockCheck = null;

                if (totalQty > currentStock) {
                    throw new Exception("Insufficient stock. Current stock is " + String.format("%.3f", currentStock));
                }
            }

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
                "(bill_id, in_qty, out_qty, customer_id, rate, total, txn_date_time, user_id, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");

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
                psStock.setString(9, "Gold transaction #" + billId + " (" + (isSale ? "SALE" : "PURCHASE") + ")");
                psStock.addBatch();
            }

            int[] detailsBatch = psDetails.executeBatch();
            if (detailsBatch == null || detailsBatch.length == 0) {
                throw new Exception("Failed to insert transaction details");
            }

            int[] stockBatch = psStock.executeBatch();
            if (stockBatch == null || stockBatch.length == 0) {
                throw new Exception("Failed to insert transaction stock rows");
            }

            // 4) Insert payments
            psPayment = con.prepareStatement(
                "INSERT INTO gold_trasaction_payment (bill_id, payment_mode, payment_bank, amount) VALUES (?, ?, ?, ?)");

            // 5) Insert bank ledger (only for bank-based payments)
            psBankLedger = con.prepareStatement(
                "INSERT INTO bank_ledger " +
                "(bill_id, bank_id, in_amount, out_amount, notes, user_id, date_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)");

            int paymentRowCount = 0;
            int bankLedgerRowCount = 0;
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
                paymentRowCount++;

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
                    bankLedgerRowCount++;
                }
            }

            if (paymentRowCount == 0) {
                throw new Exception("Failed to insert transaction payments");
            }
            int[] paymentBatch = psPayment.executeBatch();
            if (paymentBatch == null || paymentBatch.length != paymentRowCount) {
                throw new Exception("Failed to insert all payment rows");
            }

            if (bankLedgerRowCount > 0) {
                int[] bankBatch = psBankLedger.executeBatch();
                if (bankBatch == null || bankBatch.length != bankLedgerRowCount) {
                    throw new Exception("Failed to insert all bank ledger rows");
                }
            }

            // 6) Update gold_stock in the same transaction (prods_id = 1)
            double deltaQty = isPurchase ? totalQty : (isSale ? -totalQty : 0.0);
            if (deltaQty != 0.0) {
                psGoldStock = con.prepareStatement(
                    "UPDATE gold_stock SET stock = COALESCE(stock, 0) + ? WHERE prods_id = ?");
                psGoldStock.setDouble(1, deltaQty);
                psGoldStock.setInt(2, 1);
                int updated = psGoldStock.executeUpdate();
                psGoldStock.close();
                psGoldStock = null;

                if (updated == 0) {
                    psGoldStock = con.prepareStatement(
                        "INSERT INTO gold_stock (prods_id, stock) VALUES (?, ?)");
                    psGoldStock.setInt(1, 1);
                    psGoldStock.setDouble(2, deltaQty);
                    if (psGoldStock.executeUpdate() <= 0) {
                        throw new Exception("Failed to insert gold stock row");
                    }
                    psGoldStock.close();
                    psGoldStock = null;
                }
            }

            // 7) Insert gold transaction ledger summary row
            psTxnLedger = con.prepareStatement(
                "INSERT INTO gold_transaction_ledger " +
                "(bill_id, customer_id, bill_amount, in_amount, out_amount, notes, date_time, user_id, is_sale, is_purchase, is_cancelled) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)");

            psTxnLedger.setInt(1, billId);
            if (customerId > 0) psTxnLedger.setInt(2, customerId);
            else                psTxnLedger.setNull(2, Types.INTEGER);
            psTxnLedger.setDouble(3, total);
            psTxnLedger.setDouble(4, isSale ? paid : 0.0);
            psTxnLedger.setDouble(5, isPurchase ? paid : 0.0);
            psTxnLedger.setString(6, "Gold transaction #" + billId + " (" + (isSale ? "SALE" : "PURCHASE") + ")");
            psTxnLedger.setTimestamp(7, txnTs);
            psTxnLedger.setInt(8, userId);
            psTxnLedger.setInt(9, isSale ? 1 : 0);
            psTxnLedger.setInt(10, isPurchase ? 1 : 0);
            if (psTxnLedger.executeUpdate() <= 0) {
                throw new Exception("Failed to insert gold transaction ledger");
            }

            // 8) Update customer_account and compute current_balance
            double currentBalance = updateCustomerAccountForTransaction(con, customerId, balance, isSale, isPurchase);

            psUpdateMasterBal = con.prepareStatement(
                "UPDATE gold_trasaction SET current_balance = ? WHERE id = ?");
            psUpdateMasterBal.setDouble(1, currentBalance);
            psUpdateMasterBal.setInt(2, billId);
            if (psUpdateMasterBal.executeUpdate() <= 0) {
                throw new Exception("Failed to update transaction current balance");
            }

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
            close(null, psGoldStock, null);
            close(null, psStockCheck, null);
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
                double remaining = balance;
                if (advance > 0) {
                    if (remaining <= advance) {
                        advance = advance - remaining;
                        remaining = 0;
                    } else {
                        remaining = remaining - advance;
                        advance = 0;
                    }
                }
                if (remaining > 0) {
                    due = due + remaining;
                }
            } else if (isPurchase) {
                double remaining = balance;
                if (due > 0) {
                    if (remaining <= due) {
                        due = due - remaining;
                        remaining = 0;
                    } else {
                        remaining = remaining - due;
                        due = 0;
                    }
                }
                if (remaining > 0) {
                    advance = advance + remaining;
                }
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

    /**
     * Get current gold stock for a product id from gold_stock.
     */
    public double getGoldStockByProductId(int prodsId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConn();
            ps = con.prepareStatement(
                "SELECT COALESCE(stock, 0) AS stock FROM gold_stock WHERE prods_id = ? LIMIT 1");
            ps.setInt(1, prodsId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("stock");
            }
            return 0.0;
        } finally {
            close(rs, ps, con);
        }
    }

    /**
     * Summary for report cards without date filter.
     * Returns Vector: [currentStock, totalAdvanceCredit, totalDueFromCustomers]
     */
    public Vector getGoldTransactionSummaryCards() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector out = new Vector();

        double currentStock = 0.0;
        double totalAdvance = 0.0;
        double totalDue = 0.0;

        try {
            con = getConn();

            ps = con.prepareStatement(
                "SELECT COALESCE(stock, 0) AS stock FROM gold_stock WHERE prods_id = ? LIMIT 1");
            ps.setInt(1, 1);
            rs = ps.executeQuery();
            if (rs.next()) {
                currentStock = rs.getDouble("stock");
            }
            close(rs, ps, null);
            rs = null;
            ps = null;

            try {
                ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(advance), 0) AS total_advance, COALESCE(SUM(due), 0) AS total_due FROM customer_account");
                rs = ps.executeQuery();
                if (rs.next()) {
                    totalAdvance = rs.getDouble("total_advance");
                    totalDue = rs.getDouble("total_due");
                }
            } catch (SQLException dueColEx) {
                close(rs, ps, null);
                rs = null;
                ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(advance), 0) AS total_advance, COALESCE(SUM(balance), 0) AS total_due FROM customer_account");
                rs = ps.executeQuery();
                if (rs.next()) {
                    totalAdvance = rs.getDouble("total_advance");
                    totalDue = rs.getDouble("total_due");
                }
            }

            out.addElement(String.valueOf(currentStock));
            out.addElement(String.valueOf(totalAdvance));
            out.addElement(String.valueOf(totalDue));
            return out;
        } finally {
            close(rs, ps, con);
        }
    }

    /**
     * Settle customer credit by collecting from customer or paying to customer.
     * actionMode values: "collect" or "pay".
     * Returns Vector: [billId, accountCredit, due, advance]
     */
    public Vector settleCustomerCredit(
            int customerId,
            int userId,
            double amount,
            String actionMode,
            String billDate,
            String billTime,
            Vector payments) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        PreparedStatement psPayment = null;
        PreparedStatement psLedger = null;

        try {
            if (customerId <= 0) {
                throw new Exception("Invalid customer");
            }
            if (amount <= 0) {
                throw new Exception("Amount should be greater than zero");
            }

            String mode = actionMode == null ? "" : actionMode.trim().toLowerCase();
            if (!"collect".equals(mode) && !"pay".equals(mode)) {
                throw new Exception("Invalid action mode");
            }

            con = getConn();
            con.setAutoCommit(false);

            boolean hasDueColumn = true;
            double due = 0.0;
            double advance = 0.0;
            boolean rowExists = false;

            try {
                ps = con.prepareStatement("SELECT due, advance FROM customer_account WHERE customer_id=? FOR UPDATE");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    due = rs.getDouble(1);
                    advance = rs.getDouble(2);
                    rowExists = true;
                }
            } catch (SQLException dueEx) {
                hasDueColumn = false;
                close(rs, ps, null);
                rs = null;
                ps = con.prepareStatement("SELECT balance, advance FROM customer_account WHERE customer_id=? FOR UPDATE");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    due = rs.getDouble(1);
                    advance = rs.getDouble(2);
                    rowExists = true;
                }
            }
            close(rs, ps, null);
            rs = null;
            ps = null;

            if (!rowExists) {
                if (hasDueColumn) {
                    ps = con.prepareStatement("INSERT INTO customer_account (customer_id, due, advance) VALUES (?, 0, 0)");
                } else {
                    ps = con.prepareStatement("INSERT INTO customer_account (customer_id, balance, advance) VALUES (?, 0, 0)");
                }
                ps.setInt(1, customerId);
                ps.executeUpdate();
                close(null, ps, null);
                ps = null;
                due = 0.0;
                advance = 0.0;
            }

            double accountCredit = due - advance;
            if ("collect".equals(mode) && accountCredit <= 0) {
                throw new Exception("Customer has no payable due to collect");
            }
            if ("pay".equals(mode) && accountCredit >= 0) {
                throw new Exception("No payable amount from your side");
            }

            double maxSettle = Math.abs(accountCredit);
            if (amount - maxSettle > 0.01) {
                throw new Exception("Settlement amount should not exceed current balance");
            }

            if (payments == null || payments.size() == 0) {
                throw new Exception("Select at least one payment option");
            }

            double paidSum = 0.0;
            for (int i = 0; i < payments.size(); i++) {
                Vector pay = (Vector) payments.elementAt(i);
                String payMode = String.valueOf(pay.elementAt(0)).trim().toLowerCase();
                int payBank = 0;
                try { payBank = Integer.parseInt(String.valueOf(pay.elementAt(1))); } catch (Exception ex) { }
                double payAmount = parseD(pay.elementAt(2));

                if (payAmount <= 0) {
                    continue;
                }

                if ("gpay".equals(payMode) && payBank <= 0) {
                    throw new Exception("Bank is required for GPay payment");
                }

                paidSum += payAmount;
            }

            if (paidSum <= 0) {
                throw new Exception("Enter payment amount");
            }

            if (Math.abs(paidSum - amount) > 0.01) {
                throw new Exception("Payment total should match settlement amount");
            }

            if ("collect".equals(mode)) {
                if (amount <= due) {
                    due -= amount;
                } else {
                    double extra = amount - due;
                    due = 0.0;
                    advance += extra;
                }
            } else {
                if (amount <= advance) {
                    advance -= amount;
                } else {
                    double extra = amount - advance;
                    advance = 0.0;
                    due += extra;
                }
            }

            accountCredit = due - advance;
            if (hasDueColumn) {
                ps = con.prepareStatement("UPDATE customer_account SET due=?, advance=? WHERE customer_id=?");
            } else {
                ps = con.prepareStatement("UPDATE customer_account SET balance=?, advance=? WHERE customer_id=?");
            }
            ps.setDouble(1, due);
            ps.setDouble(2, advance);
            ps.setInt(3, customerId);
            if (ps.executeUpdate() <= 0) {
                throw new Exception("Failed to update customer account");
            }
            close(null, ps, null);
            ps = null;

            if (billDate == null || billDate.trim().length() == 0) {
                billDate = new java.sql.Date(System.currentTimeMillis()).toString();
            }
            if (billTime == null || billTime.trim().length() == 0) {
                billTime = new java.sql.Time(System.currentTimeMillis()).toString();
            }

            int payOrCollect = "pay".equals(mode) ? 1 : 2;

            int billId = 0;
            psPayment = con.prepareStatement(
                "INSERT INTO gold_trasaction_payment (bill_id, customer_id, user_id, payment_mode, payment_bank, amount, bill_date, bill_time, date_time, is_balance_collection, is_pay_or_collect) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), 1, ?)");

            for (int i = 0; i < payments.size(); i++) {
                Vector pay = (Vector) payments.elementAt(i);
                String payMode = String.valueOf(pay.elementAt(0)).trim().toLowerCase();
                int payBank = 0;
                try { payBank = Integer.parseInt(String.valueOf(pay.elementAt(1))); } catch (Exception ex) { }
                double payAmount = parseD(pay.elementAt(2));

                if (payAmount <= 0) {
                    continue;
                }

                psPayment.setNull(1, Types.INTEGER);
                psPayment.setInt(2, customerId);
                psPayment.setInt(3, userId);
                psPayment.setString(4, payMode);
                if (payBank > 0) psPayment.setInt(5, payBank);
                else             psPayment.setNull(5, Types.INTEGER);
                psPayment.setDouble(6, payAmount);
                psPayment.setString(7, billDate);
                psPayment.setString(8, billTime);
                psPayment.setInt(9, payOrCollect);
                psPayment.addBatch();
            }

            int[] paymentBatch = psPayment.executeBatch();
            if (paymentBatch == null || paymentBatch.length == 0) {
                throw new Exception("Failed to insert payment settlement rows");
            }
            close(null, psPayment, null);
            psPayment = null;

            psLedger = con.prepareStatement(
                "INSERT INTO gold_transaction_ledger " +
                "(bill_id, customer_id, bill_amount, in_amount, out_amount, notes, date_time, user_id, is_sale, is_purchase, is_cancelled, is_balance_collection, is_pay_or_collect) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, 0, 0, 0, 1, ?)");
            psLedger.setNull(1, Types.INTEGER);
            psLedger.setInt(2, customerId);
            psLedger.setDouble(3, amount);
            psLedger.setDouble(4, "collect".equals(mode) ? amount : 0.0);
            psLedger.setDouble(5, "pay".equals(mode) ? amount : 0.0);
            psLedger.setString(6, "Credit settlement (" + mode.toUpperCase() + ")");
            psLedger.setInt(7, userId);
            psLedger.setInt(8, payOrCollect);
            if (psLedger.executeUpdate() <= 0) {
                throw new Exception("Failed to insert transaction ledger settlement row");
            }

            con.commit();

            Vector out = new Vector();
            out.addElement(String.valueOf(billId));
            out.addElement(String.valueOf(accountCredit));
            out.addElement(String.valueOf(due));
            out.addElement(String.valueOf(advance));
            return out;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { }
            }
            throw e;
        } finally {
            close(rs, ps, null);
            close(null, psPayment, null);
            close(null, psLedger, con);
        }
    }

    /**
     * Save opening balance as one payment row + one ledger row.
     * Returns inserted ledger id.
     */
    public int saveOpeningBalance(
            int userId,
            double amount,
            String paymentMode,
            int bankId,
            String billDate,
            String billTime,
            String notes) throws Exception {

        Connection con = null;
        PreparedStatement psPayment = null;
        PreparedStatement psLedger = null;
        PreparedStatement psBankLedger = null;
        ResultSet rs = null;

        try {
            if (userId <= 0) {
                throw new Exception("Invalid user");
            }
            if (amount <= 0) {
                throw new Exception("Amount should be greater than zero");
            }

            String pm = paymentMode == null ? "" : paymentMode.trim().toLowerCase();
            if (!"cash".equals(pm) && !"gpay".equals(pm) && !"bank".equals(pm)) {
                throw new Exception("Invalid payment mode");
            }
            if (("gpay".equals(pm) || "bank".equals(pm)) && bankId <= 0) {
                throw new Exception("Bank is required for GPay/Bank payment");
            }

            if (billDate == null || billDate.trim().length() == 0) {
                billDate = new java.sql.Date(System.currentTimeMillis()).toString();
            }
            if (billTime == null || billTime.trim().length() == 0) {
                billTime = new java.sql.Time(System.currentTimeMillis()).toString();
            }
            if (notes == null || notes.trim().length() == 0) {
                notes = "Opening Balance";
            }

            con = getConn();
            con.setAutoCommit(false);

            psPayment = con.prepareStatement(
                "INSERT INTO gold_trasaction_payment " +
                "(bill_id, customer_id, user_id, payment_mode, payment_bank, amount, bill_date, bill_time, date_time, is_balance_collection, is_pay_or_collect, is_opening_balance) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), 0, 0, 1)");
            psPayment.setNull(1, Types.INTEGER);
            psPayment.setNull(2, Types.INTEGER);
            psPayment.setInt(3, userId);
            psPayment.setString(4, pm);
            if (bankId > 0) psPayment.setInt(5, bankId);
            else            psPayment.setNull(5, Types.INTEGER);
            psPayment.setDouble(6, amount);
            psPayment.setString(7, billDate);
            psPayment.setString(8, billTime);
            if (psPayment.executeUpdate() <= 0) {
                throw new Exception("Failed to insert opening balance payment");
            }
            close(null, psPayment, null);
            psPayment = null;

            if (bankId > 0) {
                psBankLedger = con.prepareStatement(
                    "INSERT INTO bank_ledger " +
                    "(bill_id, bank_id, in_amount, out_amount, notes, user_id, date_time, is_opening_balance) " +
                    "VALUES (?, ?, ?, ?, ?, ?, NOW(), 1)");
                psBankLedger.setInt(1, 0);
                psBankLedger.setInt(2, bankId);
                psBankLedger.setDouble(3, amount);
                psBankLedger.setDouble(4, 0.0);
                psBankLedger.setString(5, notes);
                psBankLedger.setInt(6, userId);
                if (psBankLedger.executeUpdate() <= 0) {
                    throw new Exception("Failed to insert opening balance bank ledger");
                }
                close(null, psBankLedger, null);
                psBankLedger = null;
            }

            psLedger = con.prepareStatement(
                "INSERT INTO gold_transaction_ledger " +
                "(bill_id, customer_id, bill_amount, in_amount, out_amount, notes, date_time, user_id, is_sale, is_purchase, is_cancelled, is_balance_collection, is_pay_or_collect, is_opening_balance) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, 0, 0, 0, 0, 0, 1)",
                Statement.RETURN_GENERATED_KEYS);
            psLedger.setNull(1, Types.INTEGER);
            psLedger.setNull(2, Types.INTEGER);
            psLedger.setDouble(3, amount);
            psLedger.setDouble(4, amount);
            psLedger.setDouble(5, 0.0);
            psLedger.setString(6, notes);
            psLedger.setInt(7, userId);
            if (psLedger.executeUpdate() <= 0) {
                throw new Exception("Failed to insert opening balance ledger");
            }

            int ledgerId = 0;
            rs = psLedger.getGeneratedKeys();
            if (rs != null && rs.next()) {
                ledgerId = rs.getInt(1);
            }

            con.commit();
            return ledgerId;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { }
            }
            throw e;
        } finally {
            close(rs, null, null);
            close(null, psPayment, null);
            close(null, psBankLedger, null);
            close(null, psLedger, con);
        }
    }

    /**
     * Returns customer account status.
     * Vector: [due, advance, netCredit]
     * netCredit = due - advance
     */
    public Vector getCustomerCreditStatus(int customerId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector out = new Vector();

        double due = 0.0;
        double advance = 0.0;

        try {
            con = getConn();
            try {
                ps = con.prepareStatement("SELECT COALESCE(due,0) AS due_amt, COALESCE(advance,0) AS adv_amt FROM customer_account WHERE customer_id=? LIMIT 1");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    due = rs.getDouble("due_amt");
                    advance = rs.getDouble("adv_amt");
                }
            } catch (SQLException dueColEx) {
                close(rs, ps, null);
                rs = null;
                ps = con.prepareStatement("SELECT COALESCE(balance,0) AS due_amt, COALESCE(advance,0) AS adv_amt FROM customer_account WHERE customer_id=? LIMIT 1");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    due = rs.getDouble("due_amt");
                    advance = rs.getDouble("adv_amt");
                }
            }

            out.addElement(String.valueOf(due));
            out.addElement(String.valueOf(advance));
            out.addElement(String.valueOf(due - advance));
            return out;
        } finally {
            close(rs, ps, con);
        }
    }

    // ═══════════════════════════════════════════════════
    // CANCEL OPEN/CLOSING ENTRY
    // ═══════════════════════════════════════════════════

    /**
     * Cancel an open/closing balance list entry.
     * SALE/PURCHASE: reverse gold_stock, insert cancel row in gold_trasaction_stock with notes,
     * mark gold_trasaction.is_cancelled = 1 and insert cancel record.
     * Other types: delete ledger + payment rows and insert cancel record.
     */
    public int cancelOpenClosingEntry(int ledgerId, int userId, String cancelReason) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement psCancel = null;
        PreparedStatement psUpdateBill = null;
        PreparedStatement psDeleteLedger = null;
        PreparedStatement psDeletePayment = null;
        ResultSet rs = null;

        if (ledgerId <= 0) {
            throw new Exception("Invalid ledger entry");
        }
        if (userId <= 0) {
            throw new Exception("Invalid user");
        }

        try {
            con = getConn();
            con.setAutoCommit(false);

            ps = con.prepareStatement(
                "SELECT gtl.id, gtl.bill_id, gtl.customer_id, gtl.bill_amount, gtl.in_amount, gtl.out_amount, " +
                "       gtl.notes, gtl.date_time, gtl.is_sale, gtl.is_purchase, " +
                "       COALESCE(gtl.is_opening_balance, 0) AS is_opening_balance, " +
                "       COALESCE(gtl.is_balance_collection, 0) AS is_balance_collection, " +
                "       COALESCE(gtl.is_pay_or_collect, 0) AS is_pay_or_collect, " +
                "       COALESCE(gt.is_cancelled, 0) AS bill_cancelled " +
                "FROM gold_transaction_ledger gtl " +
                "LEFT JOIN gold_trasaction gt ON gt.id = gtl.bill_id " +
                "WHERE gtl.id = ? AND gtl.is_cancelled = 0 " +
                "FOR UPDATE");
            ps.setInt(1, ledgerId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                throw new Exception("Entry not found or already cancelled");
            }

            int ledgerRowId = rs.getInt("id");
            int billId = rs.getInt("bill_id");
            boolean billIdNull = rs.wasNull();
            int customerIdVal = rs.getInt("customer_id");
            boolean customerNull = rs.wasNull();
            double billAmount = rs.getDouble("bill_amount");
            double inAmount = rs.getDouble("in_amount");
            double outAmount = rs.getDouble("out_amount");
            String notes = rs.getString("notes");
            Timestamp txnDateTime = rs.getTimestamp("date_time");
            int isSale = rs.getInt("is_sale");
            int isPurchase = rs.getInt("is_purchase");
            int isOpeningBalance = rs.getInt("is_opening_balance");
            int isBalanceCollection = rs.getInt("is_balance_collection");
            int payOrCollect = rs.getInt("is_pay_or_collect");
            int billCancelled = rs.getInt("bill_cancelled");

            close(rs, ps, null);
            rs = null;
            ps = null;

            String cancelType = resolveCancelType(isSale, isPurchase, isOpeningBalance, isBalanceCollection, payOrCollect);

            if (isSale == 1 || isPurchase == 1) {
                if (billIdNull || billId <= 0) {
                    throw new Exception("Invalid bill reference for this entry");
                }
                if (billCancelled == 1) {
                    throw new Exception("Transaction already cancelled");
                }

                reverseGoldTransactionStock(con, billId, isSale, isPurchase, userId, customerNull ? 0 : customerIdVal, cancelReason);
                reverseCustomerAccountForCancelledTransaction(con, billId);

                psUpdateBill = con.prepareStatement(
                    "UPDATE gold_trasaction SET is_cancelled = 1, cancel_user = ?, cancel_date_time = NOW() " +
                    "WHERE id = ? AND is_cancelled = 0");
                psUpdateBill.setInt(1, userId);
                psUpdateBill.setInt(2, billId);
                if (psUpdateBill.executeUpdate() <= 0) {
                    throw new Exception("Unable to cancel transaction");
                }
                close(null, psUpdateBill, null);
                psUpdateBill = null;
            } else {
                if (isBalanceCollection == 1 && !customerNull && customerIdVal > 0) {
                    double amount = inAmount > 0 ? inAmount : outAmount;
                    reverseCreditSettlementAccount(con, customerIdVal, amount, payOrCollect);
                }

                java.sql.Date billDate = txnDateTime == null ? null : new java.sql.Date(txnDateTime.getTime());
                java.sql.Time billTime = txnDateTime == null ? null : new java.sql.Time(txnDateTime.getTime());

                if (isOpeningBalance == 1) {
                    psDeletePayment = con.prepareStatement(
                        "DELETE FROM gold_trasaction_payment " +
                        "WHERE is_opening_balance = 1 AND bill_date = ? AND bill_time = ?");
                    psDeletePayment.setDate(1, billDate);
                    psDeletePayment.setTime(2, billTime);
                    psDeletePayment.executeUpdate();
                } else if (isBalanceCollection == 1 && !customerNull && customerIdVal > 0) {
                    psDeletePayment = con.prepareStatement(
                        "DELETE FROM gold_trasaction_payment " +
                        "WHERE is_balance_collection = 1 AND customer_id = ? AND is_pay_or_collect = ? " +
                        "AND bill_date = ? AND bill_time = ?");
                    psDeletePayment.setInt(1, customerIdVal);
                    psDeletePayment.setInt(2, payOrCollect);
                    psDeletePayment.setDate(3, billDate);
                    psDeletePayment.setTime(4, billTime);
                    psDeletePayment.executeUpdate();
                }

                psDeleteLedger = con.prepareStatement("DELETE FROM gold_transaction_ledger WHERE id = ?");
                psDeleteLedger.setInt(1, ledgerRowId);
                if (psDeleteLedger.executeUpdate() <= 0) {
                    throw new Exception("Unable to delete ledger entry");
                }
            }

            int cancelId = insertGoldTransactionCancelRecord(
                con,
                ledgerRowId,
                billIdNull ? 0 : billId,
                customerNull ? 0 : customerIdVal,
                cancelType,
                billAmount,
                inAmount,
                outAmount,
                notes,
                txnDateTime,
                isSale,
                isPurchase,
                isOpeningBalance,
                isBalanceCollection,
                payOrCollect,
                userId,
                cancelReason
            );

            con.commit();
            return cancelId;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { }
            }
            throw e;
        } finally {
            close(rs, ps, null);
            close(null, psCancel, null);
            close(null, psUpdateBill, null);
            close(null, psDeleteLedger, null);
            close(null, psDeletePayment, null);
            close(null, null, con);
        }
    }

    private void reverseCustomerAccountForCancelledTransaction(Connection con, int billId) throws Exception {
        if (billId <= 0) {
            return;
        }

        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = con.prepareStatement(
                "SELECT customer_id, balance, is_sale, is_purchase FROM gold_trasaction WHERE id = ? FOR UPDATE");
            ps.setInt(1, billId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                throw new Exception("Transaction not found for account reversal");
            }

            int customerId = rs.getInt("customer_id");
            if (rs.wasNull() || customerId <= 0) {
                return;
            }

            double balance = rs.getDouble("balance");
            int isSale = rs.getInt("is_sale");
            int isPurchase = rs.getInt("is_purchase");

            close(rs, ps, null);
            rs = null;
            ps = null;

            if (balance <= 0 || (isSale != 1 && isPurchase != 1)) {
                return;
            }

            boolean hasDueColumn = true;
            double advance = 0.0;
            double due = 0.0;
            boolean rowExists = false;

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
            close(rs, ps, null);
            rs = null;
            ps = null;

            if (!rowExists) {
                return;
            }

            double remaining = balance;
            if (isSale == 1) {
                if (due > 0) {
                    double fromDue = Math.min(due, remaining);
                    due -= fromDue;
                    remaining -= fromDue;
                }
                if (remaining > 0) {
                    advance += remaining;
                }
            } else if (isPurchase == 1) {
                if (advance > 0) {
                    double fromAdvance = Math.min(advance, remaining);
                    advance -= fromAdvance;
                    remaining -= fromAdvance;
                }
                if (remaining > 0) {
                    due += remaining;
                }
            }

            if (hasDueColumn) {
                ps = con.prepareStatement("UPDATE customer_account SET advance=?, due=? WHERE customer_id=?");
            } else {
                ps = con.prepareStatement("UPDATE customer_account SET advance=?, balance=? WHERE customer_id=?");
            }
            ps.setDouble(1, advance);
            ps.setDouble(2, due);
            ps.setInt(3, customerId);
            if (ps.executeUpdate() <= 0) {
                throw new Exception("Failed to reverse customer account for cancelled transaction");
            }
        } finally {
            close(rs, ps, null);
        }
    }

    private void reverseGoldTransactionStock(
            Connection con,
            int billId,
            int isSale,
            int isPurchase,
            int userId,
            int customerId,
            String cancelReason) throws Exception {
        if (billId <= 0 || (isSale != 1 && isPurchase != 1)) {
            return;
        }

        PreparedStatement psStockRows = null;
        PreparedStatement psInsertStock = null;
        PreparedStatement psGoldStock = null;
        ResultSet rs = null;

        try {
            psStockRows = con.prepareStatement(
                "SELECT COALESCE(SUM(in_qty), 0) AS in_qty, COALESCE(SUM(out_qty), 0) AS out_qty, " +
                "       COALESCE(SUM(total), 0) AS total_amount " +
                "FROM gold_trasaction_stock WHERE bill_id = ?");
            psStockRows.setInt(1, billId);
            rs = psStockRows.executeQuery();

            double inQty = 0.0;
            double outQty = 0.0;
            double totalAmount = 0.0;
            if (rs.next()) {
                inQty = rs.getDouble("in_qty");
                outQty = rs.getDouble("out_qty");
                totalAmount = rs.getDouble("total_amount");
            }
            close(rs, psStockRows, null);
            rs = null;
            psStockRows = null;

            double reverseInQty = 0.0;
            double reverseOutQty = 0.0;
            double deltaQty = 0.0;
            if (isPurchase == 1) {
                reverseOutQty = inQty;
                deltaQty = -inQty;
            } else if (isSale == 1) {
                reverseInQty = outQty;
                deltaQty = outQty;
            }

            if (Math.abs(deltaQty) < 0.0001) {
                return;
            }

            double reverseRate = 0.0;
            double reverseTotal = 0.0;
            if (isPurchase == 1 && reverseOutQty > 0) {
                reverseRate = totalAmount / reverseOutQty;
                reverseTotal = totalAmount;
            } else if (isSale == 1 && reverseInQty > 0) {
                reverseRate = totalAmount / reverseInQty;
                reverseTotal = totalAmount;
            }

            String noteText = "Cancelled " + (isSale == 1 ? "SALE" : "PURCHASE") + " #" + billId;
            if (cancelReason != null && cancelReason.trim().length() > 0) {
                noteText += " - " + cancelReason.trim();
            }

            psGoldStock = con.prepareStatement(
                "SELECT COALESCE(stock, 0) AS stock FROM gold_stock WHERE prods_id = ? FOR UPDATE");
            psGoldStock.setInt(1, 1);
            rs = psGoldStock.executeQuery();

            double currentStock = 0.0;
            if (rs.next()) {
                currentStock = rs.getDouble("stock");
            }
            close(rs, psGoldStock, null);
            rs = null;
            psGoldStock = null;

            if (isPurchase == 1 && (currentStock + deltaQty) < -0.0001) {
                throw new Exception("Insufficient stock to cancel purchase. Current stock is "
                    + String.format("%.3f", currentStock));
            }

            psGoldStock = con.prepareStatement(
                "UPDATE gold_stock SET stock = COALESCE(stock, 0) + ? WHERE prods_id = ?");
            psGoldStock.setDouble(1, deltaQty);
            psGoldStock.setInt(2, 1);
            int updated = psGoldStock.executeUpdate();
            close(null, psGoldStock, null);
            psGoldStock = null;

            if (updated == 0) {
                if (deltaQty < 0) {
                    throw new Exception("Unable to update gold stock for cancelled purchase");
                }
                psGoldStock = con.prepareStatement(
                    "INSERT INTO gold_stock (prods_id, stock) VALUES (?, ?)");
                psGoldStock.setInt(1, 1);
                psGoldStock.setDouble(2, deltaQty);
                if (psGoldStock.executeUpdate() <= 0) {
                    throw new Exception("Failed to insert gold stock row on cancel");
                }
                close(null, psGoldStock, null);
                psGoldStock = null;
            }

            psInsertStock = con.prepareStatement(
                "INSERT INTO gold_trasaction_stock " +
                "(bill_id, in_qty, out_qty, customer_id, rate, total, txn_date_time, user_id, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?)");
            psInsertStock.setInt(1, billId);
            psInsertStock.setDouble(2, reverseInQty);
            psInsertStock.setDouble(3, reverseOutQty);
            if (customerId > 0) {
                psInsertStock.setInt(4, customerId);
            } else {
                psInsertStock.setNull(4, Types.INTEGER);
            }
            psInsertStock.setDouble(5, reverseRate);
            psInsertStock.setDouble(6, reverseTotal);
            psInsertStock.setInt(7, userId);
            psInsertStock.setString(8, noteText);
            if (psInsertStock.executeUpdate() <= 0) {
                throw new Exception("Failed to insert cancelled stock movement row");
            }
        } finally {
            close(rs, psStockRows, null);
            close(null, psInsertStock, null);
            close(null, psGoldStock, null);
        }
    }

    private String resolveCancelType(int isSale, int isPurchase, int isOpeningBalance, int isBalanceCollection, int payOrCollect) {
        if (isOpeningBalance == 1) {
            return "OPENING";
        }
        if (isSale == 1) {
            return "SALE";
        }
        if (isPurchase == 1) {
            return "PURCHASE";
        }
        if (isBalanceCollection == 1 && payOrCollect == 1) {
            return "PAY";
        }
        if (isBalanceCollection == 1 && payOrCollect == 2) {
            return "COLLECT";
        }
        return "OTHER";
    }

    private int insertGoldTransactionCancelRecord(
            Connection con,
            int ledgerId,
            int billId,
            int customerId,
            String cancelType,
            double billAmount,
            double inAmount,
            double outAmount,
            String notes,
            Timestamp txnDateTime,
            int isSale,
            int isPurchase,
            int isOpeningBalance,
            int isBalanceCollection,
            int payOrCollect,
            int userId,
            String cancelReason) throws Exception {

        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = con.prepareStatement(
                "INSERT INTO gold_trasaction_cancel " +
                "(ledger_id, bill_id, customer_id, cancel_type, bill_amount, in_amount, out_amount, notes, " +
                " txn_date_time, is_sale, is_purchase, is_opening_balance, is_balance_collection, is_pay_or_collect, " +
                " cancel_user, cancel_date_time, cancel_reason) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?)",
                Statement.RETURN_GENERATED_KEYS);

            ps.setInt(1, ledgerId);
            if (billId > 0) {
                ps.setInt(2, billId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            if (customerId > 0) {
                ps.setInt(3, customerId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setString(4, cancelType);
            ps.setDouble(5, billAmount);
            ps.setDouble(6, inAmount);
            ps.setDouble(7, outAmount);
            ps.setString(8, notes);
            if (txnDateTime != null) {
                ps.setTimestamp(9, txnDateTime);
            } else {
                ps.setNull(9, Types.TIMESTAMP);
            }
            ps.setInt(10, isSale);
            ps.setInt(11, isPurchase);
            ps.setInt(12, isOpeningBalance);
            ps.setInt(13, isBalanceCollection);
            ps.setInt(14, payOrCollect);
            ps.setInt(15, userId);
            ps.setString(16, cancelReason == null ? "" : cancelReason.trim());

            if (ps.executeUpdate() <= 0) {
                throw new Exception("Failed to insert cancel record");
            }

            rs = ps.getGeneratedKeys();
            if (rs != null && rs.next()) {
                return rs.getInt(1);
            }
            throw new Exception("Failed to read cancel record id");
        } finally {
            close(rs, ps, null);
        }
    }

    private void reverseCreditSettlementAccount(Connection con, int customerId, double amount, int payOrCollect) throws Exception {
        if (customerId <= 0 || amount <= 0) {
            return;
        }

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean hasDueColumn = true;
        double due = 0.0;
        double advance = 0.0;

        try {
            try {
                ps = con.prepareStatement("SELECT COALESCE(due,0) AS due_amt, COALESCE(advance,0) AS adv_amt FROM customer_account WHERE customer_id=? FOR UPDATE");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    due = rs.getDouble("due_amt");
                    advance = rs.getDouble("adv_amt");
                }
            } catch (SQLException dueColEx) {
                hasDueColumn = false;
                close(rs, ps, null);
                rs = null;
                ps = con.prepareStatement("SELECT COALESCE(balance,0) AS due_amt, COALESCE(advance,0) AS adv_amt FROM customer_account WHERE customer_id=? FOR UPDATE");
                ps.setInt(1, customerId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    due = rs.getDouble("due_amt");
                    advance = rs.getDouble("adv_amt");
                }
            }
            close(rs, ps, null);
            rs = null;
            ps = null;

            if (payOrCollect == 2) {
                due += amount;
                if (advance > 0) {
                    double excessToReverse = Math.min(advance, amount);
                    advance -= excessToReverse;
                    due -= excessToReverse;
                }
            } else if (payOrCollect == 1) {
                advance += amount;
                if (due > 0) {
                    double dueToReverse = Math.min(due, amount);
                    due -= dueToReverse;
                    advance -= dueToReverse;
                }
            }

            if (hasDueColumn) {
                ps = con.prepareStatement("UPDATE customer_account SET due=?, advance=? WHERE customer_id=?");
            } else {
                ps = con.prepareStatement("UPDATE customer_account SET balance=?, advance=? WHERE customer_id=?");
            }
            ps.setDouble(1, due);
            ps.setDouble(2, advance);
            ps.setInt(3, customerId);
            if (ps.executeUpdate() <= 0) {
                throw new Exception("Failed to reverse customer account for cancelled entry");
            }
        } finally {
            close(rs, ps, null);
        }
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
