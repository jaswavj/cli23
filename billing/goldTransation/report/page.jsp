<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Gold Transaction Customer Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        :root {
            --gr-primary: #153c3c;
            --gr-primary-2: #1f5a58;
            --gr-accent: #d8b24a;
            --gr-bg: #f3f7f6;
            --gr-card: #ffffff;
            --gr-text: #1d2828;
            --gr-muted: #6b7b7b;
        }

        body {
            background: var(--gr-bg);
        }

        .gr-page {
            max-width: 1300px;
            font-family: "Trebuchet MS", "Gill Sans", "Noto Sans", sans-serif;
        }

        .gr-card {
            background: var(--gr-card);
            border-radius: 12px;
            padding: 14px;
            box-shadow: 0 4px 14px rgba(21, 60, 60, 0.09);
            margin-bottom: 14px;
        }

        .gr-title {
            margin: 0 0 12px;
            font-size: 0.95rem;
            letter-spacing: 0.6px;
            font-weight: 700;
            color: var(--gr-primary);
            text-transform: uppercase;
        }

        .gr-kpi-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 12px;
        }

        .gr-kpi {
            border-radius: 12px;
            padding: 12px;
            border: 1px solid #d8e4e2;
            background: linear-gradient(140deg, #f8fbfa, #eef5f4);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.45);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .gr-kpi:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(21, 60, 60, 0.08);
        }

        .gr-kpi-stock {
            background: linear-gradient(135deg, #edf6f2, #e4f0eb);
            border-color: #c8ddd4;
        }

        .gr-kpi-stock .gr-kpi-value {
            color: #1a5a4a;
        }

        .gr-kpi-credit {
            background: linear-gradient(135deg, #f7f1e8, #efe4d4);
            border-color: #dfcfb8;
        }

        .gr-kpi-credit .gr-kpi-value {
            color: #62471f;
        }

        .gr-kpi-due {
            background: linear-gradient(135deg, #eef2f9, #e2e9f5);
            border-color: #c8d4e7;
        }

        .gr-kpi-due .gr-kpi-value {
            color: #24466f;
        }

        .gr-kpi-label {
            font-size: 0.74rem;
            letter-spacing: 0.7px;
            text-transform: uppercase;
            color: #5f7474;
            font-weight: 700;
        }

        .gr-kpi-value {
            margin-top: 6px;
            font-size: 1.35rem;
            font-weight: 800;
            color: #1e3f3f;
        }

        .gr-kpi-note {
            margin-top: 3px;
            font-size: 0.75rem;
            color: #6b7d7d;
        }

        .gr-form-label {
            font-size: 0.74rem;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--gr-muted);
            margin-bottom: 5px;
            font-weight: 700;
        }

        .gr-input {
            height: 42px;
            border: 1.5px solid #d7e2e0;
            border-radius: 10px;
            padding: 0 12px;
            font-size: 0.92rem;
            color: var(--gr-text);
            background: #fff;
            width: 100%;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .gr-input:focus {
            border-color: var(--gr-accent);
            box-shadow: 0 0 0 3px rgba(216, 178, 74, 0.2);
        }

        .gr-btn {
            border: none;
            border-radius: 10px;
            height: 42px;
            padding: 0 18px;
            font-size: 0.85rem;
            font-weight: 700;
            color: #fff;
            background: linear-gradient(135deg, var(--gr-primary), var(--gr-primary-2));
            width: 100%;
        }

        .gr-meta {
            color: #4c6262;
            font-size: 0.84rem;
            margin-top: 8px;
        }

        .gr-tabs {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 0;
            margin-bottom: 10px;
            border-bottom: 1px solid #d7e2ea;
        }

        .gr-tab {
            border: 1px solid transparent;
            border-bottom: none;
            background: transparent;
            color: #2f4e79;
            padding: 10px 14px;
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
            font-size: 0.86rem;
            font-weight: 700;
            letter-spacing: 0.2px;
            margin-bottom: -1px;
            width: 100%;
            text-align: center;
            white-space: nowrap;
        }

        .gr-tab.active {
            border-color: #c9d8e8;
            background: linear-gradient(180deg, #f7fbff, #eef4fb);
            color: #1f4f89;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
        }

        .gr-subtabs {
            display: flex;
            gap: 0;
            flex-wrap: wrap;
            margin: -2px 0 12px;
            border-bottom: 1px solid #d7e2ea;
        }

        .gr-subtab {
            border: 1px solid transparent;
            border-bottom: none;
            background: transparent;
            color: #3e5f89;
            padding: 8px 12px;
            border-top-left-radius: 9px;
            border-top-right-radius: 9px;
            font-size: 0.8rem;
            font-weight: 700;
            letter-spacing: 0.2px;
            margin-bottom: -1px;
        }

        .gr-subtab.active {
            border-color: #c9d8e8;
            background: linear-gradient(180deg, #f7fbff, #eef4fb);
            color: #1f4f89;
        }

        .gr-credit-tools {
            display: flex;
            justify-content: flex-end;
            align-items: end;
            margin: 0 0 10px;
        }

        .gr-credit-tools .gr-form-label {
            margin-bottom: 4px;
        }

        .gr-credit-tools .gr-input {
            width: 230px;
        }

        .gr-table-wrap {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        .gr-table {
            width: 100%;
            min-width: 100%;
            border-collapse: collapse;
        }

        .gr-table.gr-table-wide {
            min-width: 1080px;
        }

        .gr-table.gr-table-medium {
            min-width: 760px;
        }

        .gr-table thead th {
            background: #f0f5f4;
            color: #334444;
            font-size: 0.72rem;
            letter-spacing: 0.6px;
            text-transform: uppercase;
            padding: 10px 8px;
            border-bottom: 1px solid #dce6e4;
            white-space: nowrap;
            position: sticky;
            top: 0;
        }

        .gr-table tbody td,
        .gr-table tfoot td {
            padding: 9px 8px;
            border-bottom: 1px solid #edf2f1;
            font-size: 0.88rem;
            color: #2e3f3f;
            white-space: nowrap;
        }

        .gr-table tfoot td {
            background: #f8fbfa;
            font-weight: 700;
            border-bottom: none;
        }

        .gr-right {
            text-align: right;
        }

        .gr-empty {
            padding: 20px;
            text-align: center;
            color: #637777;
            font-size: 0.9rem;
        }

        .gr-credit-row {
            cursor: pointer;
        }

        .gr-credit-row:hover td {
            background: #f7fbff;
        }

        @media (max-width: 900px) {
            .gr-kpi-grid {
                grid-template-columns: 1fr;
            }

            .gr-tabs {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 560px) {
            .gr-tabs {
                grid-template-columns: 1fr;
            }

            .gr-credit-tools {
                justify-content: stretch;
            }

            .gr-credit-tools .gr-input {
                width: 100%;
            }
        }
    </style>
</head>
<body>

<%@ include file="/assets/navbar/navbar.jsp" %>

<%
    request.setAttribute("pageTitle", "Gold Transaction Customer Report");
    request.setAttribute("pageSubtitle", "Date-wise customer paid split, balances, purchase TM and sale TM");
    request.setAttribute("pageIcon", "fa-solid fa-chart-column");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page gr-page">
    <div class="gr-card">
        <h6 class="gr-title"><i class="fa-solid fa-chart-pie me-2"></i>Overall Summary (No Date Filter)</h6>
        <div class="gr-kpi-grid">
            <div class="gr-kpi gr-kpi-stock">
                <div class="gr-kpi-label">Current Stock</div>
                <div class="gr-kpi-value" id="cardCurrentStock">0.000</div>
                <div class="gr-kpi-note">TM</div>
            </div>
            <div class="gr-kpi gr-kpi-credit">
                <div class="gr-kpi-label">Total Credit You Owe Customers</div>
                <div class="gr-kpi-value" id="cardTotalCredit">0.00</div>
                <div class="gr-kpi-note">Based on customer advances</div>
            </div>
            <div class="gr-kpi gr-kpi-due">
                <div class="gr-kpi-label">Total Amount Customers Owe You</div>
                <div class="gr-kpi-value" id="cardCustomerDue">0.00</div>
                <div class="gr-kpi-note">Based on customer dues</div>
            </div>
        </div>
    </div>

    <div class="gr-card">
        <h6 class="gr-title"><i class="fa-solid fa-calendar-days me-2"></i>Filters</h6>
        <div class="row g-3 align-items-end">
            <div class="col-12 col-md-4 col-lg-3">
                <label class="gr-form-label">From Date</label>
                <input id="fromDate" type="date" class="gr-input">
            </div>
            <div class="col-12 col-md-4 col-lg-3">
                <label class="gr-form-label">To Date</label>
                <input id="toDate" type="date" class="gr-input">
            </div>
            <div class="col-12 col-md-3 col-lg-2">
                <button id="btnLoad" type="button" class="gr-btn">Load Report</button>
            </div>
            <div class="col-12 col-md-9 col-lg-4">
                <div class="gr-meta" id="reportMeta">Credit list loads without date filter.</div>
            </div>
        </div>
    </div>

    <div class="gr-card">
        <div class="gr-tabs" id="reportTabs">
            <button type="button" class="gr-tab active" data-type="creditList">Credit List</button>
            <button type="button" class="gr-tab" data-type="transaction">Transaction</button>
            <button type="button" class="gr-tab" data-type="openClosing">Open/Closing Balance</button>
            <button type="button" class="gr-tab" data-type="stockTxn">Stock Transaction List</button>
            <button type="button" class="gr-tab" data-type="currentStock">Current Stock</button>
        </div>
        <div class="gr-credit-tools" id="creditScopeWrap">
            <div>
                <label class="gr-form-label">Credit Filter</label>
                <select id="creditScope" class="gr-input">
                    <option value="credit_only">Credit Customers Only</option>
                    <option value="all_customers">All Customers</option>
                </select>
            </div>
        </div>
        <div class="gr-table-wrap">
            <table class="gr-table" id="reportTable">
                <thead id="reportHead"></thead>
                <tbody id="reportBody">
                    <tr><td colspan="10" class="gr-empty">Choose date and load report.</td></tr>
                </tbody>
                <tfoot id="reportFoot"></tfoot>
            </table>
        </div>
        <div id="txnPaidSplitWrap" style="display:none;margin-top:12px;">
            <h6 class="gr-title"><i class="fa-solid fa-wallet me-2"></i>Customer-wise Cash / GPay Paid</h6>
            <div class="gr-table-wrap">
                <table class="gr-table gr-table-medium" id="txnPaidSplitTable">
                    <thead id="txnPaidSplitHead"></thead>
                    <tbody id="txnPaidSplitBody"></tbody>
                    <tfoot id="txnPaidSplitFoot"></tfoot>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    "use strict";

    var el = {
        fromDate: document.getElementById("fromDate"),
        toDate: document.getElementById("toDate"),
        creditScopeWrap: document.getElementById("creditScopeWrap"),
        creditScope: document.getElementById("creditScope"),
        btnLoad: document.getElementById("btnLoad"),
        reportTabs: document.getElementById("reportTabs"),
        reportHead: document.getElementById("reportHead"),
        reportMeta: document.getElementById("reportMeta"),
        reportTable: document.getElementById("reportTable"),
        reportBody: document.getElementById("reportBody"),
        reportFoot: document.getElementById("reportFoot"),
        txnPaidSplitWrap: document.getElementById("txnPaidSplitWrap"),
        txnPaidSplitHead: document.getElementById("txnPaidSplitHead"),
        txnPaidSplitBody: document.getElementById("txnPaidSplitBody"),
        txnPaidSplitFoot: document.getElementById("txnPaidSplitFoot"),
        cardCurrentStock: document.getElementById("cardCurrentStock"),
        cardTotalCredit: document.getElementById("cardTotalCredit"),
        cardCustomerDue: document.getElementById("cardCustomerDue")
    };

    var activeType = "creditList";

    function getApiMode() {
        if (activeType === "creditList") {
            return "credit_all";
        }
        if (activeType === "stockTxn") {
            return "stock_txn";
        }
        if (activeType === "openClosing") {
            return "open_closing";
        }
        if (activeType === "currentStock") {
            return "current_stock";
        }
        return "transaction";
    }

    function getCtx() {
        return "<%= request.getContextPath() %>";
    }

    function getCreditScope() {
        return (el.creditScope.value || "credit_only").trim();
    }

    function setDefaultDateRange() {
        var now = new Date();
        var yyyy = now.getFullYear();
        var mm = String(now.getMonth() + 1).padStart(2, "0");
        var dd = String(now.getDate()).padStart(2, "0");
        var today = yyyy + "-" + mm + "-" + dd;
        el.fromDate.value = today;
        el.toDate.value = today;
    }

    function num(v) {
        var n = parseFloat(v);
        return isNaN(n) ? 0 : n;
    }

    function money(v) {
        return num(v).toFixed(2);
    }

    function tm(v) {
        return num(v).toFixed(3);
    }

    function loadSummaryCards() {
        fetch(getCtx() + "/goldTransation/report/getData.jsp?mode=summary_cards")
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success || !data.cards) {
                    return;
                }
                el.cardCurrentStock.textContent = tm(data.cards.currentStockTM);
                el.cardTotalCredit.textContent = money(data.cards.totalCredit);
                el.cardCustomerDue.textContent = money(data.cards.customerDue);
            })
            .catch(function() {
                el.cardCurrentStock.textContent = "0.000";
                el.cardTotalCredit.textContent = "0.00";
                el.cardCustomerDue.textContent = "0.00";
            });
    }

    function getColumnsByType(type) {
        if (type === "creditList") {
            return ["#", "Customer Name", "Credit Amount"];
        }
        if (type === "stockTxn") {
            return ["#", "Bill ID", "Customer", "Bill Date", "Bill Time", "In TM", "Out TM", "Rate", "Amount", "Net TM"];
        }
        if (type === "openClosing") {
            return ["#", "Date Time", "Bill ID", "Customer", "Type", "Bill Amount", "In Amount", "Out Amount", "Opening Balance", "Closing Balance", "Notes"];
        }
        if (type === "currentStock") {
            return ["#", "Customer Name", "Purchase TM", "Sale TM", "Current Stock TM"];
        }
        return ["#", "Customer Name", "Total Purchase", "Total Sale", "Purchase Paid (Cash+Bank)", "Sale Paid (Cash+Bank)", "Balance", "Purchase TM", "Sale TM"];
    }

    function renderHead(type) {
        applyTableLayout(type);
        var cols = getColumnsByType(type);
        var tr = "<tr>";
        cols.forEach(function(col, idx) {
            var cls = idx >= 2 ? " class='gr-right'" : "";
            tr += "<th" + cls + ">" + col + "</th>";
        });
        tr += "</tr>";
        el.reportHead.innerHTML = tr;
    }

    function applyTableLayout(type) {
        el.reportTable.classList.remove("gr-table-wide", "gr-table-medium");
        if (type === "transaction" || type === "stockTxn") {
            el.reportTable.classList.add("gr-table-wide");
            return;
        }
        if (type === "openClosing") {
            el.reportTable.classList.add("gr-table-wide");
            return;
        }
        if (type === "currentStock") {
            el.reportTable.classList.add("gr-table-medium");
        }
    }

    function renderEmpty(message) {
        var cols = getColumnsByType(activeType);
        el.reportBody.innerHTML = '<tr><td colspan="' + cols.length + '" class="gr-empty">' + message + '</td></tr>';
        el.reportFoot.innerHTML = "";
        el.txnPaidSplitWrap.style.display = "none";
        el.txnPaidSplitHead.innerHTML = "";
        el.txnPaidSplitBody.innerHTML = "";
        el.txnPaidSplitFoot.innerHTML = "";
    }

    function renderTransactionPaidSplit(rows, totals) {
        el.txnPaidSplitWrap.style.display = "";
        el.txnPaidSplitHead.innerHTML = "<tr>" +
            "<th>#</th>" +
            "<th>Customer Name</th>" +
            "<th class='gr-right'>Cash Paid</th>" +
            "<th class='gr-right'>GPay Paid</th>" +
            "</tr>";

        var body = "";
        rows.forEach(function(r, idx) {
            body += "<tr>" +
                "<td>" + (idx + 1) + "</td>" +
                "<td>" + (r.customerName || "") + "</td>" +
                "<td class='gr-right'>" + money(r.cashPaid) + "</td>" +
                "<td class='gr-right'>" + money(r.gpayPaid) + "</td>" +
                "</tr>";
        });
        el.txnPaidSplitBody.innerHTML = body;

        var t = totals || {};
        el.txnPaidSplitFoot.innerHTML = "<tr>" +
            "<td colspan='2'>Total</td>" +
            "<td class='gr-right'>" + money(t.cashPaid) + "</td>" +
            "<td class='gr-right'>" + money(t.gpayPaid) + "</td>" +
            "</tr>";
    }

    function getTxnPaidTooltipNode() {
        var node = document.getElementById("txnRowPaidTooltip");
        if (node) {
            return node;
        }
        node = document.createElement("div");
        node.id = "txnRowPaidTooltip";
        node.style.position = "fixed";
        node.style.zIndex = "99999";
        node.style.maxWidth = "300px";
        node.style.display = "none";
        node.style.background = "#ffffff";
        node.style.border = "1px solid #cfe0ef";
        node.style.borderRadius = "10px";
        node.style.boxShadow = "0 10px 26px rgba(10,34,56,.18)";
        node.style.padding = "8px 10px";
        node.style.fontSize = "12px";
        node.style.color = "#304e68";
        node.style.pointerEvents = "none";
        document.body.appendChild(node);
        return node;
    }

    function hideTxnPaidTooltip() {
        var node = document.getElementById("txnRowPaidTooltip");
        if (node) {
            node.style.display = "none";
        }
    }

    function showTxnPaidTooltip(row, clientX, clientY) {
        if (!row) {
            hideTxnPaidTooltip();
            return;
        }
        var node = getTxnPaidTooltipNode();
        var customerName = decodeURIComponent(row.getAttribute("data-customer-name") || "");
        var cashPaid = num(row.getAttribute("data-cash-paid") || 0);
        var gpayPaid = num(row.getAttribute("data-gpay-paid") || 0);
        node.innerHTML = "<div style='font-weight:800;color:#1f456e;margin-bottom:4px;'>" + (customerName || "Customer") + "</div>" +
            "<div style='margin-top:2px;color:#35597a;'>Cash Paid: " + money(cashPaid) + "</div>" +
            "<div style='margin-top:2px;color:#35597a;'>GPay Paid: " + money(gpayPaid) + "</div>";
        node.style.left = ((clientX || 0) + 14) + "px";
        node.style.top = ((clientY || 0) + 14) + "px";
        node.style.display = "block";
    }

    function renderTransaction(data) {
        var rows = data.rows || [];
        if (!rows.length) {
            renderEmpty("No active customer data for selected date.");
            el.reportMeta.textContent = "0 customer rows loaded.";
            return;
        }

        var html = "";
        rows.forEach(function(r, idx) {
            html += "<tr class='gr-transaction-row' data-customer-name='" + encodeURIComponent(r.customerName || "") + "' data-cash-paid='" + money(r.cashPaid) + "' data-gpay-paid='" + money(r.gpayPaid) + "'>" +
                "<td>" + (idx + 1) + "</td>" +
                "<td>" + (r.customerName || "") + "</td>" +
                "<td class='gr-right'>" + money(r.totalPurchase) + "</td>" +
                "<td class='gr-right'>" + money(r.totalSale) + "</td>" +
                "<td class='gr-right'>" + money(r.totalDebit) + "</td>" +
                "<td class='gr-right'>" + money(r.totalCredit) + "</td>" +
                "<td class='gr-right'>" + money(r.balance) + "</td>" +
                "<td class='gr-right'>" + tm(r.purchaseTM) + "</td>" +
                "<td class='gr-right'>" + tm(r.saleTM) + "</td>" +
                "</tr>";
        });
        el.reportBody.innerHTML = html;

        var t = data.totals || {};
        el.reportFoot.innerHTML = "<tr>" +
            "<td colspan='2'>Total</td>" +
            "<td class='gr-right'>" + money(t.totalPurchase) + "</td>" +
            "<td class='gr-right'>" + money(t.totalSale) + "</td>" +
            "<td class='gr-right'>" + money(t.totalDebit) + "</td>" +
            "<td class='gr-right'>" + money(t.totalCredit) + "</td>" +
            "<td class='gr-right'>" + money(t.balance) + "</td>" +
            "<td class='gr-right'>" + tm(t.purchaseTM) + "</td>" +
            "<td class='gr-right'>" + tm(t.saleTM) + "</td>" +
            "</tr>";

        renderTransactionPaidSplit(rows, t);

        el.reportMeta.textContent = (data.count || rows.length) + " active customers loaded for " + (data.periodLabel || "selected period") + ".";
    }

    function renderCredit(data) {
        el.txnPaidSplitWrap.style.display = "none";
        var rows = data.rows || [];
        var labelText = "credit customers";

        if (!rows.length) {
            renderEmpty("No rows found.");
            el.reportMeta.textContent = "0 " + labelText + ".";
            return;
        }

        var html = "";
        rows.forEach(function(r, idx) {
            var customerName = r.customerName || "";
            html += "<tr class='gr-credit-row' data-customer-id='" + (r.customerId || 0) + "' data-customer-name='" + encodeURIComponent(customerName) + "'>" +
                "<td>" + (idx + 1) + "</td>" +
                "<td>" + customerName + "</td>" +
                "<td class='gr-right'>" + money(r.creditAmount) + "</td>" +
                "</tr>";
        });
        el.reportBody.innerHTML = html;

        var t = data.totals || {};
        el.reportFoot.innerHTML = "<tr>" +
            "<td colspan='2'>Total</td>" +
            "<td class='gr-right'>" + money(t.creditAmount) + "</td>" +
            "</tr>";

        el.reportMeta.textContent = (data.count || rows.length) + " " + labelText + " loaded.";
    }

    function openCreditExplainModal(customerId, customerName) {
        if (!customerId) {
            return;
        }

        fetch(getCtx() + "/goldTransation/report/getData.jsp?mode=credit_explain&customerId=" + encodeURIComponent(customerId))
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success) {
                    throw new Error(data && data.message ? data.message : "Unable to load explanation");
                }

                var rows = data.rows || [];
                var t = data.totals || {};
                var accountCredit = num(t.creditFromAccount);
                var actionMode = accountCredit > 0 ? "collect" : (accountCredit < 0 ? "pay" : "none");
                var actionLabel = actionMode === "collect" ? "Collect" : "Pay";
                var actionAmount = Math.abs(accountCredit);
                var accountLabel = accountCredit > 0 ? "Customer needs to pay" : (accountCredit < 0 ? "You need to pay" : "Settled");
                var modalTitle = "Credit Explanation";
                var modalSubtitle = (data.customerName || customerName || "Customer");

                var actionHtml = "";
                if (actionMode !== "none" && actionAmount > 0) {
                    actionHtml = "<div style='display:flex;gap:10px;justify-content:flex-end;align-items:center;margin:10px 0 2px;'>" +
                        "<div style='font-size:13px;color:#3b5252;'>Amount</div>" +
                        "<input id='creditSettleAmount' type='number' min='0.01' step='0.01' value='' placeholder='Enter amount' style='width:160px;height:34px;border:1px solid #c8d8d6;border-radius:8px;padding:0 8px;' />" +
                        "<button id='btnCreditSettle' type='button' style='height:34px;padding:0 16px;border:none;border-radius:8px;background:#1f4f89;color:#fff;font-weight:700;'>" + actionLabel + "</button>" +
                        "</div>" +
                        "<div style='margin:10px 0 10px;padding:10px;border:1px solid #d9e7e5;border-radius:10px;background:#fbfdfd;'>" +
                        "<div style='display:flex;gap:14px;align-items:center;margin-bottom:8px;'>" +
                        "<label style='display:flex;align-items:center;gap:6px;font-weight:700;color:#2b4545;'><input type='checkbox' id='settleModeCash' checked /> Cash</label>" +
                        "<label style='display:flex;align-items:center;gap:6px;font-weight:700;color:#2b4545;'><input type='checkbox' id='settleModeGpay' /> GPay</label>" +
                        "</div>" +
                        "<div style='display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;'>" +
                        "<div><div style='font-size:12px;color:#5f7373;margin-bottom:4px;'>Cash Amount</div><input id='settleCashAmount' type='number' min='0' step='0.01' value='' placeholder='Enter cash amount' style='width:100%;height:34px;border:1px solid #c8d8d6;border-radius:8px;padding:0 8px;' /></div>" +
                        "<div><div style='font-size:12px;color:#5f7373;margin-bottom:4px;'>GPay Amount</div><input id='settleGpayAmount' type='number' min='0' step='0.01' value='' placeholder='Enter GPay amount' disabled style='width:100%;height:34px;border:1px solid #c8d8d6;border-radius:8px;padding:0 8px;' /></div>" +
                        "<div><div style='font-size:12px;color:#5f7373;margin-bottom:4px;'>Bank (for GPay)</div><select id='settleBankId' disabled style='width:100%;height:34px;border:1px solid #c8d8d6;border-radius:8px;padding:0 8px;'><option value=''>Select Bank</option></select></div>" +
                        "</div>" +
                        "</div>";
                }

                var html = "<div class='ph-bar' style='padding:10px 14px;border:1px solid #2a3f65;border-radius:12px;background:linear-gradient(135deg,#1b2d52,#172747);margin-bottom:12px;'>" +
                    "<div class='ph-left'>" +
                    "<div class='ph-icon-wrap ph-icon-bg' style='width:42px;height:42px;font-size:18px;border-radius:11px;background:#c9a227;color:#ffffff;'><i class='fa-solid fa-chart-column'></i></div>" +
                    "<div class='ph-text'>" +
                    "<div class='ph-title' style='font-size:18px;line-height:1.2;white-space:normal;overflow:visible;color:#ffffff;font-weight:800;'>" + modalTitle + "</div>" +
                    "<div class='ph-subtitle' style='font-size:13px;white-space:normal;overflow:visible;color:#b9cae2;'>" + modalSubtitle + "</div>" +
                    "</div>" +
                    "</div>" +
                    "<div class='ph-right'><span id='modalPhDatetime' style='color:#b9cae2;font-size:13px;'></span></div>" +
                    "</div>" +
                    "<div style='display:flex;justify-content:space-between;align-items:center;background:#f6fbfa;border:1px solid #d9e7e5;border-radius:10px;padding:10px 12px;margin-bottom:10px;'>" +
                    "<div style='font-size:14px;color:#395252;font-weight:700;'>Total Balance : " + money(accountCredit) + "</div>" +
                    "<div style='font-size:13px;color:#5a7171;'>" + accountLabel + "</div>" +
                    "</div>" +
                    actionHtml +
                    "<div style='max-height:420px;overflow:auto;'><table style='width:100%;border-collapse:collapse;font-size:13px;'>" +
                    "<thead><tr style='background:#f0f5f4;'>" +
                    "<th style='text-align:left;padding:8px;border-bottom:1px solid #d8e4e2;'>Date</th>" +
                    "<th style='text-align:left;padding:8px;border-bottom:1px solid #d8e4e2;'>Type</th>" +
                    "<th style='text-align:right;padding:8px;border-bottom:1px solid #d8e4e2;'>Total</th>" +
                    "<th style='text-align:right;padding:8px;border-bottom:1px solid #d8e4e2;'>Paid</th>" +
                    "<th style='text-align:right;padding:8px;border-bottom:1px solid #d8e4e2;'>Balance</th>" +
                    "<th style='text-align:right;padding:8px;border-bottom:1px solid #d8e4e2;'>Effect</th>" +
                    "<th style='text-align:right;padding:8px;border-bottom:1px solid #d8e4e2;'>Running Credit</th>" +
                    "</tr></thead><tbody id='creditTxnRows'>";

                if (!rows.length) {
                    html += "<tr><td colspan='7' style='padding:10px;text-align:center;color:#607272;'>No transactions found.</td></tr>";
                } else {
                    rows.forEach(function(r) {
                        var billId = r.billId || 0;
                        var txnDateTime = r.txnDateTime || "";
                        html += "<tr data-bill-id='" + billId + "' data-txn-dt='" + encodeURIComponent(txnDateTime) + "' style='cursor:pointer;'>" +
                            "<td style='padding:8px;border-bottom:1px solid #edf2f1;'>" + (r.billDate || "") + " " + (r.billTime || "") + "</td>" +
                            "<td style='padding:8px;border-bottom:1px solid #edf2f1;'>" + (r.txnType || "") + "</td>" +
                            "<td style='padding:8px;border-bottom:1px solid #edf2f1;text-align:right;'>" + money(r.total) + "</td>" +
                            "<td style='padding:8px;border-bottom:1px solid #edf2f1;text-align:right;'>" + money(r.paid) + "</td>" +
                            "<td style='padding:8px;border-bottom:1px solid #edf2f1;text-align:right;'>" + money(r.balance) + "</td>" +
                            "<td style='padding:8px;border-bottom:1px solid #edf2f1;text-align:right;'>" + money(r.creditEffect) + "</td>" +
                            "<td style='padding:8px;border-bottom:1px solid #edf2f1;text-align:right;'>" + money(r.runningCredit) + "</td>" +
                            "</tr>";
                    });
                }

                html += "</tbody></table></div>" +
                    "<div style='margin-top:10px;text-align:right;color:#304848;font-size:13px;'>" +
                    "<div><strong>Credit From Transactions:</strong> " + money(t.creditFromTransactions) + "</div>" +
                    "<div><strong>Credit From Account (" + (t.accountMode || "") + "):</strong> " + money(t.creditFromAccount) + "</div>" +
                    "</div>";

                Swal.fire({
                    title: "",
                    html: html,
                    width: 980,
                    confirmButtonText: "Close",
                    confirmButtonColor: "#1f4f89",
                    didOpen: function() {
                        var modalPhDatetime = document.getElementById("modalPhDatetime");

                        function tickModalHeader() {
                            if (!modalPhDatetime) {
                                return;
                            }
                            var d = new Date();
                            var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                            var h = d.getHours();
                            var m = String(d.getMinutes()).padStart(2, "0");
                            var ap = h >= 12 ? "pm" : "am";
                            h = h % 12 || 12;
                            modalPhDatetime.textContent = days[d.getDay()] + ", " + d.getDate() + " " + months[d.getMonth()] + ", " + d.getFullYear() + ", " + h + ":" + m + " " + ap;
                        }

                        tickModalHeader();
                        if (window.modalPhTimer) {
                            clearInterval(window.modalPhTimer);
                        }
                        window.modalPhTimer = setInterval(tickModalHeader, 60000);

                        var txnRowsWrap = document.getElementById("creditTxnRows");
                        var paymentCache = {};
                        var currentTooltipKey = "";
                        var tooltipNode = document.getElementById("creditTxnPaymentTooltip");

                        if (tooltipNode) {
                            tooltipNode.remove();
                        }

                        tooltipNode = document.createElement("div");
                        tooltipNode.id = "creditTxnPaymentTooltip";
                        tooltipNode.style.position = "fixed";
                        tooltipNode.style.zIndex = "99999";
                        tooltipNode.style.maxWidth = "340px";
                        tooltipNode.style.display = "none";
                        tooltipNode.style.background = "#ffffff";
                        tooltipNode.style.border = "1px solid #cfe0ef";
                        tooltipNode.style.borderRadius = "10px";
                        tooltipNode.style.boxShadow = "0 10px 26px rgba(10,34,56,.18)";
                        tooltipNode.style.padding = "8px 10px";
                        tooltipNode.style.fontSize = "12px";
                        tooltipNode.style.color = "#304e68";
                        tooltipNode.style.pointerEvents = "none";
                        document.body.appendChild(tooltipNode);

                        function hidePaymentTooltip() {
                            currentTooltipKey = "";
                            tooltipNode.style.display = "none";
                        }

                        function movePaymentTooltip(clientX, clientY) {
                            var x = (clientX || 0) + 14;
                            var y = (clientY || 0) + 14;
                            tooltipNode.style.left = x + "px";
                            tooltipNode.style.top = y + "px";
                        }

                        function renderTooltipHtml(titleText, pd) {
                            var pRows = (pd && pd.rows) || [];
                            var tPay = (pd && pd.totals) || {};
                            var lines = "";

                            if (!pRows.length) {
                                lines = "<div style='color:#637a8f;'>No payment entries</div>";
                            } else {
                                pRows.forEach(function(pr) {
                                    lines += "<div style='display:flex;justify-content:space-between;gap:8px;margin:2px 0;'>" +
                                        "<span style='font-weight:700;'>" + ((pr.paymentMode || "").toUpperCase()) + (pr.bankName ? " (" + pr.bankName + ")" : "") + "</span>" +
                                        "<span>" + money(pr.amount) + "</span>" +
                                        "</div>";
                                });
                            }

                            return "<div style='font-weight:800;color:#1f456e;margin-bottom:4px;'>" + titleText + "</div>" +
                                lines +
                                "<div style='margin-top:6px;color:#35597a;'>Cash Paid: " + money(tPay.cash) + "</div>" +
                                "<div style='margin-top:2px;color:#35597a;'>GPay Paid: " + money(tPay.gpay) + "</div>" +
                                "<div style='margin-top:6px;padding-top:6px;border-top:1px dashed #d6e3ef;color:#3f5f7b;'>Cash " + money(tPay.cash) +
                                " | GPay " + money(tPay.gpay) +
                                " | Balance " + money(tPay.balance) +
                                "</div>";
                        }

                        function showPaymentTooltip(lookup, clientX, clientY) {
                            if (!lookup || (!lookup.billId && !lookup.txnDateTime)) {
                                hidePaymentTooltip();
                                return;
                            }

                            movePaymentTooltip(clientX, clientY);
                            tooltipNode.style.display = "block";

                            var cacheKey = lookup.billId > 0
                                ? ("bill_" + lookup.billId)
                                : ("dt_" + (lookup.customerId || 0) + "_" + (lookup.txnDateTime || ""));
                            var titleText = lookup.billId > 0
                                ? ("Bill #" + lookup.billId + " Payment")
                                : "Balance Collection Payment";

                            if (paymentCache[cacheKey]) {
                                tooltipNode.innerHTML = renderTooltipHtml(titleText, paymentCache[cacheKey]);
                                currentTooltipKey = cacheKey;
                                return;
                            }

                            currentTooltipKey = cacheKey;
                            tooltipNode.innerHTML = "<div style='font-weight:700;'>Loading payment details...</div>";

                            var reqUrl = getCtx() + "/goldTransation/report/getData.jsp?mode=credit_payment_details";
                            if (lookup.billId > 0) {
                                reqUrl += "&billId=" + encodeURIComponent(lookup.billId);
                            } else {
                                reqUrl += "&customerId=" + encodeURIComponent(lookup.customerId || 0) +
                                    "&txnDateTime=" + encodeURIComponent(lookup.txnDateTime || "");
                            }

                            fetch(reqUrl)
                                .then(function(r) { return r.json(); })
                                .then(function(pd) {
                                    if (!pd || !pd.success) {
                                        throw new Error(pd && pd.message ? pd.message : "Unable to load payment details");
                                    }
                                    paymentCache[cacheKey] = pd;
                                    if (currentTooltipKey === cacheKey) {
                                        tooltipNode.innerHTML = renderTooltipHtml(titleText, pd);
                                    }
                                })
                                .catch(function(err) {
                                    if (currentTooltipKey === cacheKey) {
                                        tooltipNode.innerHTML = "<div style='color:#b03838;'>" + (err.message || "Unable to load payment details") + "</div>";
                                    }
                                });
                        }

                        if (txnRowsWrap) {
                            txnRowsWrap.addEventListener("mousemove", function(e) {
                                var row = e.target && e.target.closest ? e.target.closest("tr[data-bill-id]") : null;
                                var billId = parseInt((row && row.getAttribute("data-bill-id")) || "0", 10);
                                var txnDateTime = row ? decodeURIComponent(row.getAttribute("data-txn-dt") || "") : "";
                                var lookup = { billId: billId, customerId: customerId, txnDateTime: txnDateTime };
                                if (billId > 0 || txnDateTime) {
                                    showPaymentTooltip(lookup, e.clientX, e.clientY);
                                } else {
                                    hidePaymentTooltip();
                                }
                            });

                            txnRowsWrap.addEventListener("mouseleave", hidePaymentTooltip);

                            txnRowsWrap.addEventListener("touchstart", function(e) {
                                var t = e.touches && e.touches[0];
                                var target = e.target;
                                var row = target && target.closest ? target.closest("tr[data-bill-id]") : null;
                                var billId = parseInt((row && row.getAttribute("data-bill-id")) || "0", 10);
                                var txnDateTime = row ? decodeURIComponent(row.getAttribute("data-txn-dt") || "") : "";
                                var lookup = { billId: billId, customerId: customerId, txnDateTime: txnDateTime };
                                if ((billId > 0 || txnDateTime) && t) {
                                    showPaymentTooltip(lookup, t.clientX, t.clientY);
                                }
                            }, { passive: true });

                            txnRowsWrap.addEventListener("touchend", function() {
                                setTimeout(hidePaymentTooltip, 1200);
                            });
                        }

                        var btnSettle = document.getElementById("btnCreditSettle");
                        if (!btnSettle || actionMode === "none") {
                            return;
                        }

                        var modeCash = document.getElementById("settleModeCash");
                        var modeGpay = document.getElementById("settleModeGpay");
                        var cashInput = document.getElementById("settleCashAmount");
                        var gpayInput = document.getElementById("settleGpayAmount");
                        var bankSelect = document.getElementById("settleBankId");

                        function syncPaymentUI() {
                            cashInput.disabled = !modeCash.checked;
                            gpayInput.disabled = !modeGpay.checked;
                            bankSelect.disabled = !modeGpay.checked;
                            if (!modeCash.checked) {
                                cashInput.value = "";
                            }
                            if (!modeGpay.checked) {
                                gpayInput.value = "";
                                bankSelect.value = "";
                            }
                        }

                        modeCash.addEventListener("change", syncPaymentUI);
                        modeGpay.addEventListener("change", syncPaymentUI);
                        syncPaymentUI();

                        fetch(getCtx() + "/goldTransation/goldTrans/getBankDetails.jsp")
                            .then(function(r) { return r.json(); })
                            .then(function(banks) {
                                var opts = "<option value=''>Select Bank</option>";
                                banks.forEach(function(b) {
                                    opts += "<option value='" + b.id + "'>" + b.name + "</option>";
                                });
                                bankSelect.innerHTML = opts;
                            })
                            .catch(function() {
                                bankSelect.innerHTML = "<option value=''>Unable to load</option>";
                            });

                        btnSettle.addEventListener("click", function() {
                            var amtNode = document.getElementById("creditSettleAmount");
                            var amt = amtNode ? num(amtNode.value) : 0;
                            if (amt <= 0) {
                                Swal.showValidationMessage("Enter valid amount");
                                return;
                            }

                            var cashAmt = modeCash.checked ? num(cashInput.value) : 0;
                            var gpayAmt = modeGpay.checked ? num(gpayInput.value) : 0;
                            var bankId = modeGpay.checked ? parseInt(bankSelect.value || "0", 10) : 0;
                            var payTotal = cashAmt + gpayAmt;

                            if (!modeCash.checked && !modeGpay.checked) {
                                Swal.showValidationMessage("Select at least one payment option");
                                return;
                            }
                            if (modeGpay.checked && bankId <= 0) {
                                Swal.showValidationMessage("Select bank for GPay");
                                return;
                            }
                            if (Math.abs(payTotal - amt) > 0.01) {
                                Swal.showValidationMessage("Cash + GPay should match Amount");
                                return;
                            }

                            fetch(getCtx() + "/goldTransation/report/getData.jsp?mode=credit_settle", {
                                method: "POST",
                                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                                body: "customerId=" + encodeURIComponent(customerId) +
                                    "&action=" + encodeURIComponent(actionMode) +
                                    "&amount=" + encodeURIComponent(amt) +
                                    "&cashAmount=" + encodeURIComponent(cashAmt) +
                                    "&gpayAmount=" + encodeURIComponent(gpayAmt) +
                                    "&bankId=" + encodeURIComponent(bankId)
                            })
                            .then(function(r) { return r.json(); })
                            .then(function(respData) {
                                if (!respData || !respData.success) {
                                    throw new Error(respData && respData.message ? respData.message : "Unable to settle credit");
                                }
                                var settledBillId = (respData.settle && respData.settle.billId) || 0;
                                var successText = actionLabel + " entry saved.";
                                if (settledBillId > 0) {
                                    successText += " Bill #" + settledBillId;
                                }
                                Swal.fire({
                                    icon: "success",
                                    title: "Success",
                                    text: successText,
                                    confirmButtonColor: "#1f4f89"
                                }).then(function() {
                                    loadSummaryCards();
                                    loadReport();
                                    openCreditExplainModal(customerId, customerName);
                                });
                            })
                            .catch(function(err) {
                                Swal.fire("Error", err.message || "Unable to settle credit", "error");
                            });
                        });
                    },
                    willClose: function() {
                        var modalPhTimer = window.modalPhTimer;
                        if (modalPhTimer) {
                            clearInterval(modalPhTimer);
                            window.modalPhTimer = null;
                        }
                        var tooltip = document.getElementById("creditTxnPaymentTooltip");
                        if (tooltip) {
                            tooltip.remove();
                        }
                    }
                });
            })
            .catch(function(err) {
                Swal.fire("Error", err.message || "Unable to load explanation", "error");
            });
    }

    function renderStockTxn(data) {
        el.txnPaidSplitWrap.style.display = "none";
        var rows = data.rows || [];
        if (!rows.length) {
            renderEmpty("No stock transactions for selected date.");
            el.reportMeta.textContent = "0 stock transactions.";
            return;
        }

        var html = "";
        rows.forEach(function(r, idx) {
            html += "<tr>" +
                "<td>" + (idx + 1) + "</td>" +
                "<td>" + (r.billId || "") + "</td>" +
                "<td>" + (r.customerName || "") + "</td>" +
                "<td>" + (r.billDate || "") + "</td>" +
                "<td>" + (r.billTime || "") + "</td>" +
                "<td class='gr-right'>" + tm(r.inTM) + "</td>" +
                "<td class='gr-right'>" + tm(r.outTM) + "</td>" +
                "<td class='gr-right'>" + money(r.rate) + "</td>" +
                "<td class='gr-right'>" + money(r.amount) + "</td>" +
                "<td class='gr-right'>" + tm(r.netTM) + "</td>" +
                "</tr>";
        });
        el.reportBody.innerHTML = html;

        var t = data.totals || {};
        el.reportFoot.innerHTML = "<tr>" +
            "<td colspan='5'>Total</td>" +
            "<td class='gr-right'>" + tm(t.inTM) + "</td>" +
            "<td class='gr-right'>" + tm(t.outTM) + "</td>" +
            "<td class='gr-right'>-</td>" +
            "<td class='gr-right'>" + money(t.amount) + "</td>" +
            "<td class='gr-right'>" + tm(t.netTM) + "</td>" +
            "</tr>";

        el.reportMeta.textContent = (data.count || rows.length) + " stock transactions loaded for " + (data.periodLabel || "selected period") + ".";
    }

    function renderOpenClosing(data) {
        el.txnPaidSplitWrap.style.display = "none";
        var rows = data.rows || [];
        if (!rows.length) {
            renderEmpty("No open/closing rows for selected date.");
            el.reportMeta.textContent = "0 open/closing rows.";
            return;
        }

        var html = "";
        rows.forEach(function(r, idx) {
            html += "<tr>" +
                "<td>" + (idx + 1) + "</td>" +
                "<td>" + (r.dateTime || "") + "</td>" +
                "<td>" + (r.billId || "") + "</td>" +
                "<td>" + (r.customerName || "") + "</td>" +
                "<td>" + (r.txnType || "") + "</td>" +
                "<td class='gr-right'>" + money(r.billAmount) + "</td>" +
                "<td class='gr-right'>" + money(r.inAmount) + "</td>" +
                "<td class='gr-right'>" + money(r.outAmount) + "</td>" +
                "<td class='gr-right'>" + money(r.openingBalance) + "</td>" +
                "<td class='gr-right'>" + money(r.closingBalance) + "</td>" +
                "<td>" + (r.notes || "") + "</td>" +
                "</tr>";
        });
        el.reportBody.innerHTML = html;

        var t = data.totals || {};
        el.reportFoot.innerHTML = "<tr>" +
            "<td colspan='5'>Total</td>" +
            "<td class='gr-right'>" + money(t.billAmount) + "</td>" +
            "<td class='gr-right'>" + money(t.inAmount) + "</td>" +
            "<td class='gr-right'>" + money(t.outAmount) + "</td>" +
            "<td class='gr-right'>" + money(t.openingBalance) + "</td>" +
            "<td class='gr-right'>" + money(t.closingBalance) + "</td>" +
            "<td class='gr-right'>-</td>" +
            "</tr>";

        el.reportMeta.textContent = (data.count || rows.length) + " open/closing rows loaded for " + (data.periodLabel || "selected period") + ".";
    }

    function renderCurrentStock(data) {
        el.txnPaidSplitWrap.style.display = "none";
        var rows = data.rows || [];
        if (!rows.length) {
            renderEmpty("No current stock rows.");
            el.reportMeta.textContent = "0 current stock rows.";
            return;
        }

        var html = "";
        rows.forEach(function(r, idx) {
            html += "<tr>" +
                "<td>" + (idx + 1) + "</td>" +
                "<td>" + (r.customerName || "") + "</td>" +
                "<td class='gr-right'>" + tm(r.purchaseTM) + "</td>" +
                "<td class='gr-right'>" + tm(r.saleTM) + "</td>" +
                "<td class='gr-right'>" + tm(r.currentStockTM) + "</td>" +
                "</tr>";
        });
        el.reportBody.innerHTML = html;

        var t = data.totals || {};
        el.reportFoot.innerHTML = "<tr>" +
            "<td colspan='2'>Total</td>" +
            "<td class='gr-right'>" + tm(t.purchaseTM) + "</td>" +
            "<td class='gr-right'>" + tm(t.saleTM) + "</td>" +
            "<td class='gr-right'>" + tm(t.currentStockTM) + "</td>" +
            "</tr>";

        el.reportMeta.textContent = (data.count || rows.length) + " current stock rows for " + (data.periodLabel || "selected period") + ".";
    }

    function renderByType(data) {
        if (activeType === "creditList") {
            renderCredit(data);
            return;
        }
        if (activeType === "stockTxn") {
            renderStockTxn(data);
            return;
        }
        if (activeType === "openClosing") {
            renderOpenClosing(data);
            return;
        }
        if (activeType === "currentStock") {
            renderCurrentStock(data);
            return;
        }
        renderTransaction(data);
    }

    function needsDateFilter() {
        return activeType === "transaction" || activeType === "openClosing" || activeType === "stockTxn" || activeType === "currentStock";
    }

    function updateFilterState() {
        var enabled = needsDateFilter();
        el.fromDate.disabled = !enabled;
        el.toDate.disabled = !enabled;
        el.creditScopeWrap.style.display = activeType === "creditList" ? "" : "none";
        if (enabled) {
            el.btnLoad.textContent = "Load Report";
        } else {
            el.btnLoad.textContent = "Load Credit";
        }
    }

    function loadReport() {
        var fromDate = (el.fromDate.value || "").trim();
        var toDate = (el.toDate.value || "").trim();
        if (needsDateFilter() && (!fromDate || !toDate)) {
            Swal.fire("Choose Date Range", "Please select from and to date.", "warning");
            return;
        }

        if (needsDateFilter() && fromDate > toDate) {
            Swal.fire("Invalid Range", "From date should be less than or equal to to date.", "warning");
            return;
        }

        el.btnLoad.disabled = true;
        el.reportMeta.textContent = "Loading report...";

        var url = getCtx() + "/goldTransation/report/getData.jsp?mode=" + encodeURIComponent(getApiMode());
        if (activeType === "creditList") {
            url += "&creditScope=" + encodeURIComponent(getCreditScope());
        }
        if (needsDateFilter()) {
            url += "&fromDate=" + encodeURIComponent(fromDate) + "&toDate=" + encodeURIComponent(toDate);
        }

        fetch(url)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                el.btnLoad.disabled = false;
                if (!data.success) {
                    renderEmpty(data.message || "Unable to load report.");
                    el.reportMeta.textContent = "Load failed.";
                    return;
                }
                renderByType(data);
            })
            .catch(function(err) {
                el.btnLoad.disabled = false;
                renderEmpty("Unable to load report.");
                el.reportMeta.textContent = "Load failed.";
                Swal.fire("Error", err.message || "Unable to load report", "error");
            });
    }

    function bindTabs() {
        var tabs = el.reportTabs.querySelectorAll(".gr-tab");
        tabs.forEach(function(btn) {
            btn.addEventListener("click", function() {
                tabs.forEach(function(b) { b.classList.remove("active"); });
                btn.classList.add("active");
                activeType = btn.getAttribute("data-type") || "creditList";
                updateFilterState();
                renderHead(activeType);
                renderEmpty("Loading " + btn.textContent.trim() + "...");
                loadReport();
            });
        });

    }

    el.btnLoad.addEventListener("click", loadReport);
    el.fromDate.addEventListener("change", loadReport);
    el.toDate.addEventListener("change", loadReport);
    el.creditScope.addEventListener("change", function() {
        if (activeType === "creditList") {
            loadReport();
        }
    });
    el.reportBody.addEventListener("click", function(e) {
        if (activeType !== "creditList") {
            return;
        }
        var node = e.target.closest(".gr-credit-row");
        if (!node) {
            return;
        }
        var customerId = parseInt(node.getAttribute("data-customer-id") || "0", 10);
        var customerName = decodeURIComponent(node.getAttribute("data-customer-name") || "");
        openCreditExplainModal(customerId, customerName);
    });

    el.reportBody.addEventListener("mousemove", function(e) {
        if (activeType !== "transaction") {
            hideTxnPaidTooltip();
            return;
        }
        var row = e.target && e.target.closest ? e.target.closest("tr.gr-transaction-row") : null;
        if (!row) {
            hideTxnPaidTooltip();
            return;
        }
        showTxnPaidTooltip(row, e.clientX, e.clientY);
    });

    el.reportBody.addEventListener("mouseleave", function() {
        hideTxnPaidTooltip();
    });

    el.reportBody.addEventListener("touchstart", function(e) {
        if (activeType !== "transaction") {
            return;
        }
        var t = e.touches && e.touches[0];
        var target = e.target;
        var row = target && target.closest ? target.closest("tr.gr-transaction-row") : null;
        if (row && t) {
            showTxnPaidTooltip(row, t.clientX, t.clientY);
        }
    }, { passive: true });

    el.reportBody.addEventListener("touchend", function() {
        setTimeout(hideTxnPaidTooltip, 1200);
    });

    setDefaultDateRange();
    loadSummaryCards();
    updateFilterState();
    renderHead(activeType);
    bindTabs();
    loadReport();
})();
</script>

</body>
</html>
