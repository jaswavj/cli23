<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String bankName = request.getParameter("bankName");
if (bankName == null) bankName = "";
else bankName = bankName.trim();

try {
    int existing = prod.checkBankNameExist(bankName.trim());

    if (existing != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/bank/page.jsp?msg=Bank+name+already+exists!&type=warning");
        return;
    }

    prod.addBankDetail(bankName.trim());
    response.sendRedirect(request.getContextPath() + "/product/master/bank/page.jsp?msg=Bank+added+successfully!&type=success");

} catch (Exception e) {
    response.sendRedirect(
        request.getContextPath() + "/product/master/bank/page.jsp?msg=Error+occurred+while+adding+bank:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>
