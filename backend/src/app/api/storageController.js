const { json } = require("body-parser");
const { Storage, StorageMember, sequelize, User } = require("../models");

class StorageController {
  // ✅ Lấy danh sách tất cả các storage (gồm cả owner và members)
  async getAllStorages(req, res) {
    try {
      const storages = await Storage.findAll({
        include: [
          {
            model: StorageMember,
            as: "members",
            include: [
              {
                model: User,
                attributes: ["id", "full_name", "email"],
              },
            ],
          },
          {
            model: User,
            as: "owner",
            attributes: ["id", "full_name", "email"],
          },
        ],
      });
      res.status(200).json(storages);
    } catch (error) {
      console.error("getAllStorages error:", error);
      res.status(500).json({ error: "Lỗi khi lấy danh sách kho" });
    }
  }

  // ✅ Lấy thông tin chi tiết của 1 storage
  async getStorageById(req, res) {
    try {
      const { id } = req.params;
      const storage = await Storage.findByPk(id, {
        include: [
          {
            model: StorageMember,
            as: "members",
            include: [
              { model: User, attributes: ["id", "full_name", "email"] },
            ],
          },
          {
            model: User,
            as: "owner",
            attributes: ["id", "full_name", "email"],
          },
        ],
      });

      if (!storage) {
        return res.status(404).json({ error: "Kho không tồn tại" });
      }

      res.status(200).json(storage);
    } catch (error) {
      console.error("getStorageById error:", error);
      res.status(500).json({ error: "Lỗi khi lấy thông tin kho" });
    }
  }

  // ✅ Lấy thông tin chi tiết của 1 storage
  async getAllUsersInStorage (req, res) {
    const storageId = req.params.storage_id;

    try {
      const members = await StorageMember.findAll({
        where: { storage_id: storageId },
        include: [
          {
            model: User,
            attributes: [
              'id',
              'email',
              'phone',
              'full_name',
              'avatar_url',
              'gender',
              'created_at',
              'updated_at',
            ],
          },
        ],
        attributes: ['role', 'joined_at'],
      });

      if (!members || members.length === 0) {
        return res.status(404).json({
          message: `Không tìm thấy thành viên nào trong kho có ID = ${storageId}`,
        });
      }

      const result = members.map((member) => ({
        ...member.User.dataValues,
        role: member.role,
        joined_at: member.joined_at,
      }));

      return res.json({
        storage_id: storageId,
        members: result,
      });
    } catch (error) {
      console.error('Lỗi khi lấy danh sách thành viên:', error);
      return res.status(500).json({ message: 'Lỗi server' });
    }
  }

  // ✅ Tạo mới storage (kèm tạo storage_member role owner)
  async createStorage(req, res) {
    const t = await sequelize.transaction();
    try {
      const { name, owner_id } = req.body;
      if (!name || !owner_id) {
        return res.status(400).json({ error: "Thiếu name hoặc owner_id" });
      }

      // Tạo key duy nhất
      const generateKey = async (length = 10) => {
        const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        let key;
        let exists;
        do {
          key = Array.from(
            { length },
            () => chars[Math.floor(Math.random() * chars.length)]
          ).join("");
          exists = await Storage.findOne({ where: { key } });
        } while (exists);
        return key;
      };

      const key = await generateKey();

      const newStorage = await Storage.create(
        {
          name,
          owner_id,
          key,
          created_at: new Date(),
        },
        { transaction: t }
      );

      await StorageMember.create(
        {
          storage_id: newStorage.id,
          user_id: owner_id,
          role: "owner",
          joined_at: new Date(),
        },
        { transaction: t }
      );

      await t.commit();
      res.status(201).json(newStorage);
    } catch (error) {
      await t.rollback();
      console.error("createStorage error:", error);
      res.status(500).json({ error: "Lỗi khi tạo kho" });
    }
  }

  // Tham gia vào kho
  async joinToStorageByKey(req, res) {
    const { key, user_id } = req.body;

    if (!key || !user_id) {
      return res.status(400).json({ error: "Thiếu mã tham gia" });
    }

    try {
      const anyMembership = await StorageMember.findOne({
        where: { user_id },
      });

      if (anyMembership) {
        return res.status(400).json({
          error: "Người dùng đã tham gia một kho hiện tại.",
        });
      }

      const storage = await Storage.findOne({ where: { key } });

      if (!storage) {
        return res.status(404).json({ error: "Mã tham gia không hợp lệ" });
      }

      const member = await StorageMember.create({
        storage_id: storage.id,
        user_id,
        role: "member", // mặc định
      });

      return res.status(201).json({
        message: "Tham gia kho thành công",
        storage: storage.toJSON(),
      });
    } catch (error) {
      console.error("Lỗi khi tham gia kho:", error);
      return res
        .status(500)
        .json({ error: "Lỗi máy chủ", detail: error.message });
    }
  }

  // ✅ Cập nhật storage (name hoặc owner_id)
  async updateStorage(req, res) {
    try {
      const { id } = req.params;
      const { name, owner_id } = req.body;

      const storage = await Storage.findByPk(id);
      if (!storage) {
        return res.status(404).json({ error: "Kho không tồn tại" });
      }

      storage.name = name ?? storage.name;
      storage.owner_id = owner_id ?? storage.owner_id;

      await storage.save();
      res.status(200).json(storage);
    } catch (error) {
      console.error("updateStorage error:", error);
      res.status(500).json({ error: "Lỗi khi cập nhật kho" });
    }
  }

  // ✅ Xoá storage và toàn bộ storage_members liên quan
  async deleteStorage(req, res) {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;

      const storage = await Storage.findByPk(id);
      if (!storage) {
        return res.status(404).json({ error: "Kho không tồn tại" });
      }

      await StorageMember.destroy({
        where: { storage_id: id },
        transaction: t,
      });
      await storage.destroy({ transaction: t });

      await t.commit();
      res.status(200).json({ message: "Xóa kho thành công" });
    } catch (error) {
      await t.rollback();
      console.error("deleteStorage error:", error);
      res.status(500).json({ error: "Lỗi khi xóa kho" });
    }
  }

  // ✅ Lấy danh sách thành viên của kho
  async getMembers(req, res) {
    try {
      const { id } = req.params;
      const members = await StorageMember.findAll({
        where: { storage_id: id },
        include: [{ model: User, attributes: ["id", "full_name", "email"] }],
      });
      res.status(200).json(members);
    } catch (error) {
      console.error("getMembers error:", error);
      res.status(500).json({ error: "Lỗi khi lấy thành viên kho" });
    }
  }
}

module.exports = new StorageController();
