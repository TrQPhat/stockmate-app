const Size = require("../models/size");

class SizeController {
  // Phương thức lấy danh sách tất cả các size
  async getAllSize(req, res) {
    try {
      // Lấy tất cả các size từ cơ sở dữ liệu
      const sizes = await Size.findAll();

      // Trả về danh sách size dưới dạng JSON
      res.status(200).json({
        success: true,
        message: "Lấy danh sách size thành công",
        data: sizes,
      });
    } catch (error) {
      // Xử lý lỗi và trả về thông báo lỗi
      res.status(500).json({
        success: false,
        message: "Lỗi khi lấy danh sách size",
        error: error.message,
      });
    }
  }
}

module.exports = new SizeController();
