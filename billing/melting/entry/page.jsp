<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Melting Entry - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .ml-total-box {
            background: linear-gradient(135deg, #fff6dc, #ffe49a);
            border: 1px solid #e6c772;
            border-radius: 10px;
            padding: 12px 16px;
            font-weight: 700;
            color: #5f4a13;
        }
        .ml-total-value {
            font-size: 1.35rem;
            color: #3f3410;
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle", "Melting Entry");
    request.setAttribute("pageSubtitle", "Record melting with purity and bonus calculation");
    request.setAttribute("pageIcon", "fa-solid fa-fire-flame-curved");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>

<div class="container-fluid mt-3 mst-page" style="max-width:900px;">
<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mb-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="card mst-card">
        <div class="mst-card-header">
            <h5 class="mb-0"><i class="fa-solid fa-fire-flame-curved me-2"></i>New Melting Entry</h5>
        </div>
        <div class="card-body p-4">
            <form id="meltingForm" action="<%=contextPath%>/melting/entry/save.jsp" method="post" class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Date</label>
                    <input type="date" name="entryDate" id="entryDate" class="form-control fg-inp" required value="<%=today%>">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Name</label>
                    <input type="text" name="name" id="name" class="form-control fg-inp" required placeholder="Enter name">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Gram</label>
                    <input type="number" name="gram" id="gram" class="form-control fg-inp" min="0.001" step="0.001" required placeholder="0.000">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Purity (%)</label>
                    <input type="number" name="purity" id="purity" class="form-control fg-inp" min="0" step="0.001" required placeholder="0.000">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Bonus (%)</label>
                    <input type="number" name="bonus" id="bonus" class="form-control fg-inp" min="0" step="0.001" value="0" placeholder="0.000">
                </div>
                <div class="col-12">
                    <div class="ml-total-box d-flex justify-content-between align-items-center">
                        <span>Total = Gram × (Purity + Bonus) %</span>
                        <span class="ml-total-value" id="totalDisplay">0.000</span>
                    </div>
                    <input type="hidden" name="total" id="total" value="0">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Melting</label>
                    <input type="text" name="melting" id="melting" class="form-control fg-inp" placeholder="Melting details">
                </div>
                <div class="col-12">
                    <label class="form-label fw-semibold">Notes</label>
                    <textarea name="notes" id="notes" class="form-control fg-inp" rows="3" placeholder="Notes"></textarea>
                </div>
                <div class="col-12 d-flex gap-2 justify-content-end mt-2">
                    <a href="<%=contextPath%>/melting/report/page.jsp" class="bb bb-outline">
                        <i class="fa-solid fa-chart-column me-1"></i>Report
                    </a>
                    <button type="reset" class="bb bb-outline" id="btnReset">
                        <i class="fa-solid fa-rotate-left me-1"></i>Reset
                    </button>
                    <button type="submit" class="bb bb-primary" id="btnSave">
                        <i class="fa-solid fa-floppy-disk me-1"></i>Save
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
(function() {
    "use strict";

    var gramEl = document.getElementById("gram");
    var purityEl = document.getElementById("purity");
    var bonusEl = document.getElementById("bonus");
    var totalEl = document.getElementById("total");
    var totalDisplay = document.getElementById("totalDisplay");

    function parseNum(v) {
        var n = parseFloat(v);
        return isNaN(n) ? 0 : n;
    }

    function calcTotal() {
        var gram = parseNum(gramEl.value);
        var purity = parseNum(purityEl.value);
        var bonus = parseNum(bonusEl.value);
        var total = gram * (purity + bonus) / 100;
        totalEl.value = total.toFixed(3);
        totalDisplay.textContent = total.toFixed(3);
    }

    [gramEl, purityEl, bonusEl].forEach(function(el) {
        el.addEventListener("input", calcTotal);
    });

    document.getElementById("btnReset").addEventListener("click", function() {
        setTimeout(calcTotal, 0);
    });

    document.getElementById("meltingForm").addEventListener("submit", function(e) {
        e.preventDefault();
        calcTotal();

        if (parseNum(gramEl.value) <= 0) {
            Swal.fire("Validation", "Enter valid gram", "warning");
            return;
        }
        if (document.getElementById("name").value.trim().length === 0) {
            Swal.fire("Validation", "Enter name", "warning");
            return;
        }

        var btnSave = document.getElementById("btnSave");
        btnSave.disabled = true;

        var body = new URLSearchParams(new FormData(document.getElementById("meltingForm")));

        fetch("<%=contextPath%>/melting/entry/save.jsp", {
            method: "POST",
            credentials: "same-origin",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: body.toString()
        })
        .then(function(r) {
            return r.text().then(function(text) {
                try {
                    return JSON.parse(text);
                } catch (parseErr) {
                    throw new Error("Invalid server response. Deploy meltingBean.class and run melting_entry SQL.");
                }
            });
        })
        .then(function(data) {
            btnSave.disabled = false;
            if (!data || !data.success) {
                throw new Error(data && data.message ? data.message : "Unable to save melting entry");
            }
            Swal.fire({
                icon: "success",
                title: "Saved",
                text: data.message || "Melting entry saved successfully",
                confirmButtonColor: "#1f5a58"
            }).then(function() {
                document.getElementById("meltingForm").reset();
                document.getElementById("entryDate").value = "<%=today%>";
                document.getElementById("bonus").value = "0";
                calcTotal();
                document.getElementById("name").focus();
            });
        })
        .catch(function(err) {
            btnSave.disabled = false;
            Swal.fire({
                icon: "error",
                title: "Save Failed",
                text: err.message || "Unable to save melting entry",
                confirmButtonColor: "#1f5a58"
            });
        });
    });

    calcTotal();
    document.getElementById("name").focus();
})();
</script>
</body>
</html>
