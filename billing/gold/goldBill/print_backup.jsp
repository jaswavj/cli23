<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<jsp:useBean id="userBean" class="user.userBean" />
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

    // bill: [0]id [1]bill_no [2]customer_id [3]cust_name [4]cust_phone [5]id_proof [6]addr_proof
    //       [7]gold_rate [8]gross_amount [9]margin [10]net_amount [11]release [12]amount_paid
    //       [13]bill_date [14]bill_time [15]entered_dt
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
    
    // Format customer ID as THIR-{id}
    String formattedCustId = custId.isEmpty() ? "-" : "THIR-" + custId;

    // company: [0]id [1]shop_name [2]address [3]gstin
    String shopName  = comp.size() > 1 ? comp.get(1).toString() : "";
    String shopAddr  = comp.size() > 2 ? comp.get(2).toString() : "";
    String shopGstin = comp.size() > 3 ? comp.get(3).toString() : "";

    // Format numbers Indian style
    DecimalFormat df = new DecimalFormat("##,##,##0.00");
    DecimalFormat df0 = new DecimalFormat("##,##,##0");
    double dGross  = Double.parseDouble(grossAmt);
    double dMargin = Double.parseDouble(margin);
    double dNet    = Double.parseDouble(netAmt);
    double dRelease = Double.parseDouble(release);
    double dPaid   = Double.parseDouble(amtPaid);

    // Total row accumulators
    double totalGrossWt = 0, totalStoneWax = 0, totalNetWt = 0, totalGrossAmt = 0;
    for (int i = 0; i < items.size(); i++) {
        Vector row = (Vector) items.get(i);
        totalGrossWt  += Double.parseDouble(row.get(1).toString());
        totalStoneWax += Double.parseDouble(row.get(2).toString());
        totalNetWt    += Double.parseDouble(row.get(3).toString());
        totalGrossAmt += Double.parseDouble(row.get(5).toString());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Gold Bill #<%= billNo %></title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 11px;
        color: #000;
        background: #fff;
        padding: 10px;
        font-weight: 700;
    }
    .bill-wrap {
        max-width: 800px;
        margin: 0 auto;
        border: 2px solid #000;
        padding: 0;
        background: #fff;
    }

    /* ── Header with Logo ── */
    .hdr { 
        text-align: center; 
        padding: 15px 20px 10px;
        border-bottom: 2px solid #000;
    }
    .hdr .logo-section {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 8px;
        gap: 20px;
    }
    .hdr .logo-left, .hdr .logo-right {
        flex: 1;
        font-weight: 900;
        letter-spacing: 2px;
    }
    .hdr .logo-left { 
        text-align: left;
        font-size: 28px;
    }
    .hdr .logo-right { 
        text-align: right;
        font-family: 'Arial Unicode MS', sans-serif;
        font-size: 28px;
        line-height: 1.2;
    }
    .hdr .tagline {
        font-size: 9px;
        font-weight: 700;
        letter-spacing: 3px;
        margin-top: 2px;
    }
    
    /* ── Black Branch/Contact Bar ── */
    .branch-bar {
        background: #000;
        color: #fff;
        padding: 8px 12px;
        font-size: 10px;
        font-weight: 700;
        text-align: center;
        letter-spacing: 0.5px;
    }
    
    /* ── Gray Address Bar ── */
    .address-bar {
        background: #d3d3d3;
        padding: 6px 12px;
        font-size: 10px;
        font-weight: 700;
        text-align: center;
        white-space: pre-line;
        border-bottom: 1px solid #000;
    }

    /* ── Customer Info Grid with Photo ── */
    .info-section {
        display: flex;
        border-bottom: 2px solid #000;
    }
    .info-grid {
        flex: 1;
    }
    .info-table { 
        width: 100%; 
        border-collapse: collapse;
    }
    .info-table td { 
        padding: 6px 10px; 
        border: 1px solid #000; 
        font-size: 10px;
        font-weight: 700;
        vertical-align: top; 
        white-space: pre-line;
    }
    .info-table .lbl { 
        width: 140px; 
        background: #fff;
        text-align: left;
        padding-left: 10px;
    }
    .info-table .val {
        text-align: left;
        padding-left: 10px;
    }
    .photo-box {
        width: 120px;
        border-left: 2px solid #000;
        background: #f5f5f5;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 9px;
        color: #666;
        text-align: center;
        padding: 10px;
    }

    /* ── Billing Table ── */
    .bil-table { 
        width: 100%; 
        border-collapse: collapse;
    }
    .bil-table th {
        background: #000;
        color: #fff;
        padding: 6px 8px;
        font-size: 9px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border: 1px solid #000;
        text-align: center;
    }
    .bil-table td {
        padding: 6px 8px;
        border: 1px solid #000;
        text-align: center;
        font-size: 10px;
        font-weight: 700;
    }
    .bil-table td.left { text-align: left; }
    .bil-table td.right { text-align: right; }
    .bil-table tr.total-row td { 
        font-weight: 900;
        background: #f0f0f0;
        font-size: 11px;
    }

    /* ── Bottom Layout: T&C + Summary ── */
    .bottom-wrap { 
        display: flex;
        border-top: 2px solid #000;
    }
    .tc-col { 
        flex: 1; 
        padding: 10px 12px;
        border-right: 2px solid #000;
    }
    .summary-col { 
        width: 240px;
        flex-shrink: 0;
    }
    
    /* ── Summary Table ── */
    .summary-table { 
        width: 100%; 
        border-collapse: collapse;
    }
    .summary-table td { 
        padding: 6px 10px;
        border: 1px solid #000;
        font-size: 10px;
        font-weight: 700;
    }
    .summary-table .slbl { 
        background: #fff;
        text-align: left;
    }
    .summary-table .sval { 
        text-align: right;
    }
    .summary-table .paid-row td { 
        background: #000;
        color: #fff;
        font-size: 11px;
        font-weight: 900;
    }

    /* ── T&C ── */
    .tc-title { 
        font-weight: 900;
        font-size: 11px;
        text-align: center;
        margin-bottom: 8px;
        text-decoration: underline;
    }
    .tc-list, .tc-tamil { 
        padding-left: 18px;
        font-size: 8.5px;
        line-height: 1.5;
        font-weight: 600;
    }
    .tc-tamil { 
        margin-top: 8px;
        font-family: 'Arial Unicode MS', sans-serif;
    }

    /* ── Signature Row ── */
    .sig-row { 
        display: flex;
        border-top: 2px solid #000;
    }
    .sig-cell { 
        flex: 1;
        text-align: center;
        padding: 8px;
        font-size: 10px;
        font-weight: 900;
        border-right: 2px solid #000;
        min-height: 60px;
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
    }
    .sig-cell:last-child { border-right: none; }

    /* ── Amount in Words ── */
    .words-row { 
        border-top: 2px solid #000;
        padding: 8px 12px;
        font-size: 10px;
        font-weight: 900;
        text-align: center;
        background: #fff;
    }

    /* Gold color accents */
    .gold-text { color: #d4af37; }
    .gold-bg { background: #d4af37; }

    @media print {
        body { padding: 0; }
        .bill-wrap { border: 2px solid #000; }
        .no-print { display: none; }
    }
</style>
</head>
<body>

<!-- Print button (hidden on print) -->
<div class="no-print" style="text-align:center; margin-bottom:10px;">
    <button onclick="window.print()"
        style="background:#d4af37; color:#000; border:none; padding:8px 24px; border-radius:6px; font-size:13px; cursor:pointer; font-weight:700;">
        🖨️ Print
    </button>
</div>

<script>
    window.addEventListener('load', function () {
        window.print();
    });
    window.addEventListener('afterprint', function () {
        window.close();
    });
</script>

<div class="bill-wrap">

    <!-- ══ HEADER WITH LOGO ══ -->
    <div class="hdr">
        <div class="logo-section">
            <div class="logo-left">
                <div style="font-size:24px; font-weight:900;"><%= shopName.toLowerCase() %><sup style="font-size:14px;">®</sup></div>
                <div class="tagline">GOLD COMPANY</div>
            </div>
            <div class="logo-right">
                கோல்ட் கம்பெனி
            </div>
        </div>
    </div>
    
    <!-- ══ BLACK BRANCH/CONTACT BAR ══ -->
    <div class="branch-bar">
        BRANCH : <%= shopAddr.split(",")[0] %> , CONTACT: 8880300300<% if(!shopGstin.isEmpty()){ %> , GST NO: <%= shopGstin %><% } %>
    </div>
    
    <!-- ══ GRAY ADDRESS BAR ══ -->
    <div class="address-bar">
        <%= shopAddr %>
    </div>

    <!-- ══ CUSTOMER INFO WITH PHOTO ══ -->
    <div class="info-section">
        <div class="info-grid">
            <table class="info-table">
                <tr>
                    <td class="lbl">CUSTOMER ID</td>
                    <td class="val"><%= formattedCustId %></td>
                    <td class="lbl">DATE / TIME</td>
                    <td class="val"><%= billDate %> <%= billTime %></td>
                </tr>
                <tr>
                    <td class="lbl">CUSTOMER NAME</td>
                    <td class="val"><%= custName %></td>
                    <td class="lbl">BILL ID</td>
                    <td class="val"><%= billNo %></td>
                </tr>
                <tr>
                    <td class="lbl">CONTACT</td>
                    <td class="val"><%= custPhone.isEmpty() ? "-" : custPhone %></td>
                    <td class="lbl">GOLD PRICE</td>
                    <td class="val">₹ <%= goldRate %>/gm</td>
                </tr>
                <tr>
                    <td class="lbl">ID PROOF</td>
                    <td class="val"><%= idProof.isEmpty() ? "-" : idProof %></td>
                    <td class="lbl">ADDRESS PROOF</td>
                    <td class="val"><%= addrProof.isEmpty() ? "-" : addrProof %></td>
                </tr>
            </table>
        </div>
        <div class="photo-box">
            <div>CUSTOMER<br>PHOTO</div>
        </div>
    </div>

    <!-- ══ BILLING TABLE ══ -->
    <table class="bil-table">
        <thead>
            <tr>
                <th>ORNAMENT TYPE</th>
                <th>GROSS WEIGHT</th>
                <th>STONE / WAX</th>
                <th>NET WEIGHT</th>
                <th>PURITY</th>
                <th>GROSS AMOUNT</th>
            </tr>
        </thead>
        <tbody>
<%
    for (int i = 0; i < items.size(); i++) {
        Vector row = (Vector) items.get(i);
        double gw  = Double.parseDouble(row.get(1).toString());
        double sw  = Double.parseDouble(row.get(2).toString());
        double nw  = Double.parseDouble(row.get(3).toString());
        double pur = Double.parseDouble(row.get(4).toString());
        double ga  = Double.parseDouble(row.get(5).toString());
%>
            <tr>
                <td class="left"><%= row.get(0) %></td>
                <td><%= new DecimalFormat("0.###").format(gw) %></td>
                <td><%= new DecimalFormat("0.###").format(sw) %></td>
                <td><%= new DecimalFormat("0.###").format(nw) %></td>
                <td><%= new DecimalFormat("0.##").format(pur) %>%</td>
                <td class="right"><%= df.format(ga) %></td>
            </tr>
<% } %>
            <tr class="total-row">
                <td class="left">GRAND TOTAL</td>
                <td><%= new DecimalFormat("0.###").format(totalGrossWt) %></td>
                <td><%= new DecimalFormat("0.###").format(totalStoneWax) %></td>
                <td><%= new DecimalFormat("0.###").format(totalNetWt) %></td>
                <td><%= totalNetWt > 0 ? new DecimalFormat("0").format((totalNetWt/totalGrossWt)*100) : "" %>%</td>
                <td class="right"><%= df.format(totalGrossAmt) %></td>
            </tr>
        </tbody>
    </table>

    <!-- ══ T&C + SUMMARY ══ -->
    <div class="bottom-wrap">
        <!-- Terms & Conditions -->
        <div class="tc-col">
            <div class="tc-title">TERMS & CONDITIONS</div>
            <ol class="tc-list">
                <li>Ornaments once purchased shall not be returned under any circumstances.</li>
                <li>If any losses are arising out of this purchase, then you are liable to settle full amount.</li>
                <li>Selling stolen gold, silver or fake gold is a criminal offence, if found will be reported to authorities.</li>
                <li>Ornaments were purchased from you based on the declaration that you hold the ownership and saleable title on the ornaments and you completely agree to indemnify Attica Gold and its employees from any further claim or dispute or levy by any criminal or civil authorities.</li>
                <li>Kindly ensure the correctness of cash before leaving the counter. No claims for shortfall will be entertained thereafter.</li>
            </ol>
            
            <div style="margin-top:10px; font-weight:900; font-size:10px; text-align:center;">விதிமுறை மற்றும் நிபந்தனைகள்</div>
            <ol class="tc-tamil">
                <li>முன்பமொருநாள் வாங்கியஒப்பாரணங்களை மற்றூரிழ்களின்படபடும் திரும்ப கொடூக்கப்பட்ட செக்கடையை.</li>
                <li>இந்த வாங்கதளால் ஏதெனும் உளிஹுகளை் பாரீட்டால் நீங்கள் முழூத்தொகையை பற்றுபட்ட வெங்களூம்.</li>
                <li>திருடப்படட தங்கமும் வெள்ளீம் அல்லதூ மெசேமானயம் விற்பதூம் சட்ட விரோதமூம் தெவல்யுகால் அறிவூக்கப்படும்.</li>
                <li>ஆலப்பளிறளுகள் நீங்கள் வைத்திரூக்குகி விடேனிடன விற்க்கை்ட்தெளளில் உரீமை எடடடர்.</li>
                <li>கசவறுவளும் வெளீயேறூம் மூன்பூ பணத்தை சரீபாட்டூடச். தவே் கோரிக்கை ஏற்கப்பட்மாட்டாதூ.</li>
            </ol>

            <!-- Thumb + Signature within T&C -->
            <div class="sig-row" style="margin-top:12px; border:none; border-top:1px solid #000;">
                <div class="sig-cell">
                    THUMB IMPRESSION
                </div>
                <div class="sig-cell">
                    CUSTOMER SIGNATURE
                </div>
            </div>
        </div>

        <!-- Summary -->
        <div class="summary-col">
            <table class="summary-table">
                <tr>
                    <td class="slbl">GROSS AMOUNT</td>
                    <td class="sval"><%= df.format(dGross) %></td>
                </tr>
                <tr>
                    <td class="slbl">MARGIN</td>
                    <td class="sval"><%= df0.format(dMargin) %></td>
                </tr>
                <tr>
                    <td class="slbl">NET AMOUNT</td>
                    <td class="sval"><%= df.format(dNet) %></td>
                </tr>
                <tr>
                    <td class="slbl">RELEASE</td>
                    <td class="sval"><%= dRelease > 0 ? df.format(dRelease) : "" %></td>
                </tr>
                <tr class="paid-row">
                    <td class="slbl">AMOUNT PAID</td>
                    <td class="sval"><%= df.format(dPaid) %></td>
                </tr>
            </table>
        </div>
    <!-- ══ AMOUNT IN WORDS ══ -->
    <div class="words-row">
        AMOUNT IN WORDS : <%= amountToWords((long) Math.round(dPaid)) %> ONLY
    </div>

</div><!-- /bill-wrap -->

<%!
/* ── Amount to words (Indian system) ── */
private String amountToWords(long n) {
    if (n == 0) return "ZERO";
    String[] ones = {"","ONE","TWO","THREE","FOUR","FIVE","SIX","SEVEN","EIGHT","NINE",
                     "TEN","ELEVEN","TWELVE","THIRTEEN","FOURTEEN","FIFTEEN","SIXTEEN",
                     "SEVENTEEN","EIGHTEEN","NINETEEN"};
    String[] tens = {"","","TWENTY","THIRTY","FORTY","FIFTY","SIXTY","SEVENTY","EIGHTY","NINETY"};
    StringBuilder sb = new StringBuilder();
    if (n >= 10000000) { sb.append(amountToWords(n / 10000000)).append(" CRORE "); n %= 10000000; }
    if (n >= 100000)   { sb.append(amountToWords(n / 100000)).append(" LAKH "); n %= 100000; }
    if (n >= 1000)     { sb.append(amountToWords(n / 1000)).append(" THOUSAND "); n %= 1000; }
    if (n >= 100)      { sb.append(ones[(int)(n/100)]).append(" HUNDRED "); n %= 100; }
    if (n >= 20)       { sb.append(tens[(int)(n/10)]); if(n%10!=0) sb.append(" ").append(ones[(int)(n%10)]); sb.append(" "); }
    else if (n > 0)    { sb.append(ones[(int)n]).append(" "); }
    return sb.toString().trim();
}
%>

</body>
</html>
