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
    String fromDate = request.getParameter("fromDate");
    String toDate = request.getParameter("toDate");
    String cidParam = request.getParameter("customerId");
    String download = request.getParameter("download");
    int customerId = 0;
    try { customerId = Integer.parseInt(cidParam); } catch (Exception e) {}

    if (fromDate == null || fromDate.trim().isEmpty()) {
        fromDate = java.time.LocalDate.now().toString();
    }
    if (toDate == null || toDate.trim().isEmpty()) {
        toDate = java.time.LocalDate.now().toString();
    }

    Vector rows = goldBean.getLedgerReport(fromDate, toDate, customerId);
    String csvHref = "?fromDate=" + enc(fromDate) + "&toDate=" + enc(toDate) + "&customerId=" + customerId + "&download=csv";
    
    // Get opening balance from is_open_balance_entry=1 records
    double openingBal = goldBean.getOpeningBalance(fromDate, toDate, customerId);
    
    // Calculate summary and running balances
    double totalIn = 0, totalOut = 0, closingBal = 0;
    double runningBalance = 0;
    
    if (rows != null && rows.size() > 0) {
        // First pass: calculate summary
        for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            String type = r.get(6) == null ? "" : r.get(6).toString();
            double amt = 0;
            try { amt = Double.parseDouble(String.valueOf(r.get(8))); } catch (Exception e) {}
            
            if ("OPENING".equals(type)) {
                totalIn += amt;
                runningBalance += amt;
            } else {
                totalOut += amt;
                runningBalance -= amt;
            }
        }
        closingBal = runningBalance;
    }
    
    // Reset running balance for display
    runningBalance = 0;

    if ("csv".equalsIgnoreCase(download)) {
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=gold_ledger_report.csv");
        StringBuilder csv = new StringBuilder();
        csv.append("Date/Time,Content,Opening,In,Out,Closing,User\n");
        double csvRunning = 0;
        for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            String dateTime = formatDate(String.valueOf(r.get(1))) + " " + r.get(2);
            String content = "Bill #" + (r.get(5) == null ? "-" : r.get(5)) + " - " + r.get(4);
            String type = r.get(6) == null ? "" : r.get(6).toString();
            double amt = 0;
            try { amt = Double.parseDouble(String.valueOf(r.get(8))); } catch (Exception e) {}
            
            double csvOpening = csvRunning;
            String csvIn = "";
            String csvOut = "";
            double csvClosing = 0;
            
            if ("OPENING".equals(type)) {
                csvIn = String.format("%.2f", amt);
                csvClosing = csvOpening + amt;
                csvRunning = csvClosing;
            } else {
                csvOut = String.format("%.2f", amt);
                csvClosing = csvOpening - amt;
                csvRunning = csvClosing;
            }
            
            String userName = "";
            try {
                if (r.get(10) != null && !r.get(10).toString().trim().isEmpty()) {
                    userName = userBean.getUserName(Integer.parseInt(r.get(10).toString()));
                    if (userName == null) userName = r.get(10).toString();
                }
            } catch (Exception e) {
                userName = r.get(10) == null ? "" : r.get(10).toString();
            }
            
            csv.append(csvCell(dateTime)).append(',')
               .append(csvCell(content)).append(',')
               .append(csvCell(String.format("%.2f", csvOpening))).append(',')
               .append(csvCell(csvIn)).append(',')
               .append(csvCell(csvOut)).append(',')
               .append(csvCell(String.format("%.2f", csvClosing))).append(',')
               .append(csvCell(userName)).append('\n');
        }
        out.print(csv.toString());
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Gold Ledger Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .glr-card { background:#fff; border-radius:.7rem; box-shadow:0 2px 10px rgba(0,0,0,.08); padding:16px; }
        .glr-title { font-size:.85rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#1a2540; }
        .glr-table { width:100%; border-collapse:collapse; min-width:960px; }
        .glr-table th { background:#1a2540; color:#fff; font-size:.68rem; text-transform:uppercase; letter-spacing:.7px; padding:8px; border:1px solid #24365f; }
        .glr-table td { padding:8px 10px; border:1px solid #ececec; font-size:.9rem; font-weight:600; color:#1a2540; }
        .num { text-align:right; font-variant-numeric:tabular-nums; }
        .muted { color:#888; }
        .summary-card { background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%); border-radius: .7rem; padding: 20px; color: white; margin-bottom: 16px; }
        .summary-item { text-align: center; }
        .summary-label { font-size: .7rem; text-transform: uppercase; letter-spacing: 1px; opacity: 0.8; margin-bottom: 5px; }
        .summary-value { font-size: 1.3rem; font-weight: 700; color: #d4af37; }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle", "Gold Ledger Report");
    request.setAttribute("pageSubtitle", "Opening, debit/credit and closing balances");
    request.setAttribute("pageIcon", "fa-solid fa-book");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page pb-4" style="max-width:1200px;">
    <div class="glr-card mb-3">
        <form method="get" class="row g-2 align-items-end">
            <div class="col-md-3 col-sm-6 input-outline">
                <input type="date" id="fromDate" name="fromDate" class="form-control" value="<%= fromDate %>">
                <label>From Date</label>
            </div>
            <div class="col-md-3 col-sm-6 input-outline">
                <input type="date" id="toDate" name="toDate" class="form-control" value="<%= toDate %>">
                <label>To Date</label>
            </div>
            <div class="col-md-3 col-sm-6 input-outline">
                <input type="number" id="customerId" name="customerId" class="form-control" value="<%= customerId > 0 ? customerId : "" %>" placeholder=" ">
                <label>Customer ID (optional)</label>
            </div>
            <div class="col-md-3 col-sm-6">
                <button class="btn btn-primary w-100" style="height:38px;">Filter</button>
            </div>
        </form>
    </div>

    <% if (rows != null && rows.size() > 0) { %>
    <div class="summary-card">
        <div class="row">
            <div class="col-md-3 col-6 summary-item">
                <div class="summary-label">Opening Balance</div>
                <div class="summary-value">₹<%= String.format("%.2f", openingBal) %></div>
            </div>
            <div class="col-md-3 col-6 summary-item">
                <div class="summary-label">Total In</div>
                <div class="summary-value" style="color:#4ade80;">₹<%= String.format("%.2f", totalIn) %></div>
            </div>
            <div class="col-md-3 col-6 summary-item">
                <div class="summary-label">Total Out</div>
                <div class="summary-value" style="color:#fb7185;">₹<%= String.format("%.2f", totalOut) %></div>
            </div>
            <div class="col-md-3 col-6 summary-item">
                <div class="summary-label">Closing Balance</div>
                <div class="summary-value">₹<%= String.format("%.2f", closingBal) %></div>
            </div>
        </div>
    </div>
    <% } %>
    
    <div class="glr-card">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <div class="glr-title mb-0"><i class="fa-solid fa-list me-2"></i>Ledger Entries</div>
            <a href="<%= csvHref %>" class="btn btn-sm btn-outline-primary">
                <i class="fa-solid fa-file-csv me-1"></i>Download CSV
            </a>
        </div>
        <div style="overflow:auto;">
            <table class="glr-table">
                <thead>
                    <tr>
                        <th>Date/Time</th>
                        <th>Content</th>
                        <th>Opening Balance</th>
                        <th>In</th>
                        <th>Out</th>
                        <th>Closing Balance</th>
                        <th>User</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (rows == null || rows.size() == 0) {
                %>
                    <tr>
                        <td colspan="7" class="muted" style="text-align:center; padding:18px;">No ledger entries found for selected filter.</td>
                    </tr>
                <%
                    } else {
                        for (int i = 0; i < rows.size(); i++) {
                            Vector r = (Vector) rows.get(i);
                            String dateTime = formatDate(String.valueOf(r.get(1))) + " " + r.get(2);
                            String content = "Bill #" + (r.get(5) == null ? "-" : r.get(5)) + " - " + r.get(4);
                            String type = r.get(6) == null ? "" : r.get(6).toString();
                            double amt = 0;
                            try { amt = Double.parseDouble(String.valueOf(r.get(8))); } catch (Exception e) {}
                            
                            // Calculate opening balance for this row
                            double rowOpening = runningBalance;
                            
                            // Calculate IN/OUT based on transaction type
                            String inAmt = "";
                            String outAmt = "";
                            double rowClosing = 0;
                            
                            if ("OPENING".equals(type)) {
                                inAmt = String.format("%.2f", amt);
                                rowClosing = rowOpening + amt;
                                runningBalance = rowClosing;
                            } else {
                                outAmt = String.format("%.2f", amt);
                                rowClosing = rowOpening - amt;
                                runningBalance = rowClosing;
                            }
                            
                            String userName = "";
                            try {
                                if (r.get(10) != null && !r.get(10).toString().trim().isEmpty()) {
                                    userName = userBean.getUserName(Integer.parseInt(r.get(10).toString()));
                                    if (userName == null) userName = r.get(10).toString();
                                }
                            } catch (Exception e) {
                                userName = r.get(10) == null ? "" : r.get(10).toString();
                            }
                %>
                    <tr>
                        <td><%= dateTime %></td>
                        <td><%= content %></td>
                        <td class="num">₹<%= String.format("%.2f", rowOpening) %></td>
                        <td class="num" style="color:#22c55e;"><%= inAmt.isEmpty() ? "" : "₹" + inAmt %></td>
                        <td class="num" style="color:#ef4444;"><%= outAmt.isEmpty() ? "" : "₹" + outAmt %></td>
                        <td class="num">₹<%= String.format("%.2f", rowClosing) %></td>
                        <td><%= userName %></td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
