<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.JSONArray" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

JSONObject resp = new JSONObject();
JSONArray rows = new JSONArray();

if (session.getAttribute("userId") == null) {
    resp.put("success", false);
    resp.put("message", "Session expired");
    out.print(resp.toString());
    return;
}

String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
String mode = request.getParameter("mode");
if (mode == null || mode.trim().isEmpty()) {
    mode = request.getParameter("reportType");
}
if (mode == null || mode.trim().isEmpty()) {
    mode = "transaction";
}

boolean needsDate = !("summary_cards".equalsIgnoreCase(mode)
    || "unbilled_orders".equalsIgnoreCase(mode)
    || "credit_all".equalsIgnoreCase(mode)
    || "credit_explain".equalsIgnoreCase(mode)
    || "credit_settle".equalsIgnoreCase(mode)
    || "save_opening_balance".equalsIgnoreCase(mode)
    || "credit_payment_details".equalsIgnoreCase(mode)
    || "cancel_open_closing".equalsIgnoreCase(mode));
if (needsDate) {
    if ((fromDate == null || fromDate.trim().isEmpty()) || (toDate == null || toDate.trim().isEmpty())) {
        String billDate = request.getParameter("billDate");
        if (billDate != null && !billDate.trim().isEmpty()) {
            fromDate = billDate;
            toDate = billDate;
        }
    }

    if ((fromDate == null || fromDate.trim().isEmpty()) || (toDate == null || toDate.trim().isEmpty())) {
        resp.put("success", false);
        resp.put("message", "fromDate and toDate are required");
        out.print(resp.toString());
        return;
    }
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    con = util.DBConnectionManager.getConnectionFromPool();

    if ("summary_cards".equalsIgnoreCase(mode)) {
        Vector s = goldBean.getGoldTransactionSummaryCards();
        double currentStock = 0;
        double totalCredit = 0;
        double customerDue = 0;
        int unbilledPurchaseCount = 0;
        int unbilledSaleCount = 0;
        double unbilledPurchaseQty = 0;
        double unbilledSaleQty = 0;
        if (s != null && s.size() >= 3) {
            try { currentStock = Double.parseDouble(String.valueOf(s.elementAt(0))); } catch (Exception ex) { }
            try { totalCredit = Double.parseDouble(String.valueOf(s.elementAt(1))); } catch (Exception ex) { }
            try { customerDue = Double.parseDouble(String.valueOf(s.elementAt(2))); } catch (Exception ex) { }
        }
        if (s != null && s.size() >= 7) {
            try { unbilledPurchaseCount = Integer.parseInt(String.valueOf(s.elementAt(3))); } catch (Exception ex) { }
            try { unbilledSaleCount = Integer.parseInt(String.valueOf(s.elementAt(4))); } catch (Exception ex) { }
            try { unbilledPurchaseQty = Double.parseDouble(String.valueOf(s.elementAt(5))); } catch (Exception ex) { }
            try { unbilledSaleQty = Double.parseDouble(String.valueOf(s.elementAt(6))); } catch (Exception ex) { }
        }

        JSONObject cards = new JSONObject();
        cards.put("currentStockTM", currentStock);
        cards.put("totalCredit", totalCredit);
        cards.put("customerDue", customerDue);
        cards.put("unbilledPurchaseCount", Double.valueOf(unbilledPurchaseCount));
        cards.put("unbilledSaleCount", Double.valueOf(unbilledSaleCount));
        cards.put("unbilledPurchaseQty", unbilledPurchaseQty);
        cards.put("unbilledSaleQty", unbilledSaleQty);
        resp.put("cards", cards);
    } else if ("unbilled_orders".equalsIgnoreCase(mode)) {
        Vector details = goldBean.getUnbilledGoldOrderDetails();
        JSONArray purchaseRows = new JSONArray();
        JSONArray saleRows = new JSONArray();

        if (details != null && details.size() >= 1) {
            Vector purchaseList = (Vector) details.elementAt(0);
            for (int i = 0; i < purchaseList.size(); i++) {
                Vector row = (Vector) purchaseList.get(i);
                JSONObject item = new JSONObject();
                item.put("orderId", row.elementAt(0).toString());
                item.put("customerId", row.elementAt(1).toString());
                item.put("customerName", row.elementAt(2).toString());
                item.put("qty", row.elementAt(3).toString());
                item.put("orderDate", row.elementAt(4).toString());
                purchaseRows.add(item);
            }
        }
        if (details != null && details.size() >= 2) {
            Vector saleList = (Vector) details.elementAt(1);
            for (int i = 0; i < saleList.size(); i++) {
                Vector row = (Vector) saleList.get(i);
                JSONObject item = new JSONObject();
                item.put("orderId", row.elementAt(0).toString());
                item.put("customerId", row.elementAt(1).toString());
                item.put("customerName", row.elementAt(2).toString());
                item.put("qty", row.elementAt(3).toString());
                item.put("orderDate", row.elementAt(4).toString());
                saleRows.add(item);
            }
        }

        resp.put("purchaseRows", purchaseRows);
        resp.put("saleRows", saleRows);
    } else if ("transaction".equalsIgnoreCase(mode)) {
        String sql =
            "SELECT c.id AS customer_id, c.name AS customer_name, " +
            " COALESCE(txn.total_purchase, 0) AS total_purchase, " +
            " COALESCE(txn.total_sale, 0) AS total_sale, " +
            " COALESCE(txn.total_credit, 0) AS total_credit, " +
            " COALESCE(txn.total_debit, 0) AS total_debit, " +
            " COALESCE(paymode.cash_paid, 0) AS cash_paid, " +
            " COALESCE(paymode.gpay_paid, 0) AS gpay_paid, " +
            " COALESCE(bal.net_balance, 0) AS net_balance, " +
            " COALESCE(stk.purchase_tm, 0) AS purchase_tm, " +
            " COALESCE(stk.sale_tm, 0) AS sale_tm " +
            "FROM customers c " +
            "LEFT JOIN ( " +
            "    SELECT gtl.customer_id, " +
            "           SUM(CASE " +
            "               WHEN gtl.is_purchase = 1 " +
            "                AND EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
            "               THEN COALESCE(gtl.bill_amount, 0) ELSE 0 END) AS total_purchase, " +
            "           SUM(CASE " +
            "               WHEN gtl.is_sale = 1 " +
            "                AND EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
            "               THEN COALESCE(gtl.bill_amount, 0) ELSE 0 END) AS total_sale, " +
            "           SUM(CASE " +
            "               WHEN gtl.is_sale = 1 " +
            "               THEN CASE WHEN EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
            "                         THEN COALESCE(gtl.in_amount, 0) ELSE 0 END " +
            "               ELSE COALESCE(gtl.in_amount, 0) END) AS total_credit, " +
            "           SUM(CASE " +
            "               WHEN gtl.is_purchase = 1 " +
            "               THEN CASE WHEN EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
            "                         THEN COALESCE(gtl.out_amount, 0) ELSE 0 END " +
            "               ELSE COALESCE(gtl.out_amount, 0) END) AS total_debit " +
            "    FROM gold_transaction_ledger gtl " +
            "    WHERE gtl.is_cancelled = 0 " +
            "      AND gtl.customer_id IS NOT NULL " +
            "      AND gtl.date_time BETWEEN ? AND ? " +
            "    GROUP BY gtl.customer_id " +
            ") txn ON txn.customer_id = c.id " +
            "LEFT JOIN ( " +
            "    SELECT src.customer_id, " +
            "           SUM(CASE WHEN src.pm = 'cash' THEN src.amount ELSE 0 END) AS cash_paid, " +
            "           SUM(CASE WHEN src.pm IN ('gpay','bank') THEN src.amount ELSE 0 END) AS gpay_paid " +
            "    FROM ( " +
            "        SELECT gt.customer_id AS customer_id, LOWER(COALESCE(gp.payment_mode,'')) AS pm, COALESCE(gp.amount,0) AS amount " +
            "        FROM gold_trasaction_payment gp " +
            "        INNER JOIN gold_trasaction gt ON gt.id = gp.bill_id " +
            "        WHERE gt.is_cancelled = 0 " +
            "          AND gt.bill_date BETWEEN ? AND ? " +
            "        UNION ALL " +
            "        SELECT gp.customer_id AS customer_id, LOWER(COALESCE(gp.payment_mode,'')) AS pm, COALESCE(gp.amount,0) AS amount " +
            "        FROM gold_trasaction_payment gp " +
            "        WHERE gp.bill_id IS NULL " +
            "          AND gp.is_balance_collection = 1 " +
            "          AND gp.bill_date BETWEEN ? AND ? " +
            "          AND gp.customer_id IS NOT NULL " +
            "    ) src " +
            "    GROUP BY src.customer_id " +
            ") paymode ON paymode.customer_id = c.id " +
            "LEFT JOIN ( " +
            "    SELECT gts.customer_id, SUM(gts.in_qty) AS purchase_tm, SUM(gts.out_qty) AS sale_tm " +
            "    FROM gold_trasaction_stock gts " +
            "    INNER JOIN gold_trasaction b2 ON b2.id = gts.bill_id AND b2.is_cancelled = 0 " +
            "    WHERE gts.customer_id IS NOT NULL " +
            "      AND gts.txn_date_time BETWEEN ? AND ? " +
            "    GROUP BY gts.customer_id " +
            ") stk ON stk.customer_id = c.id " +
            "LEFT JOIN ( " +
            "    SELECT gtl.customer_id, " +
            "           SUM(CASE " +
            "               WHEN gtl.is_sale = 1 THEN " +
            "                    (CASE WHEN EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
            "                          THEN (COALESCE(gtl.bill_amount, 0) - COALESCE(gtl.in_amount, 0)) ELSE 0 END) " +
            "               WHEN gtl.is_purchase = 1 THEN " +
            "                    (CASE WHEN EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
            "                          THEN -(COALESCE(gtl.bill_amount, 0) - COALESCE(gtl.out_amount, 0)) ELSE 0 END) " +
            "               ELSE (COALESCE(gtl.out_amount, 0) - COALESCE(gtl.in_amount, 0)) " +
            "           END) AS net_balance " +
            "    FROM gold_transaction_ledger gtl " +
            "    WHERE gtl.is_cancelled = 0 " +
            "      AND gtl.customer_id IS NOT NULL " +
            "      AND gtl.date_time BETWEEN ? AND ? " +
            "    GROUP BY gtl.customer_id " +
            ") bal ON bal.customer_id = c.id " +
            "WHERE IFNULL(c.is_active, 1) <> 0 " +
            "ORDER BY c.name";

        ps = con.prepareStatement(sql);
        String fromDateTime = fromDate + " 00:00:00";
        String toDateTime = toDate + " 23:59:59";
        ps.setString(1, fromDateTime);
        ps.setString(2, toDateTime);
        ps.setString(3, fromDate);
        ps.setString(4, toDate);
        ps.setString(5, fromDate);
        ps.setString(6, toDate);
        ps.setString(7, fromDateTime);
        ps.setString(8, toDateTime);
        ps.setString(9, fromDateTime);
        ps.setString(10, toDateTime);

        rs = ps.executeQuery();

        double sumTotalPurchase = 0;
        double sumTotalSale = 0;
        double sumTotalCredit = 0;
        double sumTotalDebit = 0;
        double sumCashPaid = 0;
        double sumGpayPaid = 0;
        double sumBalance = 0;
        double sumPurchaseTM = 0;
        double sumSaleTM = 0;

        while (rs.next()) {
            JSONObject row = new JSONObject();
            double totalPurchase = rs.getDouble("total_purchase");
            double totalSale = rs.getDouble("total_sale");
            double totalCredit = rs.getDouble("total_credit");
            double totalDebit = rs.getDouble("total_debit");
            double cashPaid = rs.getDouble("cash_paid");
            double gpayPaid = rs.getDouble("gpay_paid");
            double netBalance = rs.getDouble("net_balance");
            double purchaseTM = rs.getDouble("purchase_tm");
            double saleTM = rs.getDouble("sale_tm");

            row.put("customerId", rs.getInt("customer_id"));
            row.put("customerName", rs.getString("customer_name"));
            row.put("totalPurchase", totalPurchase);
            row.put("totalSale", totalSale);
            row.put("totalCredit", totalCredit);
            row.put("totalDebit", totalDebit);
            row.put("cashPaid", cashPaid);
            row.put("gpayPaid", gpayPaid);
            row.put("balance", netBalance);
            row.put("purchaseTM", purchaseTM);
            row.put("saleTM", saleTM);
            rows.add(row);

            sumTotalPurchase += totalPurchase;
            sumTotalSale += totalSale;
            sumTotalCredit += totalCredit;
            sumTotalDebit += totalDebit;
            sumCashPaid += cashPaid;
            sumGpayPaid += gpayPaid;
            sumBalance += netBalance;
            sumPurchaseTM += purchaseTM;
            sumSaleTM += saleTM;
        }

        JSONObject totals = new JSONObject();
        totals.put("totalPurchase", sumTotalPurchase);
        totals.put("totalSale", sumTotalSale);
        totals.put("totalCredit", sumTotalCredit);
        totals.put("totalDebit", sumTotalDebit);
        totals.put("cashPaid", sumCashPaid);
        totals.put("gpayPaid", sumGpayPaid);
        totals.put("balance", sumBalance);
        totals.put("purchaseTM", sumPurchaseTM);
        totals.put("saleTM", sumSaleTM);

        resp.put("totals", totals);
    } else if ("open_closing".equalsIgnoreCase(mode)) {
        String fromDateTime = fromDate + " 00:00:00";
        String toDateTime = toDate + " 23:59:59";

        String openClosingSql =
            "SELECT gtl.id, gtl.bill_id, gtl.customer_id, c.name AS customer_name, " +
            "       gtl.bill_amount, gtl.in_amount, gtl.out_amount, gtl.notes, gtl.date_time, " +
            "       gtl.is_sale, gtl.is_purchase, COALESCE(gtl.is_opening_balance, 0) AS is_opening_balance, " +
            "       COALESCE(gtl.is_balance_collection, 0) AS is_balance_collection, " +
            "       COALESCE(gtl.is_pay_or_collect, 0) AS is_pay_or_collect, " +
            "       CASE " +
            "         WHEN COALESCE(gtl.is_opening_balance, 0) = 1 THEN " +
            "           (SELECT COALESCE(SUM(gp.amount), 0) FROM gold_trasaction_payment gp " +
            "            WHERE COALESCE(gp.is_opening_balance, 0) = 1 " +
            "              AND gp.bill_date = DATE(gtl.date_time) " +
            "              AND gp.bill_time = TIME(gtl.date_time) " +
            "              AND LOWER(COALESCE(gp.payment_mode, '')) = 'cash') " +
            "         WHEN gtl.is_sale = 1 AND gtl.bill_id IS NOT NULL THEN " +
            "           (SELECT COALESCE(SUM(gp.amount), 0) FROM gold_trasaction_payment gp " +
            "            WHERE gp.bill_id = gtl.bill_id AND LOWER(COALESCE(gp.payment_mode, '')) = 'cash') " +
            "         WHEN COALESCE(gtl.is_balance_collection, 0) = 1 AND COALESCE(gtl.in_amount, 0) > 0 THEN " +
            "           (SELECT COALESCE(SUM(gp.amount), 0) FROM gold_trasaction_payment gp " +
            "            WHERE COALESCE(gp.is_balance_collection, 0) = 1 " +
            "              AND gp.customer_id = gtl.customer_id " +
            "              AND gp.is_pay_or_collect = gtl.is_pay_or_collect " +
            "              AND gp.date_time BETWEEN DATE_SUB(gtl.date_time, INTERVAL 10 SECOND) AND DATE_ADD(gtl.date_time, INTERVAL 10 SECOND) " +
            "              AND LOWER(COALESCE(gp.payment_mode, '')) = 'cash') " +
            "         ELSE 0 " +
            "       END AS cash_in, " +
            "       CASE " +
            "         WHEN gtl.is_purchase = 1 AND gtl.bill_id IS NOT NULL THEN " +
            "           (SELECT COALESCE(SUM(gp.amount), 0) FROM gold_trasaction_payment gp " +
            "            WHERE gp.bill_id = gtl.bill_id AND LOWER(COALESCE(gp.payment_mode, '')) = 'cash') " +
            "         WHEN COALESCE(gtl.is_balance_collection, 0) = 1 AND COALESCE(gtl.out_amount, 0) > 0 THEN " +
            "           (SELECT COALESCE(SUM(gp.amount), 0) FROM gold_trasaction_payment gp " +
            "            WHERE COALESCE(gp.is_balance_collection, 0) = 1 " +
            "              AND gp.customer_id = gtl.customer_id " +
            "              AND gp.is_pay_or_collect = gtl.is_pay_or_collect " +
            "              AND gp.date_time BETWEEN DATE_SUB(gtl.date_time, INTERVAL 10 SECOND) AND DATE_ADD(gtl.date_time, INTERVAL 10 SECOND) " +
            "              AND LOWER(COALESCE(gp.payment_mode, '')) = 'cash') " +
            "         ELSE 0 " +
            "       END AS cash_out " +
            "FROM gold_transaction_ledger gtl " +
            "LEFT JOIN gold_trasaction gt ON gt.id = gtl.bill_id " +
            "LEFT JOIN customers c ON c.id = gtl.customer_id " +
            "WHERE gtl.is_cancelled = 0 " +
            "  AND (gtl.customer_id IS NOT NULL OR COALESCE(gtl.is_opening_balance, 0) = 1) " +
            "  AND ( " +
            "       ((gtl.is_sale = 1 OR gtl.is_purchase = 1) AND COALESCE(gt.is_cancelled, 0) = 0) " +
            "       OR (gtl.is_sale = 0 AND gtl.is_purchase = 0) " +
            "       OR COALESCE(gtl.is_opening_balance, 0) = 1 " +
            "  ) " +
            "  AND gtl.date_time <= ? " +
            "ORDER BY gtl.date_time ASC, gtl.id ASC";

        ps = con.prepareStatement(openClosingSql);
        ps.setString(1, toDateTime);
        rs = ps.executeQuery();

        double runningOpening = 0;
        double sumIn = 0;
        double sumOut = 0;
        double firstOpening = 0;
        double lastClosing = 0;
        boolean firstOpeningSet = false;

        while (rs.next()) {
            String rowDateTime = rs.getString("date_time");
            double cashIn = rs.getDouble("cash_in");
            double cashOut = rs.getDouble("cash_out");
            double opening = runningOpening;
            double effect = cashIn - cashOut;
            double closing = opening + effect;
            runningOpening = closing;

            if (rowDateTime != null && rowDateTime.compareTo(fromDateTime) >= 0) {
                if (!firstOpeningSet) {
                    firstOpening = opening;
                    firstOpeningSet = true;
                }
                lastClosing = closing;

                JSONObject row = new JSONObject();
                int customerIdVal = rs.getInt("customer_id");
                boolean customerNull = rs.wasNull();
                int isSale = rs.getInt("is_sale");
                int isPurchase = rs.getInt("is_purchase");
                int isOpeningBalance = rs.getInt("is_opening_balance");
                double ledgerIn = rs.getDouble("in_amount");
                double ledgerOut = rs.getDouble("out_amount");

                row.put("id", rs.getInt("id"));
                row.put("billId", rs.getInt("bill_id"));
                row.put("customerId", customerNull ? null : new Integer(customerIdVal));
                row.put("customerName", rs.getString("customer_name"));
                row.put("billAmount", rs.getDouble("bill_amount"));
                row.put("inAmount", cashIn);
                row.put("outAmount", cashOut);
                row.put("openingBalance", opening);
                row.put("closingBalance", closing);
                row.put("effect", effect);
                row.put("isOpeningBalance", isOpeningBalance);
                row.put("isSale", isSale);
                row.put("isPurchase", isPurchase);
                row.put("isBalanceCollection", rs.getInt("is_balance_collection"));
                row.put("isPayOrCollect", rs.getInt("is_pay_or_collect"));
                row.put("txnType", isOpeningBalance == 1 ? "OPENING" : (isSale == 1 ? "SALE" : (isPurchase == 1 ? "PURCHASE" : (ledgerIn > 0 ? "COLLECT" : (ledgerOut > 0 ? "PAY" : "-")))));
                row.put("notes", rs.getString("notes"));
                row.put("dateTime", rowDateTime);
                rows.add(row);

                sumIn += cashIn;
                sumOut += cashOut;
            }
        }

        if (!firstOpeningSet) {
            firstOpening = runningOpening;
            lastClosing = runningOpening;
        }

        JSONObject totals = new JSONObject();
        totals.put("inAmount", sumIn);
        totals.put("outAmount", sumOut);
        totals.put("openingBalance", firstOpening);
        totals.put("closingBalance", lastClosing);
        resp.put("totals", totals);
    } else if ("credit_all".equalsIgnoreCase(mode)) {
        String creditScope = request.getParameter("creditScope");
        boolean showAllCustomers = "all_customers".equalsIgnoreCase(creditScope);
        String sql;
        if (showAllCustomers) {
            sql =
                "SELECT c.id AS customer_id, c.name AS customer_name, c.phone_number, " +
                " COALESCE(glc.credit_amount, 0) AS credit_amount " +
                "FROM customers c " +
                "LEFT JOIN ( " +
                "    SELECT gtl.customer_id, " +
                "           SUM(CASE " +
                "               WHEN gtl.is_sale = 1 AND EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
                "                   THEN (COALESCE(gtl.bill_amount, 0) - COALESCE(gtl.in_amount, 0)) " +
                "               WHEN gtl.is_purchase = 1 AND EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
                "                   THEN -(COALESCE(gtl.bill_amount, 0) - COALESCE(gtl.out_amount, 0)) " +
                "               WHEN gtl.is_sale = 0 AND gtl.is_purchase = 0 " +
                "                   THEN (COALESCE(gtl.out_amount, 0) - COALESCE(gtl.in_amount, 0)) " +
                "               ELSE 0 " +
                "           END) AS credit_amount " +
                "    FROM gold_transaction_ledger gtl " +
                "    WHERE gtl.is_cancelled = 0 AND gtl.customer_id IS NOT NULL " +
                "    GROUP BY gtl.customer_id " +
                ") glc ON glc.customer_id = c.id " +
                "WHERE IFNULL(c.is_active, 1) <> 0 " +
                "ORDER BY c.name";
        } else {
            sql =
                "SELECT c.id AS customer_id, c.name AS customer_name, c.phone_number, " +
                " COALESCE(glc.credit_amount, 0) AS credit_amount " +
                "FROM customers c " +
                "INNER JOIN ( " +
                "    SELECT gtl.customer_id, " +
                "           SUM(CASE " +
                "               WHEN gtl.is_sale = 1 AND EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
                "                   THEN (COALESCE(gtl.bill_amount, 0) - COALESCE(gtl.in_amount, 0)) " +
                "               WHEN gtl.is_purchase = 1 AND EXISTS (SELECT 1 FROM gold_trasaction b WHERE b.id = gtl.bill_id AND b.is_cancelled = 0) " +
                "                   THEN -(COALESCE(gtl.bill_amount, 0) - COALESCE(gtl.out_amount, 0)) " +
                "               WHEN gtl.is_sale = 0 AND gtl.is_purchase = 0 " +
                "                   THEN (COALESCE(gtl.out_amount, 0) - COALESCE(gtl.in_amount, 0)) " +
                "               ELSE 0 " +
                "           END) AS credit_amount " +
                "    FROM gold_transaction_ledger gtl " +
                "    WHERE gtl.is_cancelled = 0 AND gtl.customer_id IS NOT NULL " +
                "    GROUP BY gtl.customer_id " +
                "    HAVING ABS(COALESCE(credit_amount, 0)) > 0.0001 " +
                ") glc ON glc.customer_id = c.id " +
                "WHERE IFNULL(c.is_active, 1) <> 0 " +
                "ORDER BY credit_amount DESC, c.name";
        }
        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();

        double sumCreditAmount = 0;
        while (rs.next()) {
            JSONObject row = new JSONObject();
            double creditAmount = rs.getDouble("credit_amount");
            row.put("customerId", rs.getInt("customer_id"));
            row.put("customerName", rs.getString("customer_name") == null ? "" : rs.getString("customer_name"));
            row.put("phone", rs.getString("phone_number") == null ? "" : rs.getString("phone_number"));
            row.put("creditAmount", creditAmount);
            rows.add(row);
            sumCreditAmount += creditAmount;
        }

        JSONObject totals = new JSONObject();
        totals.put("creditAmount", sumCreditAmount);
        resp.put("totals", totals);
    } else if ("credit_explain".equalsIgnoreCase(mode)) {
        int customerId = 0;
        try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception ex) { }
        if (customerId <= 0) {
            resp.put("success", false);
            resp.put("message", "Invalid customer id");
            out.print(resp.toString());
            return;
        }

        String customerName = "";
        ps = con.prepareStatement("SELECT name FROM customers WHERE id = ? LIMIT 1");
        ps.setInt(1, customerId);
        rs = ps.executeQuery();
        if (rs.next()) {
            customerName = rs.getString("name");
        }
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}

        double accountCredit = 0;
        String accountMode = "due-advance";
        try {
            ps = con.prepareStatement(
                "SELECT (COALESCE(due, 0) - COALESCE(advance, 0)) AS credit_amount FROM customer_account WHERE customer_id = ? LIMIT 1");
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                accountCredit = rs.getDouble("credit_amount");
            }
        } catch (SQLException dueColEx) {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            accountMode = "balance-advance";
            ps = con.prepareStatement(
                "SELECT (COALESCE(balance, 0) - COALESCE(advance, 0)) AS credit_amount FROM customer_account WHERE customer_id = ? LIMIT 1");
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                accountCredit = rs.getDouble("credit_amount");
            }
        }
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}

        ps = con.prepareStatement(
            "SELECT gtl.id, gtl.bill_id, " +
            " DATE_FORMAT(gtl.date_time, '%Y-%m-%d') AS bill_date, " +
            " DATE_FORMAT(gtl.date_time, '%H:%i:%s') AS bill_time, " +
            " DATE_FORMAT(gtl.date_time, '%Y-%m-%d %H:%i:%s') AS txn_date_time, " +
            " COALESCE(gtl.bill_amount, 0) AS bill_amount, " +
            " COALESCE(gtl.in_amount, 0) AS in_amount, " +
            " COALESCE(gtl.out_amount, 0) AS out_amount, " +
            " COALESCE(gtl.is_sale, 0) AS is_sale, " +
            " COALESCE(gtl.is_purchase, 0) AS is_purchase, " +
            " COALESCE(gtl.is_balance_collection, 0) AS is_balance_collection " +
            "FROM gold_transaction_ledger gtl " +
            "LEFT JOIN gold_trasaction gt ON gt.id = gtl.bill_id " +
            "WHERE gtl.is_cancelled = 0 AND gtl.customer_id = ? " +
            "  AND ( " +
            "       ((gtl.is_sale = 1 OR gtl.is_purchase = 1) AND COALESCE(gt.is_cancelled, 0) = 0) " +
            "       OR (gtl.is_sale = 0 AND gtl.is_purchase = 0) " +
            "  ) " +
            "ORDER BY gtl.date_time ASC, gtl.id ASC");
        ps.setInt(1, customerId);
        rs = ps.executeQuery();

        double runningCredit = 0;
        while (rs.next()) {
            JSONObject row = new JSONObject();
            double billAmount = rs.getDouble("bill_amount");
            int isSale = rs.getInt("is_sale");
            int isPurchase = rs.getInt("is_purchase");
            double inAmount = rs.getDouble("in_amount");
            double outAmount = rs.getDouble("out_amount");
            double paid = isSale == 1 ? inAmount : (isPurchase == 1 ? outAmount : (inAmount + outAmount));
            double bal = (isSale == 1 || isPurchase == 1) ? (billAmount - paid) : 0.0;
            double effect = isSale == 1 ? bal : (isPurchase == 1 ? -bal : (outAmount - inAmount));
            runningCredit += effect;

            String txnType = isSale == 1 ? "SALE" : (isPurchase == 1 ? "PURCHASE" : (inAmount > 0 ? "COLLECT" : (outAmount > 0 ? "PAY" : "-")));

            row.put("billId", rs.getInt("bill_id"));
            row.put("billDate", rs.getString("bill_date"));
            row.put("billTime", rs.getString("bill_time"));
            row.put("txnDateTime", rs.getString("txn_date_time"));
            row.put("txnType", txnType);
            row.put("total", billAmount);
            row.put("paid", paid);
            row.put("balance", bal);
            row.put("creditEffect", effect);
            row.put("runningCredit", runningCredit);
            rows.add(row);
        }

        JSONObject totals = new JSONObject();
        totals.put("creditFromTransactions", runningCredit);
        totals.put("creditFromAccount", accountCredit);
        totals.put("accountMode", accountMode);
        resp.put("totals", totals);
        resp.put("customerId", customerId);
        resp.put("customerName", customerName);
    } else if ("cancel_open_closing".equalsIgnoreCase(mode)) {
        int ledgerId = 0;
        try { ledgerId = Integer.parseInt(request.getParameter("ledgerId")); } catch (Exception ex) { }
        Integer uid = (Integer) session.getAttribute("userId");
        int userId = uid == null ? 0 : uid.intValue();
        String cancelReason = request.getParameter("cancelReason");
        if (cancelReason == null) cancelReason = "";

        if (ledgerId <= 0) {
            resp.put("success", false);
            resp.put("message", "Invalid ledger entry");
            out.print(resp.toString());
            return;
        }
        if (userId <= 0) {
            resp.put("success", false);
            resp.put("message", "Invalid user session");
            out.print(resp.toString());
            return;
        }

        int cancelId = goldBean.cancelOpenClosingEntry(ledgerId, userId, cancelReason);
        resp.put("cancelId", cancelId);
        resp.put("message", "Entry cancelled successfully");
    } else if ("credit_settle".equalsIgnoreCase(mode)) {
        int customerId = 0;
        Integer uid = (Integer) session.getAttribute("userId");
        try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception ex) { }
        String action = request.getParameter("action");
        double amount = 0;
        try { amount = Double.parseDouble(request.getParameter("amount")); } catch (Exception ex) { }
        double cashAmount = 0;
        double gpayAmount = 0;
        int bankId = 0;
        try { cashAmount = Double.parseDouble(request.getParameter("cashAmount")); } catch (Exception ex) { }
        try { gpayAmount = Double.parseDouble(request.getParameter("gpayAmount")); } catch (Exception ex) { }
        try { bankId = Integer.parseInt(request.getParameter("bankId")); } catch (Exception ex) { }

        if (uid == null) {
            resp.put("success", false);
            resp.put("message", "Session expired");
            out.print(resp.toString());
            return;
        }

        Vector payments = new Vector();
        if (cashAmount > 0) {
            Vector p = new Vector();
            p.addElement("cash");
            p.addElement("0");
            p.addElement(String.valueOf(cashAmount));
            payments.addElement(p);
        }
        if (gpayAmount > 0) {
            Vector p = new Vector();
            p.addElement("gpay");
            p.addElement(String.valueOf(bankId));
            p.addElement(String.valueOf(gpayAmount));
            payments.addElement(p);
        }

        Vector outData = goldBean.settleCustomerCredit(
            customerId,
            uid.intValue(),
            amount,
            action,
            request.getParameter("billDate"),
            request.getParameter("billTime"),
            payments
        );

        int billId = 0;
        double accountCredit = 0;
        double due = 0;
        double advance = 0;
        if (outData != null && outData.size() >= 4) {
            try { billId = Integer.parseInt(String.valueOf(outData.elementAt(0))); } catch (Exception ex) { }
            try { accountCredit = Double.parseDouble(String.valueOf(outData.elementAt(1))); } catch (Exception ex) { }
            try { due = Double.parseDouble(String.valueOf(outData.elementAt(2))); } catch (Exception ex) { }
            try { advance = Double.parseDouble(String.valueOf(outData.elementAt(3))); } catch (Exception ex) { }
        }

        JSONObject settle = new JSONObject();
        settle.put("billId", billId);
        settle.put("accountCredit", accountCredit);
        settle.put("due", due);
        settle.put("advance", advance);
        settle.put("action", action == null ? "" : action);
        resp.put("settle", settle);
    } else if ("save_opening_balance".equalsIgnoreCase(mode)) {
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid == null) {
            resp.put("success", false);
            resp.put("message", "Session expired");
            out.print(resp.toString());
            return;
        }

        double amount = 0;
        int bankId = 0;
        String paymentMode = request.getParameter("paymentMode");
        String notes = request.getParameter("notes");
        String reqBillDate = request.getParameter("billDate");
        String reqBillTime = request.getParameter("billTime");
        try { amount = Double.parseDouble(request.getParameter("amount")); } catch (Exception ex) { }
        try { bankId = Integer.parseInt(request.getParameter("bankId")); } catch (Exception ex) { }

        if (amount <= 0) {
            resp.put("success", false);
            resp.put("message", "Enter valid amount");
            out.print(resp.toString());
            return;
        }

        String pm = paymentMode == null ? "" : paymentMode.trim().toLowerCase();
        if (!("cash".equals(pm) || "gpay".equals(pm) || "bank".equals(pm))) {
            resp.put("success", false);
            resp.put("message", "Select valid payment mode");
            out.print(resp.toString());
            return;
        }
        if (("gpay".equals(pm) || "bank".equals(pm)) && bankId <= 0) {
            resp.put("success", false);
            resp.put("message", "Select bank for GPay/Bank");
            out.print(resp.toString());
            return;
        }

        int ledgerId = goldBean.saveOpeningBalance(
            uid.intValue(),
            amount,
            pm,
            bankId,
            reqBillDate,
            reqBillTime,
            notes
        );

        JSONObject openingBalance = new JSONObject();
        openingBalance.put("ledgerId", ledgerId);
        openingBalance.put("amount", amount);
        openingBalance.put("paymentMode", pm);
        openingBalance.put("bankId", bankId);
        resp.put("openingBalance", openingBalance);
    } else if ("credit_payment_details".equalsIgnoreCase(mode)) {
        int billId = 0;
        int customerId = 0;
        String txnDateTime = request.getParameter("txnDateTime");
        try { billId = Integer.parseInt(request.getParameter("billId")); } catch (Exception ex) { }
        try { customerId = Integer.parseInt(request.getParameter("customerId")); } catch (Exception ex) { }

        if (billId > 0) {
            ps = con.prepareStatement(
                "SELECT gp.payment_mode, gp.amount, gp.payment_bank, COALESCE(cbd.NAME, '') AS bank_name " +
                "FROM gold_trasaction_payment gp " +
                "LEFT JOIN configure_bank_details cbd ON cbd.id = gp.payment_bank " +
                "WHERE gp.bill_id = ? ORDER BY gp.id ASC");
            ps.setInt(1, billId);
        } else if (customerId > 0 && txnDateTime != null && txnDateTime.trim().length() > 0) {
            ps = con.prepareStatement(
                "SELECT gp.payment_mode, gp.amount, gp.payment_bank, COALESCE(cbd.NAME, '') AS bank_name " +
                "FROM gold_trasaction_payment gp " +
                "LEFT JOIN configure_bank_details cbd ON cbd.id = gp.payment_bank " +
                "WHERE gp.is_balance_collection = 1 " +
                "AND gp.customer_id = ? " +
                "AND gp.date_time BETWEEN DATE_SUB(?, INTERVAL 2 SECOND) AND DATE_ADD(?, INTERVAL 2 SECOND) " +
                "ORDER BY gp.id ASC");
            ps.setInt(1, customerId);
            ps.setString(2, txnDateTime.trim());
            ps.setString(3, txnDateTime.trim());
        } else {
            resp.put("success", false);
            resp.put("message", "Invalid payment lookup details");
            out.print(resp.toString());
            return;
        }
        rs = ps.executeQuery();

        double totalCash = 0;
        double totalGpay = 0;
        double totalBalance = 0;
        double totalOther = 0;

        while (rs.next()) {
            JSONObject row = new JSONObject();
            String paymentMode = rs.getString("payment_mode");
            String bankName = rs.getString("bank_name");
            double amountVal = rs.getDouble("amount");

            row.put("paymentMode", paymentMode == null ? "" : paymentMode);
            row.put("bankName", bankName == null ? "" : bankName);
            row.put("amount", amountVal);
            rows.add(row);

            String pm = paymentMode == null ? "" : paymentMode.trim().toLowerCase();
            if ("cash".equals(pm)) {
                totalCash += amountVal;
            } else if ("gpay".equals(pm) || "bank".equals(pm)) {
                totalGpay += amountVal;
            } else if ("balance".equals(pm)) {
                totalBalance += amountVal;
            } else {
                totalOther += amountVal;
            }
        }

        JSONObject totals = new JSONObject();
        totals.put("cash", totalCash);
        totals.put("gpay", totalGpay);
        totals.put("balance", totalBalance);
        totals.put("other", totalOther);
        resp.put("totals", totals);
        resp.put("billId", billId);
        resp.put("customerId", customerId);
        resp.put("txnDateTime", txnDateTime == null ? "" : txnDateTime);
    } else if ("stock_txn".equalsIgnoreCase(mode)) {
        String sql =
            "SELECT gts.id AS stock_id, gts.bill_id, gts.in_qty, gts.out_qty, gts.rate, gts.total, gts.txn_date_time, " +
            "       COALESCE(gts.notes, '') AS notes, " +
            "       DATE_FORMAT(gts.txn_date_time, '%Y-%m-%d') AS stock_date, " +
            "       DATE_FORMAT(gts.txn_date_time, '%H:%i:%s') AS stock_time, " +
            "       COALESCE(gt.is_sale, 0) AS is_sale, COALESCE(gt.is_purchase, 0) AS is_purchase, " +
            "       COALESCE(gt.is_cancelled, 0) AS is_cancelled, c.name AS customer_name " +
            "FROM gold_trasaction_stock gts " +
            "LEFT JOIN gold_trasaction gt ON gt.id = gts.bill_id " +
            "LEFT JOIN customers c ON c.id = COALESCE(gts.customer_id, gt.customer_id) " +
            "WHERE DATE(gts.txn_date_time) BETWEEN ? AND ? " +
            "ORDER BY gts.txn_date_time ASC, gts.id ASC";

        ps = con.prepareStatement(sql);
        ps.setString(1, fromDate);
        ps.setString(2, toDate);
        rs = ps.executeQuery();

        double sumIn = 0;
        double sumOut = 0;
        double sumTotal = 0;

        while (rs.next()) {
            JSONObject row = new JSONObject();
            double inQty = rs.getDouble("in_qty");
            double outQty = rs.getDouble("out_qty");
            double total = rs.getDouble("total");
            double netQty = inQty - outQty;
            double rate = rs.getDouble("rate");
            if (rate == 0 && netQty != 0) {
                rate = total / netQty;
            }
            String notes = rs.getString("notes");
            String txnType = "-";
            if (notes != null && notes.startsWith("Cancelled")) {
                txnType = "CANCEL";
            } else if (rs.getInt("is_purchase") == 1) {
                txnType = "PURCHASE";
            } else if (rs.getInt("is_sale") == 1) {
                txnType = "SALE";
            }

            row.put("stockId", rs.getInt("stock_id"));
            row.put("billId", rs.getInt("bill_id"));
            row.put("billDate", rs.getString("stock_date"));
            row.put("billTime", rs.getString("stock_time"));
            row.put("customerName", rs.getString("customer_name"));
            row.put("txnType", txnType);
            row.put("notes", notes == null ? "" : notes);
            row.put("inTM", inQty);
            row.put("outTM", outQty);
            row.put("netTM", netQty);
            row.put("rate", rate);
            row.put("amount", total);
            rows.add(row);

            sumIn += inQty;
            sumOut += outQty;
            sumTotal += total;
        }

        JSONObject totals = new JSONObject();
        totals.put("inTM", sumIn);
        totals.put("outTM", sumOut);
        totals.put("netTM", (sumIn - sumOut));
        totals.put("amount", sumTotal);
        resp.put("totals", totals);
    } else if ("profit_loss".equalsIgnoreCase(mode)) {
        String sql =
            "SELECT " +
            " COALESCE(SUM(CASE WHEN gt.is_purchase = 1 THEN gts.in_qty ELSE 0 END), 0) AS purchase_tm, " +
            " COALESCE(SUM(CASE WHEN gt.is_sale = 1 THEN gts.out_qty ELSE 0 END), 0) AS sale_tm, " +
            " COALESCE(SUM(CASE WHEN gt.is_purchase = 1 THEN gts.total ELSE 0 END), 0) AS purchase_amount, " +
            " COALESCE(SUM(CASE WHEN gt.is_sale = 1 THEN gts.total ELSE 0 END), 0) AS sale_amount " +
            "FROM gold_trasaction_stock gts " +
            "INNER JOIN gold_trasaction gt ON gt.id = gts.bill_id " +
            "WHERE gt.is_cancelled = 0 " +
            "  AND gt.bill_date BETWEEN ? AND ?";

        ps = con.prepareStatement(sql);
        ps.setString(1, fromDate);
        ps.setString(2, toDate);
        rs = ps.executeQuery();

        JSONObject totals = new JSONObject();
        if (rs.next()) {
            double purchaseTM = rs.getDouble("purchase_tm");
            double saleTM = rs.getDouble("sale_tm");
            double purchaseAmount = rs.getDouble("purchase_amount");
            double saleAmount = rs.getDouble("sale_amount");

            double purchaseRate = purchaseTM > 0 ? (purchaseAmount / purchaseTM) : 0;
            double saleRate = saleTM > 0 ? (saleAmount / saleTM) : 0;
            double matchedTM = Math.min(purchaseTM, saleTM);
            double profitPerTM = saleRate - purchaseRate;
            double profitLoss = profitPerTM * matchedTM;

            JSONObject row = new JSONObject();
            row.put("label", "Overall Profit/Loss");
            row.put("purchaseTM", purchaseTM);
            row.put("saleTM", saleTM);
            row.put("purchaseRate", purchaseRate);
            row.put("saleRate", saleRate);
            row.put("matchedTM", matchedTM);
            row.put("profitPerTM", profitPerTM);
            row.put("profitLoss", profitLoss);
            rows.add(row);

            totals.put("purchaseTM", purchaseTM);
            totals.put("saleTM", saleTM);
            totals.put("purchaseRate", purchaseRate);
            totals.put("saleRate", saleRate);
            totals.put("matchedTM", matchedTM);
            totals.put("profitPerTM", profitPerTM);
            totals.put("profitLoss", profitLoss);
        }
        resp.put("totals", totals);
    } else if ("current_stock".equalsIgnoreCase(mode)) {
        String sql =
            "SELECT " +
            " COALESCE(SUM(gts.in_qty), 0) AS total_in_qty, " +
            " COALESCE(SUM(gts.out_qty), 0) AS total_out_qty, " +
            " COALESCE(SUM(gts.total), 0) AS total_amount " +
            "FROM gold_trasaction_stock gts " +
            "INNER JOIN gold_trasaction gt ON gt.id = gts.bill_id " +
            "WHERE gt.is_cancelled = 0 AND gt.bill_date BETWEEN ? AND ?";

        ps = con.prepareStatement(sql);
        ps.setString(1, fromDate);
        ps.setString(2, toDate);
        rs = ps.executeQuery();

        JSONObject totals = new JSONObject();
        if (rs.next()) {
            double inQty = rs.getDouble("total_in_qty");
            double outQty = rs.getDouble("total_out_qty");
            double netQty = inQty - outQty;
            double totalAmount = rs.getDouble("total_amount");
            totals.put("purchaseTM", inQty);
            totals.put("saleTM", outQty);
            totals.put("currentStockTM", netQty);
            totals.put("totalAmount", totalAmount);

            JSONObject row = new JSONObject();
            row.put("label", "Stock movement from " + fromDate + " to " + toDate);
            row.put("customerName", "Overall Stock");
            row.put("purchaseTM", inQty);
            row.put("saleTM", outQty);
            row.put("currentStockTM", netQty);
            row.put("totalAmount", totalAmount);
            rows.add(row);
        }
        resp.put("totals", totals);
    } else {
        resp.put("success", false);
        resp.put("message", "Invalid mode");
        out.print(resp.toString());
        return;
    }

    resp.put("success", true);
    resp.put("mode", mode);
    resp.put("fromDate", fromDate == null ? "" : fromDate);
    resp.put("toDate", toDate == null ? "" : toDate);
    resp.put("periodLabel", needsDate ? (fromDate + " to " + toDate) : "All time");
    resp.put("rows", rows);
    resp.put("count", rows.size());

    out.print(resp.toString());
} catch (Throwable e) {
    e.printStackTrace();
    resp.put("success", false);
    String errPrefix = "Unable to load report: ";
    if ("save_opening_balance".equalsIgnoreCase(mode)) {
        errPrefix = "Unable to save opening balance: ";
    } else if ("cancel_open_closing".equalsIgnoreCase(mode)) {
        errPrefix = "Unable to cancel entry: ";
    } else if ("credit_settle".equalsIgnoreCase(mode)) {
        errPrefix = "Unable to settle credit: ";
    }
    String errMsg = e.getMessage();
    if (errMsg == null || errMsg.trim().length() == 0) {
        errMsg = e.getClass().getSimpleName();
    }
    resp.put("message", errPrefix + errMsg);
    out.print(resp.toString());
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (con != null) try { con.close(); } catch (Exception e) {}
}
%>
