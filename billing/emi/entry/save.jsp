<%@page language="java" import="java.util.*, java.sql.*" %>
<jsp:useBean id="emi" class="product.emiBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String customerName = request.getParameter("customerName");
String phoneNumber = request.getParameter("phoneNumber");
String firstDueDate = request.getParameter("firstDueDate");
String emiType = request.getParameter("emiType");
double totalAmount = 0;
double emiAmount = 0;
int emiMonths = 0;
try { totalAmount = Double.parseDouble(request.getParameter("totalAmount")); } catch (Exception ex) { }
try { emiAmount = Double.parseDouble(request.getParameter("emiAmount")); } catch (Exception ex) { }
try { emiMonths = Integer.parseInt(request.getParameter("emiMonths")); } catch (Exception ex) { }

try {
    java.sql.Date dueDate = java.sql.Date.valueOf(firstDueDate.trim());
    emi.saveEmiCustomer(
        userId.intValue(),
        customerName,
        phoneNumber,
        totalAmount,
        emiType,
        emiAmount,
        emiMonths,
        dueDate
    );
    response.sendRedirect(request.getContextPath() + "/emi/entry/page.jsp?msg=EMI+saved+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(
        request.getContextPath() + "/emi/entry/page.jsp?msg="
        + java.net.URLEncoder.encode("Error: " + e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>
