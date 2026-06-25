<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bank - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table td, .table th { vertical-align: middle; }
        .btn-edit { margin: 0 2px; }
        @media (max-width: 768px) {
            .container-fluid { padding-left: 0.5rem; padding-right: 0.5rem; }
            .col-md-6 { margin-bottom: 1rem; }
        }
    </style>
</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Bank");
    request.setAttribute("pageSubtitle", "Bank Management");
    request.setAttribute("pageIcon",     "fa-solid fa-building-columns");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />
<%
String msg  = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="container-fluid mt-4 mst-page" style="max-width: 1400px;">
        <div class="row g-4">
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-body">
                        <h5 id="formCardTitle" class="mb-3">Add Bank</h5>
                        <form id="bankForm" action="<%=contextPath%>/product/master/bank/page1.jsp" method="post" class="row g-3">
                            <div class="col-md-12 input-outline">
                                <input type="text" name="bankName" id="bankNameInput" class="form-control" placeholder="" required>
                                <label>Bank Name</label>
                            </div>

                            <div class="col-md-12" id="blockWrap" style="display:none;">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="block" name="block" value="block">
                                    <label class="form-check-label" for="block">Block Bank</label>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <input type="hidden" name="bankId" id="bankId" value="">
                                <button type="submit" id="submitBtn" class="bb bb-primary">Add Bank</button>
                                <button type="button" id="cancelBtn" class="bb bb-outline ms-2" style="display:none;" onclick="resetFormToAdd()">Cancel</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-body">
                        <h5 class="mb-3">Bank List</h5>
                        <div class="table-responsive">
                        <table class="table table-hover mb-0 mst-table" style="min-width: 400px;">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Functions</th>
                                    <th>Bank Name</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                Vector vec = prod.getConfigureBankDetailsList();
                                for (int i = 0; i < vec.size(); i++) {
                                    Vector vec1 = (Vector) vec.get(i);
                                    String bankName = vec1.elementAt(0).toString();
                                    int id = Integer.parseInt(vec1.elementAt(1).toString());
                                    String safeName = bankName.replace("\\", "\\\\").replace("'", "\\'").replace("\n", " ");
                                %>
                                <tr>
                                    <td><%=i+1%></td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-outline-warning btn-edit" onclick="populateForm(<%=id%>, '<%=safeName%>')">Edit</button>
                                    </td>
                                    <td><%=bankName%></td>
                                </tr>
                                <%
                                }
                                %>
                            </tbody>
                        </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        var contextPath = "<%=contextPath%>";

        function populateForm(id, name) {
            document.getElementById('bankForm').action = contextPath + '/product/master/bank/edit1.jsp';
            document.getElementById('bankNameInput').value = name;
            document.getElementById('bankId').value = id;
            document.getElementById('block').checked = false;
            document.getElementById('blockWrap').style.display = 'block';
            document.getElementById('submitBtn').textContent = 'Update Bank';
            document.getElementById('cancelBtn').style.display = 'inline-block';
            document.getElementById('formCardTitle').textContent = 'Edit Bank';
            document.getElementById('bankForm').scrollIntoView({ behavior: 'smooth' });
        }

        function resetFormToAdd() {
            document.getElementById('bankForm').action = contextPath + '/product/master/bank/page1.jsp';
            document.getElementById('bankForm').reset();
            document.getElementById('bankId').value = '';
            document.getElementById('blockWrap').style.display = 'none';
            document.getElementById('submitBtn').textContent = 'Add Bank';
            document.getElementById('cancelBtn').style.display = 'none';
            document.getElementById('formCardTitle').textContent = 'Add Bank';
        }

        window.addEventListener('load', function() {
            const sidebar = document.getElementById('sidebar');
            if (sidebar) {
                sidebar.classList.remove('show');
                if (window.innerWidth > 768) {
                    sidebar.classList.add('hidden');
                    document.body.classList.add('sidebar-hidden');
                }
            }
            const bankNameInput = document.getElementById('bankNameInput');
            if (bankNameInput) {
                bankNameInput.focus();
            }
        });
    </script>

<script>
  document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
  });
</script>
</body>
</html>
