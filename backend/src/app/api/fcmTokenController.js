const { FcmToken, User } = require("../models");

class FcmTokenController {
  // Lấy danh sách tất cả token (có thể lọc theo user_id)
  async getAllTokens(req, res) {
    try {
      const { user_id } = req.query;

      const where = {};
      if (user_id) where.user_id = user_id;

      const tokens = await FcmToken.findAll({
        where,
        include: [
          {
            model: User,
            attributes: ["id", "email", "full_name"],
          },
        ],
      });

      res.status(200).json(tokens);
    } catch (error) {
      console.error("Lỗi khi lấy danh sách token:", error);
      res.status(500).json({ error: "Lỗi khi lấy danh sách token" });
    }
  }

  // Tạo mới hoặc cập nhật token cho người dùng
  async createOrUpdateToken(req, res) {
    try {
      const { user_id, token, device_name, platform } = req.body;

      if (!user_id || !token) {
        return res.status(400).json({ error: "Thiếu user_id hoặc token" });
      }

      const [fcmToken, created] = await FcmToken.findOrCreate({
        where: { user_id, token },
        defaults: { device_name, platform },
      });

      if (!created) {
        fcmToken.device_name = device_name ?? fcmToken.device_name;
        fcmToken.platform = platform ?? fcmToken.platform;
        fcmToken.updated_at = new Date();
        await fcmToken.save();
      }

      res.status(created ? 201 : 200).json(fcmToken);
    } catch (error) {
      console.error("Lỗi khi tạo/cập nhật token:", error);
      res.status(500).json({ error: "Lỗi khi tạo/cập nhật token" });
    }
  }

  // Xoá token theo ID
  async deleteToken(req, res) {
    try {
      const { id } = req.params;

      const token = await FcmToken.findByPk(id);
      if (!token) {
        return res.status(404).json({ error: "Token không tồn tại" });
      }

      await token.destroy();
      res.status(200).json({ message: "Xoá token thành công" });
    } catch (error) {
      console.error("Lỗi khi xoá token:", error);
      res.status(500).json({ error: "Lỗi khi xoá token" });
    }
  }
}

module.exports = new FcmTokenController();
