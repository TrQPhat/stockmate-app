const Option = require("../models/option");

class OptionController {
  // Lấy danh sách tất cả các option
  async getAllOptions(req, res) {
    try {
      const options = await Option.findAll();
      res.status(200).json({ success: true, data: options });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  // Lấy chi tiết một option theo ID
  async getOptionsByProductId(req, res) {
    try {
      const { product_id } = req.params; // Lấy product_id từ params
      const options = await Option.findAll({
        where: { product_id }, // Điều kiện tìm kiếm theo product_id
      });

      if (options.length === 0) {
        return res.status(404).json({
          success: false,
          message: "No options found for this product",
        });
      }

      res.status(200).json({ success: true, data: options });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  // Tạo một option mới
  async createOption(req, res) {
    try {
      const { product_id, name, description, price } = req.body;
      const newOption = await Option.create({
        product_id,
        name,
        description,
        price,
      });
      res.status(201).json({ success: true, data: newOption });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  // Cập nhật một option theo ID
  async updateOption(req, res) {
    try {
      const { id } = req.params;
      const { name, description, price } = req.body;
      const option = await Option.findByPk(id);
      if (!option) {
        return res
          .status(404)
          .json({ success: false, message: "Option not found" });
      }
      option.name = name || option.name;
      option.description = description || option.description;
      option.price = price || option.price;
      await option.save();
      res.status(200).json({ success: true, data: option });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  // Xóa một option theo ID
  async deleteOption(req, res) {
    try {
      const { id } = req.params;
      const option = await Option.findByPk(id);
      if (!option) {
        return res
          .status(404)
          .json({ success: false, message: "Option not found" });
      }
      await option.destroy();
      res
        .status(200)
        .json({ success: true, message: "Option deleted successfully" });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new OptionController();
