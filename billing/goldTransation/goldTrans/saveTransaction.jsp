<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<%
    request.setCharacterEncoding("UTF-8");
    JSONObject resp = new JSONObject();

    try {
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid == null) {
            resp.put("status", "error");
            resp.put("msg", "Session expired. Please login again.");
            out.print(resp.toString());
            return;
        }

        int customerId = 0;
        try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception ex) { ; }

        String txnType = request.getParameter("txnType");
        boolean isSale = "sale".equalsIgnoreCase(txnType);
        boolean isPurchase = "purchase".equalsIgnoreCase(txnType);

        String billDate = request.getParameter("billDate");
        String billTime = request.getParameter("billTime");

        double total = Double.parseDouble(request.getParameter("total"));
        double paid = Double.parseDouble(request.getParameter("paid"));
        double balance = Double.parseDouble(request.getParameter("balance"));

        JSONArray jItems = new JSONArray(request.getParameter("items"));
        Vector items = new Vector();
        for (int i = 0; i < jItems.length(); i++) {
            JSONObject rowObj = jItems.getJSONObject(i);
            Vector row = new Vector();
            row.addElement(rowObj.optString("particular", ""));
            row.addElement(String.valueOf(rowObj.optDouble("qty", 0.0)));
            row.addElement(String.valueOf(rowObj.optDouble("rate", 0.0)));
            row.addElement(String.valueOf(rowObj.optDouble("total", 0.0)));
            items.addElement(row);
        }

        JSONArray jPayments = new JSONArray(request.getParameter("payments"));
        Vector payments = new Vector();
        for (int i = 0; i < jPayments.length(); i++) {
            JSONObject payObj = jPayments.getJSONObject(i);
            Vector row = new Vector();
            row.addElement(payObj.optString("mode", ""));
            row.addElement(String.valueOf(payObj.optInt("bankId", 0)));
            row.addElement(String.valueOf(payObj.optDouble("amount", 0.0)));
            payments.addElement(row);
        }

        int billId = goldBean.saveGoldTransaction(
            customerId,
            uid.intValue(),
            billDate,
            billTime,
            total,
            paid,
            balance,
            isSale,
            isPurchase,
            items,
            payments
        );

        double currentStock = goldBean.getGoldStockByProductId(1);

        resp.put("status", "ok");
        resp.put("bill_id", billId);
        resp.put("current_stock", currentStock);
        resp.put("msg", "Transaction saved successfully");
    } catch (Exception e) {
        e.printStackTrace();
        resp.put("status", "error");
        resp.put("msg", e.getMessage() == null ? "Unable to save transaction" : e.getMessage());
    }

    out.print(resp.toString());
%>
