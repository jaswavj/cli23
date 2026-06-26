<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<%
    request.setCharacterEncoding("UTF-8");
    JSONObject resp = new JSONObject();
    JSONArray rows = new JSONArray();

    try {
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid == null) {
            resp.put("success", false);
            resp.put("message", "Session expired");
            out.print(resp.toString());
            return;
        }

        int customerId = 0;
        try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception ex) { }

        if (customerId <= 0) {
            resp.put("success", true);
            resp.put("rows", rows);
            resp.put("count", 0);
            out.print(resp.toString());
            return;
        }

        Vector list = goldBean.getPendingGoldOrdersByCustomer(customerId);
        for (int i = 0; i < list.size(); i++) {
            Vector row = (Vector) list.get(i);
            JSONObject item = new JSONObject();
            item.put("orderId", row.elementAt(0).toString());
            item.put("type", row.elementAt(1).toString());
            item.put("qty", row.elementAt(2).toString());
            item.put("orderDate", row.elementAt(3).toString());
            rows.put(item);
        }

        resp.put("success", true);
        resp.put("rows", rows);
        resp.put("count", rows.length());
    } catch (Exception e) {
        resp.put("success", false);
        resp.put("message", e.getMessage() == null ? "Unable to load TM orders" : e.getMessage());
    }

    out.print(resp.toString());
%>
