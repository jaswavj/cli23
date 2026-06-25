<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.JSONArray" %>
<jsp:useBean id="prod" class="product.productBean" />
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
if (mode == null) mode = "detail";

int bankId = 0;
try { bankId = Integer.parseInt(request.getParameter("bankId")); } catch (Exception ex) { }

if (bankId <= 0) {
    resp.put("success", false);
    resp.put("message", "Select bank");
    out.print(resp.toString());
    return;
}

try {
    if ("adjust".equalsIgnoreCase(mode)) {
        double amount = 0;
        String action = request.getParameter("action");
        String notes = request.getParameter("notes");
        try { amount = Double.parseDouble(request.getParameter("amount")); } catch (Exception ex) { }

        double newBalance = prod.adjustBankBalance(uid.intValue(), bankId, action, amount, notes);

        resp.put("success", true);
        resp.put("mode", mode);
        resp.put("bankId", bankId);
        resp.put("balance", newBalance);
        resp.put("message", "add".equalsIgnoreCase(action) ? "Money added successfully" : "Money removed successfully");
        out.print(resp.toString());
        return;
    }

    Vector bank = prod.getConfigureBankDetailById(bankId);
    if (bank == null || bank.isEmpty()) {
        resp.put("success", false);
        resp.put("message", "Bank not found");
        out.print(resp.toString());
        return;
    }

    String fromDate = request.getParameter("fromDate");
    String toDate = request.getParameter("toDate");

    Vector ledgerResult = prod.getBankLedgerList(bankId, fromDate, toDate);
    ArrayList ledgerRows = (ArrayList) ledgerResult.elementAt(0);
    String openingBalance = ledgerResult.elementAt(1).toString();
    String periodIn = ledgerResult.elementAt(2).toString();
    String periodOut = ledgerResult.elementAt(3).toString();
    String closingBalance = ledgerResult.elementAt(4).toString();

    for (int i = 0; i < ledgerRows.size(); i++) {
        Vector row = (Vector) ledgerRows.get(i);
        JSONObject item = new JSONObject();
        item.put("id", row.elementAt(0).toString());
        item.put("billId", row.elementAt(1).toString());
        item.put("inAmount", row.elementAt(2).toString());
        item.put("outAmount", row.elementAt(3).toString());
        item.put("notes", row.elementAt(4).toString());
        item.put("dateTime", row.elementAt(5).toString());
        item.put("userName", row.elementAt(6).toString());
        item.put("runningBalance", row.elementAt(7).toString());
        rows.add(item);
    }

    JSONObject totals = new JSONObject();
    totals.put("openingBalance", openingBalance);
    totals.put("periodIn", periodIn);
    totals.put("periodOut", periodOut);
    totals.put("closingBalance", closingBalance);

    resp.put("success", true);
    resp.put("mode", mode);
    resp.put("bankId", bankId);
    resp.put("bankName", bank.elementAt(0).toString());
    resp.put("balance", bank.elementAt(2).toString());
    resp.put("fromDate", fromDate == null ? "" : fromDate.trim());
    resp.put("toDate", toDate == null ? "" : toDate.trim());
    resp.put("totals", totals);
    resp.put("rows", rows);
    resp.put("count", rows.size());
    out.print(resp.toString());
} catch (Exception e) {
    resp.put("success", false);
    String errPrefix = "adjust".equalsIgnoreCase(mode) ? "Unable to update balance: " : "Unable to load bank details: ";
    resp.put("message", errPrefix + e.getMessage());
    out.print(resp.toString());
}
%>
