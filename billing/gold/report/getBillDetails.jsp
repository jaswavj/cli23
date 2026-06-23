<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<jsp:useBean id="goldBean" class="gold.goldBillingBean" />
<jsp:useBean id="userBean" class="user.userBean" />
<%
    response.setContentType("application/json; charset=UTF-8");
    JSONObject resp = new JSONObject();
    
    try {
        String billIdStr = request.getParameter("id");
        if (billIdStr == null || billIdStr.trim().isEmpty()) {
            resp.put("status", "error");
            resp.put("message", "Bill ID is required");
            out.print(resp.toString());
            return;
        }
        
        int billId = Integer.parseInt(billIdStr);
        Vector billData = goldBean.getBillById(billId);
        
        if (billData == null || billData.size() < 16) {
            resp.put("status", "error");
            resp.put("message", "Bill not found");
            out.print(resp.toString());
            return;
        }
        
        // Bill data indices from getBillById: 
        // [0]id [1]bill_no [2]customer_id [3]customer_name [4]customer_phone 
        // [5]id_proof_no [6]addr_proof_no [7]gold_rate [8]gross_amount 
        // [9]margin [10]net_amount [11]release_amount [12]amount_paid 
        // [13]bill_date [14]bill_time [15]entered_dt
        
        JSONObject billInfo = new JSONObject();
        billInfo.put("id", billData.get(0));
        billInfo.put("bill_no", billData.get(1));
        billInfo.put("customer_id", billData.get(2));
        billInfo.put("customer_name", billData.get(3));
        billInfo.put("customer_phone", billData.get(4));
        billInfo.put("id_proof_no", billData.get(5));
        billInfo.put("addr_proof_no", billData.get(6));
        billInfo.put("gold_rate", billData.get(7));
        billInfo.put("gross_amount", billData.get(8));
        billInfo.put("margin", billData.get(9));
        billInfo.put("net_amount", billData.get(10));
        billInfo.put("release_amount", billData.get(11));
        billInfo.put("amount_paid", billData.get(12));
        billInfo.put("bill_date", billData.get(13));
        billInfo.put("bill_time", billData.get(14));
        billInfo.put("entered_dt", billData.get(15));
        
        // Get items
        Vector items = goldBean.getBillItems(billId);
        JSONArray itemsArray = new JSONArray();
        
        if (items != null && items.size() > 0) {
            for (int i = 0; i < items.size(); i++) {
                Vector item = (Vector) items.get(i);
                JSONObject itemObj = new JSONObject();
                
                // Item indices from getBillItems: [0]ornament_type [1]gross_wt [2]stone_wax 
                // [3]net_wt [4]purity [5]gross_amount
                itemObj.put("ornament_type", item.get(0) == null ? "" : item.get(0));
                itemObj.put("gross_wt", item.get(1) == null ? "" : item.get(1));
                itemObj.put("stone_wax", item.get(2) == null ? "" : item.get(2));
                itemObj.put("net_wt", item.get(3) == null ? "" : item.get(3));
                itemObj.put("purity", item.get(4) == null ? "" : item.get(4));
                itemObj.put("gross_amount", item.get(5) == null ? "" : item.get(5));
                
                itemsArray.put(itemObj);
            }
        }
        
        resp.put("status", "ok");
        resp.put("bill", billInfo);
        resp.put("items", itemsArray);
        
    } catch (Exception e) {
        resp.put("status", "error");
        resp.put("message", e.getMessage());
    }
    
    out.print(resp.toString());
%>
