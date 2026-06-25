package product;

import java.sql.*;
import java.util.Calendar;
import java.util.Vector;

public class emiBean {

    public emiBean() {}

    private Connection getConn() throws SQLException {
        return util.DBConnectionManager.getConnectionFromPool();
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection con) {
        if (rs != null) try { rs.close(); } catch (Exception e) { }
        if (ps != null) try { ps.close(); } catch (Exception e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }

    public int saveEmiCustomer(
            int userId,
            String customerName,
            String phoneNumber,
            double totalAmount,
            String emiType,
            double emiAmount,
            int emiMonths,
            java.sql.Date firstDueDate) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            if (userId <= 0) {
                throw new Exception("Invalid user");
            }
            if (customerName == null || customerName.trim().length() == 0) {
                throw new Exception("Enter customer name");
            }
            if (totalAmount <= 0) {
                throw new Exception("Enter valid total amount");
            }
            String type = emiType == null ? "" : emiType.trim().toLowerCase();
            if (!"borrow".equals(type) && !"give".equals(type)) {
                throw new Exception("Select Borrow or Give");
            }
            if (emiAmount <= 0) {
                throw new Exception("Enter valid EMI amount");
            }
            if (emiMonths <= 0) {
                throw new Exception("Enter valid EMI months");
            }
            if (firstDueDate == null) {
                throw new Exception("Select first due date");
            }

            Calendar cal = Calendar.getInstance();
            cal.setTime(firstDueDate);
            int dueDay = cal.get(Calendar.DAY_OF_MONTH);
            if (dueDay < 1 || dueDay > 31) {
                throw new Exception("Invalid due day");
            }

            con = getConn();
            con.setAutoCommit(false);

            ps = con.prepareStatement(
                "INSERT INTO emi_customer " +
                "(customer_name, phone_number, total_amount, emi_type, emi_amount, emi_months, due_day, first_due_date, user_id, date_time, is_closed) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 0)",
                Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, customerName.trim());
            if (phoneNumber == null || phoneNumber.trim().length() == 0) {
                ps.setNull(2, Types.VARCHAR);
            } else {
                ps.setString(2, phoneNumber.trim());
            }
            ps.setDouble(3, totalAmount);
            ps.setString(4, type);
            ps.setDouble(5, emiAmount);
            ps.setInt(6, emiMonths);
            ps.setInt(7, dueDay);
            ps.setDate(8, firstDueDate);
            ps.setInt(9, userId);
            if (ps.executeUpdate() <= 0) {
                throw new Exception("Failed to save EMI customer");
            }

            int emiCustomerId = 0;
            rs = ps.getGeneratedKeys();
            if (rs != null && rs.next()) {
                emiCustomerId = rs.getInt(1);
            }
            close(rs, ps, null);
            rs = null;
            ps = null;

            if (emiCustomerId <= 0) {
                throw new Exception("Failed to read EMI customer id");
            }

            ps = con.prepareStatement(
                "INSERT INTO emi_installment " +
                "(emi_customer_id, installment_no, due_date, emi_amount, paid_amount, is_paid) " +
                "VALUES (?, ?, ?, ?, 0, 0)");

            Calendar dueCal = Calendar.getInstance();
            dueCal.setTime(firstDueDate);

            for (int i = 1; i <= emiMonths; i++) {
                if (i > 1) {
                    dueCal.add(Calendar.MONTH, 1);
                }
                java.sql.Date dueDate = new java.sql.Date(dueCal.getTimeInMillis());
                ps.setInt(1, emiCustomerId);
                ps.setInt(2, i);
                ps.setDate(3, dueDate);
                ps.setDouble(4, emiAmount);
                ps.addBatch();
            }

            int[] batch = ps.executeBatch();
            if (batch == null || batch.length != emiMonths) {
                throw new Exception("Failed to create EMI schedule");
            }

            con.commit();
            return emiCustomerId;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { }
            }
            throw e;
        } finally {
            close(rs, ps, con);
        }
    }

    public Vector getPendingEmiCustomersList() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConn();
            Vector major = new Vector();
            ps = con.prepareStatement(
                "SELECT ec.id, ec.customer_name, COALESCE(ec.phone_number, '') AS phone_number, " +
                "       ec.total_amount, ec.emi_type, ec.emi_amount, ec.emi_months, " +
                "       SUM(CASE WHEN ei.is_paid = 0 THEN 1 ELSE 0 END) AS pending_count, " +
                "       SUM(CASE WHEN ei.is_paid = 1 THEN 1 ELSE 0 END) AS paid_count, " +
                "       MIN(CASE WHEN ei.is_paid = 0 THEN ei.due_date END) AS next_due_date, " +
                "       (SELECT ei2.id FROM emi_installment ei2 " +
                "        WHERE ei2.emi_customer_id = ec.id AND ei2.is_paid = 0 " +
                "        ORDER BY ei2.due_date ASC, ei2.installment_no ASC LIMIT 1) AS next_installment_id, " +
                "       (SELECT ei2.installment_no FROM emi_installment ei2 " +
                "        WHERE ei2.emi_customer_id = ec.id AND ei2.is_paid = 0 " +
                "        ORDER BY ei2.due_date ASC, ei2.installment_no ASC LIMIT 1) AS next_installment_no " +
                "FROM emi_customer ec " +
                "INNER JOIN emi_installment ei ON ei.emi_customer_id = ec.id " +
                "WHERE ec.is_closed = 0 " +
                "GROUP BY ec.id, ec.customer_name, ec.phone_number, ec.total_amount, ec.emi_type, ec.emi_amount, ec.emi_months " +
                "HAVING pending_count > 0 " +
                "ORDER BY next_due_date ASC, ec.customer_name ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString("id"));
                row.addElement(rs.getString("customer_name"));
                row.addElement(rs.getString("phone_number"));
                row.addElement(rs.getString("total_amount"));
                row.addElement(rs.getString("emi_type"));
                row.addElement(rs.getString("emi_amount"));
                row.addElement(rs.getString("emi_months"));
                row.addElement(rs.getString("pending_count"));
                row.addElement(rs.getString("paid_count"));
                row.addElement(rs.getString("next_due_date"));
                row.addElement(rs.getString("next_installment_id"));
                row.addElement(rs.getString("next_installment_no"));
                major.addElement(row);
            }
            return major;
        } finally {
            close(rs, ps, con);
        }
    }

    public Vector getCompletedEmiCustomersList() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConn();
            Vector major = new Vector();
            ps = con.prepareStatement(
                "SELECT ec.id, ec.customer_name, COALESCE(ec.phone_number, '') AS phone_number, " +
                "       ec.total_amount, ec.emi_type, ec.emi_amount, ec.emi_months, " +
                "       SUM(CASE WHEN ei.is_paid = 1 THEN 1 ELSE 0 END) AS paid_count, " +
                "       COALESCE(DATE_FORMAT(MAX(ei.paid_date), '%Y-%m-%d %H:%i:%s'), '') AS completed_date " +
                "FROM emi_customer ec " +
                "INNER JOIN emi_installment ei ON ei.emi_customer_id = ec.id " +
                "WHERE ec.is_closed = 1 " +
                "GROUP BY ec.id, ec.customer_name, ec.phone_number, ec.total_amount, ec.emi_type, ec.emi_amount, ec.emi_months " +
                "ORDER BY MAX(ei.paid_date) DESC, ec.customer_name ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString("id"));
                row.addElement(rs.getString("customer_name"));
                row.addElement(rs.getString("phone_number"));
                row.addElement(rs.getString("total_amount"));
                row.addElement(rs.getString("emi_type"));
                row.addElement(rs.getString("emi_amount"));
                row.addElement(rs.getString("emi_months"));
                row.addElement(rs.getString("paid_count"));
                row.addElement(rs.getString("completed_date"));
                major.addElement(row);
            }
            return major;
        } finally {
            close(rs, ps, con);
        }
    }

    public Vector getEmiInstallmentList(int emiCustomerId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConn();
            Vector major = new Vector();
            ps = con.prepareStatement(
                "SELECT id, installment_no, due_date, emi_amount, is_paid, paid_amount, paid_date " +
                "FROM emi_installment WHERE emi_customer_id = ? " +
                "ORDER BY installment_no ASC");
            ps.setInt(1, emiCustomerId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString("id"));
                row.addElement(rs.getString("installment_no"));
                row.addElement(rs.getString("due_date"));
                row.addElement(rs.getString("emi_amount"));
                row.addElement(rs.getString("is_paid"));
                row.addElement(rs.getString("paid_amount"));
                row.addElement(rs.getString("paid_date") == null ? "" : rs.getString("paid_date"));
                major.addElement(row);
            }
            return major;
        } finally {
            close(rs, ps, con);
        }
    }

    public void payEmiInstallment(int installmentId, int userId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            if (installmentId <= 0) {
                throw new Exception("Invalid installment");
            }
            if (userId <= 0) {
                throw new Exception("Invalid user");
            }

            con = getConn();
            con.setAutoCommit(false);

            ps = con.prepareStatement(
                "SELECT ei.id, ei.emi_customer_id, ei.emi_amount, ei.is_paid " +
                "FROM emi_installment ei " +
                "INNER JOIN emi_customer ec ON ec.id = ei.emi_customer_id " +
                "WHERE ei.id = ? FOR UPDATE");
            ps.setInt(1, installmentId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                throw new Exception("Installment not found");
            }
            if (rs.getInt("is_paid") == 1) {
                throw new Exception("This EMI is already paid");
            }

            int emiCustomerId = rs.getInt("emi_customer_id");
            double emiAmount = rs.getDouble("emi_amount");

            close(rs, ps, null);
            rs = null;
            ps = null;

            ps = con.prepareStatement(
                "UPDATE emi_installment SET is_paid = 1, paid_amount = ?, paid_date = NOW(), paid_user_id = ? " +
                "WHERE id = ? AND is_paid = 0");
            ps.setDouble(1, emiAmount);
            ps.setInt(2, userId);
            ps.setInt(3, installmentId);
            if (ps.executeUpdate() <= 0) {
                throw new Exception("Unable to mark EMI as paid");
            }
            close(null, ps, null);
            ps = null;

            ps = con.prepareStatement(
                "SELECT COUNT(*) AS pending_count FROM emi_installment " +
                "WHERE emi_customer_id = ? AND is_paid = 0");
            ps.setInt(1, emiCustomerId);
            rs = ps.executeQuery();
            int pendingCount = 0;
            if (rs.next()) {
                pendingCount = rs.getInt("pending_count");
            }
            close(rs, ps, null);
            rs = null;
            ps = null;

            if (pendingCount == 0) {
                ps = con.prepareStatement(
                    "UPDATE emi_customer SET is_closed = 1 WHERE id = ?");
                ps.setInt(1, emiCustomerId);
                ps.executeUpdate();
            }

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { }
            }
            throw e;
        } finally {
            close(rs, ps, con);
        }
    }
}
