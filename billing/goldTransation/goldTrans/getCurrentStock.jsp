<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.simple.JSONObject" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<%
JSONObject resp = new JSONObject();

try {
    if (session.getAttribute("userId") == null) {
        resp.put("success", false);
        resp.put("message", "Session expired");
        out.print(resp.toString());
        return;
    }

    double stock = goldBean.getGoldStockByProductId(1);

    resp.put("success", true);
    resp.put("stock", stock);
    out.print(resp.toString());
} catch (Exception e) {
    resp.put("success", false);
    resp.put("message", "Unable to fetch stock: " + e.getMessage());
    out.print(resp.toString());
}
%>