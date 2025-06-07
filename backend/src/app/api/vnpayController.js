const crypto = require("crypto");
const qs = require("qs");

class VNPayController {
  constructor() {
    this.vnp_TmnCode = process.env.VNP_TMN_CODE || "LJMCJ8KZ";
    this.vnp_HashSecret =
      process.env.VNP_HASH_SECRET || "RD0B365HBVL8ZN4A0FA9DB1UZ3RJTI3W";
    this.vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    this.vnp_ReturnUrl =
      "https://1d4a-2402-800-f685-2dee-cdc8-500b-7d8-6088.ngrok-free.app/api/payment/vnpay_return";
  }

  async createPayment(req, res) {
    try {
      const ipAddr =
        req.headers["x-forwarded-for"]?.split(",")[0] ||
        req.connection?.remoteAddress ||
        req.socket?.remoteAddress;

      const { orderId, totalPrice, userEmail } = req.body;

      console.log("-----------1-------------------");
      console.log("IP Address:", ipAddr);
      console.log("Order ID:", orderId);
      console.log("Total Price:", totalPrice);
      console.log("User Email:", userEmail);

      // Validate input
      if (!orderId || typeof orderId !== "string") {
        console.log("Order ID:", orderId);
        return res.status(400).json({ message: "Invalid orderId" });
      }
      if (!totalPrice || isNaN(totalPrice) || Number(totalPrice) <= 0) {
        console.log("Total Price:", totalPrice);
        return res.status(400).json({ message: "Invalid totalPrice" });
      }
      // if (!userEmail || !this.validateEmail(userEmail)) {
      //   return res.status(400).json({ message: "Invalid email" });
      // }
      const date = new Date();

      const createDate = this.formatDate(date);

      const expireDate = this.formatDate(
        new Date(date.getTime() + 15 * 60 * 1000)
      );
      const amount = Math.round(Number(totalPrice) * 100);
      const vnp_Params = {
        vnp_Version: "2.1.0",
        vnp_Command: "pay",
        vnp_TmnCode: this.vnp_TmnCode,
        vnp_Locale: "vn",
        vnp_CurrCode: "VND",
        vnp_TxnRef: orderId,
        vnp_OrderInfo: `Thanhtoandonhang${orderId}`,
        vnp_OrderType: "other",
        vnp_Amount: amount,
        vnp_ReturnUrl: this.vnp_ReturnUrl,
        vnp_IpAddr: ipAddr,
        vnp_CreateDate: createDate,
        vnp_ExpireDate: expireDate,
      };
      console.log("-----------8-------------------");
      const sortedParams = this.sortObject(vnp_Params);
      const rawDataToSign = Object.entries(sortedParams)
        .map(([key, value]) => `${key}=${encodeURIComponent(value)}`)
        .join("&");
      console.log("-----------9-------------------");
      const secureHash = crypto
        .createHmac("sha512", this.vnp_HashSecret)
        .update(rawDataToSign)
        .digest("hex")
        .toUpperCase();
      console.log("-----------10-------------------");
      sortedParams.vnp_SecureHash = secureHash;
      sortedParams.vnp_SecureHashType = "SHA512";

      const paymentUrl =
        this.vnp_Url + "?" + qs.stringify(sortedParams, { encode: true });

      return res.json({
        code: "00",
        message: "Success",
        paymentUrl,
      });
    } catch (error) {
      console.error("Error creating payment:", error);
      return res.status(500).json({
        code: "99",
        message: "Internal server error",
        error: error.message,
      });
    }
  }

  getClientIp(req) {
    return (
      req.headers["x-forwarded-for"]?.split(",")[0]?.trim() ||
      req.connection?.remoteAddress ||
      req.socket?.remoteAddress ||
      req.connection?.socket?.remoteAddress ||
      "127.0.0.1"
    ); // fallback to localhost
  }

  validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(String(email).toLowerCase());
  }

  formatDate(date) {
    if (!(date instanceof Date) || isNaN(date)) {
      throw new Error("Invalid date object");
    }

    const pad = (n) => (n < 10 ? "0" + n : n);
    return (
      date.getFullYear().toString() +
      pad(date.getMonth() + 1) +
      pad(date.getDate()) +
      pad(date.getHours()) +
      pad(date.getMinutes()) +
      pad(date.getSeconds())
    );
  }

  sortObject(obj) {
    if (typeof obj !== "object" || obj === null) {
      return {};
    }

    return Object.keys(obj)
      .sort()
      .reduce((acc, key) => {
        if (obj[key] !== undefined) {
          acc[key] = obj[key];
        }
        return acc;
      }, {});
  }

  async returnURL(req, res, next) {
    let vnp_Params = req.query;

    let secureHash = vnp_Params["vnp_SecureHash"];

    delete vnp_Params["vnp_SecureHash"];
    delete vnp_Params["vnp_SecureHashType"];

    vnp_Params = sortObject(vnp_Params);

    let config = require("config");
    let tmnCode = config.get("vnp_TmnCode");
    let secretKey = config.get("vnp_HashSecret");

    let querystring = require("qs");
    let signData = querystring.stringify(vnp_Params, { encode: false });
    let crypto = require("crypto");
    let hmac = crypto.createHmac("sha512", secretKey);
    let signed = hmac.update(new Buffer(signData, "utf-8")).digest("hex");

    if (secureHash === signed) {
      //Kiem tra xem du lieu trong db co hop le hay khong va thong bao ket qua

      res.render("success", { code: vnp_Params["vnp_ResponseCode"] });
    } else {
      res.render("success", { code: "97" });
    }
  }
  sortObject(obj) {
    let sorted = {};
    let str = [];
    let key;
    for (key in obj) {
      if (obj.hasOwnProperty(key)) {
        str.push(encodeURIComponent(key));
      }
    }
    str.sort();
    for (key = 0; key < str.length; key++) {
      sorted[str[key]] = encodeURIComponent(obj[str[key]]).replace(/%20/g, "+");
    }
    return sorted;
  }
}

module.exports = new VNPayController();
