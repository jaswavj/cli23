<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="java.util.Vector" %>
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

    int customerId = 0;
    try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception ex) { }
    if (customerId <= 0) {
        resp.put("success", false);
        resp.put("message", "Invalid customer id");
        out.print(resp.toString());
        return;
    }

    Vector v = goldBean.getCustomerCreditStatus(customerId);
    double due = 0.0;
    double advance = 0.0;
    double credit = 0.0;

    if (v != null && v.size() >= 3) {
        try { due = Double.parseDouble(String.valueOf(v.elementAt(0))); } catch (Exception ex) { }
        try { advance = Double.parseDouble(String.valueOf(v.elementAt(1))); } catch (Exception ex) { }
        try { credit = Double.parseDouble(String.valueOf(v.elementAt(2))); } catch (Exception ex) { }
    }

    resp.put("success", true);
    resp.put("due", due);
    resp.put("advance", advance);
    resp.put("credit", credit);
    out.print(resp.toString());
} catch (Exception e) {
    resp.put("success", false);
    resp.put("message", "Unable to load customer credit: " + e.getMessage());
    out.print(resp.toString());
}
%>