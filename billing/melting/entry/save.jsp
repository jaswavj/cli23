<%@page language="java" import="java.util.*, java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:useBean id="melting" class="product.meltingBean" />
<%
response.setCharacterEncoding("UTF-8");

org.json.simple.JSONObject resp = new org.json.simple.JSONObject();

Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    resp.put("success", false);
    resp.put("message", "Session expired. Please login again.");
    out.print(resp.toString());
    return;
}

String entryDate = request.getParameter("entryDate");
String name = request.getParameter("name");
String meltingVal = request.getParameter("melting");
String notes = request.getParameter("notes");
double gram = 0;
double purity = 0;
double bonus = 0;
try { gram = Double.parseDouble(request.getParameter("gram")); } catch (Exception ex) { }
try { purity = Double.parseDouble(request.getParameter("purity")); } catch (Exception ex) { }
try { bonus = Double.parseDouble(request.getParameter("bonus")); } catch (Exception ex) { }

try {
    int entryId = melting.saveMeltingEntry(
        userId.intValue(),
        entryDate,
        name,
        gram,
        purity,
        bonus,
        meltingVal,
        notes
    );

    if (entryId <= 0) {
        throw new Exception("Melting entry was not saved");
    }

    resp.put("success", true);
    resp.put("entryId", entryId);
    resp.put("message", "Melting entry saved successfully");
} catch (Exception e) {
    resp.put("success", false);
    String err = e.getMessage();
    resp.put("message", err == null || err.trim().length() == 0 ? "Unable to save melting entry" : err);
}

out.print(resp.toString());
%>
