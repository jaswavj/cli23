<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    response.setHeader("Cache-Control","no-cache");
    out.clearBuffer();
    
    org.json.JSONObject resp = new org.json.JSONObject();
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT bill_no FROM gold_bill WHERE is_cancelled = 0 ORDER BY id DESC LIMIT 1");
        rs = ps.executeQuery();
        if (rs.next()) {
            resp.put("status", "ok");
            resp.put("bill_no", rs.getString("bill_no"));
        } else {
            resp.put("status", "empty");
            resp.put("bill_no", "0");
        }
    } catch (Exception e) {
        resp.put("status", "error");
        resp.put("msg", e.getMessage() != null ? e.getMessage() : "Server error");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    out.print(resp.toString());
%>
