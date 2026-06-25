<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String bankName = request.getParameter("bankName");
int id = Integer.parseInt(request.getParameter("bankId"));
String block = request.getParameter("block");

if (bankName == null) bankName = "";
bankName = bankName.trim();

if (block != null) {
    prod.blockBankDetail(id);
    response.sendRedirect(request.getContextPath() + "/product/master/bank/page.jsp?msg=Bank+blocked+successfully&type=success");
} else {
    try {
        int bankId = prod.checkBankNameExist(bankName, id);
        if (bankId != 0) {
            response.sendRedirect(request.getContextPath() + "/product/master/bank/page.jsp?msg=Bank+name+already+exists&type=warning");
            return;
        }

        prod.editBankDetail(id, bankName);
        response.sendRedirect(request.getContextPath() + "/product/master/bank/page.jsp?msg=Bank+updated+successfully&type=success");
    } catch (Exception e) {
        response.sendRedirect(request.getContextPath() + "/product/master/bank/page.jsp?msg=Error+occurred+while+updating+bank&type=danger");
    }
}
%>
