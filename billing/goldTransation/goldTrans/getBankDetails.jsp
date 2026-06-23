<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    JSONArray results = new JSONArray();
    try {
        Vector banks = prod.getBankDetails();
        for (int i = 0; i < banks.size(); i++) {
            Vector row = (Vector) banks.get(i);
            JSONObject obj = new JSONObject();
            obj.put("id", row.get(0));
            obj.put("name", row.get(1));
            results.put(obj);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    out.print(results.toString());
%>
