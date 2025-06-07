const { User } = require("../models");

class UserController {
  // Lấy danh sách tất cả người dùng
  async getAll(req, res) {
    try {
      const users = await User.findAll();
      res.status(200).json(users);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // Lấy thông tin người dùng theo user_id (UUID)
  async getById(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findOne({ where: { user_id: id } });

      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }

      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin người dùng" });
    }
  }

  // Tạo người dùng mới
  async create(req, res) {
    try {
      const {
        user_id,
        email,
        phone,
        full_name,
        password_hash,
        avatar_url,
        gender,
      } = req.body;

      const newUser = await User.create({
        user_id,
        email,
        phone,
        full_name,
        password_hash,
        avatar_url,
        gender,
      });

      res.status(201).json(newUser);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo người dùng" });
    }
  }

  // Cập nhật người dùng theo user_id
  async update(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findOne({ where: { user_id: id } });

      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }

      const { email, phone, full_name, password_hash, avatar_url, gender } =
        req.body;

      await user.update({
        email: email ?? user.email,
        phone: phone ?? user.phone,
        full_name: full_name ?? user.full_name,
        password_hash: password_hash ?? user.password_hash,
        avatar_url: avatar_url ?? user.avatar_url,
        gender: gender ?? user.gender,
      });

      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật người dùng" });
    }
  }

  // Xóa người dùng theo user_id
  async delete(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findOne({ where: { user_id: id } });

      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }

      await user.destroy();
      res.status(200).json({ message: "Xóa người dùng thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa người dùng" });
    }
  }
}

module.exports = new UserController();
