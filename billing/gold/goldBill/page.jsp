<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Gold Buyer Entry</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        /* ─── Gold Rate Banner ─── */
        .gold-rate-banner {
            background: linear-gradient(135deg, #1a2540 0%, #c9a227 100%);
            border-radius: 0.75rem;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 14px;
            box-shadow: 0 2px 12px rgba(201,162,39,0.25);
            flex-wrap: wrap;
        }
        .gold-rate-banner .gr-label {
            color: #fff;
            font-weight: 700;
            font-size: 0.85rem;
            letter-spacing: 1px;
            text-transform: uppercase;
            white-space: nowrap;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .gold-rate-banner .gr-label i {
            font-size: 1.2rem;
            color: #ffe066;
        }
        .gold-rate-input-wrap {
            display: flex;
            align-items: center;
            background: rgba(255,255,255,0.15);
            border: 2px solid rgba(255,255,255,0.4);
            border-radius: 0.5rem;
            padding: 4px 12px;
            gap: 6px;
            flex: 1;
            min-width: 140px;
            max-width: 220px;
        }
        .gold-rate-input-wrap .gr-symbol {
            color: #ffe066;
            font-weight: 800;
            font-size: 1rem;
        }
        .gold-rate-input-wrap input {
            background: transparent;
            border: none;
            outline: none;
            color: #fff;
            font-size: 1.4rem;
            font-weight: 800;
            width: 100%;
            letter-spacing: 1px;
        }
        .gr-unit {
            color: rgba(255,255,255,0.8);
            font-size: 0.78rem;
            white-space: nowrap;
        }

        /* ─── Section Cards ─── */
        .gb-section {
            background: #fff;
            border-radius: 0.75rem;
            box-shadow: 0 2px 12px rgba(26,37,64,0.08);
            padding: 20px;
            margin-bottom: 18px;
        }
        .gb-section-title {
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            color: #1a2540;
            border-left: 3px solid #c9a227;
            padding-left: 10px;
            margin-bottom: 16px;
        }

        /* ─── Billing Table ─── */
        .billing-table-wrap {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            border-radius: 0.6rem;
        }
        .billing-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            min-width: 680px;
            table-layout: fixed;
        }
        .billing-table thead tr {
            background: linear-gradient(135deg, #1a2540 0%, #1e2d55 100%);
        }
        .billing-table thead th {
            color: #fff;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            padding: 10px 10px;
            border: none;
            white-space: nowrap;
        }
        .billing-table thead th:first-child { border-radius: 0.6rem 0 0 0; }
        .billing-table thead th:last-child  { border-radius: 0 0.6rem 0 0; }
        .billing-table tbody tr { transition: background 0.15s; }
        .billing-table tbody tr:nth-child(even) { background: #f9f7f0; }
        .billing-table tbody tr:hover { background: #fef9ec; }
        .billing-table td {
            padding: 6px 6px;
            vertical-align: middle;
            border-bottom: 1px solid #f0ede0;
        }
        .billing-table .row-input {
            width: 100%;
            border: 1.5px solid #ddd;
            border-radius: 0.4rem;
            padding: 5px 8px;
            font-size: 0.8rem;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            background: #fff;
        }
        .billing-table .row-input:focus {
            border-color: #c9a227;
            box-shadow: 0 0 0 2px rgba(201,162,39,0.18);
        }
        .billing-table .row-input.is-invalid {
            border-color: #f87171;
            box-shadow: 0 0 0 2px rgba(248,113,113,0.15);
        }
        .gross-amount-cell {
            font-weight: 700;
            color: #1a2540;
            text-align: right;
            min-width: 90px;
            padding-right: 12px;
            font-size: 0.85rem;
        }
        .btn-del-row {
            background: none;
            border: 1.5px solid #f87171;
            color: #f87171;
            border-radius: 0.4rem;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background 0.15s, color 0.15s;
            font-size: 0.8rem;
        }
        .btn-del-row:hover { background: #f87171; color: #fff; }

        /* ─── Add Row Button ─── */
        .btn-add-row {
            background: linear-gradient(135deg, #1a2540, #1e2d55);
            color: #fff;
            border: none;
            border-radius: 0.5rem;
            padding: 8px 18px;
            font-size: 0.78rem;
            font-weight: 600;
            letter-spacing: 0.5px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            transition: opacity 0.2s;
        }
        .btn-add-row:hover { opacity: 0.88; }

        /* ─── Totals Bar ─── */
        .totals-bar {
            background: linear-gradient(135deg, #1a2540, #1e2d55);
            border-radius: 0.6rem;
            padding: 14px 20px;
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            align-items: center;
            justify-content: flex-end;
            margin-top: 14px;
        }
        .totals-bar .tot-item {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
        }
        .totals-bar .tot-label {
            color: rgba(255,255,255,0.65);
            font-size: 0.68rem;
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }
        .totals-bar .tot-value {
            color: #ffe066;
            font-size: 1.05rem;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        /* ─── Submit Bar ─── */
        .submit-bar {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            flex-wrap: wrap;
            padding: 0 0 10px;
        }
        .btn-gb-save {
            background: linear-gradient(135deg, #c9a227, #dbb82e);
            color: #1a2540;
            border: none;
            border-radius: 0.5rem;
            padding: 10px 30px;
            font-size: 0.85rem;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 14px rgba(201,162,39,0.3);
            transition: opacity 0.2s;
        }
        .btn-gb-save:hover { opacity: 0.9; }
        .btn-gb-reset {
            background: #f0f0f0;
            color: #555;
            border: 1.5px solid #ddd;
            border-radius: 0.5rem;
            padding: 10px 22px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.15s;
        }
        .btn-gb-reset:hover { background: #e0e0e0; }

        /* ─── Mobile tweaks ─── */
        @media (max-width: 768px) {
            .gold-rate-banner { gap: 10px; }
            .gold-rate-input-wrap { max-width: 100%; }
            .gb-section { padding: 14px 12px; }
            .totals-bar { justify-content: flex-start; }
            .submit-bar { justify-content: stretch; }
            .btn-gb-save, .btn-gb-reset { flex: 1; justify-content: center; }
        }

        /* ─── Autocomplete dropdown override ─── */
        .ui-autocomplete {
            font-size: 0.8rem;
            border-radius: 0.4rem;
            border: 1.5px solid #c9a22760;
            box-shadow: 0 4px 14px rgba(0,0,0,0.12);
            z-index: 9999;
        }
        .ui-menu-item-wrapper { padding: 7px 12px; }
        .ui-state-active, .ui-widget-content .ui-state-active {
            background: #c9a227 !important;
            color: #fff !important;
            border-color: #c9a227 !important;
        }
    </style>
</head>
<body>

<%@ include file="/assets/navbar/navbar.jsp" %>

<%
    request.setAttribute("pageTitle",    "Gold Buyer Entry");
    request.setAttribute("pageSubtitle", "Record gold purchase from customer");
    request.setAttribute("pageIcon",     "fa-solid fa-coins");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page pb-4" style="max-width:1100px;">

    <!-- ══════════════ TOP ROW: GOLD RATE (30%) + CUSTOMER DETAILS (70%) ══════════════ -->
    <div class="d-flex gap-3 mb-3 align-items-stretch flex-wrap">

        <!-- Gold Rate Card (30%) -->
        <div class="gold-rate-banner flex-shrink-0" id="goldRateCard" style="position:relative; flex:0 0 28%; min-width:220px; flex-direction:column; align-items:flex-start; gap:10px; cursor:pointer; user-select:none;" title="Click to update gold rate">
            <div class="gr-label" style="width:100%; justify-content:space-between;">
                <span><i class="fas fa-coins"></i> Today's Gold Rate</span>
                <i class="fas fa-pen" style="font-size:0.75rem; color:rgba(255,255,255,0.7);"></i>
            </div>
            <div style="display:flex; align-items:baseline; gap:6px; width:100%;">
                <span style="color:#ffe066; font-size:1rem; font-weight:800;">₹</span>
                <span id="goldRateDisplay" style="color:#fff; font-size:2rem; font-weight:800; letter-spacing:1px;">0.00</span>
            </div>
            <span class="gr-unit">/ gram &nbsp;|&nbsp; Click to update</span>
            <div id="lastBillNoDisplay" style="width:100%; text-align:center; padding-top:8px; margin-top:8px; border-top:1px solid rgba(255,255,255,0.2); font-size:0.8rem; color:rgba(255,255,255,0.7); display:none;">
                Last Bill No: <span id="lastBillNo" style="font-weight:800; font-size:1rem; color:#ffe066; letter-spacing:0.5px;">-</span>
            </div>
            <input type="hidden" id="goldRateInput" value="0">
        </div>

        <!-- Customer Details Card (70%) -->
        <div class="gb-section mb-0" style="flex:1 1 0; min-width:0;">
            <div class="gb-section-title" style="display:flex; align-items:center; justify-content:space-between;">
                <span><i class="fas fa-user-circle me-2"></i>Customer Details</span>
                <button type="button" id="btnAddCustomer" onclick="window.open('<%= request.getContextPath() %>/product/master/customer/page.jsp', '_blank', 'width=900,height=600')" 
                    style="background:linear-gradient(135deg,#1a2540,#1e2d55); color:#fff; border:none; border-radius:0.4rem; padding:5px 12px; font-size:0.7rem; font-weight:600; cursor:pointer; display:inline-flex; align-items:center; gap:5px;">
                    <i class="fas fa-user-plus"></i> Add Customer
                </button>
            </div>
            <div class="row g-3">

                <!-- Customer Name -->
                <div class="col-md-5 col-sm-6 input-outline">
                    <input type="text" id="custName" class="form-control" placeholder=" " autocomplete="off">
                    <input type="hidden" id="customerId" value="0">
                    <label>Customer Name</label>
                </div>

                <!-- Phone Number -->
                <div class="col-md-4 col-sm-6 input-outline">
                    <input type="text" id="custPhone" class="form-control" placeholder=" " autocomplete="off" maxlength="15">
                    <label>Phone Number</label>
                </div>

                <!-- Bill Date -->
                <div class="col-md-4 col-sm-6 input-outline">
                    <input type="date" id="billDate" class="form-control" placeholder=" ">
                    <label>Bill Date</label>
                </div>

                <!-- Bill Time -->
                <div class="col-md-3 col-sm-6 input-outline">
                    <input type="text" id="billTime" class="form-control" placeholder="15:38:45" readonly style="background:#f9f7f0;">
                    <label>Bill Time</label>
                </div>

                <!-- ID Proof Number -->
                <div class="col-md-5 col-sm-6 input-outline">
                    <input type="text" id="idProofNo" class="form-control" placeholder=" ">
                    <label>ID Proof Number</label>
                </div>

                <!-- Address Proof Number -->
                <div class="col-md-7 col-sm-6 input-outline">
                    <input type="text" id="addrProofNo" class="form-control" placeholder=" ">
                    <label>Address Proof Number</label>
                </div>

            </div>
        </div>

    </div>

    <!-- ══════════════ BILLING PARTICULARS ══════════════ -->
    <div class="gb-section">
        <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
            <div class="gb-section-title mb-0"><i class="fas fa-layer-group me-2"></i>Billing Particulars</div>
            <button class="btn-add-row" id="btnAddRow" type="button">
                <i class="fas fa-plus"></i> Add Row
            </button>
        </div>

        <div class="billing-table-wrap">
            <table class="billing-table" id="billingTable">
                <thead>
                    <tr>
                        <th style="width:36px;">#</th>
                        <th style="width:180px;">Ornament Type</th>
                        <th style="width:90px;">Gross Wt (g)</th>
                        <th style="width:90px;">Stone/Wax (g)</th>
                        <th style="width:90px;">Net Wt (g)</th>
                        <th style="width:90px;">Purity (%)</th>
                        <th style="width:120px; text-align:right;">Gross Amount</th>
                        <th style="width:40px;"></th>
                    </tr>
                </thead>
                <tbody id="billingBody">
                    <!-- rows injected by JS -->
                </tbody>
            </table>
        </div>

        <!-- Summary Panel -->
        <div style="display:flex; justify-content:flex-end; margin-top:14px;">
            <div style="background:#fff; border-radius:0.6rem; box-shadow:0 2px 12px rgba(26,37,64,0.1); overflow:hidden; min-width:320px;">
                <div style="background:linear-gradient(135deg,#1a2540,#1e2d55); padding:8px 16px; color:rgba(255,255,255,0.7); font-size:0.65rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; display:flex; justify-content:space-between;">
                    <span>Total Net Wt (g)</span>
                    <span id="totalNetWt" style="color:#ffe066;">0.000</span>
                </div>
                <table style="width:100%; border-collapse:collapse;">
                    <tr style="border-bottom:1px solid #f0ede0;">
                        <td style="padding:9px 16px; font-size:0.8rem; font-weight:600; color:#555; text-transform:uppercase; letter-spacing:0.5px;">Gross Amount</td>
                        <td style="padding:9px 16px; text-align:right; font-size:0.95rem; font-weight:800; color:#1a2540;" id="totalGrossAmt">&#8377; 0</td>
                    </tr>
                    <tr style="border-bottom:1px solid #f0ede0; background:#fafafa;">
                        <td style="padding:9px 16px; font-size:0.8rem; font-weight:600; color:#555; text-transform:uppercase; letter-spacing:0.5px;">Margin</td>
                        <td style="padding:6px 16px; text-align:right;">
                            <input type="number" id="marginInput" placeholder="0" min="0" step="1"
                                style="width:110px; border:1.5px solid #ddd; border-radius:0.4rem; padding:4px 8px; font-size:0.9rem; font-weight:700; color:#1a2540; text-align:right; outline:none;">
                        </td>
                    </tr>
                    <tr style="border-bottom:1px solid #f0ede0;">
                        <td style="padding:9px 16px; font-size:0.8rem; font-weight:600; color:#555; text-transform:uppercase; letter-spacing:0.5px;">Net Amount</td>
                        <td style="padding:9px 16px; text-align:right; font-size:0.95rem; font-weight:800; color:#1a2540;" id="netAmountDisplay">&#8377; 0</td>
                    </tr>
                    <tr style="border-bottom:1px solid #f0ede0; background:#fafafa;">
                        <td style="padding:9px 16px; font-size:0.8rem; font-weight:600; color:#555; text-transform:uppercase; letter-spacing:0.5px;">Release</td>
                        <td style="padding:6px 16px; text-align:right;">
                            <input type="number" id="releaseInput" placeholder="0" min="0" step="1"
                                style="width:110px; border:1.5px solid #ddd; border-radius:0.4rem; padding:4px 8px; font-size:0.9rem; font-weight:700; color:#1a2540; text-align:right; outline:none;">
                        </td>
                    </tr>
                    <tr style="background:linear-gradient(135deg,#1a2540,#1e2d55);">
                        <td style="padding:11px 16px; font-size:0.8rem; font-weight:700; color:rgba(255,255,255,0.8); text-transform:uppercase; letter-spacing:0.5px;">Amount Paid</td>
                        <td style="padding:11px 16px; text-align:right; font-size:1.05rem; font-weight:800; color:#6effa0;" id="amountPaidDisplay">&#8377; 0</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

    <!-- ══════════════ ACTION BAR ══════════════ -->
    <div class="submit-bar">
        <button class="btn-gb-reset" type="button" id="btnReset">
            <i class="fas fa-undo"></i> Reset
        </button>
        <button class="btn-gb-save" type="button" id="btnSave">
            <i class="fas fa-save"></i> Save Bill
        </button>
    </div>

</div><!-- /container -->

<!-- ══════════════ GOLD RATE MODAL ══════════════ -->
<div class="modal fade" id="goldRateModal" tabindex="-1" aria-labelledby="goldRateModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:380px;">
        <div class="modal-content" style="border:none; border-radius:1rem; overflow:hidden;">
            <div style="background:linear-gradient(135deg,#1a2540 0%,#c9a227 100%); padding:20px 24px 16px;">
                <div style="display:flex; align-items:center; justify-content:space-between;">
                    <span style="color:#fff; font-weight:700; font-size:1rem; letter-spacing:1px; text-transform:uppercase;">
                        <i class="fas fa-coins me-2" style="color:#ffe066;"></i>Update Gold Rate
                    </span>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div style="color:rgba(255,255,255,0.7); font-size:0.78rem; margin-top:4px;">Set today's gold rate per gram</div>
            </div>
            <div class="modal-body" style="padding:24px;">
                <div class="input-outline">
                    <input type="number" id="goldRateModalInput" class="form-control" placeholder=" " min="0" step="0.01" autocomplete="off" style="font-size:1.4rem; font-weight:700; color:#1a2540;">
                    <label>Gold Rate (₹ / gram)</label>
                </div>
                <div id="goldRateModalHint" style="font-size:0.75rem; color:#888; margin-top:8px;"></div>
            </div>
            <div class="modal-footer" style="border:none; padding:0 24px 20px; gap:10px;">
                <button type="button" class="btn-gb-reset" data-bs-dismiss="modal" style="flex:1;">Cancel</button>
                <button type="button" class="btn-gb-save" id="btnSetGoldRate" style="flex:2;">
                    <i class="fas fa-check"></i> Set Rate
                </button>
            </div>
        </div>
    </div>
</div>

<script>
(function () {
    "use strict";

    /* ── Set default date & time ── */
    (function setDefaults() {
        var now = new Date();
        var yyyy = now.getFullYear();
        var mm   = String(now.getMonth() + 1).padStart(2, '0');
        var dd   = String(now.getDate()).padStart(2, '0');
        document.getElementById('billDate').value = yyyy + '-' + mm + '-' + dd;

        // Initial time set
        updateBillTime();
    })();

    /* ── Update bill time every second ── */
    function updateBillTime() {
        var now = new Date();
        var hh = String(now.getHours()).padStart(2, '0');
        var mi = String(now.getMinutes()).padStart(2, '0');
        var ss = String(now.getSeconds()).padStart(2, '0');
        document.getElementById('billTime').value = hh + ':' + mi + ':' + ss;
    }
    
    // Update time every second
    setInterval(updateBillTime, 1000);

    /* ── Row management ── */
    var rowCount = 0;

    function createRow() {
        rowCount++;
        var idx = rowCount;
        var tr = document.createElement('tr');
        tr.setAttribute('data-row', idx);
        tr.innerHTML =
            '<td style="text-align:center;color:#888;font-size:0.75rem;" class="row-num">' + idx + '</td>' +
            '<td><input type="text"   class="row-input" data-col="ornament"  placeholder="e.g. Necklace" autocomplete="off"></td>' +
            '<td><input type="number" class="row-input" data-col="gross_wt"  placeholder="0.000" min="0" step="0.001" inputmode="decimal"></td>' +
            '<td><input type="number" class="row-input" data-col="stone_wax" placeholder="0.000" min="0" step="0.001" inputmode="decimal"></td>' +
            '<td><input type="number" class="row-input" data-col="net_wt"    placeholder="0.000" min="0" step="0.001" inputmode="decimal" readonly style="background:#f9f7f0;"></td>' +
            '<td><input type="number" class="row-input" data-col="purity"    placeholder="e.g. 91.6" min="0" max="100" step="0.01" inputmode="decimal"></td>' +
            '<td class="gross-amount-cell" data-col="gross_amount">0.00</td>' +
            '<td style="text-align:center;"><button class="btn-del-row" title="Delete row"><i class="fas fa-trash-alt"></i></button></td>';

        /* Auto-calc net weight */
        var grossWtInput  = tr.querySelector('[data-col="gross_wt"]');
        var stoneWaxInput = tr.querySelector('[data-col="stone_wax"]');
        var netWtInput    = tr.querySelector('[data-col="net_wt"]');
        var purityInput   = tr.querySelector('[data-col="purity"]');
        var grossAmtCell  = tr.querySelector('[data-col="gross_amount"]');

        function calcNet() {
            var g = parseFloat(grossWtInput.value)  || 0;
            var s = parseFloat(stoneWaxInput.value) || 0;
            var net = Math.max(0, g - s);
            netWtInput.value = net.toFixed(3);
            calcGrossAmt();
        }

        function calcGrossAmt() {
            var g       = parseFloat(grossWtInput.value)  || 0;
            var s       = parseFloat(stoneWaxInput.value) || 0;
            var purity  = parseFloat(purityInput.value)   || 0;
            var rate    = parseFloat(document.getElementById('goldRateInput').value) || 0;
            var amt     = Math.round((g - s) * (purity / 100) * rate);
            grossAmtCell.textContent = amt.toFixed(2);
            updateTotals();
        }

        grossWtInput.addEventListener('input', calcNet);
        stoneWaxInput.addEventListener('input', calcNet);
        purityInput.addEventListener('input', calcGrossAmt);

        /* Delete row */
        tr.querySelector('.btn-del-row').addEventListener('click', function () {
            if (document.querySelectorAll('#billingBody tr').length === 1) return; /* keep ≥1 row */
            tr.remove();
            reNumberRows();
            updateTotals();
        });

        /* Clear validation highlight on input */
        tr.querySelectorAll('.row-input').forEach(function (inp) {
            inp.addEventListener('input', function () { inp.classList.remove('is-invalid'); });
        });

        return tr;
    }

    function reNumberRows() {
        var rows = document.querySelectorAll('#billingBody tr');
        rows.forEach(function (r, i) {
            var numCell = r.querySelector('.row-num');
            if (numCell) numCell.textContent = i + 1;
            r.setAttribute('data-row', i + 1);
        });
        rowCount = rows.length;
    }

    function updateTotals() {
        var rows = document.querySelectorAll('#billingBody tr');
        var totalNet = 0, totalAmt = 0;
        rows.forEach(function (r) {
            totalNet += parseFloat(r.querySelector('[data-col="net_wt"]').value) || 0;
            totalAmt += parseFloat(r.querySelector('[data-col="gross_amount"]').textContent) || 0;
        });
        document.getElementById('totalNetWt').textContent  = totalNet.toFixed(3);
        document.getElementById('totalGrossAmt').textContent = '₹ ' + Math.round(totalAmt).toLocaleString('en-IN');
        calcSummary();
    }

    function calcSummary() {
        var gross   = parseFloat(document.getElementById('totalGrossAmt').textContent.replace(/[₹,\s]/g, '')) || 0;
        var margin  = parseFloat(document.getElementById('marginInput').value)  || 0;
        var netAmt  = gross - margin;
        var release = parseFloat(document.getElementById('releaseInput').value) || 0;
        var paid    = netAmt - release;
        document.getElementById('netAmountDisplay').textContent  = '₹ ' + Math.round(netAmt).toLocaleString('en-IN');
        document.getElementById('amountPaidDisplay').textContent = '₹ ' + Math.round(paid).toLocaleString('en-IN');
    }

    document.getElementById('marginInput').addEventListener('input', calcSummary);
    document.getElementById('releaseInput').addEventListener('input', calcSummary);

    /* ── Gold Rate Modal ── */
    function recalcAllRows() {
        var rate = parseFloat(document.getElementById('goldRateInput').value) || 0;
        document.querySelectorAll('#billingBody tr').forEach(function (r) {
            var g      = parseFloat(r.querySelector('[data-col="gross_wt"]').value)  || 0;
            var s      = parseFloat(r.querySelector('[data-col="stone_wax"]').value) || 0;
            var purity = parseFloat(r.querySelector('[data-col="purity"]').value)    || 0;
            r.querySelector('[data-col="gross_amount"]').textContent = Math.round((g - s) * (purity / 100) * rate).toFixed(2);
        });
        updateTotals();
    }

    document.getElementById('goldRateCard').addEventListener('click', function () {
        var current = parseFloat(document.getElementById('goldRateInput').value) || 0;
        var modalInput = document.getElementById('goldRateModalInput');
        modalInput.value = current > 0 ? current : '';
        document.getElementById('goldRateModalHint').textContent =
            current > 0 ? 'Current rate: ₹ ' + current.toFixed(2) + ' / gram' : '';
        var modal = new bootstrap.Modal(document.getElementById('goldRateModal'));
        modal.show();
        document.getElementById('goldRateModal').addEventListener('shown.bs.modal', function () {
            modalInput.focus();
            modalInput.select();
        }, { once: true });
    });

    document.getElementById('btnSetGoldRate').addEventListener('click', function () {
        var val = parseFloat(document.getElementById('goldRateModalInput').value);
        if (!val || val <= 0) {
            document.getElementById('goldRateModalInput').classList.add('is-invalid');
            return;
        }
        document.getElementById('goldRateModalInput').classList.remove('is-invalid');

        var btn = document.getElementById('btnSetGoldRate');
        btn.disabled = true;

        fetch('<%= request.getContextPath() %>/gold/goldBill/saveGoldRate.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'rate=' + encodeURIComponent(val)
        })
        .then(function (r) {
            if (!r.ok) throw new Error('Server returned HTTP ' + r.status);
            return r.text();
        })
        .then(function (txt) {
            var data;
            try {
                data = JSON.parse(txt);
            } catch (e) {
                throw new Error('Invalid server response: ' + txt);
            }
            return data;
        })
        .then(function (data) {
            btn.disabled = false;
            if (data.status === 'ok') {
                /* Use rate returned by server — not from a secondary fetch */
                var savedRate = parseFloat(data.rate);
                document.getElementById('goldRateInput').value = savedRate;
                document.getElementById('goldRateDisplay').textContent =
                    savedRate.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                recalcAllRows();
                bootstrap.Modal.getInstance(document.getElementById('goldRateModal')).hide();
                Swal.fire({
                    toast: true,
                    position: 'top-end',
                    icon: 'success',
                    title: 'Gold rate saved: ₹ ' + savedRate.toLocaleString('en-IN', { minimumFractionDigits: 2 }),
                    showConfirmButton: false,
                    timer: 2500,
                    timerProgressBar: true
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Rate Not Saved',
                    text: data.msg || 'Could not save rate to database.',
                    confirmButtonColor: '#c9a227'
                });
            }
        })
        .catch(function (e) {
            btn.disabled = false;
            /* Network/parse error — do NOT update UI */
            Swal.fire({
                icon: 'error',
                title: 'Network Error',
                text: 'Rate was NOT saved. Please try again.\n' + e.message,
                confirmButtonColor: '#c9a227'
            });
        });
    });

    /* ── Gold Rate: load latest from DB on page load ── */
    function loadLatestGoldRate(callback) {
        fetch('<%= request.getContextPath() %>/gold/goldBill/getLatestGoldRate.jsp')
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.status === 'ok' && parseFloat(data.rate) > 0) {
                    var rate = parseFloat(data.rate);
                    document.getElementById('goldRateInput').value = rate;
                    document.getElementById('goldRateDisplay').textContent =
                        rate.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                    recalcAllRows();
                }
                if (callback) callback();
            })
            .catch(function () { if (callback) callback(); });
    }
    loadLatestGoldRate();

    /* ── Load latest bill number on page load ── */
    function loadLatestBillNo() {
        fetch('<%= request.getContextPath() %>/gold/goldBill/getLatestBillNo.jsp')
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.status === 'ok' && data.bill_no && data.bill_no !== '0') {
                    document.getElementById('lastBillNo').textContent = data.bill_no;
                    document.getElementById('lastBillNoDisplay').style.display = 'block';
                }
            })
            .catch(function (e) { console.error('Failed to load last bill no:', e); });
    }
    loadLatestBillNo();

    /* Allow Enter key in modal input */
    document.getElementById('goldRateModalInput').addEventListener('keydown', function (e) {
        if (e.key === 'Enter') document.getElementById('btnSetGoldRate').click();
    });
    document.getElementById('btnAddRow').addEventListener('click', function () {
        var tbody = document.getElementById('billingBody');
        var row = createRow();
        tbody.appendChild(row);
        row.querySelector('[data-col="ornament"]').focus();
    });

    /* Initial first row */
    document.getElementById('billingBody').appendChild(createRow());

    /* ── Validation ── */
    function validateForm() {
        var valid = true;

        /* Customer name */
        var cn = document.getElementById('custName');
        if (!cn.value.trim()) { cn.classList.add('is-invalid'); valid = false; }
        else cn.classList.remove('is-invalid');

        /* Billing rows */
        var rows = document.querySelectorAll('#billingBody tr');
        rows.forEach(function (r) {
            var ornament  = r.querySelector('[data-col="ornament"]');
            var grossWt   = r.querySelector('[data-col="gross_wt"]');
            var grossAmt  = parseFloat(r.querySelector('[data-col="gross_amount"]').textContent) || 0;

            if (!ornament.value.trim()) { ornament.classList.add('is-invalid'); valid = false; }
            if (!(parseFloat(grossWt.value) >= 0)) { grossWt.classList.add('is-invalid'); valid = false; }
            if (grossAmt <= 0) {
                r.querySelector('[data-col="gross_amount"]').style.color = '#f87171';
                valid = false;
            } else {
                r.querySelector('[data-col="gross_amount"]').style.color = '';
            }
        });

        if (!valid) {
            Swal.fire({
                icon: 'warning',
                title: 'Incomplete Entry',
                text: 'Please fill all required fields. Gross Amount must be greater than 0.',
                confirmButtonColor: '#c9a227'
            });
        }
        return valid;
    }

    /* ── Save ── */
    document.getElementById('btnSave').addEventListener('click', function () {
        // Check if opening balance is required
        if (openingBalanceRequired && !openingBalanceCancelled) {
            showOpeningBalanceModal(function() {
                // User cancelled - show warning
                Swal.fire({
                    icon: 'warning',
                    title: 'Opening Balance Required',
                    text: 'Please enter opening balance before saving bills.',
                    confirmButtonColor: '#c9a227'
                });
            });
            return;
        }
        
        if (!validateForm()) return;

        /* Collect items */
        var itemsArr = [];
        document.querySelectorAll('#billingBody tr').forEach(function (r) {
            itemsArr.push({
                ornament:     r.querySelector('[data-col="ornament"]').value.trim(),
                gross_wt:     parseFloat(r.querySelector('[data-col="gross_wt"]').value)    || 0,
                stone_wax:    parseFloat(r.querySelector('[data-col="stone_wax"]').value)   || 0,
                net_wt:       parseFloat(r.querySelector('[data-col="net_wt"]').value)      || 0,
                purity:       parseFloat(r.querySelector('[data-col="purity"]').value)      || 0,
                gross_amount: parseFloat(r.querySelector('[data-col="gross_amount"]').textContent) || 0
            });
        });

        /* Parse summary values (strip ₹ and commas) */
        function parseAmt(id) {
            return parseFloat(document.getElementById(id).textContent.replace(/[₹,\s]/g,'')) || 0;
        }

        var payload = new URLSearchParams();
        payload.append('customerId',   document.getElementById('customerId').value || '0');
        payload.append('customerName',  document.getElementById('custName').value.trim());
        payload.append('customerPhone', document.getElementById('custPhone').value.trim());
        payload.append('idProofNo',     document.getElementById('idProofNo').value.trim());
        payload.append('addrProofNo',   document.getElementById('addrProofNo').value.trim());
        payload.append('goldRate',      document.getElementById('goldRateInput').value || '0');
        payload.append('grossAmount',   parseAmt('totalGrossAmt'));
        payload.append('margin',        parseFloat(document.getElementById('marginInput').value)  || 0);
        payload.append('netAmount',     parseAmt('netAmountDisplay'));
        payload.append('releaseAmount', parseFloat(document.getElementById('releaseInput').value) || 0);
        payload.append('amountPaid',    parseAmt('amountPaidDisplay'));
        payload.append('billDate',      document.getElementById('billDate').value);
        payload.append('billTime',      document.getElementById('billTime').value);
        payload.append('items',         JSON.stringify(itemsArr));

        var btn = document.getElementById('btnSave');
        btn.disabled = true;

        fetch('<%= request.getContextPath() %>/gold/goldBill/saveBill.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: payload.toString()
        })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            btn.disabled = false;
            if (data.status === 'ok') {
                /* Update last bill number display */
                if (data.bill_no) {
                    document.getElementById('lastBillNo').textContent = data.bill_no;
                    document.getElementById('lastBillNoDisplay').style.display = 'block';
                }
                Swal.fire({
                    icon: 'success',
                    title: 'Bill Saved!',
                    text: 'Bill #' + (data.bill_no || data.bill_id) + ' saved successfully.',
                    confirmButtonColor: '#c9a227',
                    confirmButtonText: 'Print Bill'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        window.open('<%= request.getContextPath() %>/gold/goldBill/print.jsp?id=' + data.bill_id, '_blank');
                    }
                });
            } else {
                Swal.fire({ icon: 'error', title: 'Error', text: data.msg || 'Save failed.', confirmButtonColor: '#c9a227' });
            }
        })
        .catch(function (e) {
            btn.disabled = false;
            Swal.fire({ icon: 'error', title: 'Network Error', text: e.message, confirmButtonColor: '#c9a227' });
        });
    });

    /* ── Reset ── */
    document.getElementById('btnReset').addEventListener('click', function () {
        Swal.fire({
            title: 'Reset Form?',
            text: 'All entered data will be cleared.',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#c9a227',
            cancelButtonColor: '#aaa',
            confirmButtonText: 'Yes, Reset'
        }).then(function (result) {
            if (result.isConfirmed) {
                document.getElementById('customerId').value = '0';
                document.getElementById('custName').value   = '';
                document.getElementById('custPhone').value  = '';
                document.getElementById('idProofNo').value  = '';
                document.getElementById('addrProofNo').value = '';
                document.getElementById('goldRateInput').value = '0';
                document.getElementById('goldRateDisplay').textContent = '0.00';
                document.getElementById('marginInput').value = '';
                document.getElementById('releaseInput').value = '';
                document.getElementById('netAmountDisplay').textContent = '₹ 0';
                document.getElementById('amountPaidDisplay').textContent = '₹ 0';
                var tbody = document.getElementById('billingBody');
                tbody.innerHTML = '';
                rowCount = 0;
                tbody.appendChild(createRow());
                updateTotals();
                (function setDefaults() {
                    var now = new Date();
                    var yyyy = now.getFullYear();
                    var mm   = String(now.getMonth() + 1).padStart(2, '0');
                    var dd   = String(now.getDate()).padStart(2, '0');
                    document.getElementById('billDate').value = yyyy + '-' + mm + '-' + dd;
                    updateBillTime();
                })();
            }
        });
    });

    /* ── Customer Autocomplete ── */
    var custACTimeout;
    var custIdInput    = document.getElementById('customerId');
    var custNameInput  = document.getElementById('custName');
    var custPhoneInput = document.getElementById('custPhone');

    /* ── Name input ── */
    custNameInput.addEventListener('input', function () {
        var query = this.value.trim();
        custIdInput.value = '0';
        clearTimeout(custACTimeout);
        removeCustDropdown('name');
        if (query.length < 2) return;
        custACTimeout = setTimeout(function () {
            fetch('<%= request.getContextPath() %>/gold/goldBill/customerAutocomplete.jsp?query=' + encodeURIComponent(query))
                .then(function (r) { return r.json(); })
                .then(function (data) { if (data.length > 0) showCustDropdown(data, 'name'); })
                .catch(function (e) { console.error(e); });
        }, 300);
    });

    /* ── Phone input ── */
    custPhoneInput.addEventListener('input', function () {
        var phone = this.value.trim();
        custIdInput.value = '0';
        clearTimeout(custACTimeout);
        removeCustDropdown('phone');
        if (phone.length < 3) return;
        custACTimeout = setTimeout(function () {
            fetch('<%= request.getContextPath() %>/gold/goldBill/customerAutocomplete.jsp?phone=' + encodeURIComponent(phone))
                .then(function (r) { return r.json(); })
                .then(function (data) { if (data.length > 0) showCustDropdown(data, 'phone'); })
                .catch(function (e) { console.error(e); });
        }, 300);
    });

    function showCustDropdown(customers, trigger) {
        removeCustDropdown(trigger);
        var anchor = trigger === 'phone' ? custPhoneInput : custNameInput;
        var ul = document.createElement('ul');
        ul.id = 'custDropdown_' + trigger;
        ul.style.cssText = 'position:absolute;top:100%;left:0;z-index:9999;background:#fff;border:1.5px solid #c9a22760;border-radius:0.4rem;list-style:none;padding:0;margin:0;max-height:220px;overflow-y:auto;box-shadow:0 4px 14px rgba(0,0,0,0.12);min-width:260px;';
        customers.forEach(function (c) {
            var li = document.createElement('li');
            li.style.cssText = 'padding:8px 14px;cursor:pointer;border-bottom:1px solid #f0ede0;font-size:0.82rem;color:#1a2540;display:flex;justify-content:space-between;gap:16px;';
            li.innerHTML = '<span style="font-weight:600;">' + c.name + '</span>' +
                           (c.phone && c.phone !== '-' ? '<span style="color:#888;font-size:0.75rem;">' + c.phone + '</span>' : '');
            li.addEventListener('mouseenter', function () { this.style.background = '#fef9ec'; });
            li.addEventListener('mouseleave', function () { this.style.background = ''; });
            li.addEventListener('mousedown', function (e) {
                e.preventDefault();
                selectCust(c, trigger);
            });
            ul.appendChild(li);
        });
        anchor.parentElement.style.position = 'relative';
        anchor.parentElement.appendChild(ul);
    }

    function selectCust(c, trigger) {
        custIdInput.value   = (c.id != null ? c.id : 0);
        custNameInput.value  = c.name;
        custPhoneInput.value = (c.phone && c.phone !== '-') ? c.phone : '';
        removeCustDropdown('name');
        removeCustDropdown('phone');
    }

    function removeCustDropdown(trigger) {
        var existing = document.getElementById('custDropdown_' + trigger);
        if (existing) existing.remove();
    }

    document.addEventListener('click', function (e) {
        if (e.target !== custNameInput)  removeCustDropdown('name');
        if (e.target !== custPhoneInput) removeCustDropdown('phone');
    });

})();
</script>

<!-- Opening Balance Modal -->
<jsp:include page="openingBalanceModal.jsp" />

<script>
// Check opening balance on page load
document.addEventListener('DOMContentLoaded', function() {
    checkOpeningBalance();
});
</script>

</body>
</html>
