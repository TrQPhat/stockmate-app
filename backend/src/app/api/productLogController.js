const { ProductLog } = require("../models");

class ProductLogController {
  // Lấy tất cả bản ghi product log
  async getAllProductLogs(req, res) {
    try {
      const logs = await ProductLog.findAll();
      res.status(200).json(logs);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy danh sách product logs" });
    }
  }

  // Lấy product log theo id
  async getProductLogById(req, res) {
    try {
      const { id } = req.params;
      const log = await ProductLog.findByPk(id);
      if (!log) {
        return res.status(404).json({ error: "Product log không tồn tại" });
      }
      res.status(200).json(log);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin product log" });
    }
  }

  // Tạo mới product log
  async createProductLog(req, res) {
    try {
      const { id, product_id, action, quantity, note } = req.body;

      const newLog = await ProductLog.create({
        id,
        product_id,
        action,
        quantity,
        note,
      });

      res.status(201).json(newLog);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo product log" });
    }
  }

  // Cập nhật product log theo id
  async updateProductLog(req, res) {
    try {
      const { id } = req.params;
      const log = await ProductLog.findByPk(id);
      if (!log) {
        return res.status(404).json({ error: "Product log không tồn tại" });
      }

      const { product_id, action, quantity, note } = req.body;

      log.product_id = product_id ?? log.product_id;
      log.action = action ?? log.action;
      log.quantity = quantity ?? log.quantity;
      log.note = note ?? log.note;

      await log.save();

      res.status(200).json(log);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật product log" });
    }
  }

  // Xóa product log theo id
  async deleteProductLog(req, res) {
    try {
      const { id } = req.params;
      const log = await ProductLog.findByPk(id);
      if (!log) {
        return res.status(404).json({ error: "Product log không tồn tại" });
      }

      await log.destroy();

      res.status(200).json({ message: "Xóa product log thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa product log" });
    }
  }
}

module.exports = new ProductLogController();
