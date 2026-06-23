<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*, java.sql.*, javax.naming.*, javax.sql.*" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<jsp:useBean id="userBean" class="user.userBean" />
<%!
    // Number to Words conversion (Indian numbering system)
    public String convertToWords(long number) {
        if (number == 0) return "ZERO";
        
        String[] ones = {"", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"};
        String[] teens = {"TEN", "ELEVEN", "TWELVE", "THIRTEEN", "FOURTEEN", "FIFTEEN", "SIXTEEN", "SEVENTEEN", "EIGHTEEN", "NINETEEN"};
        String[] tens = {"", "", "TWENTY", "THIRTY", "FORTY", "FIFTY", "SIXTY", "SEVENTY", "EIGHTY", "NINETY"};
        
        StringBuilder words = new StringBuilder();
        
        if (number >= 10000000) {
            long crores = number / 10000000;
            words.append(convertToWords(crores)).append(" CRORE ");
            number %= 10000000;
        }
        
        if (number >= 100000) {
            long lakhs = number / 100000;
            words.append(convertToWords(lakhs)).append(" LAKH ");
            number %= 100000;
        }
        
        if (number >= 1000) {
            long thousands = number / 1000;
            words.append(convertToWords(thousands)).append(" THOUSAND ");
            number %= 1000;
        }
        
        if (number >= 100) {
            long hundreds = number / 100;
            words.append(ones[(int)hundreds]).append(" HUNDRED ");
            number %= 100;
        }
        
        if (number >= 20) {
            words.append(tens[(int)(number / 10)]).append(" ");
            number %= 10;
        } else if (number >= 10) {
            words.append(teens[(int)(number - 10)]).append(" ");
            number = 0;
        }
        
        if (number > 0) {
            words.append(ones[(int)number]).append(" ");
        }
        
        return words.toString().trim();
    }
%>
<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty()) {
        out.print("Missing bill id"); return;
    }
    int billId = Integer.parseInt(idParam.trim());

    Vector bill  = goldBean.getBillById(billId);
    Vector items = goldBean.getBillItems(billId);
    Vector comp  = userBean.getCompanyDetails();

    if (bill == null || bill.isEmpty()) {
        out.print("Bill not found"); return;
    }

    String billNo      = bill.get(1).toString();
    String custId      = bill.get(2) != null ? bill.get(2).toString() : "";
    String custName    = bill.get(3) != null ? bill.get(3).toString() : "-";
    String custPhone   = bill.get(4) != null ? bill.get(4).toString() : "-";
    String idProof     = bill.get(5) != null ? bill.get(5).toString() : "";
    String addrProof   = bill.get(6) != null ? bill.get(6).toString() : "";
    String goldRate    = bill.get(7).toString();
    String grossAmt    = bill.get(8).toString();
    String margin      = bill.get(9).toString();
    String netAmt      = bill.get(10).toString();
    String release     = bill.get(11).toString();
    String amtPaid     = bill.get(12).toString();
    String billDate    = bill.get(13).toString();
    String billTime    = bill.get(14).toString();
    String enteredDt   = bill.get(15).toString();
    
    String formattedCustId = custId.isEmpty() ? "-" : "THIR-" + custId;

    String shopName  = comp.size() > 1 ? comp.get(1).toString() : "";
    String shopAddr  = comp.size() > 2 ? comp.get(2).toString() : "";
    String shopGstin = comp.size() > 3 ? comp.get(3).toString() : "";
    
    // Fetch customer address from customers table
    String customerAddress = "-";
    if (!custId.isEmpty()) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/golddb");
            con = ds.getConnection();
            ps = con.prepareStatement("SELECT address FROM customers WHERE id = ?");
            ps.setInt(1, Integer.parseInt(custId));
            rs = ps.executeQuery();
            if (rs.next()) {
                customerAddress = rs.getString("address");
                if (customerAddress == null || customerAddress.trim().isEmpty()) {
                    customerAddress = "-";
                }
            }
        } catch (Exception e) {
            customerAddress = "-";
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e) {}
            if (ps != null) try { ps.close(); } catch(Exception e) {}
            if (con != null) try { con.close(); } catch(Exception e) {}
        }
    }

    DecimalFormat df = new DecimalFormat("##,##,##0.00");
    DecimalFormat df0 = new DecimalFormat("##,##,##0");
    double dGross  = Double.parseDouble(grossAmt);
    double dMargin = Double.parseDouble(margin);
    double dNet    = Double.parseDouble(netAmt);
    double dRelease = Double.parseDouble(release);
    double dPaid   = Double.parseDouble(amtPaid);

    double totalGrossWt = 0, totalStoneWax = 0, totalNetWt = 0, totalGrossAmt = 0;
    for (int i = 0; i < items.size(); i++) {
        Vector row = (Vector) items.get(i);
        totalGrossWt  += Double.parseDouble(row.get(1).toString());
        totalStoneWax += Double.parseDouble(row.get(2).toString());
        totalNetWt    += Double.parseDouble(row.get(3).toString());
        totalGrossAmt += Double.parseDouble(row.get(5).toString());
    }
    
    String amountInWords = "RUPEES " + convertToWords((long)dPaid) + " ONLY";
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Invoice #<%= billNo %> - <%= shopName %></title>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap');
    
    * { margin: 0; padding: 0; box-sizing: border-box; }
    
    body {
        font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        padding: 20px 15px;
        color: #2d3436;
    }
    
    .bill-container {
        max-width: 700px;
        margin: 0 auto;
        background: #fff;
        box-shadow: 0 20px 60px rgba(0,0,0,0.15);
        border-radius: 12px;
        overflow: hidden;
    }

    /* ═══ PREMIUM HEADER ═══ */
    .header {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
        padding: 20px 30px 15px;
        position: relative;
        overflow: hidden;
    }
    
    .header::before {
        content: '';
        position: absolute;
        top: 0;
        right: 0;
        width: 300px;
        height: 300px;
        background: radial-gradient(circle, rgba(212,175,55,0.1) 0%, transparent 70%);
    }
    
    .logo-section {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        margin-bottom: 12px;
        position: relative;
        z-index: 1;
    }
    
    .logo-img {
        width: 70px;
        height: 70px;
        object-fit: contain;
        filter: brightness(1.2) drop-shadow(0 4px 8px rgba(212,175,55,0.4));
        background: rgba(255,255,255,0.1);
        padding: 10px;
        border-radius: 50%;
        border: 3px solid #d4af37;
        flex-shrink: 0;
    }
    
    .company-info {
        text-align: center;
        position: relative;
        z-index: 1;
        flex: 1;
    }
    
    .company-name {
        font-size: 16px;
        font-weight: 900;
        color: #fff;
        letter-spacing: 2px;
        text-transform: uppercase;
        text-shadow: 2px 2px 8px rgba(0,0,0,0.3);
        margin-bottom: 6px;
    }
    
    .company-tagline {
        font-size: 10px;
        color: #d4af37;
        letter-spacing: 2px;
        font-weight: 700;
        text-transform: uppercase;
        margin-bottom: 8px;
    }
    
    .company-address {
        font-size: 9px;
        color: #dfe6e9;
        line-height: 1.6;
    }
    
    .company-address strong {
        color: #d4af37;
        font-weight: 700;
    }
    
    .gold-line {
        height: 3px;
        background: linear-gradient(90deg, transparent 0%, #d4af37 50%, transparent 100%);
        margin: 6px 0 0;
    }

    /* ═══ CUSTOMER INFO SECTION ═══ */
    .customer-section {
        padding: 8px 30px 15px;
        background: #fff;
    }
    
    .customer-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 0;
        border: 2px solid #666;
    }
    
    .customer-table td {
        padding: 8px 12px;
        border: 1px solid #666;
        font-size: 9px;
    }
    
    .customer-table .label-col {
        background: #e8e8e8;
        font-weight: 700;
        text-transform: uppercase;
        color: #2d3436;
        width: 180px;
    }
    
    .customer-table .value-col {
        background: #fff;
        font-weight: 600;
        color: #2d3436;
    }
    
    .customer-table .value-col.gold {
        color: #d4af37;
        font-weight: 900;
        font-size: 11px;
    }
    
    .customer-table .address-row td {
        font-size: 9px;
        padding: 10px 12px;
    }
    


    /* ═══ ITEMS TABLE ═══ */
    .items-section {
        padding: 0 30px 20px;
    }
    
    .items-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 0;
        box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        border-radius: 8px;
        overflow: hidden;
    }
    
    .items-table thead {
        background: #f8f9fa;
        border-bottom: 2px solid #2d3436;
    }
    
    .items-table th {
        color: #2d3436;
        padding: 10px;
        text-align: center;
        font-size: 9px;
        font-weight: 900;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border: 1px solid #dee2e6;
    }
    
    .items-table td {
        padding: 10px;
        text-align: center;
        font-size: 9px;
        font-weight: 600;
        border-bottom: 1px solid #e0e0e0;
        border-right: 1px solid #f0f0f0;
    }
    
    .items-table td:last-child {
        border-right: none;
    }
    
    .items-table tbody tr {
        background: #fff;
        transition: all 0.2s;
    }
    
    .items-table tbody tr:nth-child(even) {
        background: #f8f9fa;
    }
    
    .items-table tbody tr:hover {
        background: #fff9e6;
        transform: scale(1.01);
    }
    
    .items-table .total-row {
        background: linear-gradient(135deg, #2d3436 0%, #1a1a2e 100%) !important;
        color: #fff;
        font-weight: 900;
        font-size: 10px;
    }
    
    .items-table .total-row td {
        border: none;
        padding: 12px 10px;
        color: #fff;
    }
    
    .items-table .gold-value {
        color: #d4af37;
        font-weight: 900;
    }

    /* ═══ SUMMARY SECTION ═══ */
    .summary-wrapper {
        display: grid;
        grid-template-columns: 1fr 300px;
        gap: 0;
        border-top: 4px solid #d4af37;
    }
    
    .terms-column {
        padding: 20px 25px;
        background: #f8f9fa;
        border-right: 3px solid #d4af37;
    }
    
    .terms-title {
        font-size: 10px;
        font-weight: 900;
        color: #2d3436;
        letter-spacing: 1px;
        text-transform: uppercase;
        margin-bottom: 8px;
        color: #d4af37;
    }
    
    .terms-list {
        font-size: 8px;
        line-height: 1.4;
        color: #636e72;
        padding-left: 12px;
    }
    
    .terms-list li {
        margin-bottom: 2px;
    }
    
    .terms-tamil {
        margin-top: 12px;
        padding-top: 8px;
        border-top: 1px solid #dee2e6;
    }
    
    .terms-tamil-list {
        font-size: 8px;
        line-height: 1.5;
        color: #636e72;
        padding-left: 12px;
        font-family: 'Noto Sans Tamil', 'Latha', 'Arial Unicode MS', sans-serif;
    }
    
    .terms-tamil-list li {
        margin-bottom: 2px;
    }
    
    .summary-column {
        background: linear-gradient(135deg, #2d3436 0%, #1a1a2e 100%);
        padding: 20px 25px;
    }
    
    .summary-table {
        width: 100%;
    }
    
    .summary-row {
        display: flex;
        justify-content: space-between;
        padding: 8px 0;
        border-bottom: 1px solid rgba(255,255,255,0.1);
        font-size: 10px;
    }
    
    .summary-label {
        color: #dfe6e9;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-size: 9px;
    }
    
    .summary-value {
        color: #fff;
        font-weight: 700;
        font-size: 11px;
    }
    
    .summary-row.grand-total {
        border-top: 3px solid #d4af37;
        border-bottom: 3px solid #d4af37;
        padding: 12px 0;
        margin-top: 8px;
    }
    
    .summary-row.grand-total .summary-label {
        font-size: 12px;
        font-weight: 900;
        color: #d4af37;
        letter-spacing: 1.5px;
    }
    
    .summary-row.grand-total .summary-value {
        font-size: 14px;
        font-weight: 900;
        color: #d4af37;
    }

    /* ═══ AMOUNT IN WORDS ═══ */
    .amount-words {
        padding: 12px 30px;
        background: #fff;
        text-align: left;
        border-top: 2px solid #666;
        font-size: 10px;
        font-weight: 700;
        color: #2d3436;
    }
    
    .amount-words-label {
        font-size: 8px;
        color: #888;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 2px;
        font-weight: 600;
    }
    
    .amount-words-value {
        font-size: 11px;
        color: #000;
        font-weight: 900;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* ═══ SIGNATURE SECTION ═══ */
    .signature-section {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        border-top: 3px solid #d4af37;
    }
    
    .signature-box {
        padding: 25px 15px;
        text-align: center;
        border-right: 2px solid #e0e0e0;
        min-height: 80px;
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
    }
    
    .signature-box:last-child {
        border-right: none;
    }
    
    .signature-label {
        font-size: 9px;
        font-weight: 900;
        color: #2d3436;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-top: 2px solid #2d3436;
        padding-top: 8px;
        margin-top: 30px;
    }

    /* ═══ FOOTER ═══ */
    .footer {
        background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
        padding: 10px 30px;
        text-align: center;
        color: #dfe6e9;
        font-size: 8px;
    }
    
    .footer strong {
        color: #d4af37;
    }

    /* ═══ PRINT BUTTON ═══ */
    .print-button {
        position: fixed;
        bottom: 30px;
        right: 30px;
        background: linear-gradient(135deg, #d4af37 0%, #f39c12 100%);
        color: #000;
        border: none;
        padding: 12px 28px;
        border-radius: 50px;
        font-size: 13px;
        font-weight: 900;
        cursor: pointer;
        box-shadow: 0 8px 24px rgba(212,175,55,0.4);
        transition: all 0.3s;
        z-index: 1000;
        letter-spacing: 1px;
        text-transform: uppercase;
    }
    
    .print-button:hover {
        transform: translateY(-3px);
        box-shadow: 0 12px 32px rgba(212,175,55,0.6);
    }

    @media print {
        body {
            background: white;
            padding: 0;
        }
        .bill-container {
            box-shadow: none;
            border-radius: 0;
            max-width: 100%;
        }
        .print-button {
            display: none;
        }
    }
</style>
</head>
<body>

<button class="print-button no-print" onclick="window.print()">🖨️ PRINT INVOICE</button>

<div class="bill-container">
    
    <!-- ═══ PREMIUM HEADER ═══ -->
    <div class="header">
        <div class="logo-section">
            <img src="logo.jpeg" alt="Logo" class="logo-img">
            <div class="company-info">
                <div class="company-name"><%= shopName %> <span>திருமலா கோல்டு பையர்ஸ்</span></div>
                <div class="company-tagline">GOLD BUYERS & TRADERS</div>
                <div class="company-address">
                    <%= shopAddr %><br>
                    <% if(!shopGstin.isEmpty()){ %><strong>GSTIN:</strong> <%= shopGstin %> | <% } %>
                    <strong>Contact:</strong> 8778630760
                </div>
            </div>
        </div>
        <div class="gold-line"></div>
    </div>
    
    <!-- ═══ CUSTOMER INFO ═══ -->
    <div class="customer-section">
        <table class="customer-table">
            <tr>
                <td class="label-col">CUSTOMER NAME</td>
                <td class="value-col"><%= custName %></td>
                <td class="label-col">DATE / TIME</td>
                <td class="value-col"><%= billDate %> <%= billTime %></td>
            </tr>
            <tr>
                <td class="label-col">CONTACT</td>
                <td class="value-col"><%= custPhone %></td>
                <td class="label-col">GOLD PRICE</td>
                <td class="value-col gold"><%= goldRate %></td>
            </tr>
            <tr class="address-row">
                <td class="label-col">Address</td>
                <td colspan="3" class="value-col" style="white-space: pre-line;"><%= customerAddress %></td>
            </tr>
            <tr>
                <td class="label-col">ID PROOF</td>
                <td class="value-col"><%= idProof.isEmpty() ? "-" : idProof %></td>
                <td class="label-col">ADDRESS PROOF</td>
                <td class="value-col"><%= addrProof.isEmpty() ? "-" : addrProof %></td>
            </tr>
        </table>
    </div>
    
    <!-- ═══ ITEMS TABLE ═══ -->
    <div class="items-section">
        <table class="items-table">
            <thead>
                <tr>
                    <th>S.NO</th>
                    <th>ORNAMENT TYPE</th>
                    <th>GROSS WT (g)</th>
                    <th>STONE/WAX (g)</th>
                    <th>NET WT (g)</th>
                    <th>PURITY</th>
                    <th>AMOUNT (₹)</th>
                </tr>
            </thead>
            <tbody>
                <% 
                for (int i = 0; i < items.size(); i++) {
                    Vector row = (Vector) items.get(i);
                    String ornType = row.get(0).toString();
                    double gwt = Double.parseDouble(row.get(1).toString());
                    double swt = Double.parseDouble(row.get(2).toString());
                    double nwt = Double.parseDouble(row.get(3).toString());
                    String pur = row.get(4).toString();
                    double amt = Double.parseDouble(row.get(5).toString());
                %>
                <tr>
                    <td><%= (i+1) %></td>
                    <td style="text-align:left; padding-left:15px;"><strong><%= ornType %></strong></td>
                    <td class="gold-value"><%= df.format(gwt) %></td>
                    <td><%= df.format(swt) %></td>
                    <td class="gold-value"><%= df.format(nwt) %></td>
                    <td><%= pur %></td>
                    <td class="gold-value">₹ <%= df.format(amt) %></td>
                </tr>
                <% } %>
                <tr class="total-row">
                    <td colspan="2" style="text-align:right; padding-right:15px;">TOTAL</td>
                    <td class="gold-value"><%= df.format(totalGrossWt) %></td>
                    <td><%= df.format(totalStoneWax) %></td>
                    <td class="gold-value"><%= df.format(totalNetWt) %></td>
                    <td>-</td>
                    <td class="gold-value">₹ <%= df.format(totalGrossAmt) %></td>
                </tr>
            </tbody>
        </table>
    </div>
    
    <!-- ═══ SUMMARY & TERMS ═══ -->
    <div class="summary-wrapper">
        <div class="terms-column">
            <div class="terms-title">Terms & Conditions</div>
            <ul class="terms-list">
                <li>Ornaments once purchased shall not be returned under any circumstances.</li>
                <li>If any losses arise out of this purchase, you shall be liable to pay the full amount.</li>
                <li>Selling stolen gold, silver, or fake gold is a criminal offence. If detected, it will be reported to the authorities.</li>
                <li>The ornaments were purchased from you based on your declaration that you hold the ownership and saleable title to the ornaments.</li>
                <li>Kindly ensure the correctness of the cash before leaving the counter. No claims for any shortage will be entertained thereafter.</li>
            </ul>
            
            <div class="terms-tamil">
                <div class="terms-title">விதிமுறைகள் மற்றும் நிபந்தனைகள்</div>
                <ul class="terms-tamil-list">
                    <li>ஒருமுறை வாங்கிய ஆபரணங்கள் எந்த சூழ்நிலையிலும் திரும்பக் கொடுக்கப்படாது.</li>
                    <li>இந்த வாங்குதலில் ஏதேனும் இழப்புகள் ஏற்பட்டால், நீங்கள் முழுத் தொகையையும் செலுத்த வேண்டும்.</li>
                    <li>திருடப்பட்ட தங்கம், வெள்ளி அல்லது போலி தங்கத்தை விற்பனை செய்வது கிரிமினல் குற்றமாகும். அது கண்டுபிடிக்கப்பட்டால் சம்பந்தப்பட்ட அதிகாரிகளுக்குத் தெரிவிக்கப்படும்.</li>
                    <li>ஆபரணங்கள் மீதான உரிமை மற்றும் விற்பனை உரிமை உங்களிடம் உள்ளது என்ற அறிவிப்பின் அடிப்படையில், உங்களிடமிருந்து ஆபரணங்கள் வாங்கப்பட்டன.</li>
                    <li>கவுண்டரை விட்டு வெளியேறும் முன், பணத்தின் சரியான தன்மையை உறுதிசெய்து கொள்ளுங்கள்.</li>
                </ul>
            </div>
        </div>
        
        <div class="summary-column">
            <div class="summary-table">
                <div class="summary-row">
                    <div class="summary-label">Gross Amount</div>
                    <div class="summary-value">₹ <%= df.format(dGross) %></div>
                </div>
                <div class="summary-row">
                    <div class="summary-label">Margin</div>
                    <div class="summary-value">₹ <%= df.format(dMargin) %></div>
                </div>
                <div class="summary-row">
                    <div class="summary-label">Net Amount</div>
                    <div class="summary-value">₹ <%= df.format(dNet) %></div>
                </div>
                <div class="summary-row">
                    <div class="summary-label">Release Amount</div>
                    <div class="summary-value">₹ <%= df.format(dRelease) %></div>
                </div>
                <div class="summary-row grand-total">
                    <div class="summary-label">Amount Paid</div>
                    <div class="summary-value">₹ <%= df.format(dPaid) %></div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- ═══ AMOUNT IN WORDS ═══ -->
    <div class="amount-words">
        <div class="amount-words-label">Amount in Words</div>
        <div class="amount-words-value">
            <%= amountInWords %>
        </div>
    </div>
    
    <!-- ═══ SIGNATURES ═══ -->
    <div class="signature-section">
        <div class="signature-box">
            <div class="signature-label">Thumb Impression</div>
        </div>
        <div class="signature-box">
            <div class="signature-label">Customer Signature</div>
        </div>
    </div>
    
    <!-- ═══ FOOTER ═══ -->
    <div class="footer">
        This is a computer generated invoice | <strong>Thank you for your business!</strong> | For queries: contact@<%= shopName.toLowerCase().replace(" ", "") %>.com
    </div>
    
</div>

<script>
window.addEventListener('load', function() {
    setTimeout(function() {
        window.print();
    }, 500);
});

window.addEventListener('afterprint', function() {
    window.close();
});
</script>

</body>
</html>
