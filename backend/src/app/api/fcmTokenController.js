const { FcmToken } = require("../models");

class FcmTokenController {
  // Lấy danh sách tất cả FcmToken
  async getAll(req, res) {
    try {
      const tokens = await FcmToken.findAll();
      res.status(200).json(tokens);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // Lấy FcmToken theo id
  async getById(req, res) {
    try {
      const { id } = req.params;
      const token = await FcmToken.findByPk(id);

      if (!token) {
        return res.status(404).json({ error: "FcmToken không tồn tại" });
      }

      res.status(200).json(token);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy FcmToken" });
    }
  }

  // Tạo mới FcmToken
  async create(req, res) {
    try {
      const { id, user_id, token, device_name, platform } = req.body;

      const newToken = await FcmToken.create({
        id,
        user_id,
        token,
        device_name,
        platform,
      });

      res.status(201).json(newToken);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo FcmToken" });
    }
  }

  // Cập nhật FcmToken theo id
  async update(req, res) {
    try {
      const { id } = req.params;
      const token = await FcmToken.findByPk(id);

      if (!token) {
        return res.status(404).json({ error: "FcmToken không tồn tại" });
      }

      const { user_id, token: tokenValue, device_name, platform } = req.body;

      await token.update({
        user_id: user_id ?? token.user_id,
        token: tokenValue ?? token.token,
        device_name: device_name ?? token.device_name,
        platform: platform ?? token.platform,
      });

      res.status(200).json(token);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật FcmToken" });
    }
  }

  // Xóa FcmToken theo id
  async delete(req, res) {
    try {
      const { id } = req.params;
      const token = await FcmToken.findByPk(id);

      if (!token) {
        return res.status(404).json({ error: "FcmToken không tồn tại" });
      }

      await token.destroy();
      res.status(200).json({ message: "Xóa FcmToken thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa FcmToken" });
    }
  }
}

module.exports = new FcmTokenController();
