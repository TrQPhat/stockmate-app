const { Storage, StorageMember, sequelize } = require("../models");
const { v4: uuidv4 } = require("uuid");

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

  async createStorage(req, res) {
    const t = await sequelize.transaction(); // Bắt đầu transaction
    try {
      const { id = uuidv4(), name, owner_id } = req.body;

      if (!name || !owner_id) {
        return res.status(400).json({ error: "Thiếu name hoặc owner_id" });
      }

      const generateRandomKey = (length = 10) => {
        const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        let key = "";
        for (let i = 0; i < length; i++) {
          key += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return key;
      };

      const generateUniqueKey = async () => {
        let key;
        let exists = true;
        while (exists) {
          key = generateRandomKey();
          const existing = await Storage.findOne({ where: { key } });
          exists = !!existing;
        }
        return key;
      };

      const key = await generateUniqueKey();

      const newStorage = await Storage.create(
        {
          id,
          name,
          key,
          owner_id,
        },
        { transaction: t }
      );

      await StorageMember.create(
        {
          id: uuidv4(),
          storage_id: newStorage.id,
          user_id: owner_id,
          role: "owner",
          joined_at: new Date(),
        },
        { transaction: t }
      );

      await t.commit(); // Thành công: lưu thay đổi
      res.status(201).json(newStorage);
    } catch (error) {
      await t.rollback(); // Thất bại: huỷ tất cả
      console.error("Error creating storage:", error);
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
