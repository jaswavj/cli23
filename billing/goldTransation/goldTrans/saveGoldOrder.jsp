<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.JSONObject" %>
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
        try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception ex) { }

        String orderTypeRaw = request.getParameter("orderType");
        int orderType = 0;
        if ("purchase".equalsIgnoreCase(orderTypeRaw)) {
            orderType = 1;
        } else if ("sale".equalsIgnoreCase(orderTypeRaw)) {
            orderType = 2;
        }

        String orderDate = request.getParameter("orderDate");
        double qty = 0;
        try { qty = Double.parseDouble(request.getParameter("qty")); } catch (Exception ex) { }

        int orderId = goldBean.saveGoldOrder(
            customerId,
            uid.intValue(),
            orderDate,
            orderType,
            qty
        );

        double currentStock = goldBean.getGoldStockByProductId(1);

        resp.put("status", "ok");
        resp.put("order_id", orderId);
        resp.put("current_stock", currentStock);
        resp.put("msg", "TM order saved successfully");
    } catch (Exception e) {
        e.printStackTrace();
        resp.put("status", "error");
        resp.put("msg", e.getMessage() == null ? "Unable to save TM order" : e.getMessage());
    }

    out.print(resp.toString());
%>
