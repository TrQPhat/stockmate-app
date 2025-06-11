const { Storage } = require("../models");

class StorageController {
  // Lấy danh sách tất cả storage
  async getAllStorages(req, res) {
    try {
      const storages = await Storage.findAll();
      res.status(200).json(storages);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy danh sách storage" });
    }
  }

  // Lấy storage theo id
  async getStorageById(req, res) {
    try {
      const { id } = req.params;
      const storage = await Storage.findByPk(id);
      if (!storage) {
        return res.status(404).json({ error: "Storage không tồn tại" });
      }
      res.status(200).json(storage);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin storage" });
    }
  }

  // Tạo mới storage
  async createStorage(req, res) {
    try {
      const { id, name, owner_id } = req.body;

      const newStorage = await Storage.create({
        id,
        name,
        owner_id,
      });

      res.status(201).json(newStorage);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo storage" });
    }
  }

  // Cập nhật storage theo id
  async updateStorage(req, res) {
    try {
      const { id } = req.params;
      const storage = await Storage.findByPk(id);
      if (!storage) {
        return res.status(404).json({ error: "Storage không tồn tại" });
      }

      const { name, owner_id } = req.body;

      storage.name = name ?? storage.name;
      storage.owner_id = owner_id ?? storage.owner_id;

      await storage.save();

      res.status(200).json(storage);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật storage" });
    }
  }

  // Xóa storage theo id
  async deleteStorage(req, res) {
    try {
      const { id } = req.params;
      const storage = await Storage.findByPk(id);
      if (!storage) {
        return res.status(404).json({ error: "Storage không tồn tại" });
      }

      await storage.destroy();

      res.status(200).json({ message: "Xóa storage thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa storage" });
    }
  }
}

module.exports = new StorageController();
