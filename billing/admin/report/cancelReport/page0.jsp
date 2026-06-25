<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
%>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cancel Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Cancel Report");
    request.setAttribute("pageSubtitle", "Admin — Gold Transaction Cancellations");
    request.setAttribute("pageIcon",     "fa-solid fa-ban");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <div class="d-flex flex-wrap gap-2 mb-3 no-print">
        <a href="<%=contextPath%>/admin/report/cancelReport/page.jsp" class="bb bb-outline">
            <i class="fa-solid fa-arrow-left me-1"></i>Back
        </a>
        <button class="bb bb-navy" onclick="printReport()">
            <i class="fa-solid fa-print me-1"></i>Print
        </button>
        <button class="bb bb-green" onclick="exportTableToExcel()">
            <i class="fa-solid fa-file-excel me-1"></i>Export Excel
        </button>
    </div>
    <div class="alert alert-info mb-3">
        <strong>Report Period:</strong> <%= fromDate %> to <%= toDate %>
    </div>

    <div class="table-responsive">
        <table id="cancelReportTable" class="table mst-table">
            <thead>
                <tr>
                    <th class="text-center">#</th>
                    <th>Type</th>
                    <th>Bill ID</th>
                    <th>Ledger ID</th>
                    <th>Customer</th>
                    <th class="text-end">Bill Amt</th>
                    <th class="text-end">In Amt</th>
                    <th class="text-end">Out Amt</th>
                    <th>Original Notes</th>
                    <th>Txn Date</th>
                    <th>Txn Time</th>
                    <th>Cancel Reason</th>
                    <th>Cancel Date</th>
                    <th>Cancel Time</th>
                    <th>Cancelled By</th>
                </tr>
            </thead>
            <tbody>
                <%
                Vector list = goldBean.getGoldTransactionCancelReport(fromDate, toDate);
                if (list != null && !list.isEmpty()) {
                    for (int i = 0; i < list.size(); i++) {
                        Vector row = (Vector) list.get(i);
                %>
                <tr>
                    <td class="text-center"><%= i + 1 %></td>
                    <td><%= row.elementAt(1) %></td>
                    <td><%= row.elementAt(2) %></td>
                    <td><%= row.elementAt(3) %></td>
                    <td><%= row.elementAt(4) %></td>
                    <td class="text-end"><%= row.elementAt(5) %></td>
                    <td class="text-end"><%= row.elementAt(6) %></td>
                    <td class="text-end"><%= row.elementAt(7) %></td>
                    <td><%= row.elementAt(8) %></td>
                    <td><%= row.elementAt(9) %></td>
                    <td><%= row.elementAt(10) %></td>
                    <td><%= row.elementAt(11) %></td>
                    <td><%= row.elementAt(12) %></td>
                    <td><%= row.elementAt(13) %></td>
                    <td><%= row.elementAt(14) %></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="15" class="text-center">No cancelled entries found for the selected period.</td>
                </tr>
                <%
                }
                %>
            </tbody>
        </table>
    </div>

    <% if (list != null && !list.isEmpty()) { %>
    <div class="alert alert-secondary mt-3">
        <strong>Total Records:</strong> <%= list.size() %>
    </div>
    <% } %>
</div>

<style>
@media print {
    @page { size: landscape; margin: 0.3cm; }
    body * { visibility: hidden; }
    #printArea, #printArea * { visibility: visible; }
    #printArea { position: absolute; left: 0; top: 0; width: 100%; }
    .no-print { display: none !important; }
    body { font-size: 8px; padding: 0; margin: 0; }
    table { font-size: 8px; width: 100%; border-collapse: collapse; }
    th, td { padding: 2px 3px; word-wrap: break-word; }
}
</style>

<script>
function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(function(response) { return response.text(); })
        .then(function(headerHtml) {
            var printArea = document.createElement('div');
            printArea.id = 'printArea';
            printArea.innerHTML = headerHtml;
            var container = document.querySelector('.mst-page').cloneNode(true);
            container.querySelectorAll('.no-print').forEach(function(el) { el.remove(); });
            printArea.appendChild(container);
            document.body.appendChild(printArea);
            window.print();
            document.body.removeChild(printArea);
        })
        .catch(function(err) {
            console.error(err);
            alert('Error loading print header');
        });
}

function exportTableToExcel() {
    var table = document.getElementById('cancelReportTable');
    var tableClone = table.cloneNode(true);
    var html = '<html><head><meta charset="utf-8"></head><body>' + tableClone.outerHTML + '</body></html>';
    var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
    var url = URL.createObjectURL(blob);
    var link = document.createElement('a');
    link.href = url;
    link.download = 'Gold_Cancel_Report.xls';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
}
</script>
</body>
</html>
