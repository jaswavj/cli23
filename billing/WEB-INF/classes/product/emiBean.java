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

    private boolean isInterestDept(String deptType) {
        return "interest".equals(deptType == null ? "" : deptType.trim().toLowerCase());
    }

    public int saveEmiCustomer(
            int userId,
            String customerName,
            String phoneNumber,
            String deptType,
            double totalAmount,
            String emiType,
            double emiAmount,
            int emiMonths,
            double interestPerMonth,
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

            String borrowGive = emiType == null ? "" : emiType.trim().toLowerCase();
            if (!"borrow".equals(borrowGive) && !"give".equals(borrowGive)) {
                throw new Exception("Select Borrow or Give");
            }

            String dept = deptType == null ? "normal" : deptType.trim().toLowerCase();
            if (!"normal".equals(dept) && !"interest".equals(dept)) {
                throw new Exception("Select valid dept type");
            }

            if (firstDueDate == null) {
                throw new Exception("Select due date");
            }

            Calendar cal = Calendar.getInstance();
            cal.setTime(firstDueDate);
            int dueDay = cal.get(Calendar.DAY_OF_MONTH);
            if (dueDay < 1 || dueDay > 31) {
                throw new Exception("Invalid due day");
            }

            boolean interestDept = isInterestDept(dept);
            double storedEmiAmount = emiAmount;
            int storedEmiMonths = emiMonths;
            double storedInterest = 0.0;

            if (interestDept) {
                if (interestPerMonth <= 0) {
                    throw new Exception("Enter valid interest per month");
                }
                storedInterest = interestPerMonth;
                storedEmiAmount = interestPerMonth;
                storedEmiMonths = 0;
            } else {
                if (emiAmount <= 0) {
                    throw new Exception("Enter valid EMI amount");
                }
                if (emiMonths <= 0) {
                    throw new Exception("Enter valid EMI months");
                }
            }

            con = getConn();
            con.setAutoCommit(false);

            ps = con.prepareStatement(
                "INSERT INTO emi_customer " +
                "(customer_name, phone_number, total_amount, emi_type, dept_type, emi_amount, emi_months, " +
                " interest_per_month, due_day, first_due_date, user_id, date_time, is_closed) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 0)",
                Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, customerName.trim());
            if (phoneNumber == null || phoneNumber.trim().length() == 0) {
                ps.setNull(2, Types.VARCHAR);
            } else {
                ps.setString(2, phoneNumber.trim());
            }
            ps.setDouble(3, totalAmount);
            ps.setString(4, borrowGive);
            ps.setString(5, dept);
            ps.setDouble(6, storedEmiAmount);
            ps.setInt(7, storedEmiMonths);
            ps.setDouble(8, storedInterest);
            ps.setInt(9, dueDay);
            ps.setDate(10, firstDueDate);
            ps.setInt(11, userId);
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

            if (interestDept) {
                ps.setInt(1, emiCustomerId);
                ps.setInt(2, 1);
                ps.setDate(3, firstDueDate);
                ps.setDouble(4, storedInterest);
                if (ps.executeUpdate() <= 0) {
                    throw new Exception("Failed to create interest schedule");
                }
            } else {
                Calendar dueCal = Calendar.getInstance();
                dueCal.setTime(firstDueDate);
                for (int i = 1; i <= storedEmiMonths; i++) {
                    if (i > 1) {
                        dueCal.add(Calendar.MONTH, 1);
                    }
                    java.sql.Date dueDate = new java.sql.Date(dueCal.getTimeInMillis());
                    ps.setInt(1, emiCustomerId);
                    ps.setInt(2, i);
                    ps.setDate(3, dueDate);
                    ps.setDouble(4, storedEmiAmount);
                    ps.addBatch();
                }
                int[] batch = ps.executeBatch();
                if (batch == null || batch.length != storedEmiMonths) {
                    throw new Exception("Failed to create EMI schedule");
                }
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

    private void appendPendingRow(Vector major, ResultSet rs) throws SQLException {
        Vector row = new Vector();
        row.addElement(rs.getString("id"));
        row.addElement(rs.getString("customer_name"));
        row.addElement(rs.getString("phone_number"));
        row.addElement(rs.getString("total_amount"));
        row.addElement(rs.getString("emi_type"));
        row.addElement(rs.getString("dept_type"));
        row.addElement(rs.getString("emi_amount"));
        row.addElement(rs.getString("interest_per_month"));
        row.addElement(rs.getString("emi_months"));
        row.addElement(rs.getString("pending_count"));
        row.addElement(rs.getString("paid_count"));
        row.addElement(rs.getString("next_due_date"));
        row.addElement(rs.getString("next_installment_id"));
        row.addElement(rs.getString("next_installment_no"));
        major.addElement(row);
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
                "       ec.total_amount, ec.emi_type, ec.dept_type, ec.emi_amount, ec.interest_per_month, ec.emi_months, " +
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
                "GROUP BY ec.id, ec.customer_name, ec.phone_number, ec.total_amount, ec.emi_type, ec.dept_type, " +
                "         ec.emi_amount, ec.interest_per_month, ec.emi_months " +
                "HAVING pending_count > 0 " +
                "ORDER BY next_due_date ASC, ec.customer_name ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
                appendPendingRow(major, rs);
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
                "       ec.total_amount, ec.emi_type, ec.dept_type, ec.emi_amount, ec.interest_per_month, ec.emi_months, " +
                "       SUM(CASE WHEN ei.is_paid = 1 THEN 1 ELSE 0 END) AS paid_count, " +
                "       COALESCE(DATE_FORMAT(ec.closed_date, '%Y-%m-%d %H:%i:%s'), " +
                "                DATE_FORMAT(MAX(ei.paid_date), '%Y-%m-%d %H:%i:%s'), '') AS completed_date " +
                "FROM emi_customer ec " +
                "INNER JOIN emi_installment ei ON ei.emi_customer_id = ec.id " +
                "WHERE ec.is_closed = 1 " +
                "GROUP BY ec.id, ec.customer_name, ec.phone_number, ec.total_amount, ec.emi_type, ec.dept_type, " +
                "         ec.emi_amount, ec.interest_per_month, ec.emi_months, ec.closed_date " +
                "ORDER BY ec.closed_date DESC, MAX(ei.paid_date) DESC, ec.customer_name ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString("id"));
                row.addElement(rs.getString("customer_name"));
                row.addElement(rs.getString("phone_number"));
                row.addElement(rs.getString("total_amount"));
                row.addElement(rs.getString("emi_type"));
                row.addElement(rs.getString("dept_type"));
                row.addElement(rs.getString("emi_amount"));
                row.addElement(rs.getString("interest_per_month"));
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

    private void createNextInterestInstallment(Connection con, int emiCustomerId, double interestAmount) throws Exception {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = con.prepareStatement(
                "SELECT installment_no, due_date FROM emi_installment " +
                "WHERE emi_customer_id = ? ORDER BY installment_no DESC LIMIT 1");
            ps.setInt(1, emiCustomerId);
            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new Exception("Unable to create next interest installment");
            }
            int nextNo = rs.getInt("installment_no") + 1;
            java.sql.Date lastDue = rs.getDate("due_date");
            close(rs, ps, null);
            rs = null;
            ps = null;

            Calendar dueCal = Calendar.getInstance();
            dueCal.setTime(lastDue);
            dueCal.add(Calendar.MONTH, 1);
            java.sql.Date nextDue = new java.sql.Date(dueCal.getTimeInMillis());

            ps = con.prepareStatement(
                "INSERT INTO emi_installment (emi_customer_id, installment_no, due_date, emi_amount, paid_amount, is_paid) " +
                "VALUES (?, ?, ?, ?, 0, 0)");
            ps.setInt(1, emiCustomerId);
            ps.setInt(2, nextNo);
            ps.setDate(3, nextDue);
            ps.setDouble(4, interestAmount);
            if (ps.executeUpdate() <= 0) {
                throw new Exception("Failed to create next interest installment");
            }
        } finally {
            close(rs, ps, null);
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
                "SELECT ei.id, ei.emi_customer_id, ei.emi_amount, ei.is_paid, " +
                "       ec.dept_type, ec.is_closed, ec.interest_per_month " +
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
            if (rs.getInt("is_closed") == 1) {
                throw new Exception("This EMI account is closed");
            }

            int emiCustomerId = rs.getInt("emi_customer_id");
            double emiAmount = rs.getDouble("emi_amount");
            String deptType = rs.getString("dept_type");
            double interestPerMonth = rs.getDouble("interest_per_month");

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

            if (isInterestDept(deptType)) {
                double nextInterest = interestPerMonth > 0 ? interestPerMonth : emiAmount;
                createNextInterestInstallment(con, emiCustomerId, nextInterest);
            } else {
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
                        "UPDATE emi_customer SET is_closed = 1, closed_date = NOW() WHERE id = ?");
                    ps.setInt(1, emiCustomerId);
                    ps.executeUpdate();
                }
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

    public void closeEmiCustomer(int emiCustomerId, int userId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            if (emiCustomerId <= 0) {
                throw new Exception("Invalid EMI customer");
            }
            if (userId <= 0) {
                throw new Exception("Invalid user");
            }

            con = getConn();
            con.setAutoCommit(false);

            ps = con.prepareStatement(
                "SELECT id, is_closed FROM emi_customer WHERE id = ? FOR UPDATE");
            ps.setInt(1, emiCustomerId);
            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new Exception("EMI customer not found");
            }
            if (rs.getInt("is_closed") == 1) {
                throw new Exception("EMI already closed");
            }
            close(rs, ps, null);
            rs = null;
            ps = null;

            ps = con.prepareStatement(
                "DELETE FROM emi_installment WHERE emi_customer_id = ? AND is_paid = 0");
            ps.setInt(1, emiCustomerId);
            ps.executeUpdate();
            close(null, ps, null);
            ps = null;

            ps = con.prepareStatement(
                "UPDATE emi_customer SET is_closed = 1, closed_date = NOW() WHERE id = ? AND is_closed = 0");
            ps.setInt(1, emiCustomerId);
            if (ps.executeUpdate() <= 0) {
                throw new Exception("Unable to close EMI");
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
