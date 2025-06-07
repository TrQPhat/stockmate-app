const { StorageMember } = require("../models");

class StorageMemberController {
  // Lấy danh sách tất cả storage member
  async getAllStorageMembers(req, res) {
    try {
      const members = await StorageMember.findAll();
      res.status(200).json(members);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy danh sách storage member" });
    }
  }

  // Lấy storage member theo id
  async getStorageMemberById(req, res) {
    try {
      const { id } = req.params;
      const member = await StorageMember.findByPk(id);
      if (!member) {
        return res.status(404).json({ error: "Storage member không tồn tại" });
      }
      res.status(200).json(member);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin storage member" });
    }
  }

  // Tạo mới storage member
  async createStorageMember(req, res) {
    try {
      const { id, storage_id, user_id, role } = req.body;

      const newMember = await StorageMember.create({
        id,
        storage_id,
        user_id,
        role,
      });

      res.status(201).json(newMember);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo storage member" });
    }
  }

  // Cập nhật storage member theo id
  async updateStorageMember(req, res) {
    try {
      const { id } = req.params;
      const member = await StorageMember.findByPk(id);
      if (!member) {
        return res.status(404).json({ error: "Storage member không tồn tại" });
      }

      const { storage_id, user_id, role } = req.body;

      member.storage_id = storage_id ?? member.storage_id;
      member.user_id = user_id ?? member.user_id;
      member.role = role ?? member.role;

      await member.save();

      res.status(200).json(member);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật storage member" });
    }
  }

  // Xóa storage member theo id
  async deleteStorageMember(req, res) {
    try {
      const { id } = req.params;
      const member = await StorageMember.findByPk(id);
      if (!member) {
        return res.status(404).json({ error: "Storage member không tồn tại" });
      }

      await member.destroy();

      res.status(200).json({ message: "Xóa storage member thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa storage member" });
    }
  }
}

module.exports = new StorageMemberController();
