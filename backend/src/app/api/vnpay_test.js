const crypto = require("crypto");
const querystring = require("querystring");
const moment = require("moment");

class VNPayController {
  constructor() {
    this._vnp_TmnCode = process.env.VNP_TMN_CODE || "LJMCJ8KZ";
    this._vnp_HashSecret =
      process.env.VNP_HASH_SECRET || "RD0B365HBVL8ZN4A0FA9DB1UZ3RJTI3W";
    this._vnp_Url =
      process.env.VNP_URL ||
      "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    this._vnp_ReturnUrl =
      process.env.VNP_RETURN_URL ||
      "https://example.com/api/payment/vnpay_return";
  }

  /**
   * API tạo URL thanh toán VNPay
   * @param {Object} req - Request từ client
   * @param {Object} res - Response trả về client
   */
  async createPayment(req, res) {
    try {
      const { orderId, totalPrice, userEmail, ipAddr, bankCode } = req.body;

      // Kiểm tra dữ liệu đầu vào
      if (!orderId || !totalPrice || !userEmail || !ipAddr) {
        return res.status(400).json({
          message: "Thiếu thông tin cần thiết",
          response: false,
        });
      }

      const date = new Date();

      const createDate = this.formatDate(date);

      const expireDate = this.formatDate(
        new Date(date.getTime() + 15 * 60 * 1000)
      );

      const vnp_Params = {
        vnp_Version: "2.1.0",
        vnp_Command: "pay",
        vnp_TmnCode: this._vnp_TmnCode,
        vnp_Amount: totalPrice * 100, // VNPay yêu cầu nhân 100
        vnp_CreateDate: createDate,
        vnp_ExpireDate: expireDate,
        vnp_CurrCode: "VND",
        vnp_IpAddr: ipAddr,
        vnp_Locale: "vn",
        vnp_OrderInfo: `Thanh toan don hang ${orderId}`,
        vnp_OrderType: "other",
        vnp_ReturnUrl: this._vnp_ReturnUrl,
        vnp_TxnRef: orderId,
        vnp_Inv_Email: userEmail,
      };

      // Thêm bankCode nếu có
      if (bankCode) {
        vnp_Params["vnp_BankCode"] = bankCode;
      }

      // Sắp xếp tham số theo thứ tự alphabet
      const sortedParams = this.sortObject(vnp_Params);

      // Tạo query string và hash
      const signData = querystring.stringify(sortedParams, { encode: false });
      const hmac = crypto.createHmac("sha512", this._vnp_HashSecret);
      const signed = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

      // Thêm chữ ký vào params
      sortedParams["vnp_SecureHash"] = signed;

      // Tạo URL thanh toán
      const paymentUrl =
        this._vnp_Url +
        "?" +
        querystring.stringify(sortedParams, { encode: false });

      // Trả về URL thanh toán
      return res.status(200).json({
        message: "Tạo URL thanh toán thành công",
        response: true,
        paymentUrl,
      });
    } catch (error) {
      console.error("Error:", error);
      return res.status(500).json({
        message: "Đã xảy ra lỗi khi tạo URL thanh toán",
        response: false,
        error: error.message,
      });
    }
  }

  /**
   * API xác minh kết quả thanh toán từ VNPay
   * @param {Object} req - Request từ client
   * @param {Object} res - Response trả về client
   */
  async verifyPayment(req, res) {
    try {
      const query = req.query; // Lấy query parameters từ URL

      const vnp_Params = { ...query };
      const secureHash = vnp_Params["vnp_SecureHash"];

      // Lọc bỏ các param không cần thiết
      const excludeParams = ["vnp_SecureHash", "vnp_SecureHashType"];
      excludeParams.forEach((param) => delete vnp_Params[param]);

      // Sắp xếp lại params và tạo chữ ký
      const sortedParams = this.sortObject(vnp_Params);
      const signData = querystring.stringify(sortedParams, { encode: false });
      const hmac = crypto.createHmac("sha512", this._vnp_HashSecret);
      const signed = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

      // Kiểm tra chữ ký
      if (secureHash !== signed) {
        return res.status(400).json({
          message: "Chữ ký không hợp lệ",
          response: false,
          data: {
            orderId: "",
            amount: 0,
            raw: vnp_Params,
          },
        });
      }

      // Kiểm tra kết quả giao dịch
      const responseCode = vnp_Params["vnp_ResponseCode"];
      const isSuccess = responseCode === "00";

      return res.status(200).json({
        message: isSuccess
          ? "Xác minh thanh toán thành công"
          : "Xác minh thanh toán thất bại",
        response: isSuccess,
        data: {
          orderId: vnp_Params["vnp_TxnRef"],
          amount: parseInt(vnp_Params["vnp_Amount"], 10) / 100,
          bankCode: vnp_Params["vnp_BankCode"],
          bankTranNo: vnp_Params["vnp_BankTranNo"],
          transactionNo: vnp_Params["vnp_TransactionNo"],
          paymentDate: vnp_Params["vnp_PayDate"],
          raw: vnp_Params,
        },
      });
    } catch (error) {
      console.error("Error:", error);
      return res.status(500).json({
        message: "Đã xảy ra lỗi khi xác minh thanh toán",
        response: false,
        error: error.message,
      });
    }
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

  /**
   * Sắp xếp object theo key
   * @param {Object} obj - Object cần sắp xếp
   * @returns {Object} Object đã sắp xếp
   * @private
   */
  sortObject(obj) {
    const sorted = {};
    Object.keys(obj)
      .sort()
      .forEach((key) => {
        sorted[key] = obj[key];
      });
    return sorted;
  }

  /**
   * Lấy mô tả mã lỗi từ VNPay
   * @param {string} responseCode - Mã lỗi từ VNPay
   * @returns {string} Mô tả mã lỗi
   * @private
   */
  getResponseDescription(responseCode) {
    const codeMap = {
      "00": "Giao dịch thành công",
      "07": "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường).",
      "09": "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng.",
      10: "Giao dịch không thành công do: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần",
      11: "Giao dịch không thành công do: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch.",
      12: "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng bị khóa.",
      24: "Giao dịch không thành công do: Khách hàng hủy giao dịch",
      51: "Giao dịch không thành công do: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch.",
      65: "Giao dịch không thành công do: Tài khoản của Quý khách đã vượt quá hạn mức giao dịch trong ngày.",
      75: "Ngân hàng thanh toán đang bảo trì.",
      99: "Các lỗi khác (lỗi còn lại, không có trong danh sách mã lỗi đã liệt kê)",
    };

    return codeMap[responseCode] || `Mã lỗi không xác định (${responseCode})`;
  }
}

module.exports = new VNPayController();
