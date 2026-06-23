<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<%
    request.setCharacterEncoding("UTF-8");
    JSONObject resp = new JSONObject();

    try {
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid == null) uid = 1; // fallback

        // ── Master fields ──
        int    customerId    = 0;
        try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception e) {}
        String customerName  = request.getParameter("customerName");
        String customerPhone = request.getParameter("customerPhone");
        String idProofNo     = request.getParameter("idProofNo");
        String addrProofNo   = request.getParameter("addrProofNo");
        double goldRate      = Double.parseDouble(request.getParameter("goldRate"));
        double grossAmount   = Double.parseDouble(request.getParameter("grossAmount"));
        double margin        = Double.parseDouble(request.getParameter("margin"));
        double netAmount     = Double.parseDouble(request.getParameter("netAmount"));
        double releaseAmount = Double.parseDouble(request.getParameter("releaseAmount"));
        double amountPaid    = Double.parseDouble(request.getParameter("amountPaid"));
        String billDate      = request.getParameter("billDate");
        String billTime      = request.getParameter("billTime");

        // ── Items (JSON array) ──
        String itemsJson = request.getParameter("items");
        JSONArray jItems = new JSONArray(itemsJson);
        Vector items = new Vector();
        for (int i = 0; i < jItems.length(); i++) {
            JSONObject ji = jItems.getJSONObject(i);
            Vector row = new Vector();
            row.addElement(ji.getString("ornament"));
            row.addElement(String.valueOf(ji.getDouble("gross_wt")));
            row.addElement(String.valueOf(ji.getDouble("stone_wax")));
            row.addElement(String.valueOf(ji.getDouble("net_wt")));
            row.addElement(String.valueOf(ji.getDouble("purity")));
            row.addElement(String.valueOf(ji.getDouble("gross_amount")));
            items.addElement(row);
        }



        // ── Save bill ──
        int billId = goldBean.saveBill(
            customerId, customerName, customerPhone,
            idProofNo, addrProofNo,
            goldRate, grossAmount, margin, netAmount, releaseAmount, amountPaid,
            billDate, billTime, uid, items);

        if (billId > 0) {
            resp.put("status",  "ok");
            resp.put("bill_id", billId);
            resp.put("bill_no", billId); // bill_no = id
        } else {
            resp.put("status", "error");
            resp.put("msg",    "Insert failed");
        }

    } catch (Exception e) {
        e.printStackTrace();
        resp.put("status", "error");
        resp.put("msg", e.getMessage());
    }

    out.print(resp.toString());
%>
