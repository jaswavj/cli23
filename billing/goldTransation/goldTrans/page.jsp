<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Gold Transaction</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        :root {
            --gt-primary: #153c3c;
            --gt-primary-2: #1f5a58;
            --gt-accent: #d8b24a;
            --gt-bg: #f3f7f6;
            --gt-card: #ffffff;
            --gt-text: #1d2828;
            --gt-muted: #6b7b7b;
            --gt-danger: #dc3545;
            --gt-success: #198754;
        }

        .gt-page {
            max-width: 1150px;
            font-family: "Trebuchet MS", "Gill Sans", "Noto Sans", sans-serif;
        }

        .gt-hero {
            background: linear-gradient(120deg, var(--gt-primary) 0%, var(--gt-primary-2) 72%);
            color: #fff;
            border-radius: 14px;
            padding: 18px;
            box-shadow: 0 10px 24px rgba(21, 60, 60, 0.18);
            margin-bottom: 16px;
            position: relative;
            overflow: hidden;
        }

        .gt-hero::after {
            content: "";
            position: absolute;
            right: -34px;
            top: -34px;
            width: 130px;
            height: 130px;
            border-radius: 50%;
            background: rgba(216, 178, 74, 0.22);
        }

        .gt-hero h5 {
            margin: 0;
            font-weight: 700;
            letter-spacing: 0.4px;
        }

        .gt-hero p {
            margin: 6px 0 0;
            opacity: 0.92;
            font-size: 0.9rem;
        }

        .gt-card {
            background: var(--gt-card);
            border-radius: 12px;
            padding: 16px;
            box-shadow: 0 4px 14px rgba(21, 60, 60, 0.09);
            margin-bottom: 14px;
        }

        .gt-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
            padding-bottom: 10px;
            border-bottom: 1px solid #e7eceb;
        }

        .gt-title h6 {
            margin: 0;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.9px;
            font-weight: 700;
            color: var(--gt-primary);
        }

        .gt-form-label {
            font-size: 0.74rem;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--gt-muted);
            margin-bottom: 5px;
            font-weight: 700;
        }

        .gt-input,
        .gt-select {
            height: 42px;
            border: 1.5px solid #d7e2e0;
            border-radius: 10px;
            padding: 0 12px;
            font-size: 0.92rem;
            color: var(--gt-text);
            background: #fff;
            width: 100%;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .gt-input:focus,
        .gt-select:focus {
            border-color: var(--gt-accent);
            box-shadow: 0 0 0 3px rgba(216, 178, 74, 0.2);
        }

        .gt-input-readonly {
            background: #f8fbfa;
        }

        .gt-customer-wrap {
            position: relative;
        }

        .gt-add-customer {
            height: 42px;
            width: 42px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #114544, #1f6360);
            color: #fff;
            font-size: 1rem;
        }

        .gt-items-wrap {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        .gt-items-table {
            width: 100%;
            min-width: 650px;
            border-collapse: collapse;
        }

        .gt-items-table thead th {
            background: #f0f5f4;
            color: #334444;
            font-size: 0.73rem;
            letter-spacing: 0.7px;
            text-transform: uppercase;
            padding: 10px 8px;
            border-bottom: 1px solid #dce6e4;
            white-space: nowrap;
        }

        .gt-items-table tbody td {
            padding: 8px;
            border-bottom: 1px solid #edf2f1;
            vertical-align: middle;
        }

        .gt-row-total {
            font-weight: 700;
            text-align: right;
            color: var(--gt-primary);
            min-width: 100px;
        }

        .gt-row-delete {
            border: 1.5px solid #f0c6cb;
            color: var(--gt-danger);
            background: #fff;
            border-radius: 8px;
            width: 34px;
            height: 34px;
        }

        .gt-row-delete:hover {
            background: #fff3f4;
        }

        .gt-add-row {
            border: none;
            background: linear-gradient(135deg, var(--gt-primary), var(--gt-primary-2));
            color: #fff;
            border-radius: 9px;
            padding: 8px 14px;
            font-size: 0.82rem;
            font-weight: 600;
        }

        .gt-summary {
            display: flex;
            justify-content: flex-end;
            margin-top: 12px;
        }

        .gt-summary-box {
            min-width: 260px;
            background: #f4f8f7;
            border: 1px solid #dce8e6;
            border-radius: 10px;
            padding: 10px 14px;
        }

        .gt-summary-row {
            display: flex;
            justify-content: space-between;
            margin: 4px 0;
            color: #3c4f4f;
            font-size: 0.88rem;
        }

        .gt-summary-row strong {
            color: var(--gt-primary);
            font-size: 1rem;
        }

        .gt-pay-mode {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            align-items: center;
            padding: 8px 0 2px;
        }

        .gt-check {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-size: 0.9rem;
            color: #2d3d3d;
            font-weight: 600;
        }

        .gt-check input {
            width: 18px;
            height: 18px;
            accent-color: var(--gt-primary);
        }

        .gt-bank-note {
            font-size: 0.78rem;
            color: var(--gt-muted);
            margin-top: 3px;
        }

        .gt-action-bar {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .gt-btn {
            border: none;
            border-radius: 10px;
            height: 42px;
            padding: 0 20px;
            font-size: 0.9rem;
            font-weight: 700;
        }

        .gt-btn-save {
            color: #173737;
            background: linear-gradient(135deg, #d8b24a, #f1ce70);
        }

        .gt-btn-reset {
            background: #edf2f1;
            color: #4b5e5e;
            border: 1px solid #d8e2e0;
        }

        .gt-autocomplete {
            position: absolute;
            left: 0;
            right: 0;
            top: 100%;
            margin-top: 4px;
            background: #fff;
            border: 1px solid #dbe6e4;
            border-radius: 8px;
            list-style: none;
            padding: 4px 0;
            z-index: 1005;
            max-height: 220px;
            overflow-y: auto;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.08);
        }

        .gt-autocomplete li {
            padding: 8px 12px;
            cursor: pointer;
            font-size: 0.85rem;
            color: #223333;
            display: flex;
            justify-content: space-between;
            gap: 8px;
        }

        .gt-autocomplete li:hover {
            background: #f8fbfa;
        }

        .is-invalid-gt {
            border-color: #dc3545 !important;
            box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.18) !important;
        }

        @media (max-width: 768px) {
            .gt-page {
                padding-right: 0;
                padding-left: 0;
            }

            .gt-hero {
                border-radius: 10px;
                padding: 14px;
            }

            .gt-card {
                border-radius: 10px;
                padding: 12px;
            }

            .gt-action-bar {
                justify-content: stretch;
            }

            .gt-btn {
                flex: 1;
            }

            .gt-summary {
                justify-content: stretch;
            }

            .gt-summary-box {
                width: 100%;
                min-width: 0;
            }
        }
    </style>
</head>
<body style="background: var(--gt-bg);">

<%@ include file="/assets/navbar/navbar.jsp" %>

<%
    request.setAttribute("pageTitle", "Gold Transaction Entry");
    request.setAttribute("pageSubtitle", "Purchase and sale in one unified entry page");
    request.setAttribute("pageIcon", "fa-solid fa-scale-balanced");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page gt-page">
    

    <div class="gt-card">
        <div class="gt-title">
            <h6><i class="fa-solid fa-user-group me-2"></i>Transaction and Customer</h6>
        </div>
        <div class="row g-3">
            <div class="col-12 col-md-4">
                <label class="gt-form-label">Transaction Type</label>
                <select id="txnType" class="gt-select">
                    <option value="">Select</option>
                    <option value="purchase">Purchase</option>
                    <option value="sale">Sale</option>
                </select>
            </div>
            <div class="col-12 col-md-4">
                <label class="gt-form-label">Bill Date</label>
                <input id="billDate" type="date" class="gt-input">
            </div>
            <div class="col-12 col-md-4">
                <label class="gt-form-label">Bill Time</label>
                <input id="billTime" type="text" class="gt-input gt-input-readonly" readonly>
            </div>

            <div class="col-12 col-md-5">
                <label class="gt-form-label">Customer Name</label>
                <div class="d-flex gap-2">
                    <div class="gt-customer-wrap flex-grow-1">
                        <input id="customerName" type="text" class="gt-input" autocomplete="off" placeholder="Type customer name">
                        <input id="customerId" type="hidden" value="0">
                    </div>
                    <button type="button" class="gt-add-customer" title="Add new customer" id="btnOpenCustomer">
                        <i class="fa-solid fa-user-plus"></i>
                    </button>
                </div>
            </div>

            <div class="col-12 col-md-5">
                <label class="gt-form-label">Customer Phone</label>
                <div class="gt-customer-wrap">
                    <input id="customerPhone" type="text" class="gt-input" autocomplete="off" maxlength="15" placeholder="Type phone number">
                </div>
            </div>

            <div class="col-12 col-md-2 d-flex align-items-end">
                <button type="button" id="btnClearCustomer" class="gt-btn gt-btn-reset w-100">Clear</button>
            </div>
        </div>
    </div>

    <div class="gt-card">
        <div class="gt-title">
            <h6><i class="fa-solid fa-list-check me-2"></i>Particulars</h6>
            <button id="btnAddRow" type="button" class="gt-add-row"><i class="fa-solid fa-plus me-1"></i>Add Row</button>
        </div>

        <div class="gt-items-wrap">
            <table class="gt-items-table" id="itemsTable">
                <thead>
                    <tr>
                        <th style="width: 42px;">#</th>
                        <th>Particular</th>
                        <th style="width: 120px;">Qty (Gram)</th>
                        <th style="width: 120px;">Rate</th>
                        <th style="width: 130px; text-align: right;">Total</th>
                        <th style="width: 44px;"></th>
                    </tr>
                </thead>
                <tbody id="itemsBody"></tbody>
            </table>
        </div>

        <div class="gt-summary">
            <div class="gt-summary-box">
                <div class="gt-summary-row"><span>Total Qty</span><strong id="totalQty">0.000</strong></div>
                <div class="gt-summary-row"><span>Grand Total</span><strong id="grandTotal">0.00</strong></div>
            </div>
        </div>
    </div>

    <div class="gt-card">
        <div class="gt-title">
            <h6><i class="fa-solid fa-wallet me-2"></i>Payment</h6>
        </div>

        <div class="gt-pay-mode">
            <label class="gt-check"><input type="checkbox" id="modeCash">Cash</label>
            <label class="gt-check"><input type="checkbox" id="modeGpay">GPay</label>
        </div>

        <div class="row g-3 mt-1">
            <div class="col-12 col-md-4">
                <label class="gt-form-label">Cash Amount</label>
                <input id="cashAmount" type="number" class="gt-input" min="0" step="0.01" placeholder="0.00" disabled>
            </div>
            <div class="col-12 col-md-4">
                <label class="gt-form-label">GPay Amount</label>
                <input id="gpayAmount" type="number" class="gt-input" min="0" step="0.01" placeholder="0.00" disabled>
            </div>
            <div class="col-12 col-md-4">
                <label class="gt-form-label">Bank (for GPay)</label>
                <select id="bankId" class="gt-select" disabled>
                    <option value="">Select Bank</option>
                </select>
                <div class="gt-bank-note">If GPay is selected, bank selection is mandatory.</div>
            </div>

            <div class="col-12 col-md-4">
                <label class="gt-form-label">Balance</label>
                <input id="balanceAmount" type="number" class="gt-input" min="0" step="0.01" placeholder="0.00">
            </div>
            <div class="col-12 col-md-4">
                <label class="gt-form-label">Paid Total</label>
                <input id="paidTotal" type="text" class="gt-input gt-input-readonly" readonly value="0.00">
            </div>
            <div class="col-12 col-md-4">
                <label class="gt-form-label">Remaining</label>
                <input id="remainingAmount" type="text" class="gt-input gt-input-readonly" readonly value="0.00">
            </div>
        </div>
    </div>

    <div class="gt-action-bar">
        <button type="button" class="gt-btn gt-btn-reset" id="btnResetAll"><i class="fa-solid fa-rotate-left me-1"></i>Reset</button>
        <button type="button" class="gt-btn gt-btn-save" id="btnSave"><i class="fa-solid fa-floppy-disk me-1"></i>Save Transaction</button>
    </div>
</div>

<script>
(function() {
    "use strict";

    var rowCount = 0;
    var autoTimer;

    var el = {
        txnType: document.getElementById("txnType"),
        billDate: document.getElementById("billDate"),
        billTime: document.getElementById("billTime"),
        customerName: document.getElementById("customerName"),
        customerPhone: document.getElementById("customerPhone"),
        customerId: document.getElementById("customerId"),
        btnOpenCustomer: document.getElementById("btnOpenCustomer"),
        btnClearCustomer: document.getElementById("btnClearCustomer"),
        itemsBody: document.getElementById("itemsBody"),
        btnAddRow: document.getElementById("btnAddRow"),
        totalQty: document.getElementById("totalQty"),
        grandTotal: document.getElementById("grandTotal"),
        modeCash: document.getElementById("modeCash"),
        modeGpay: document.getElementById("modeGpay"),
        cashAmount: document.getElementById("cashAmount"),
        gpayAmount: document.getElementById("gpayAmount"),
        bankId: document.getElementById("bankId"),
        balanceAmount: document.getElementById("balanceAmount"),
        paidTotal: document.getElementById("paidTotal"),
        remainingAmount: document.getElementById("remainingAmount"),
        btnSave: document.getElementById("btnSave"),
        btnResetAll: document.getElementById("btnResetAll")
    };

    function setDateTimeDefaults() {
        var now = new Date();
        var yyyy = now.getFullYear();
        var mm = String(now.getMonth() + 1).padStart(2, "0");
        var dd = String(now.getDate()).padStart(2, "0");
        el.billDate.value = yyyy + "-" + mm + "-" + dd;
        updateTime();
    }

    function updateTime() {
        var now = new Date();
        var hh = String(now.getHours()).padStart(2, "0");
        var mi = String(now.getMinutes()).padStart(2, "0");
        var ss = String(now.getSeconds()).padStart(2, "0");
        el.billTime.value = hh + ":" + mi + ":" + ss;
    }

    function parseNumber(v) {
        var n = parseFloat(v);
        return isNaN(n) ? 0 : n;
    }

    function money(v) {
        return parseNumber(v).toFixed(2);
    }

    function clearInvalidState() {
        document.querySelectorAll(".is-invalid-gt").forEach(function(node) {
            node.classList.remove("is-invalid-gt");
        });
    }

    function createRow() {
        rowCount += 1;
        var tr = document.createElement("tr");
        tr.innerHTML =
            '<td class="gt-row-no" style="text-align:center;color:#708585;font-size:0.8rem;">' + rowCount + '</td>' +
            '<td><input type="text" class="gt-input gt-item-particular" placeholder="Particular"></td>' +
            '<td><input type="number" class="gt-input gt-item-qty" min="0" step="0.001" placeholder="0.000"></td>' +
            '<td><input type="number" class="gt-input gt-item-rate" min="0" step="0.01" placeholder="0.00"></td>' +
            '<td class="gt-row-total">0.00</td>' +
            '<td style="text-align:center;"><button type="button" class="gt-row-delete"><i class="fa-solid fa-trash"></i></button></td>';

        var qtyInput = tr.querySelector(".gt-item-qty");
        var rateInput = tr.querySelector(".gt-item-rate");
        var delBtn = tr.querySelector(".gt-row-delete");

        function calcRow() {
            var total = parseNumber(qtyInput.value) * parseNumber(rateInput.value);
            tr.querySelector(".gt-row-total").textContent = money(total);
            refreshTotals();
        }

        qtyInput.addEventListener("input", calcRow);
        rateInput.addEventListener("input", calcRow);

        delBtn.addEventListener("click", function() {
            if (el.itemsBody.querySelectorAll("tr").length <= 1) {
                return;
            }
            tr.remove();
            renumberRows();
            refreshTotals();
        });

        tr.querySelectorAll("input").forEach(function(inp) {
            inp.addEventListener("input", function() {
                inp.classList.remove("is-invalid-gt");
            });
        });

        return tr;
    }

    function renumberRows() {
        var rows = el.itemsBody.querySelectorAll("tr");
        rows.forEach(function(r, idx) {
            r.querySelector(".gt-row-no").textContent = idx + 1;
        });
        rowCount = rows.length;
    }

    function refreshTotals() {
        var totalQty = 0;
        var grandTotal = 0;
        el.itemsBody.querySelectorAll("tr").forEach(function(tr) {
            totalQty += parseNumber(tr.querySelector(".gt-item-qty").value);
            grandTotal += parseNumber(tr.querySelector(".gt-row-total").textContent);
        });

        el.totalQty.textContent = totalQty.toFixed(3);
        el.grandTotal.textContent = money(grandTotal);
        refreshPaymentSummary();
    }

    function refreshPaymentModeUI() {
        el.cashAmount.disabled = !el.modeCash.checked;
        el.gpayAmount.disabled = !el.modeGpay.checked;
        el.bankId.disabled = !el.modeGpay.checked;

        if (!el.modeCash.checked) {
            el.cashAmount.value = "";
        }
        if (!el.modeGpay.checked) {
            el.gpayAmount.value = "";
            el.bankId.value = "";
        }
        refreshPaymentSummary();
    }

    function refreshPaymentSummary() {
        var cash = el.modeCash.checked ? parseNumber(el.cashAmount.value) : 0;
        var gpay = el.modeGpay.checked ? parseNumber(el.gpayAmount.value) : 0;
        var paid = cash + gpay;
        var grand = parseNumber(el.grandTotal.textContent);
        var remaining = grand - paid;

        el.paidTotal.value = money(paid);
        el.remainingAmount.value = money(remaining > 0 ? remaining : 0);

        if (!el.balanceAmount.dataset.userEdited) {
            el.balanceAmount.value = money(remaining > 0 ? remaining : 0);
        }
    }

    function getCtx() {
        return "<%= request.getContextPath() %>";
    }

    function loadBanks() {
        fetch(getCtx() + "/goldTransation/goldTrans/getBankDetails.jsp")
            .then(function(r) { return r.json(); })
            .then(function(banks) {
                var options = '<option value="">Select Bank</option>';
                banks.forEach(function(bank) {
                    options += '<option value="' + bank.id + '">' + bank.name + '</option>';
                });
                el.bankId.innerHTML = options;
            })
            .catch(function() {
                el.bankId.innerHTML = '<option value="">Unable to load banks</option>';
            });
    }

    function removeCustomerDropdown(type) {
        var oldNode = document.getElementById("gtCustDropdown_" + type);
        if (oldNode) {
            oldNode.remove();
        }
    }

    function showCustomerDropdown(type, list) {
        removeCustomerDropdown(type);

        var anchor = type === "name" ? el.customerName : el.customerPhone;
        var wrap = anchor.closest(".gt-customer-wrap");
        var ul = document.createElement("ul");
        ul.id = "gtCustDropdown_" + type;
        ul.className = "gt-autocomplete";

        list.forEach(function(customer) {
            var li = document.createElement("li");
            var phoneText = customer.phone && customer.phone !== "-" ? customer.phone : "No phone";
            li.innerHTML = "<span>" + customer.name + "</span><small style='color:#6f8181;'>" + phoneText + "</small>";
            li.addEventListener("mousedown", function(e) {
                e.preventDefault();
                selectCustomer(customer);
            });
            ul.appendChild(li);
        });

        wrap.appendChild(ul);
    }

    function selectCustomer(customer) {
        el.customerId.value = customer.id || "0";
        el.customerName.value = customer.name || "";
        el.customerPhone.value = customer.phone && customer.phone !== "-" ? customer.phone : "";
        removeCustomerDropdown("name");
        removeCustomerDropdown("phone");
    }

    function queryCustomerByName() {
        clearTimeout(autoTimer);
        removeCustomerDropdown("name");
        var query = el.customerName.value.trim();
        el.customerId.value = "0";
        if (query.length < 2) {
            return;
        }
        autoTimer = setTimeout(function() {
            fetch(getCtx() + "/billing/customerAutocomplete.jsp?query=" + encodeURIComponent(query))
                .then(function(r) { return r.json(); })
                .then(function(rows) {
                    if (rows && rows.length) {
                        showCustomerDropdown("name", rows);
                    }
                });
        }, 250);
    }

    function queryCustomerByPhone() {
        clearTimeout(autoTimer);
        removeCustomerDropdown("phone");
        var query = el.customerPhone.value.trim();
        el.customerId.value = "0";
        if (query.length < 3) {
            return;
        }
        autoTimer = setTimeout(function() {
            fetch(getCtx() + "/billing/customerAutocomplete.jsp?phone=" + encodeURIComponent(query))
                .then(function(r) { return r.json(); })
                .then(function(rows) {
                    if (rows && rows.length) {
                        showCustomerDropdown("phone", rows);
                    }
                });
        }, 250);
    }

    function validateForm() {
        var valid = true;
        clearInvalidState();

        if (!el.txnType.value) {
            el.txnType.classList.add("is-invalid-gt");
            valid = false;
        }

        if (!el.customerName.value.trim()) {
            el.customerName.classList.add("is-invalid-gt");
            valid = false;
        }

        var rowValidCount = 0;
        el.itemsBody.querySelectorAll("tr").forEach(function(tr) {
            var particular = tr.querySelector(".gt-item-particular");
            var qty = tr.querySelector(".gt-item-qty");
            var rate = tr.querySelector(".gt-item-rate");

            var hasParticular = particular.value.trim().length > 0;
            var hasQty = parseNumber(qty.value) > 0;
            var hasRate = parseNumber(rate.value) > 0;

            if (hasParticular || hasQty || hasRate) {
                rowValidCount += 1;
                if (!hasParticular) {
                    particular.classList.add("is-invalid-gt");
                    valid = false;
                }
                if (!hasQty) {
                    qty.classList.add("is-invalid-gt");
                    valid = false;
                }
                if (!hasRate) {
                    rate.classList.add("is-invalid-gt");
                    valid = false;
                }
            }
        });

        if (rowValidCount === 0) {
            valid = false;
            var firstRowParticular = el.itemsBody.querySelector(".gt-item-particular");
            if (firstRowParticular) {
                firstRowParticular.classList.add("is-invalid-gt");
            }
        }

        if (!el.modeCash.checked && !el.modeGpay.checked && parseNumber(el.balanceAmount.value) <= 0) {
            valid = false;
            Swal.fire({
                icon: "warning",
                title: "Payment Required",
                text: "Select cash or GPay, or enter a balance amount.",
                confirmButtonColor: "#1f5a58"
            });
            return false;
        }

        if (el.modeGpay.checked && !el.bankId.value) {
            el.bankId.classList.add("is-invalid-gt");
            valid = false;
        }

        if (!valid) {
            Swal.fire({
                icon: "warning",
                title: "Please Check Inputs",
                text: "Fill all required transaction details before saving.",
                confirmButtonColor: "#1f5a58"
            });
        }

        return valid;
    }

    function buildSavePayload() {
        var items = [];
        el.itemsBody.querySelectorAll("tr").forEach(function(tr) {
            var particular = tr.querySelector(".gt-item-particular").value.trim();
            var qty = parseNumber(tr.querySelector(".gt-item-qty").value);
            var rate = parseNumber(tr.querySelector(".gt-item-rate").value);
            var total = parseNumber(tr.querySelector(".gt-row-total").textContent);
            if (particular.length > 0 || qty > 0 || rate > 0 || total > 0) {
                items.push({
                    particular: particular,
                    qty: qty,
                    rate: rate,
                    total: total
                });
            }
        });

        var payments = [];
        if (el.modeCash.checked) {
            payments.push({
                mode: "cash",
                bankId: 0,
                amount: parseNumber(el.cashAmount.value)
            });
        }
        if (el.modeGpay.checked) {
            payments.push({
                mode: "gpay",
                bankId: parseInt(el.bankId.value || "0", 10),
                amount: parseNumber(el.gpayAmount.value)
            });
        }
        var balanceAmt = parseNumber(el.balanceAmount.value);
        if (balanceAmt > 0) {
            payments.push({
                mode: "balance",
                bankId: 0,
                amount: balanceAmt
            });
        }

        var payload = new URLSearchParams();
        payload.append("customerId", el.customerId.value || "0");
        payload.append("txnType", el.txnType.value);
        payload.append("billDate", el.billDate.value);
        payload.append("billTime", el.billTime.value);
        payload.append("total", money(el.grandTotal.textContent));
        payload.append("paid", money(el.paidTotal.value));
        payload.append("balance", money(el.balanceAmount.value));
        payload.append("items", JSON.stringify(items));
        payload.append("payments", JSON.stringify(payments));
        return payload;
    }

    function resetForm() {
        el.txnType.value = "";
        el.customerId.value = "0";
        el.customerName.value = "";
        el.customerPhone.value = "";
        el.itemsBody.innerHTML = "";
        rowCount = 0;
        el.itemsBody.appendChild(createRow());

        el.modeCash.checked = false;
        el.modeGpay.checked = false;
        el.cashAmount.value = "";
        el.gpayAmount.value = "";
        el.bankId.value = "";
        el.balanceAmount.value = "0.00";
        delete el.balanceAmount.dataset.userEdited;
        refreshPaymentModeUI();

        setDateTimeDefaults();
        refreshTotals();
        clearInvalidState();
    }

    el.btnOpenCustomer.addEventListener("click", function() {
        window.open(getCtx() + "/product/master/customer/page.jsp", "_blank", "width=980,height=680");
    });

    el.btnClearCustomer.addEventListener("click", function() {
        el.customerId.value = "0";
        el.customerName.value = "";
        el.customerPhone.value = "";
        removeCustomerDropdown("name");
        removeCustomerDropdown("phone");
    });

    el.btnAddRow.addEventListener("click", function() {
        var row = createRow();
        el.itemsBody.appendChild(row);
        row.querySelector(".gt-item-particular").focus();
    });

    el.modeCash.addEventListener("change", refreshPaymentModeUI);
    el.modeGpay.addEventListener("change", refreshPaymentModeUI);

    [el.cashAmount, el.gpayAmount].forEach(function(node) {
        node.addEventListener("input", refreshPaymentSummary);
    });

    el.balanceAmount.addEventListener("input", function() {
        el.balanceAmount.dataset.userEdited = "1";
    });

    el.customerName.addEventListener("input", queryCustomerByName);
    el.customerPhone.addEventListener("input", queryCustomerByPhone);

    document.addEventListener("click", function(e) {
        if (e.target !== el.customerName) {
            removeCustomerDropdown("name");
        }
        if (e.target !== el.customerPhone) {
            removeCustomerDropdown("phone");
        }
    });

    el.btnSave.addEventListener("click", function() {
        if (!validateForm()) {
            return;
        }

        var payload = buildSavePayload();
        el.btnSave.disabled = true;

        fetch(getCtx() + "/goldTransation/goldTrans/saveTransaction.jsp", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: payload.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            el.btnSave.disabled = false;
            if (data.status === "ok") {
                Swal.fire({
                    icon: "success",
                    title: "Saved",
                    text: "Transaction #" + data.bill_id + " saved successfully.",
                    confirmButtonColor: "#1f5a58"
                }).then(function() {
                    resetForm();
                });
            } else {
                Swal.fire({
                    icon: "error",
                    title: "Save Failed",
                    text: data.msg || "Unable to save transaction",
                    confirmButtonColor: "#1f5a58"
                });
            }
        })
        .catch(function(err) {
            el.btnSave.disabled = false;
            Swal.fire({
                icon: "error",
                title: "Network Error",
                text: err.message || "Unable to save transaction",
                confirmButtonColor: "#1f5a58"
            });
        });
    });

    el.btnResetAll.addEventListener("click", function() {
        Swal.fire({
            icon: "question",
            title: "Reset Form?",
            text: "All entered values will be cleared.",
            showCancelButton: true,
            confirmButtonColor: "#1f5a58",
            cancelButtonColor: "#8aa1a0",
            confirmButtonText: "Yes, Reset"
        }).then(function(result) {
            if (result.isConfirmed) {
                resetForm();
            }
        });
    });

    setDateTimeDefaults();
    setInterval(updateTime, 1000);
    loadBanks();
    el.itemsBody.appendChild(createRow());
    refreshPaymentModeUI();
    refreshTotals();
})();
</script>

</body>
</html>
