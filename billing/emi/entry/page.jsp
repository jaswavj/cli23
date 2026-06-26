<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>EMI Entry - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .emi-form-card { max-width: 900px; margin: 0 auto; }
        .table td, .table th { vertical-align: middle; }
        .badge-pending { background: #fef3c7; color: #92400e; border: 1px solid #fcd34d; padding: 4px 10px; border-radius: 999px; font-size: 0.8rem; font-weight: 600; }
        .badge-borrow { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 4px 10px; border-radius: 999px; font-size: 0.78rem; font-weight: 600; }
        .badge-give { background: #dbeafe; color: #1e40af; border: 1px solid #bfdbfe; padding: 4px 10px; border-radius: 999px; font-size: 0.78rem; font-weight: 600; }
        .badge-completed { background: #dcfce7; color: #166534; border: 1px solid #86efac; padding: 4px 10px; border-radius: 999px; font-size: 0.78rem; font-weight: 600; }
        .badge-normal { background: #e0e7ff; color: #3730a3; border: 1px solid #c7d2fe; padding: 4px 10px; border-radius: 999px; font-size: 0.78rem; font-weight: 600; }
        .badge-interest { background: #ffedd5; color: #9a3412; border: 1px solid #fed7aa; padding: 4px 10px; border-radius: 999px; font-size: 0.78rem; font-weight: 600; }
        .badge-ongoing { background: #f3e8ff; color: #6b21a8; border: 1px solid #e9d5ff; padding: 4px 10px; border-radius: 999px; font-size: 0.78rem; font-weight: 600; }
        .inst-paid { color: #0f766e; font-weight: 600; }
        .inst-pending { color: #b45309; font-weight: 600; }
        .schedule-wrap { max-height: 220px; overflow: auto; border: 1px solid #dbe7e5; border-radius: 8px; }
        .emi-tab-btn.active { background: #1f2f57; color: #fff; border-color: #1f2f57; }
        .emi-tab-pane { display: none; }
        .emi-tab-pane.active { display: block; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "EMI Entry");
    request.setAttribute("pageSubtitle", "Add EMI & collect monthly payments");
    request.setAttribute("pageIcon",     "fa-solid fa-calendar-check");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>

<div class="container-fluid mt-3 mst-page" style="max-width: 1400px;">
<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mb-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="row g-4">
        <div class="col-12">
            <div class="card emi-form-card">
                <div class="card-body p-4">
                    <h5 class="mb-3">New EMI Entry</h5>
                    <form id="emiForm" action="<%=contextPath%>/emi/entry/save.jsp" method="post" class="row g-3">
                        <div class="col-12 input-outline">
                            <input type="text" name="customerName" id="customerName" class="form-control" required placeholder="">
                            <label>Customer Name</label>
                        </div>
                        <div class="col-12 input-outline">
                            <input type="text" name="phoneNumber" id="phoneNumber" class="form-control" placeholder="">
                            <label>Phone Number (optional)</label>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Type</label>
                            <select name="emiType" id="emiType" class="form-select" required>
                                <option value="borrow">Borrow</option>
                                <option value="give">Give</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Dept Type</label>
                            <select name="deptType" id="deptType" class="form-select" required>
                                <option value="normal">Normal</option>
                                <option value="interest">Interest</option>
                            </select>
                        </div>
                        <div class="col-md-6 input-outline">
                            <input type="number" name="totalAmount" id="totalAmount" class="form-control" min="0.01" step="0.01" required placeholder="">
                            <label>Total Amount</label>
                        </div>
                        <div class="col-md-6 input-outline normal-field">
                            <input type="number" name="emiAmount" id="emiAmount" class="form-control" min="0.01" step="0.01" required placeholder="">
                            <label>EMI Amount (monthly)</label>
                        </div>
                        <div class="col-md-6 input-outline normal-field">
                            <input type="number" name="emiMonths" id="emiMonths" class="form-control" min="1" step="1" required placeholder="">
                            <label>EMI Months</label>
                        </div>
                        <div class="col-md-6 input-outline interest-field" style="display:none;">
                            <input type="number" name="interestPerMonth" id="interestPerMonth" class="form-control" min="0.01" step="0.01" placeholder="">
                            <label>Interest Per Month</label>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" id="dueDateLabel">First Due Date</label>
                            <input type="date" name="firstDueDate" id="firstDueDate" class="form-control" required>
                            <small class="text-muted" id="dueDateHint">Next months will be due on the same day each month.</small>
                        </div>
                        <div class="col-12">
                            <button type="submit" class="bb bb-primary w-100">Save EMI</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-12">
            <div class="card">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                        <h5 class="mb-0" id="emiListTitle">Pending EMI Customers</h5>
                        <div class="d-flex gap-2">
                            <button type="button" class="bb bb-outline btn-sm emi-tab-btn active" data-tab="pending">Pending</button>
                            <button type="button" class="bb bb-outline btn-sm emi-tab-btn" data-tab="completed">Completed</button>
                            <button type="button" class="bb bb-outline btn-sm" onclick="refreshActiveTab()">
                                <i class="fa-solid fa-rotate"></i> Refresh
                            </button>
                        </div>
                    </div>

                    <div id="pendingPane" class="emi-tab-pane active">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0 mst-table">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Customer</th>
                                        <th>Type</th>
                                        <th>Dept</th>
                                        <th class="text-end">Total</th>
                                        <th>Phone</th>
                                        <th class="text-end">Monthly</th>
                                        <th class="text-center">Pending</th>
                                        <th>Next Due</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody id="pendingBody">
                                    <tr><td colspan="10" class="text-center text-muted py-4">Loading...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div id="completedPane" class="emi-tab-pane">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0 mst-table">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Customer</th>
                                        <th>Type</th>
                                        <th>Dept</th>
                                        <th class="text-end">Total</th>
                                        <th>Phone</th>
                                        <th class="text-end">Monthly</th>
                                        <th class="text-center">Paid</th>
                                        <th>Completed On</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody id="completedBody">
                                    <tr><td colspan="10" class="text-center text-muted py-4">Loading...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    var contextPath = "<%=contextPath%>";
    var activeTab = "pending";

    function formatMoney(val) {
        var n = parseFloat(val);
        if (isNaN(n)) return "0.00";
        return n.toFixed(2);
    }

    function formatDisplayDate(raw) {
        if (!raw) return "";
        var m = String(raw).trim().match(/^(\d{4})-(\d{2})-(\d{2})/);
        if (!m) return raw;
        return m[3] + "-" + m[2] + "-" + m[1];
    }

    function escAttr(val) {
        return String(val == null ? "" : val)
            .replace(/&/g, "&amp;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;")
            .replace(/</g, "&lt;");
    }

    function loadPendingEmi() {
        fetch(contextPath + "/emi/entry/getData.jsp?mode=pending", { credentials: "same-origin" })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data || !data.success) {
                throw new Error(data && data.message ? data.message : "Unable to load pending EMI");
            }
            renderPending(data.rows || []);
        })
        .catch(function(err) {
            Swal.fire("Error", err.message || "Unable to load pending EMI", "error");
        });
    }

    function loadCompletedEmi() {
        fetch(contextPath + "/emi/entry/getData.jsp?mode=completed", { credentials: "same-origin" })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data || !data.success) {
                throw new Error(data && data.message ? data.message : "Unable to load completed EMI");
            }
            renderCompleted(data.rows || []);
        })
        .catch(function(err) {
            Swal.fire("Error", err.message || "Unable to load completed EMI", "error");
        });
    }

    function emiTypeLabel(type) {
        var t = String(type || "").toLowerCase();
        if (t === "give") {
            return "<span class='badge-give'>Give</span>";
        }
        return "<span class='badge-borrow'>Borrow</span>";
    }

    function deptTypeLabel(type) {
        var t = String(type || "").toLowerCase();
        if (t === "interest") {
            return "<span class='badge-interest'>Interest</span>";
        }
        return "<span class='badge-normal'>Normal</span>";
    }

    function isInterestDept(type) {
        return String(type || "").toLowerCase() === "interest";
    }

    function monthlyDisplay(r) {
        if (isInterestDept(r.deptType)) {
            return formatMoney(r.interestPerMonth || r.emiAmount);
        }
        return formatMoney(r.emiAmount);
    }

    function pendingStatusDisplay(r) {
        if (isInterestDept(r.deptType)) {
            return "<span class='badge-ongoing'>Ongoing (" + (r.paidCount || 0) + " paid)</span>";
        }
        return "<span class='badge-pending'>" + (r.pendingCount || 0) + " / " + (r.emiMonths || 0) + "</span>";
    }

    function completedStatusDisplay(r) {
        if (isInterestDept(r.deptType)) {
            return "<span class='badge-completed'>" + (r.paidCount || 0) + " paid</span>";
        }
        return "<span class='badge-completed'>" + (r.paidCount || 0) + " / " + (r.emiMonths || 0) + "</span>";
    }

    function renderPending(rows) {
        var tbody = document.getElementById("pendingBody");
        if (!rows.length) {
            tbody.innerHTML = '<tr><td colspan="10" class="text-center text-muted py-4">No pending EMI customers</td></tr>';
            return;
        }
        var html = "";
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var payAmount = isInterestDept(r.deptType) ? (r.interestPerMonth || r.emiAmount) : r.emiAmount;
            html += "<tr>";
            html += "<td>" + (i + 1) + "</td>";
            html += "<td><strong>" + (r.customerName || "") + "</strong></td>";
            html += "<td>" + emiTypeLabel(r.emiType) + "</td>";
            html += "<td>" + deptTypeLabel(r.deptType) + "</td>";
            html += "<td class='text-end'>" + formatMoney(r.totalAmount) + "</td>";
            html += "<td>" + (r.phoneNumber || "-") + "</td>";
            html += "<td class='text-end'>" + monthlyDisplay(r) + "</td>";
            html += "<td class='text-center'>" + pendingStatusDisplay(r) + "</td>";
            html += "<td>" + formatDisplayDate(r.nextDueDate) + " <small class='text-muted'>(#" + (r.nextInstallmentNo || "") + ")</small></td>";
            html += "<td>";
            html += "<button type='button' class='bb bb-primary btn-sm me-1 pay-emi-btn' " +
                "data-installment-id='" + escAttr(r.nextInstallmentId) + "' " +
                "data-customer-name='" + escAttr(r.customerName) + "' " +
                "data-amount='" + escAttr(payAmount) + "' " +
                "data-due-date='" + escAttr(formatDisplayDate(r.nextDueDate)) + "' " +
                "data-installment-no='" + escAttr(r.nextInstallmentNo) + "'>Pay</button>";
            if (isInterestDept(r.deptType)) {
                html += "<button type='button' class='bb bb-outline btn-sm me-1 close-emi-btn' " +
                    "data-customer-id='" + escAttr(r.emiCustomerId) + "' " +
                    "data-customer-name='" + escAttr(r.customerName) + "'>Close</button>";
            }
            html += "<button type='button' class='bb bb-outline btn-sm view-schedule-btn' " +
                "data-customer-id='" + escAttr(r.emiCustomerId) + "' " +
                "data-customer-name='" + escAttr(r.customerName) + "'>Schedule</button>";
            html += "</td>";
            html += "</tr>";
        }
        tbody.innerHTML = html;
    }

    function renderCompleted(rows) {
        var tbody = document.getElementById("completedBody");
        if (!rows.length) {
            tbody.innerHTML = '<tr><td colspan="10" class="text-center text-muted py-4">No completed EMI customers</td></tr>';
            return;
        }
        var html = "";
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            html += "<tr>";
            html += "<td>" + (i + 1) + "</td>";
            html += "<td><strong>" + (r.customerName || "") + "</strong></td>";
            html += "<td>" + emiTypeLabel(r.emiType) + "</td>";
            html += "<td>" + deptTypeLabel(r.deptType) + "</td>";
            html += "<td class='text-end'>" + formatMoney(r.totalAmount) + "</td>";
            html += "<td>" + (r.phoneNumber || "-") + "</td>";
            html += "<td class='text-end'>" + monthlyDisplay(r) + "</td>";
            html += "<td class='text-center'>" + completedStatusDisplay(r) + "</td>";
            html += "<td>" + formatDisplayDate(r.completedDate) + "</td>";
            html += "<td>";
            html += "<button type='button' class='bb bb-outline btn-sm view-schedule-btn' " +
                "data-customer-id='" + escAttr(r.emiCustomerId) + "' " +
                "data-customer-name='" + escAttr(r.customerName) + "'>Schedule</button>";
            html += "</td>";
            html += "</tr>";
        }
        tbody.innerHTML = html;
    }

    function setActiveTab(tab) {
        activeTab = tab === "completed" ? "completed" : "pending";

        var pendingPane = document.getElementById("pendingPane");
        var completedPane = document.getElementById("completedPane");
        var title = document.getElementById("emiListTitle");
        var tabBtns = document.querySelectorAll(".emi-tab-btn");

        if (activeTab === "completed") {
            pendingPane.classList.remove("active");
            completedPane.classList.add("active");
            title.textContent = "Completed EMI Customers";
        } else {
            completedPane.classList.remove("active");
            pendingPane.classList.add("active");
            title.textContent = "Pending EMI Customers";
        }

        for (var i = 0; i < tabBtns.length; i++) {
            var btn = tabBtns[i];
            if (btn.getAttribute("data-tab") === activeTab) {
                btn.classList.add("active");
            } else {
                btn.classList.remove("active");
            }
        }

        refreshActiveTab();
    }

    function refreshActiveTab() {
        if (activeTab === "completed") {
            loadCompletedEmi();
            return;
        }
        loadPendingEmi();
    }

    document.getElementById("pendingBody").addEventListener("click", function(e) {
        var payBtn = e.target.closest(".pay-emi-btn");
        if (payBtn) {
            payEmi(
                payBtn.getAttribute("data-installment-id"),
                payBtn.getAttribute("data-customer-name"),
                payBtn.getAttribute("data-amount"),
                payBtn.getAttribute("data-due-date"),
                payBtn.getAttribute("data-installment-no")
            );
            return;
        }
        var closeBtn = e.target.closest(".close-emi-btn");
        if (closeBtn) {
            closeEmi(
                closeBtn.getAttribute("data-customer-id"),
                closeBtn.getAttribute("data-customer-name")
            );
            return;
        }
        var scheduleBtn = e.target.closest(".view-schedule-btn");
        if (scheduleBtn) {
            viewSchedule(
                scheduleBtn.getAttribute("data-customer-id"),
                scheduleBtn.getAttribute("data-customer-name")
            );
        }
    });

    document.getElementById("completedBody").addEventListener("click", function(e) {
        var scheduleBtn = e.target.closest(".view-schedule-btn");
        if (scheduleBtn) {
            viewSchedule(
                scheduleBtn.getAttribute("data-customer-id"),
                scheduleBtn.getAttribute("data-customer-name")
            );
        }
    });

    document.querySelectorAll(".emi-tab-btn").forEach(function(btn) {
        btn.addEventListener("click", function() {
            setActiveTab(btn.getAttribute("data-tab"));
        });
    });

    function closeEmi(emiCustomerId, customerName) {
        Swal.fire({
            title: "Close EMI?",
            html: "<div style='text-align:left;line-height:1.7;'>" +
                "<strong>Customer:</strong> " + customerName + "<br>" +
                "This will stop future interest payments and move the account to completed." +
                "</div>",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Close EMI",
            confirmButtonColor: "#b45309"
        }).then(function(result) {
            if (!result.isConfirmed) return;

            var body = new URLSearchParams();
            body.append("mode", "close");
            body.append("emiCustomerId", String(emiCustomerId));

            fetch(contextPath + "/emi/entry/getData.jsp", {
                method: "POST",
                credentials: "same-origin",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: body.toString()
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success) {
                    throw new Error(data && data.message ? data.message : "Unable to close EMI");
                }
                Swal.fire("Closed", data.message || "EMI closed", "success");
                refreshActiveTab();
            })
            .catch(function(err) {
                Swal.fire("Error", err.message || "Unable to close EMI", "error");
            });
        });
    }

    function toggleDeptFields() {
        var deptType = document.getElementById("deptType").value;
        var isInterest = deptType === "interest";
        var normalFields = document.querySelectorAll(".normal-field");
        var interestFields = document.querySelectorAll(".interest-field");
        var emiAmount = document.getElementById("emiAmount");
        var emiMonths = document.getElementById("emiMonths");
        var interestPerMonth = document.getElementById("interestPerMonth");
        var dueDateLabel = document.getElementById("dueDateLabel");
        var dueDateHint = document.getElementById("dueDateHint");

        for (var i = 0; i < normalFields.length; i++) {
            normalFields[i].style.display = isInterest ? "none" : "";
        }
        for (var j = 0; j < interestFields.length; j++) {
            interestFields[j].style.display = isInterest ? "" : "none";
        }

        if (isInterest) {
            emiAmount.removeAttribute("required");
            emiMonths.removeAttribute("required");
            interestPerMonth.setAttribute("required", "required");
            dueDateLabel.textContent = "Due Date";
            dueDateHint.textContent = "Pay interest on this date every month until you close the account.";
        } else {
            emiAmount.setAttribute("required", "required");
            emiMonths.setAttribute("required", "required");
            interestPerMonth.removeAttribute("required");
            dueDateLabel.textContent = "First Due Date";
            dueDateHint.textContent = "Next months will be due on the same day each month.";
        }
    }

    function payEmi(installmentId, customerName, amount, dueDate, installmentNo) {
        Swal.fire({
            title: "Pay EMI?",
            html: "<div style='text-align:left;line-height:1.7;'>" +
                "<strong>Customer:</strong> " + customerName + "<br>" +
                "<strong>Installment:</strong> #" + installmentNo + "<br>" +
                "<strong>Due Date:</strong> " + dueDate + "<br>" +
                "<strong>Amount:</strong> " + formatMoney(amount) +
                "</div>",
            icon: "question",
            showCancelButton: true,
            confirmButtonText: "Mark as Paid",
            confirmButtonColor: "#0f766e"
        }).then(function(result) {
            if (!result.isConfirmed) return;

            var body = new URLSearchParams();
            body.append("mode", "pay");
            body.append("installmentId", String(installmentId));

            fetch(contextPath + "/emi/entry/getData.jsp", {
                method: "POST",
                credentials: "same-origin",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: body.toString()
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success) {
                    throw new Error(data && data.message ? data.message : "Unable to pay EMI");
                }
                Swal.fire("Success", data.message || "EMI paid", "success");
                refreshActiveTab();
            })
            .catch(function(err) {
                Swal.fire("Error", err.message || "Unable to pay EMI", "error");
            });
        });
    }

    function viewSchedule(emiCustomerId, customerName) {
        fetch(contextPath + "/emi/entry/getData.jsp?mode=schedule&emiCustomerId=" + emiCustomerId, { credentials: "same-origin" })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data || !data.success) {
                throw new Error(data && data.message ? data.message : "Unable to load schedule");
            }
            var rows = data.rows || [];
            var html = "<div class='schedule-wrap'><table class='table table-sm mb-0'><thead><tr>" +
                "<th>#</th><th>Due Date</th><th>Paid Date</th><th class='text-end'>Amount</th><th>Status</th></tr></thead><tbody>";
            if (!rows.length) {
                html += "<tr><td colspan='5' class='text-center text-muted py-3'>No schedule found</td></tr>";
            } else {
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    var paid = row.isPaid === "1" || row.isPaid === 1;
                    var paidDate = paid ? formatDisplayDate(row.paidDate) : "-";
                    html += "<tr>";
                    html += "<td>" + row.installmentNo + "</td>";
                    html += "<td>" + formatDisplayDate(row.dueDate) + "</td>";
                    html += "<td>" + paidDate + "</td>";
                    html += "<td class='text-end'>" + formatMoney(row.emiAmount) + "</td>";
                    html += "<td class='" + (paid ? "inst-paid" : "inst-pending") + "'>" + (paid ? "Paid" : "Pending") + "</td>";
                    html += "</tr>";
                }
            }
            html += "</tbody></table></div>";

            Swal.fire({
                title: customerName + " — EMI Schedule",
                html: html,
                width: 560,
                confirmButtonText: "Close"
            });
        })
        .catch(function(err) {
            Swal.fire("Error", err.message || "Unable to load schedule", "error");
        });
    }

    window.addEventListener("load", function() {
        var today = new Date();
        var yyyy = today.getFullYear();
        var mm = String(today.getMonth() + 1).padStart(2, "0");
        var dd = String(today.getDate()).padStart(2, "0");
        var firstDue = document.getElementById("firstDueDate");
        if (firstDue && !firstDue.value) {
            firstDue.value = yyyy + "-" + mm + "-" + dd;
        }
        document.getElementById("deptType").addEventListener("change", toggleDeptFields);
        toggleDeptFields();
        refreshActiveTab();
        document.getElementById("customerName").focus();
    });
</script>
</body>
</html>
