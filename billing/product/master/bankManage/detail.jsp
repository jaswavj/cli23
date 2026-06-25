<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
int bankId = 0;
try { bankId = Integer.parseInt(request.getParameter("bankId")); } catch (Exception ex) { }
if (bankId <= 0) {
    response.sendRedirect(request.getContextPath() + "/product/master/bankManage/page.jsp");
    return;
}

Vector bank = prod.getConfigureBankDetailById(bankId);
if (bank == null || bank.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/product/master/bankManage/page.jsp");
    return;
}

String bankName = bank.elementAt(0).toString();
String bankBalance = bank.elementAt(2).toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%=bankName%> - Bank Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .balance-card {
            background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
            color: #fff;
            border: none;
            border-radius: 12px;
        }
        .balance-card .balance-label { opacity: 0.85; font-size: 0.95rem; }
        .balance-card .balance-value { font-size: 2rem; font-weight: 700; letter-spacing: 0.5px; }
        .action-btns .bb { min-width: 140px; }
        .table td, .table th { vertical-align: middle; }
        .amount-in { color: #0f766e; font-weight: 600; }
        .amount-out { color: #b91c1c; font-weight: 600; }
        .amount-run { color: #1e3a8a; font-weight: 700; }
        .filter-row { display: flex; flex-wrap: wrap; gap: 12px; align-items: end; margin-bottom: 16px; }
        .filter-row label { font-size: 0.85rem; font-weight: 600; margin-bottom: 4px; display: block; }
        .filter-row input[type="date"] { height: 38px; border: 1px solid #c8d8d6; border-radius: 8px; padding: 0 10px; min-width: 160px; }
        .period-summary { display: flex; flex-wrap: wrap; gap: 16px; margin-bottom: 12px; font-size: 0.92rem; }
        .period-summary span { background: #f0fdfa; border: 1px solid #99f6e4; border-radius: 8px; padding: 6px 12px; }
        .back-link { text-decoration: none; color: #0f766e; font-weight: 600; }
        .back-link:hover { text-decoration: underline; }
        @media (max-width: 768px) {
            .action-btns .bb { width: 100%; margin-bottom: 0.5rem; }
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    bankName);
    request.setAttribute("pageSubtitle", "Bank Management");
    request.setAttribute("pageIcon",     "fa-solid fa-building-columns");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page" style="max-width: 1400px;">
        <div class="mb-3">
            <a href="<%=contextPath%>/product/master/bankManage/page.jsp" class="back-link">
                <i class="fa-solid fa-arrow-left"></i> Change Bank
            </a>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-5 col-lg-4">
                <div class="card balance-card h-100">
                    <div class="card-body p-4">
                        <div class="balance-label mb-1">Current Balance</div>
                        <div class="balance-value" id="bankBalanceDisplay"><%=bankBalance%></div>
                        <div class="mt-2 opacity-75"><%=bankName%></div>
                    </div>
                </div>
            </div>
            <div class="col-md-7 col-lg-8">
                <div class="card h-100">
                    <div class="card-body p-4">
                        <h5 class="mb-3">Adjust Balance</h5>
                        <div class="action-btns d-flex flex-wrap gap-2">
                            <button type="button" class="bb bb-primary" onclick="openAdjustModal('add')">
                                <i class="fa-solid fa-plus"></i> Add Money
                            </button>
                            <button type="button" class="bb bb-outline" onclick="openAdjustModal('remove')">
                                <i class="fa-solid fa-minus"></i> Remove Money
                            </button>
                        </div>
                        <p class="text-muted small mt-3 mb-0">
                            Use add/remove for cash deposits or withdrawals not linked to a gold bill.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                    <h5 class="mb-0">Bank Transactions</h5>
                    <button type="button" class="bb bb-outline btn-sm" onclick="loadLedger()">
                        <i class="fa-solid fa-rotate"></i> Refresh
                    </button>
                </div>

                <div class="filter-row">
                    <div>
                        <label for="fromDate">From Date</label>
                        <input id="fromDate" type="date">
                    </div>
                    <div>
                        <label for="toDate">To Date</label>
                        <input id="toDate" type="date">
                    </div>
                    <div>
                        <button type="button" class="bb bb-primary" onclick="loadLedger()">Load</button>
                    </div>
                </div>

                <div class="period-summary" id="periodSummary" style="display:none;"></div>

                <div class="table-responsive">
                    <table class="table table-hover mb-0 mst-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Date &amp; Time</th>
                                <th>Reference</th>
                                <th>Notes</th>
                                <th class="text-end">In</th>
                                <th class="text-end">Out</th>
                                <th class="text-end">Running Balance</th>
                                <th>User</th>
                            </tr>
                        </thead>
                        <tbody id="ledgerBody">
                            <tr><td colspan="8" class="text-center text-muted py-4">Loading...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        var contextPath = "<%=contextPath%>";
        var bankId = <%=bankId%>;

        function formatMoney(val) {
            var n = parseFloat(val);
            if (isNaN(n)) return "0.00";
            return n.toFixed(2);
        }

        function formatDateTime(raw) {
            if (!raw) return "";
            var s = String(raw).trim();
            var m = s.match(/^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}:\d{2}(?::\d{2})?))?/);
            if (!m) return s;
            return m[3] + "-" + m[2] + "-" + m[1] + (m[4] ? " " + m[4] : "");
        }

        function referenceLabel(billId, notes) {
            var bid = parseInt(billId, 10);
            if (!isNaN(bid) && bid > 0) {
                return "Bill #" + bid;
            }
            return "Manual";
        }

        function setDefaultDates() {
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = String(today.getMonth() + 1).padStart(2, "0");
            var dd = String(today.getDate()).padStart(2, "0");
            var todayStr = yyyy + "-" + mm + "-" + dd;
            var firstStr = yyyy + "-" + mm + "-01";
            document.getElementById("fromDate").value = firstStr;
            document.getElementById("toDate").value = todayStr;
        }

        function loadLedger() {
            var fromDate = (document.getElementById("fromDate").value || "").trim();
            var toDate = (document.getElementById("toDate").value || "").trim();
            if (fromDate && toDate && fromDate > toDate) {
                Swal.fire("Error", "From date cannot be after To date", "error");
                return;
            }

            var url = contextPath + "/product/master/bankManage/getData.jsp?mode=detail&bankId=" + bankId;
            if (fromDate) url += "&fromDate=" + encodeURIComponent(fromDate);
            if (toDate) url += "&toDate=" + encodeURIComponent(toDate);

            fetch(url, { credentials: "same-origin" })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success) {
                    throw new Error(data && data.message ? data.message : "Unable to load transactions");
                }
                document.getElementById("bankBalanceDisplay").textContent = formatMoney(data.balance);
                renderPeriodSummary(data.totals || {}, fromDate, toDate);
                renderLedger(data.rows || []);
            })
            .catch(function(err) {
                Swal.fire("Error", err.message || "Unable to load transactions", "error");
            });
        }

        function renderPeriodSummary(totals, fromDate, toDate) {
            var wrap = document.getElementById("periodSummary");
            if (!fromDate && !toDate) {
                wrap.style.display = "none";
                wrap.innerHTML = "";
                return;
            }
            wrap.style.display = "flex";
            wrap.innerHTML =
                "<span><strong>Opening:</strong> " + formatMoney(totals.openingBalance) + "</span>" +
                "<span><strong>Total In:</strong> " + formatMoney(totals.periodIn) + "</span>" +
                "<span><strong>Total Out:</strong> " + formatMoney(totals.periodOut) + "</span>" +
                "<span><strong>Closing:</strong> " + formatMoney(totals.closingBalance) + "</span>";
        }

        function renderLedger(rows) {
            var tbody = document.getElementById("ledgerBody");
            if (!rows.length) {
                tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted py-4">No transactions found</td></tr>';
                return;
            }
            var html = "";
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var inAmt = parseFloat(row.inAmount || 0);
                var outAmt = parseFloat(row.outAmount || 0);
                html += "<tr>";
                html += "<td>" + (i + 1) + "</td>";
                html += "<td>" + formatDateTime(row.dateTime) + "</td>";
                html += "<td>" + referenceLabel(row.billId, row.notes) + "</td>";
                html += "<td>" + (row.notes || "") + "</td>";
                html += "<td class=\"text-end amount-in\">" + (inAmt > 0 ? formatMoney(inAmt) : "-") + "</td>";
                html += "<td class=\"text-end amount-out\">" + (outAmt > 0 ? formatMoney(outAmt) : "-") + "</td>";
                html += "<td class=\"text-end amount-run\">" + formatMoney(row.runningBalance) + "</td>";
                html += "<td>" + (row.userName || "") + "</td>";
                html += "</tr>";
            }
            tbody.innerHTML = html;
        }

        function openAdjustModal(action) {
            var isAdd = action === "add";
            Swal.fire({
                title: isAdd ? "Add Money" : "Remove Money",
                html:
                    "<div style='text-align:left;'>" +
                    "<label style='display:block;margin-bottom:6px;font-weight:600;'>Amount</label>" +
                    "<input id='adjAmount' type='number' min='0.01' step='0.01' class='swal2-input' placeholder='Enter amount' style='width:100%;margin:0 0 12px;' />" +
                    "<label style='display:block;margin-bottom:6px;font-weight:600;'>Notes (optional)</label>" +
                    "<input id='adjNotes' type='text' class='swal2-input' placeholder='Reason / reference' style='width:100%;margin:0;' />" +
                    "</div>",
                showCancelButton: true,
                confirmButtonText: isAdd ? "Add Money" : "Remove Money",
                confirmButtonColor: isAdd ? "#0f766e" : "#b91c1c",
                focusConfirm: false,
                preConfirm: function() {
                    var amount = parseFloat(document.getElementById("adjAmount").value);
                    if (isNaN(amount) || amount <= 0) {
                        Swal.showValidationMessage("Enter valid amount");
                        return false;
                    }
                    return {
                        amount: amount,
                        notes: document.getElementById("adjNotes").value || ""
                    };
                }
            }).then(function(result) {
                if (!result.isConfirmed) return;
                saveAdjust(action, result.value.amount, result.value.notes);
            });
        }

        function saveAdjust(action, amount, notes) {
            var body = new URLSearchParams();
            body.append("mode", "adjust");
            body.append("bankId", String(bankId));
            body.append("action", action);
            body.append("amount", String(amount));
            body.append("notes", notes);

            fetch(contextPath + "/product/master/bankManage/getData.jsp", {
                method: "POST",
                credentials: "same-origin",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: body.toString()
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success) {
                    throw new Error(data && data.message ? data.message : "Unable to update balance");
                }
                Swal.fire("Success", data.message || "Updated", "success");
                loadLedger();
            })
            .catch(function(err) {
                Swal.fire("Error", err.message || "Unable to update balance", "error");
            });
        }

        window.addEventListener("load", function() {
            setDefaultDates();
            loadLedger();
        });

        document.getElementById("fromDate").addEventListener("change", loadLedger);
        document.getElementById("toDate").addEventListener("change", loadLedger);
    </script>
</body>
</html>
