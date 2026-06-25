<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Vector" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.JSONArray" %>
<jsp:useBean id="emi" class="product.emiBean" />
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

JSONObject resp = new JSONObject();
JSONArray rows = new JSONArray();

Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    resp.put("success", false);
    resp.put("message", "Session expired");
    out.print(resp.toString());
    return;
}

String mode = request.getParameter("mode");
if (mode == null) mode = "pending";

try {
    if ("pay".equalsIgnoreCase(mode)) {
        int installmentId = 0;
        try { installmentId = Integer.parseInt(request.getParameter("installmentId")); } catch (Exception ex) { }
        emi.payEmiInstallment(installmentId, uid.intValue());
        resp.put("success", true);
        resp.put("message", "EMI payment recorded successfully");
        out.print(resp.toString());
        return;
    }

    if ("schedule".equalsIgnoreCase(mode)) {
        int emiCustomerId = 0;
        try { emiCustomerId = Integer.parseInt(request.getParameter("emiCustomerId")); } catch (Exception ex) { }
        if (emiCustomerId <= 0) {
            resp.put("success", false);
            resp.put("message", "Invalid EMI customer");
            out.print(resp.toString());
            return;
        }

        Vector list = emi.getEmiInstallmentList(emiCustomerId);
        for (int i = 0; i < list.size(); i++) {
            Vector row = (Vector) list.get(i);
            JSONObject item = new JSONObject();
            item.put("installmentId", row.elementAt(0).toString());
            item.put("installmentNo", row.elementAt(1).toString());
            item.put("dueDate", row.elementAt(2).toString());
            item.put("emiAmount", row.elementAt(3).toString());
            item.put("isPaid", row.elementAt(4).toString());
            item.put("paidAmount", row.elementAt(5).toString());
            item.put("paidDate", row.elementAt(6).toString());
            rows.add(item);
        }

        resp.put("success", true);
        resp.put("mode", mode);
        resp.put("rows", rows);
        resp.put("count", rows.size());
        out.print(resp.toString());
        return;
    }

    if ("completed".equalsIgnoreCase(mode)) {
        Vector completed = emi.getCompletedEmiCustomersList();
        for (int i = 0; i < completed.size(); i++) {
            Vector row = (Vector) completed.get(i);
            JSONObject item = new JSONObject();
            item.put("emiCustomerId", row.elementAt(0).toString());
            item.put("customerName", row.elementAt(1).toString());
            item.put("phoneNumber", row.elementAt(2).toString());
            item.put("totalAmount", row.elementAt(3).toString());
            item.put("emiType", row.elementAt(4).toString());
            item.put("emiAmount", row.elementAt(5).toString());
            item.put("emiMonths", row.elementAt(6).toString());
            item.put("paidCount", row.elementAt(7).toString());
            item.put("completedDate", row.elementAt(8).toString());
            rows.add(item);
        }
    } else {
        Vector pending = emi.getPendingEmiCustomersList();
        for (int i = 0; i < pending.size(); i++) {
            Vector row = (Vector) pending.get(i);
            JSONObject item = new JSONObject();
            item.put("emiCustomerId", row.elementAt(0).toString());
            item.put("customerName", row.elementAt(1).toString());
            item.put("phoneNumber", row.elementAt(2).toString());
            item.put("totalAmount", row.elementAt(3).toString());
            item.put("emiType", row.elementAt(4).toString());
            item.put("emiAmount", row.elementAt(5).toString());
            item.put("emiMonths", row.elementAt(6).toString());
            item.put("pendingCount", row.elementAt(7).toString());
            item.put("paidCount", row.elementAt(8).toString());
            item.put("nextDueDate", row.elementAt(9).toString());
            item.put("nextInstallmentId", row.elementAt(10).toString());
            item.put("nextInstallmentNo", row.elementAt(11).toString());
            rows.add(item);
        }
    }

    resp.put("success", true);
    resp.put("mode", mode);
    resp.put("rows", rows);
    resp.put("count", rows.size());
    out.print(resp.toString());
} catch (Exception e) {
    resp.put("success", false);
    String prefix = "pay".equalsIgnoreCase(mode) ? "Unable to pay EMI: " : "Unable to load EMI: ";
    resp.put("message", prefix + e.getMessage());
    out.print(resp.toString());
}
%>
