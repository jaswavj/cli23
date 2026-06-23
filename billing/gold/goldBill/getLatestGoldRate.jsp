<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<%
    response.setContentType("application/json; charset=UTF-8");
    response.setHeader("Cache-Control","no-cache");
    out.clearBuffer();
    org.json.JSONObject resp = new org.json.JSONObject();
    try {
        java.util.Vector v = goldBean.getLatestGoldRate();
        if (v != null && !v.isEmpty()) {
            resp.put("status", "ok");
            resp.put("rate",       v.get(1).toString());
            resp.put("entered_dt", v.get(3).toString());
        } else {
            resp.put("status", "empty");
            resp.put("rate", "0");
        }
    } catch (Exception e) {
        resp.put("status", "error");
        resp.put("msg", e.getMessage() != null ? e.getMessage() : "Server error");
    }
    out.print(resp.toString());
%>
