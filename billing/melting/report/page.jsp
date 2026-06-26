<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.text.DecimalFormat" %>
<jsp:useBean id="melting" class="product.meltingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate == null || toDate.isEmpty()) toDate = today;

Vector rows = new Vector();
double sumGram = 0;
double sumTotal = 0;
DecimalFormat df3 = new DecimalFormat("#,##0.000");
DecimalFormat df2 = new DecimalFormat("#,##0.00");

try {
    rows = melting.getMeltingReportList(fromDate, toDate);
    for (int i = 0; i < rows.size(); i++) {
        Vector row = (Vector) rows.get(i);
        sumGram += Double.parseDouble(row.elementAt(3).toString());
        sumTotal += Double.parseDouble(row.elementAt(6).toString());
    }
} catch (Exception e) {
    request.setAttribute("loadError", e.getMessage());
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Melting Report - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .ml-summary {
            background: var(--bill-bg);
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 0.75rem;
            text-align: center;
        }
        .ml-summary-value { font-size: 1.2rem; font-weight: 700; color: var(--bill-navy); }
        .ml-summary-label { font-size: 0.75rem; color: var(--bill-muted); }
        @media print { .print-hide { display: none !important; } body { background: #fff; } }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle", "Melting Report");
    request.setAttribute("pageSubtitle", "Date-wise melting entries with totals");
    request.setAttribute("pageIcon", "fa-solid fa-fire-flame-curved");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
<% if (request.getAttribute("loadError") != null) { %>
<div class="alert alert-danger mb-3"><%= request.getAttribute("loadError") %></div>
<% } %>

    <div class="card mst-card print-hide mb-3">
        <div class="card-body p-3">
            <form method="get" class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label fw-semibold">From Date</label>
                    <input type="date" name="fromDate" class="form-control fg-inp" value="<%=fromDate%>" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold">To Date</label>
                    <input type="date" name="toDate" class="form-control fg-inp" value="<%=toDate%>" required>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="bb bb-primary w-100">
                        <i class="fa-solid fa-magnifying-glass me-1"></i>Load
                    </button>
                </div>
                <div class="col-md-2">
                    <a href="<%=request.getContextPath()%>/melting/entry/page.jsp" class="bb bb-outline w-100 d-inline-block text-center">
                        <i class="fa-solid fa-plus me-1"></i>Entry
                    </a>
                </div>
            </form>
        </div>
    </div>

    <div class="row g-2 mb-3">
        <div class="col-md-3">
            <div class="ml-summary">
                <div class="ml-summary-value"><%= rows.size() %></div>
                <div class="ml-summary-label">Total Entries</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="ml-summary">
                <div class="ml-summary-value"><%= df3.format(sumGram) %></div>
                <div class="ml-summary-label">Total Gram</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="ml-summary">
                <div class="ml-summary-value"><%= df3.format(sumTotal) %></div>
                <div class="ml-summary-label">Total (Calculated)</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="ml-summary">
                <div class="ml-summary-value"><%= fromDate %> to <%= toDate %></div>
                <div class="ml-summary-label">Period</div>
            </div>
        </div>
    </div>

    <div class="card mst-card">
        <div class="mst-card-header d-flex justify-content-between align-items-center print-hide">
            <h5 class="mb-0"><i class="fa-solid fa-table me-2"></i>Melting Details</h5>
            <button type="button" onclick="window.print()" class="bb bb-navy btn-sm">
                <i class="fa-solid fa-print me-1"></i>Print
            </button>
        </div>
        <div class="table-responsive">
            <table class="table mst-table mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Date</th>
                        <th>Name</th>
                        <th class="text-end">Gram</th>
                        <th class="text-end">Purity %</th>
                        <th class="text-end">Bonus %</th>
                        <th class="text-end">Total</th>
                        <th>Melting</th>
                        <th>Notes</th>
                        <th>Entry By</th>
                    </tr>
                </thead>
                <tbody>
                <%
                if (rows.size() == 0) {
                %>
                    <tr><td colspan="10" class="text-center text-muted py-4">No melting entries found</td></tr>
                <%
                } else {
                    for (int i = 0; i < rows.size(); i++) {
                        Vector r = (Vector) rows.get(i);
                        String dt = r.elementAt(1).toString();
                        if (dt.length() >= 10) {
                            dt = dt.substring(8, 10) + "-" + dt.substring(5, 7) + "-" + dt.substring(0, 4);
                        }
                %>
                    <tr>
                        <td><%= i + 1 %></td>
                        <td><%= dt %></td>
                        <td><%= r.elementAt(2) %></td>
                        <td class="text-end"><%= df3.format(Double.parseDouble(r.elementAt(3).toString())) %></td>
                        <td class="text-end"><%= df2.format(Double.parseDouble(r.elementAt(4).toString())) %></td>
                        <td class="text-end"><%= df2.format(Double.parseDouble(r.elementAt(5).toString())) %></td>
                        <td class="text-end"><%= df3.format(Double.parseDouble(r.elementAt(6).toString())) %></td>
                        <td><%= r.elementAt(7) %></td>
                        <td><%= r.elementAt(8) %></td>
                        <td><%= r.elementAt(9) %></td>
                    </tr>
                <%
                    }
                }
                %>
                </tbody>
                <% if (rows.size() > 0) { %>
                <tfoot>
                    <tr class="fw-bold">
                        <td colspan="3" class="text-end">Totals</td>
                        <td class="text-end"><%= df3.format(sumGram) %></td>
                        <td colspan="2"></td>
                        <td class="text-end"><%= df3.format(sumTotal) %></td>
                        <td colspan="3"></td>
                    </tr>
                </tfoot>
                <% } %>
            </table>
        </div>
    </div>
</div>
</body>
</html>
