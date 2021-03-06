﻿<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.Xml"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>当批订单查询测试</title>
</head>
<body>

    <%
        string begTime = Request.Params.Get("begTime");
        string endTime = Request.Params.Get("endTime");
        string flag = Request.Params.Get("flag");
        string begIndex = Request.Params.Get("begIndex");
        string begOrder = Request.Params.Get("begOrder");
        string endOrder = Request.Params.Get("endOrder");
        string sortField = Request.Params.Get("sortField");
        string sortOrder = Request.Params.Get("sortOrder");
        string tranCode = "cb2203_queryCurOrderOp";

        StringBuilder sendMsg = new StringBuilder("");

        //组织申请报文
        sendMsg.Append("<Message>")
               .Append("<TranCode>").Append(tranCode).Append("</TranCode>")
               .Append("<MsgContent><BOCOMB2C><opName>").Append(tranCode).Append("</opName><reqParam><merchantID>")
               .Append(config.merchantID).Append("</merchantID>")
               .Append("<beginTime>").Append(begTime).Append("</beginTime><endTime>")
               .Append(endTime).Append("</endTime><flag>").Append(flag).Append("</flag><beginIndex>")
               .Append(begIndex).Append("</beginIndex><beginOrder>").Append(begOrder).Append("</beginOrder><endOrder>")
               .Append(endOrder).Append("</endOrder><sortField>").Append(sortField).Append("</sortField><sortOrder>")
               .Append(sortOrder).Append("</sortOrder>")
               .Append("</reqParam></BOCOMB2C></MsgContent></Message>");


        TcpClient client = new TcpClient(config.ip, config.port);
        NetworkStream stream = client.GetStream();

        Byte[] data = System.Text.Encoding.UTF8.GetBytes(sendMsg.ToString());
        stream.Write(data, 0, data.Length);
        data = new Byte[50 * 1024];
        String responseData = String.Empty;
        Int32 bytes = stream.Read(data, 0, data.Length);
        responseData = System.Text.Encoding.UTF8.GetString(data, 0, bytes);
        stream.Close();
        client.Close();

        //解析返回报文
        XmlDocument xmlDoc = new XmlDocument();
        xmlDoc.LoadXml(responseData);
        XmlNodeList list = xmlDoc.GetElementsByTagName("retCode");
        string retCode = list.Item(0).InnerText.Trim();
        list = xmlDoc.GetElementsByTagName("errMsg");
        string errMsg = "";
        if (list.Item(0) != null)
        {
            errMsg = list.Item(0).InnerText.Trim();
        }

        Response.Write("交易返回码：" + retCode + "<br>");
        Response.Write("交易错误信息：" + errMsg + "<br>");
        if ("0".Equals(retCode))
        {

            XmlNodeList result = xmlDoc.GetElementsByTagName("opResult");
            string merchantID = result.Item(0).SelectSingleNode("merchantID").InnerText.Trim();
            string totalNumber = result.Item(0).SelectSingleNode("totalNumber").InnerText.Trim();
            string beginIndex;
            if (int.Parse(totalNumber) > 20)
            {
                beginIndex = "20";
            }
            else
            {
                beginIndex = totalNumber;
            }
            
            Response.Write("总交易记录数：" + totalNumber + "<br>");
            Response.Write("本次返回记录数：" + beginIndex + "<br>");

        
            XmlNode opResultSet = xmlDoc.GetElementsByTagName("opResultSet").Item(0);
            XmlNodeList opResult = opResultSet.SelectNodes("opResult");
            for (int i = 0; i < opResult.Count; i++)
            {
                string order = opResult.Item(i).SelectSingleNode("order").InnerText.Trim();
                string orderDate = opResult.Item(i).SelectSingleNode("orderDate").InnerText.Trim();
                string orderTime = opResult.Item(i).SelectSingleNode("orderTime").InnerText.Trim();
                string curType = opResult.Item(i).SelectSingleNode("curType").InnerText.Trim();
                string amount = opResult.Item(i).SelectSingleNode("amount").InnerText.Trim();
                string tranDate = opResult.Item(i).SelectSingleNode("tranDate").InnerText.Trim();
                string tranTime = opResult.Item(i).SelectSingleNode("tranTime").InnerText.Trim();
                string tranState = opResult.Item(i).SelectSingleNode("tranState").InnerText.Trim();
                string orderState = opResult.Item(i).SelectSingleNode("orderState").InnerText.Trim();
                string fee = opResult.Item(i).SelectSingleNode("fee").InnerText.Trim();
                string bankSerialNo = opResult.Item(i).SelectSingleNode("bankSerialNo").InnerText.Trim();
                string bankBatNo = opResult.Item(i).SelectSingleNode("bankBatNo").InnerText.Trim();
                string cardType = opResult.Item(i).SelectSingleNode("cardType").InnerText.Trim();
                string merchantBatNo;
                string merchantComment;
                string bankComment;

                if (!opResult.Item(i).Name.Equals("merchantBatNo"))
                {
                    merchantBatNo = "";
                }
                else
                {
                    merchantBatNo = opResult.Item(i).SelectSingleNode("merchantBatNo").InnerText.Trim();
                }

                if (!opResult.Item(i).Name.Equals("merchantComment"))
                {
                    merchantComment = "";
                }
                else
                {
                    merchantComment = opResult.Item(i).SelectSingleNode("merchantComment").InnerText.Trim();
                }

                if (!opResult.Item(i).Name.Equals("bankComment"))
                {
                    bankComment = "";
                }
                else
                {
                    bankComment = opResult.Item(i).SelectSingleNode("bankComment").InnerText.Trim();
                }


                Response.Write("订单号：" + order + "<br>");
                Response.Write("订单日期：" + orderDate + "<br>");
                Response.Write("订单时间：" + orderTime + "<br>");
                Response.Write("币种：" + curType + "<br>");
                Response.Write("金额：" + amount + "<br>");
                Response.Write("交易日期：" + tranDate + "<br>");
                Response.Write("交易时间：" + tranTime + "<br>");
                Response.Write("支付交易状态：" + tranState + "<br>");
                Response.Write("定单状态[0 所有 1 已支付 2 已撤销 3 部分退货 4退货处理中 5 全部退货]：" + orderState + "<br>");
                Response.Write("手续费：" + fee + "<br>");
                Response.Write("银行流水号：" + bankSerialNo + "<br>");
                Response.Write("银行批次号：" + bankBatNo + "<br>");
                Response.Write("交易卡类型[0:借记卡 1：准贷记卡 2:贷记卡]：" + cardType + "<br>");
                Response.Write("商户批次号：" + merchantBatNo + "<br>");
                Response.Write("商户备注：" + merchantComment + "<br>");
                Response.Write("银行备注：" + bankComment + "<br>");
                Response.Write("<br>");
            }
        }
     %>
    
</body>
</html>
