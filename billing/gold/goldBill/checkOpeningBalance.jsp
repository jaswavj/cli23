<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="org.json.JSONObject" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    JSONObject resp = new JSONObject();
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        // Get today's date
        String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
        
        // Check if opening balance entry exists for today
        InitialContext ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/golddb");
        con = ds.getConnection();
        
        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM gold_ledger WHERE txn_date = ? AND is_open_balance_entry = 1"
        );
        ps.setString(1, today);
        rs = ps.executeQuery();
        
        boolean hasOpeningEntry = false;
        if (rs.next()) {
            hasOpeningEntry = rs.getInt(1) > 0;
        }
        
        resp.put("status", "ok");
        resp.put("hasOpeningEntry", hasOpeningEntry);
        resp.put("date", today);
        
    } catch (Exception e) {
        resp.put("status", "error");
        resp.put("message", e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    
    out.print(resp.toString());
%>
