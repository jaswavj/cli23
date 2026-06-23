<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<jsp:useBean id="userBean" class="user.userBean" />
<%!
    private String csvCell(Object val) {
        String s = val == null ? "" : String.valueOf(val);
        s = s.replace("\r", " ").replace("\n", " ").replace("\"", "\"\"");
        return "\"" + s + "\"";
    }

    private String enc(String s) throws Exception {
        return URLEncoder.encode(s == null ? "" : s, "UTF-8");
    }
    
    private String formatDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return "";
        try {
            String[] parts = dateStr.split("-");
            if (parts.length == 3) {
                return parts[2] + "-" + parts[1] + "-" + parts[0];
            }
        } catch (Exception e) {}
        return dateStr;
    }
%>
<%
    String mode = request.getParameter("mode");
    if (mode == null || mode.trim().isEmpty()) mode = "dateCustomer";
    String download = request.getParameter("download");

    String fromDate = request.getParameter("fromDate");
    String toDate = request.getParameter("toDate");
    String customerName = request.getParameter("customerName");
    String searchBy = request.getParameter("searchBy");
    String searchText = request.getParameter("searchText");

    if ("dateCustomer".equals(mode)) {
        if (fromDate == null || fromDate.trim().isEmpty()) {
            java.time.LocalDate today = java.time.LocalDate.now();
            fromDate = today.withDayOfMonth(1).toString();
        }
        if (toDate == null || toDate.trim().isEmpty()) {
            toDate = java.time.LocalDate.now().toString();
        }
    }

    if (customerName == null) customerName = "";
    if (searchText == null) searchText = "";
    if (searchBy == null || searchBy.trim().isEmpty()) searchBy = "name";

    Vector rows;
    if ("customerOnly".equals(mode)) {
        rows = goldBean.getBillReport(null, null, searchText, searchBy, true);
    } else {
        rows = goldBean.getBillReport(fromDate, toDate, customerName, "name", false);
    }

    String csvHref;
    if ("customerOnly".equals(mode)) {
        csvHref = "?mode=customerOnly&searchBy=" + enc(searchBy) + "&searchText=" + enc(searchText) + "&download=csv";
    } else {
        csvHref = "?mode=dateCustomer&fromDate=" + enc(fromDate) + "&toDate=" + enc(toDate) + "&customerName=" + enc(customerName) + "&download=csv";
    }

    double totGross = 0, totMargin = 0, totNet = 0, totRelease = 0, totPaid = 0;
    for (int i = 0; i < rows.size(); i++) {
        Vector r = (Vector) rows.get(i);
        try { totGross += Double.parseDouble(String.valueOf(r.get(8))); } catch (Exception e) {}
        try { totMargin += Double.parseDouble(String.valueOf(r.get(9))); } catch (Exception e) {}
        try { totNet += Double.parseDouble(String.valueOf(r.get(10))); } catch (Exception e) {}
        try { totRelease += Double.parseDouble(String.valueOf(r.get(11))); } catch (Exception e) {}
        try { totPaid += Double.parseDouble(String.valueOf(r.get(12))); } catch (Exception e) {}
    }

    if ("csv".equalsIgnoreCase(download)) {
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=gold_bill_report.csv");
        StringBuilder csv = new StringBuilder();
        csv.append("Bill No,Bill Date,Bill Time,Cust ID,Customer Name,Phone,Gold Rate,Gross,Margin,Net,Release,Amount Paid,User\n");
        for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            String custId = r.get(4) == null || r.get(4).toString().trim().isEmpty() ? "" : "THIR-" + r.get(4);
            String userName = "";
            try {
                if (r.get(13) != null && !r.get(13).toString().trim().isEmpty()) {
                    userName = userBean.getUserName(Integer.parseInt(r.get(13).toString()));
                    if (userName == null) userName = r.get(13).toString();
                }
            } catch (Exception e) {
                userName = r.get(13) == null ? "" : r.get(13).toString();
            }
            csv.append(csvCell(r.get(1))).append(',')
               .append(csvCell(formatDate(String.valueOf(r.get(2))))).append(',')
               .append(csvCell(r.get(3))).append(',')
               .append(csvCell(custId)).append(',')
               .append(csvCell(r.get(5))).append(',')
               .append(csvCell(r.get(6))).append(',')
               .append(csvCell(r.get(7))).append(',')
               .append(csvCell(r.get(8))).append(',')
               .append(csvCell(r.get(9))).append(',')
               .append(csvCell(r.get(10))).append(',')
               .append(csvCell(r.get(11))).append(',')
               .append(csvCell(r.get(12))).append(',')
               .append(csvCell(userName)).append('\n');
        }
        csv.append(csvCell("TOTAL")).append(',')
           .append(csvCell(""))
           .append(',').append(csvCell(""))
           .append(',').append(csvCell(""))
           .append(',').append(csvCell(""))
           .append(',').append(csvCell(""))
           .append(',').append(csvCell(String.format("%.2f", totGross)))
           .append(',').append(csvCell(String.format("%.2f", totMargin)))
           .append(',').append(csvCell(String.format("%.2f", totNet)))
           .append(',').append(csvCell(String.format("%.2f", totRelease)))
           .append(',').append(csvCell(String.format("%.2f", totPaid)))
           .append(',').append(csvCell(""))
           .append('\n');
        out.print(csv.toString());
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Gold Bill Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .gbr-card { background:#fff; border-radius:.7rem; box-shadow:0 2px 10px rgba(0,0,0,.08); padding:16px; }
        .gbr-title { font-size:.85rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#1a2540; }
        .gbr-tabs .nav-link { font-weight:700; color:#4a607f; }
        .gbr-tabs .nav-link.active { color:#d4af37; border-bottom-color:#d4af37; }
        .gbr-table { width:100%; border-collapse:collapse; min-width:1200px; }
        .gbr-table th { background:#1a2540; color:#fff; font-size:.68rem; text-transform:uppercase; letter-spacing:.7px; padding:8px; border:1px solid #24365f; }
        .gbr-table td { padding:8px 10px; border:1px solid #ececec; font-size:.9rem; font-weight:600; color:#1a2540; }
        .gbr-table tbody tr:not(.total-row) { cursor: pointer; transition: background-color 0.2s; }
        .gbr-table tbody tr:not(.total-row):hover { background-color: #f8f9fa; }
        .num { text-align:right; font-variant-numeric:tabular-nums; }
        .muted { color:#888; }
        .total-row td { font-weight:700; background:#f8fafc; }
        .modal-header { background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%); color: white; }
        .modal-header .btn-close { filter: invert(1); }
        .bill-detail-label { font-weight: 600; color: #666; font-size: 0.8rem; text-transform: uppercase; margin-bottom: 2px; }
        .bill-detail-value { font-size: 0.95rem; color: #1a2540; margin-bottom: 12px; }
        .items-table { width: 100%; border-collapse: collapse; }
        .items-table th { background: #1a2540; color: white; padding: 8px; font-size: 0.75rem; text-align: left; }
        .items-table td { padding: 6px 8px; border: 1px solid #e0e0e0; font-size: 0.8rem; }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle", "Gold Bill Report");
    request.setAttribute("pageSubtitle", "Filter by bill date range and customer name/phone");
    request.setAttribute("pageIcon", "fa-solid fa-file-invoice");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page pb-4" style="max-width:1280px;">
    <div class="gbr-card mb-3">
        <ul class="nav nav-tabs gbr-tabs" id="billReportTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link <%= "dateCustomer".equals(mode) ? "active" : "" %>" id="date-customer-tab" data-bs-toggle="tab" data-bs-target="#date-customer-pane" type="button" role="tab" aria-controls="date-customer-pane" aria-selected="<%= "dateCustomer".equals(mode) ? "true" : "false" %>">By Date </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link <%= "customerOnly".equals(mode) ? "active" : "" %>" id="customer-only-tab" data-bs-toggle="tab" data-bs-target="#customer-only-pane" type="button" role="tab" aria-controls="customer-only-pane" aria-selected="<%= "customerOnly".equals(mode) ? "true" : "false" %>">By Customer</button>
            </li>
        </ul>

        <div class="tab-content pt-3" id="billReportTabsContent">
            <div class="tab-pane fade <%= "dateCustomer".equals(mode) ? "show active" : "" %>" id="date-customer-pane" role="tabpanel" aria-labelledby="date-customer-tab" tabindex="0">
                <form method="get" class="row g-2 align-items-end">
                    <input type="hidden" name="mode" value="dateCustomer">
                    <div class="col-md-3 col-sm-6 input-outline">
                        <input type="date" id="fromDate" name="fromDate" class="form-control" value="<%= fromDate %>">
                        <label>From Bill Date</label>
                    </div>
                    <div class="col-md-3 col-sm-6 input-outline">
                        <input type="date" id="toDate" name="toDate" class="form-control" value="<%= toDate %>">
                        <label>To Bill Date</label>
                    </div>
                    <div class="col-md-4 col-sm-12 input-outline">
                        <input type="text" id="customerName" name="customerName" class="form-control" value="<%= customerName %>" placeholder=" ">
                        <label>Customer Name</label>
                    </div>
                    <div class="col-md-2 col-sm-12">
                        <button class="btn btn-primary w-100" style="height:38px;">Run Report</button>
                    </div>
                </form>
            </div>

            <div class="tab-pane fade <%= "customerOnly".equals(mode) ? "show active" : "" %>" id="customer-only-pane" role="tabpanel" aria-labelledby="customer-only-tab" tabindex="0">
                <form method="get" class="row g-2 align-items-end">
                    <input type="hidden" name="mode" value="customerOnly">
                    <div class="col-md-3 col-sm-6 input-outline">
                        <select id="searchBy" name="searchBy" class="form-select">
                            <option value="name" <%= "name".equalsIgnoreCase(searchBy) ? "selected" : "" %>>Customer Name</option>
                            <option value="phone" <%= "phone".equalsIgnoreCase(searchBy) ? "selected" : "" %>>Phone Number</option>
                        </select>
                        <label>Filter By</label>
                    </div>
                    <div class="col-md-7 col-sm-12 input-outline">
                        <input type="text" id="searchText" name="searchText" class="form-control" value="<%= searchText %>" placeholder=" ">
                        <label>Customer (All Bills, No Date Filter)</label>
                    </div>
                    <div class="col-md-2 col-sm-12">
                        <button class="btn btn-success w-100" style="height:38px;">Run Report</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="gbr-card">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <div class="gbr-title mb-0"><i class="fa-solid fa-list me-2"></i>Bill Entries</div>
            <a href="<%= csvHref %>" class="btn btn-sm btn-outline-primary">
                <i class="fa-solid fa-file-csv me-1"></i>Download CSV
            </a>
        </div>
        <div style="overflow:auto;">
            <table class="gbr-table">
                <thead>
                    <tr>
                        <th>Print</th>
                        <th>Bill No</th>
                        <th>Bill Date</th>
                        <th>Bill Time</th>
                        <th>Cust ID</th>
                        <th>Customer Name</th>
                        <th>Phone</th>
                        <th>Gold Rate</th>
                        <th>Gross</th>
                        <th>Margin</th>
                        <th>Net</th>
                        <th>Release</th>
                        <th>Amount Paid</th>
                        <th>User</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (rows == null || rows.size() == 0) {
                %>
                    <tr>
                        <td colspan="14" class="muted" style="text-align:center; padding:18px;">No bills found for selected filters.</td>
                    </tr>
                <%
                    } else {
                        for (int i = 0; i < rows.size(); i++) {
                            Vector r = (Vector) rows.get(i);
                            String custId = r.get(4) == null || r.get(4).toString().trim().isEmpty() ? "" : "THIR-" + r.get(4);
                            String userName = "";
                            try {
                                if (r.get(13) != null && !r.get(13).toString().trim().isEmpty()) {
                                    userName = userBean.getUserName(Integer.parseInt(r.get(13).toString()));
                                    if (userName == null) userName = r.get(13).toString();
                                }
                            } catch (Exception e) {
                                userName = r.get(13) == null ? "" : r.get(13).toString();
                            }
                %>
                    <tr onclick="viewBillDetails(<%= r.get(0) %>)">
                        <td style="text-align:center;" onclick="event.stopPropagation();">
                            <a href="<%= request.getContextPath() %>/gold/goldBill/print.jsp?id=<%= r.get(0) %>" target="_blank" class="btn btn-sm btn-outline-primary">Print</a>
                        </td>
                        <td><%= r.get(1) %></td>
                        <td><%= formatDate(String.valueOf(r.get(2))) %></td>
                        <td><%= r.get(3) %></td>
                        <td><%= custId %></td>
                        <td><%= r.get(5) %></td>
                        <td><%= r.get(6) == null ? "" : r.get(6) %></td>
                        <td class="num"><%= r.get(7) %></td>
                        <td class="num"><%= r.get(8) %></td>
                        <td class="num"><%= r.get(9) %></td>
                        <td class="num"><%= r.get(10) %></td>
                        <td class="num"><%= r.get(11) %></td>
                        <td class="num"><%= r.get(12) %></td>
                        <td><%= userName %></td>
                    </tr>
                <%
                        }
                    }
                %>
                <tr class="total-row">
                    <td colspan="8" class="num">TOTAL</td>
                    <td class="num"><%= String.format("%.2f", totGross) %></td>
                    <td class="num"><%= String.format("%.2f", totMargin) %></td>
                    <td class="num"><%= String.format("%.2f", totNet) %></td>
                    <td class="num"><%= String.format("%.2f", totRelease) %></td>
                    <td class="num"><%= String.format("%.2f", totPaid) %></td>
                    <td colspan="2"></td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Bill Details Modal -->
<div class="modal fade" id="billDetailsModal" tabindex="-1" aria-labelledby="billDetailsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="billDetailsModalLabel"><i class="fa-solid fa-file-invoice me-2"></i>Bill Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="billDetailsContent">
                <div class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function viewBillDetails(billId) {
    const modal = new bootstrap.Modal(document.getElementById('billDetailsModal'));
    const content = document.getElementById('billDetailsContent');
    
    // Show loading
    content.innerHTML = `
        <div class="text-center py-4">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
        </div>
    `;
    
    modal.show();
    
    // Fetch bill details
    fetch('<%= request.getContextPath() %>/gold/report/getBillDetails.jsp?id=' + billId)
        .then(response => response.json())
        .then(data => {
            if (data.status === 'ok') {
                displayBillDetails(data.bill, data.items);
            } else {
                content.innerHTML = '<div class="alert alert-danger">Error: ' + data.message + '</div>';
            }
        })
        .catch(error => {
            content.innerHTML = '<div class="alert alert-danger">Failed to load bill details</div>';
            console.error('Error:', error);
        });
}

function displayBillDetails(bill, items) {
    const content = document.getElementById('billDetailsContent');
    
    let itemsHtml = '';
    if (items && items.length > 0) {
        itemsHtml = `
            <table class="items-table">
                <thead>
                    <tr>
                        <th>Ornament Type</th>
                        <th>Gross Wt</th>
                        <th>Stone/Wax</th>
                        <th>Net Wt</th>
                        <th>Purity</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
        `;
        items.forEach(item => {
            itemsHtml += `
                <tr>
                    <td>${item.ornament_type}</td>
                    <td>${item.gross_wt}</td>
                    <td>${item.stone_wax}</td>
                    <td>${item.net_wt}</td>
                    <td>${item.purity}</td>
                    <td>₹${parseFloat(item.gross_amount).toFixed(2)}</td>
                </tr>
            `;
        });
        itemsHtml += `
                </tbody>
            </table>
        `;
    } else {
        itemsHtml = '<div class="alert alert-info">No items found</div>';
    }
    
    content.innerHTML = `
        <div class="row mb-3">
            <div class="col-md-6">
                <div class="bill-detail-label">Bill No</div>
                <div class="bill-detail-value">${bill.bill_no}</div>
            </div>
            <div class="col-md-6">
                <div class="bill-detail-label">Bill Date & Time</div>
                <div class="bill-detail-value">${formatDisplayDate(bill.bill_date)} ${bill.bill_time}</div>
            </div>
        </div>
        
        <div class="row mb-3">
            <div class="col-md-6">
                <div class="bill-detail-label">Customer ID</div>
                <div class="bill-detail-value">THIR-${bill.customer_id}</div>
            </div>
            <div class="col-md-6">
                <div class="bill-detail-label">Customer Name</div>
                <div class="bill-detail-value">${bill.customer_name}</div>
            </div>
        </div>
        
        <div class="row mb-3">
            <div class="col-md-6">
                <div class="bill-detail-label">Phone</div>
                <div class="bill-detail-value">${bill.customer_phone}</div>
            </div>
            <div class="col-md-6">
                <div class="bill-detail-label">Gold Rate</div>
                <div class="bill-detail-value">₹${parseFloat(bill.gold_rate).toFixed(2)}</div>
            </div>
        </div>
        
        <div class="row mb-3">
            <div class="col-md-6">
                <div class="bill-detail-label">ID Proof No</div>
                <div class="bill-detail-value">${bill.id_proof_no || '-'}</div>
            </div>
            <div class="col-md-6">
                <div class="bill-detail-label">Address Proof No</div>
                <div class="bill-detail-value">${bill.addr_proof_no || '-'}</div>
            </div>
        </div>
        
        <hr class="my-3">
        
        <h6 class="mb-3"><i class="fa-solid fa-gem me-2"></i>Ornaments</h6>
        ${itemsHtml}
        
        <hr class="my-3">
        
        <div class="row">
            <div class="col-md-6">
                <div class="bill-detail-label">Gross Amount</div>
                <div class="bill-detail-value">₹${parseFloat(bill.gross_amount).toFixed(2)}</div>
            </div>
            <div class="col-md-6">
                <div class="bill-detail-label">Margin</div>
                <div class="bill-detail-value">₹${parseFloat(bill.margin).toFixed(2)}</div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="bill-detail-label">Net Amount</div>
                <div class="bill-detail-value" style="font-size:1.1rem; color:#d4af37; font-weight:700;">₹${parseFloat(bill.net_amount).toFixed(2)}</div>
            </div>
            <div class="col-md-6">
                <div class="bill-detail-label">Release Amount</div>
                <div class="bill-detail-value">₹${parseFloat(bill.release_amount).toFixed(2)}</div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="bill-detail-label">Amount Paid</div>
                <div class="bill-detail-value" style="font-size:1.1rem; color:#28a745; font-weight:700;">₹${parseFloat(bill.amount_paid).toFixed(2)}</div>
            </div>
        </div>
    `;
}

function formatDisplayDate(dateStr) {
    if (!dateStr) return '';
    try {
        const parts = dateStr.split('-');
        if (parts.length === 3) {
            return parts[2] + '-' + parts[1] + '-' + parts[0];
        }
    } catch (e) {}
    return dateStr;
}
</script>

</body>
</html>
