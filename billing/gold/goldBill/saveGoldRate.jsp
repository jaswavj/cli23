<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="false" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<%
    response.setContentType("application/json; charset=UTF-8");
    response.setHeader("Cache-Control","no-cache");
    out.clearBuffer();

    org.json.JSONObject resp = new org.json.JSONObject();
    try {
        String rateParam = request.getParameter("rate");
        if (rateParam == null || rateParam.trim().isEmpty()) {
            resp.put("status", "error");
            resp.put("msg", "Rate parameter missing");
            out.print(resp.toString());
            return;
        }
        double rate = Double.parseDouble(rateParam.trim());
        if (rate <= 0) {
            resp.put("status", "error");
            resp.put("msg", "Rate must be greater than 0");
            out.print(resp.toString());
            return;
        }
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid == null) uid = 1;

        int id = goldBean.insertGoldRate(rate, uid);
        if (id > 0) {
            resp.put("status", "ok");
            resp.put("id",   id);
            resp.put("rate", rate);
        } else {
            resp.put("status", "error");
            resp.put("msg", "DB insert returned no ID — gold_rate table may not exist. Run createTables.sql first.");
        }
    } catch (NumberFormatException e) {
        resp.put("status", "error");
        resp.put("msg", "Invalid rate value: " + e.getMessage());
    } catch (Exception e) {
        // Print full stack trace to server log
        e.printStackTrace();
        String msg = e.getMessage();
        if (msg == null || msg.isEmpty()) msg = e.getClass().getName();
        resp.put("status", "error");
        resp.put("msg", msg);
    }
    out.print(resp.toString());
%>
