<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bank Management - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .bank-select-card { max-width: 520px; margin: 0 auto; }
        .bank-select-card .form-select { height: 44px; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Bank Management");
    request.setAttribute("pageSubtitle", "Select Bank");
    request.setAttribute("pageIcon",     "fa-solid fa-building-columns");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-4 mst-page" style="max-width: 700px;">
        <div class="card bank-select-card">
            <div class="card-body p-4">
                <h5 class="mb-3">Choose Bank</h5>
                <form id="bankSelectForm" action="<%=contextPath%>/product/master/bankManage/detail.jsp" method="get" class="row g-3">
                    <div class="col-12">
                        <label for="bankId" class="form-label">Bank</label>
                        <select name="bankId" id="bankId" class="form-select" required>
                            <option value="">-- Select Bank --</option>
                            <%
                            Vector banks = prod.getConfigureBankDetailsList();
                            for (int i = 0; i < banks.size(); i++) {
                                Vector row = (Vector) banks.get(i);
                                String bankName = row.elementAt(0).toString();
                                int id = Integer.parseInt(row.elementAt(1).toString());
                                String balance = row.size() > 2 ? row.elementAt(2).toString() : "0.00";
                            %>
                            <option value="<%=id%>"><%=bankName%> (Balance: <%=balance%>)</option>
                            <%
                            }
                            %>
                        </select>
                    </div>
                    <div class="col-12">
                        <button type="submit" class="bb bb-primary w-100">Continue</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        window.addEventListener('load', function() {
            var bankSelect = document.getElementById('bankId');
            if (bankSelect) bankSelect.focus();
        });
    </script>
</body>
</html>
