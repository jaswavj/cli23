package product;

import java.sql.*;
import java.util.Vector;

public class meltingBean {

    public meltingBean() {}

    private Connection getConn() throws SQLException {
        return util.DBConnectionManager.getConnectionFromPool();
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection con) {
        if (rs != null) try { rs.close(); } catch (Exception e) { }
        if (ps != null) try { ps.close(); } catch (Exception e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }

    public static double calcTotal(double gram, double purity, double bonus) {
        return gram * (purity + bonus) / 100.0;
    }

    public int saveMeltingEntry(
            int userId,
            String entryDate,
            String name,
            double gram,
            double purity,
            double bonus,
            String melting,
            String notes) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            if (userId <= 0) {
                throw new Exception("Invalid user");
            }
            if (entryDate == null || entryDate.trim().length() == 0) {
                throw new Exception("Select date");
            }
            if (name == null || name.trim().length() == 0) {
                throw new Exception("Enter name");
            }
            if (gram <= 0) {
                throw new Exception("Enter valid gram");
            }
            if (purity < 0) {
                throw new Exception("Enter valid purity");
            }
            if (bonus < 0) {
                throw new Exception("Enter valid bonus");
            }

            java.sql.Date sqlDate = java.sql.Date.valueOf(entryDate.trim());
            double total = calcTotal(gram, purity, bonus);

            con = getConn();
            con.setAutoCommit(false);

            ps = con.prepareStatement(
                "INSERT INTO melting_entry " +
                "(entry_date, name, gram, purity, bonus, total, melting, notes, user_id, enter_date_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())",
                Statement.RETURN_GENERATED_KEYS);
            ps.setDate(1, sqlDate);
            ps.setString(2, name.trim());
            ps.setDouble(3, gram);
            ps.setDouble(4, purity);
            ps.setDouble(5, bonus);
            ps.setDouble(6, total);
            if (melting == null || melting.trim().length() == 0) {
                ps.setNull(7, Types.VARCHAR);
            } else {
                ps.setString(7, melting.trim());
            }
            if (notes == null || notes.trim().length() == 0) {
                ps.setNull(8, Types.LONGVARCHAR);
            } else {
                ps.setString(8, notes.trim());
            }
            ps.setInt(9, userId);

            if (ps.executeUpdate() <= 0) {
                throw new Exception("Failed to save melting entry");
            }

            rs = ps.getGeneratedKeys();
            if (rs != null && rs.next()) {
                int entryId = rs.getInt(1);
                if (entryId <= 0) {
                    throw new Exception("Failed to read melting entry id");
                }
                con.commit();
                return entryId;
            }
            throw new Exception("Failed to read melting entry id");
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { }
            }
            throw e;
        } finally {
            close(rs, ps, con);
        }
    }

    public Vector getMeltingReportList(String fromDate, String toDate) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            if (fromDate == null || fromDate.trim().length() == 0) {
                throw new Exception("From date required");
            }
            if (toDate == null || toDate.trim().length() == 0) {
                throw new Exception("To date required");
            }

            con = getConn();
            Vector major = new Vector();
            ps = con.prepareStatement(
                "SELECT me.id, DATE_FORMAT(me.entry_date, '%Y-%m-%d') AS entry_date, me.name, " +
                "me.gram, me.purity, me.bonus, me.total, COALESCE(me.melting, '') AS melting, " +
                "COALESCE(me.notes, '') AS notes, COALESCE(u.user_name, u.fullName, '') AS username " +
                "FROM melting_entry me " +
                "LEFT JOIN users u ON u.id = me.user_id " +
                "WHERE me.entry_date BETWEEN ? AND ? " +
                "ORDER BY me.entry_date DESC, me.id DESC");
            ps.setString(1, fromDate.trim());
            ps.setString(2, toDate.trim());
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString("id"));
                row.addElement(rs.getString("entry_date"));
                row.addElement(rs.getString("name"));
                row.addElement(rs.getString("gram"));
                row.addElement(rs.getString("purity"));
                row.addElement(rs.getString("bonus"));
                row.addElement(rs.getString("total"));
                row.addElement(rs.getString("melting"));
                row.addElement(rs.getString("notes"));
                row.addElement(rs.getString("username"));
                major.addElement(row);
            }
            return major;
        } finally {
            close(rs, ps, con);
        }
    }
}
