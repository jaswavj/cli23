<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page language="java" import="java.util.*" %>
<jsp:useBean id="user" class="user.userBean" />
<%
Integer uids = (Integer) session.getAttribute("userId");
 
// Check if session is null or expired
if (uids == null) {
    response.setContentType("text/html");
    out.println("<script type='text/javascript'>");
    out.println("Swal.fire({");
    out.println("  icon: 'warning',");
    out.println("  title: 'Session Expired',");
    out.println("  text: 'Your session has expired. Please login again.',");
    out.println("  confirmButtonText: 'OK',");
    out.println("  allowOutsideClick: false");
    out.println("}).then(function() {");
    out.println("  window.location.href = '" + request.getContextPath() + "/index.jsp';");
    out.println("});");
    out.println("</script>");
    return;
}

String userNameUni = user.getUserName(uids);
String head1 = user.getHead1();
String head2 = user.getHead2();
String head3 = user.getHead3();

Vector vecPer = user.getUserPermission(uids);
Set<Integer> permissions = new HashSet<Integer>();

for (int i = 0; i < vecPer.size(); i++) {
    Vector cat = (Vector) vecPer.get(i);
    int modId = Integer.parseInt(cat.elementAt(0).toString()); 
    permissions.add(modId);
}
%> 

<!-- Mobile Top Navbar (visible only on mobile) -->
<div class="mobile-top-navbar">
  <div class="mobile-nav-logo">
    <div class="logo-icon">
      <i class="fas fa-cash-register"></i>
    </div>
    <div class="mobile-nav-title">
      <div class="title">JASXBILL</div>
      <div class="subtitle">POS System</div>
    </div>
  </div>
  <div class="mobile-nav-user">
    <i class="fa-solid fa-user"></i>
    <span><%=userNameUni%></span>
  </div>
  <button class="mobile-nav-logout" onclick="handleLogout(); return false;" title="Logout">
    <i class="fa-solid fa-arrow-right-from-bracket"></i>
  </button>
  <button class="mobile-nav-toggle" id="mobileNavToggle" title="Menu">
    <i class="fas fa-bars"></i>
  </button>
</div>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
  <!-- Logo Section -->
  <div class="sidebar-header">
    <div class="sidebar-logo">
      
      <div class="logo-text">
        <div class="logo-title">JASXBILL</div>
        <div class="logo-subtitle">POS System</div>
      </div>
      <button class="sidebar-toggle-btn" id="sidebarToggle" title="Toggle Sidebar">
        <i class="fas fa-bars"></i>
      </button>
    </div>
  </div>
  
  <!-- User Section -->
  <div class="sidebar-user-section">
    <div class="user-info">
      <i class="fa-solid fa-user"></i>
      <span class="user-name"><%=userNameUni%></span>
    </div>
    <a href="#" onclick="handleLogout(); return false;" class="sidebar-logout-btn" title="Logout">
      <i class="fa-solid fa-arrow-right-from-bracket"></i>
      <span class="logout-text">Logout</span>
    </a>
  </div>
  
  <div class="sidebar-menu">
    <!-- Permission 1: Gold transaction -->
    <% if (permissions.contains(1)) { %>
    <a href="<%=request.getContextPath()%>/goldTransation/goldTrans/page.jsp" class="sidebar-item">
      <i class="fas fa-arrow-right-arrow-left"></i>
      <span>Gold Transaction</span>
    </a>
    <a href="<%=request.getContextPath()%>/goldTransation/report/page.jsp" class="sidebar-item">
      <i class="fas fa-chart-column"></i>
      <span>Gold Transaction Report</span>
    </a>
    <% } %>

    <!-- Permission 2: Gold and Master items as main menu -->
    <% if (permissions.contains(2)) { %>
    <a href="<%=request.getContextPath()%>/gold/goldBill/page.jsp" class="sidebar-item">
      <i class="fas fa-coins"></i>
      <span>Gold Buy Entry</span>
    </a>
    <% } %>

    <% if (permissions.contains(2)) { %>
    <a href="<%=request.getContextPath()%>/gold/report/billReport.jsp" class="sidebar-item">
      <i class="fas fa-file-invoice"></i>
      <span>Gold Bill Report</span>
    </a>
    <% } %>

    <% if (permissions.contains(2)) { %>
    <a href="<%=request.getContextPath()%>/gold/report/ledgerReport.jsp" class="sidebar-item">
      <i class="fas fa-book"></i>
      <span>Gold Ledger Report</span>
    </a>
    <% } %>

    <% if (permissions.contains(2)) { %>
    <a href="<%=request.getContextPath()%>/product/master/customer/page.jsp" class="sidebar-item">
      <i class="fas fa-users"></i>
      <span>Customers</span>
    </a>
    <% } %>

    <!-- 5: Expense items as main menu -->
    <% if (permissions.contains(12)) { %>
    <a href="<%=request.getContextPath()%>/expense/expenseType/expenseType.jsp" class="sidebar-item">
      <i class="fas fa-tags"></i>
      <span>Expense Type</span>
    </a>
    <% } %>

    <% if (permissions.contains(12)) { %>
    <a href="<%=request.getContextPath()%>/expense/expenseEntry/page.jsp" class="sidebar-item">
      <i class="fas fa-receipt"></i>
      <span>Expense Entry</span>
    </a>
    <% } %>

    <% if (permissions.contains(12)) { %>
    <a href="<%=request.getContextPath()%>/expense/expenseReport/page.jsp" class="sidebar-item">
      <i class="fas fa-chart-line"></i>
      <span>Expense Report</span>
    </a>
    <% } %>

    <!-- 6: Admin menu with dropdown (includes User Management + Company Details) -->
    <% if (permissions.contains(4) || permissions.contains(7)) { %>
    <div class="sidebar-dropdown">
      <a href="#" class="sidebar-item" data-bs-toggle="collapse" data-bs-target="#adminMenu">
        <i class="fas fa-user-shield"></i>
        <span>Admin</span>
        <i class="fas fa-chevron-down ms-auto"></i>
      </a>
      <div class="collapse sidebar-submenu" id="adminMenu">
        <% if (permissions.contains(4)) { %>
        <a href="<%=request.getContextPath()%>/admin/companyDetails/page.jsp" class="sidebar-subitem">Company Details</a>
        <% } %>
        <% if (permissions.contains(4)) { %>
        <a href="<%=request.getContextPath()%>/admin/userCreate/page.jsp" class="sidebar-subitem">Create User</a>
        <a href="<%=request.getContextPath()%>/admin/permission/page.jsp" class="sidebar-subitem">Module Permission</a>
        <a href="<%=request.getContextPath()%>/admin/changePassword/changePassword.jsp" class="sidebar-subitem">Change Password</a>
        <% } %>
      </div>
    </div>
    <% } %>
    
  </div>
</div>

<!-- Sidebar Overlay for Mobile -->
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebarOverlay = document.getElementById('sidebarOverlay');
    const body = document.body;
    
    // Check if we're on mobile
    function isMobile() {
        return window.innerWidth <= 768;
    }
    
    // Toggle sidebar (desktop toggle button)
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            if (isMobile()) {
                sidebar.classList.toggle('show');
                sidebarOverlay.classList.toggle('show');
                body.classList.toggle('sidebar-open');
            } else {
                sidebar.classList.toggle('hidden');
                body.classList.toggle('sidebar-hidden');
            }
        });
    }
    
    // Mobile nav toggle button
    if (mobileNavToggle) {
        mobileNavToggle.addEventListener('click', function() {
            sidebar.classList.toggle('show');
            sidebarOverlay.classList.toggle('show');
            body.classList.toggle('sidebar-open');
        });
    }
    
    // Close sidebar when clicking overlay (mobile)
    sidebarOverlay.addEventListener('click', function() {
        sidebar.classList.remove('show');
        sidebarOverlay.classList.remove('show');
        body.classList.remove('sidebar-open');
    });
    
    // Auto-close other menus when opening a new main menu
    const mainMenuToggles = document.querySelectorAll('.sidebar-item[data-bs-toggle="collapse"]');
    mainMenuToggles.forEach(toggle => {
        toggle.addEventListener('click', function(e) {
            const targetId = this.getAttribute('data-bs-target');
            
            // Close all other main menus (not submenus)
            mainMenuToggles.forEach(otherToggle => {
                const otherTargetId = otherToggle.getAttribute('data-bs-target');
                
                // Only close if it's a different main menu (not nested submenu)
                if (otherTargetId !== targetId && !otherToggle.closest('.sidebar-submenu')) {
                    const otherTarget = document.querySelector(otherTargetId);
                    if (otherTarget && otherTarget.classList.contains('show')) {
                        // Use Bootstrap's collapse hide method
                        const bsCollapse = bootstrap.Collapse.getInstance(otherTarget);
                        if (bsCollapse) {
                            bsCollapse.hide();
                        } else {
                            otherTarget.classList.remove('show');
                        }
                        otherToggle.setAttribute('aria-expanded', 'false');
                    }
                }
            });
        });
    });
    
    // Auto-close sibling submenus within the same parent menu
    const subMenuToggles = document.querySelectorAll('.sidebar-submenu-item > .sidebar-subitem[data-bs-toggle="collapse"]');
    subMenuToggles.forEach(toggle => {
        toggle.addEventListener('click', function(e) {
            const targetId = this.getAttribute('data-bs-target');
            const parentMenu = this.closest('.sidebar-submenu');
            
            if (parentMenu) {
                // Find all sibling submenu toggles within the same parent
                const siblingToggles = parentMenu.querySelectorAll('.sidebar-submenu-item > .sidebar-subitem[data-bs-toggle="collapse"]');
                
                siblingToggles.forEach(siblingToggle => {
                    const siblingTargetId = siblingToggle.getAttribute('data-bs-target');
                    
                    // Only close if it's a different submenu
                    if (siblingTargetId !== targetId) {
                        const siblingTarget = document.querySelector(siblingTargetId);
                        if (siblingTarget && siblingTarget.classList.contains('show')) {
                            const bsCollapse = bootstrap.Collapse.getInstance(siblingTarget);
                            if (bsCollapse) {
                                bsCollapse.hide();
                            } else {
                                siblingTarget.classList.remove('show');
                            }
                            siblingToggle.setAttribute('aria-expanded', 'false');
                        }
                    }
                });
            }
        });
    });
    
    // Highlight active menu based on current URL
    const currentPath = window.location.pathname;
    const allSubitems = sidebar.querySelectorAll('.sidebar-subitem');
    const allMainItems = sidebar.querySelectorAll('.sidebar-item');
    
    // Check subitems first
    allSubitems.forEach(subitem => {
        const href = subitem.getAttribute('href');
        if (href && currentPath.includes(href)) {
            subitem.classList.add('active');
            // Find and open parent collapse
            const parentCollapse = subitem.closest('.sidebar-submenu');
            if (parentCollapse) {
                parentCollapse.classList.add('show');
                // Add active class to parent menu item
                const parentToggle = parentCollapse.previousElementSibling;
                if (parentToggle) {
                    parentToggle.classList.add('active');
                    parentToggle.setAttribute('aria-expanded', 'true');
                }
            }
        }
    });
    
    // Check main items if no submenu is active
    allMainItems.forEach(item => {
        const href = item.getAttribute('href');
        if (href && href !== '#' && currentPath.includes(href)) {
            item.classList.add('active');
        }
    });
    
    // Close sidebar when clicking any link (mobile)
    // Use event delegation to handle dynamic changes and ensure navigation works
    sidebar.addEventListener('click', function(e) {
        // Find the closest anchor tag
        const link = e.target.closest('a');
        if (!link) return;
        
        // Check if it's a valid link for navigation
        const href = link.getAttribute('href');
        // Check if it's a toggle or a placeholder link
        const isToggle = link.hasAttribute('data-bs-toggle') || href === '#';
        
        if (href && !isToggle) {
            // If on mobile, close sidebar and navigate manually
            if (isMobile()) {
                e.preventDefault(); // Prevent default to avoid race conditions
                
                // Close sidebar
                sidebar.classList.remove('show');
                sidebarOverlay.classList.remove('show');
                body.classList.remove('sidebar-open');
                
                // Navigate manually
                window.location.href = href;
            }
        }
    });
    
    // Handle window resize
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            if (!isMobile()) {
                sidebar.classList.remove('show');
                sidebarOverlay.classList.remove('show');
                body.classList.remove('sidebar-open');
            }
        }, 250);
    });
});

// Logout function - works inside iframe
function handleLogout() {
    var contextPath = '<%=request.getContextPath()%>';
    // If inside iframe, redirect the top window
    if (window.top !== window.self) {
        window.top.location.href = contextPath + '/logout.jsp';
    } else {
        // If not in iframe, redirect normally
        window.location.href = contextPath + '/logout.jsp';
    }
}
</script>










