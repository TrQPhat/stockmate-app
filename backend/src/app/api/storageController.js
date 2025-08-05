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

  // Chỉnh sửa role của thành viên trong kho
  async updateMemberRole(req, res) {
    try {
      const { storage_id, user_id } = req.params;
      const { role } = req.body;

      if (!role) {
        return res.status(400).json({
          success: false,
          error: "Thiếu role mới"
        });
      }

      const member = await StorageMember.findOne({
        where: { storage_id, user_id },
      });

      if (!member) {
        return res.status(404).json({
          success: false,
          error: "Không tìm thấy thành viên trong kho"
        });
      }

      member.role = role;
      await member.save();

      return res.status(200).json({
        success: true,
        message: "Cập nhật role thành công",
        member,
      });
    } catch (error) {
      console.error("updateMemberRole error:", error);
      return res.status(500).json({
        success: false,
        error: "Lỗi khi cập nhật role thành viên"
      });
    }
  }

  async removeMember(req, res) {
    try {
      const { storage_id, user_id } = req.params;

      // Tìm thành viên trong kho dựa trên storage_id và user_id
      const member = await StorageMember.findOne({
        where: { storage_id, user_id },
      });

      // Nếu không tìm thấy thành viên, trả về lỗi 404
      if (!member) {
        return res.status(404).json({
          success: false,
          error: "Không tìm thấy thành viên trong kho"
        });
      }

      // Nếu tìm thấy, xoá bản ghi thành viên
      await member.destroy();

      // Trả về thông báo thành công
      return res.status(200).json({
        success: true,
        message: "Xoá thành viên ra khỏi kho thành công",
      });
      
    } catch (error) {
      console.error("removeMember error:", error);
      return res.status(500).json({
        success: false,
        error: "Lỗi khi xoá thành viên khỏi kho"
      });
    }
  }

  async inviteMember(req, res) {
    try {
      const { storage_id } = req.params;
      const { email, role } = req.body;

      // Các bước 1, 2, 3: Validation, tìm user, kiểm tra tồn tại... giữ nguyên như cũ
      if (!email || !role) {
        return res.status(400).json({ success: false, error: "Thiếu email hoặc role" });
      }

      const user = await User.findOne({ where: { email } });
      if (!user) {
        return res.status(404).json({ success: false, error: "Người dùng với email này không tồn tại" });
      }

      const existingMember = await StorageMember.findOne({ where: { storage_id, user_id: user.id } });
      if (existingMember) {
        return res.status(409).json({ success: false, error: "Thành viên này đã có trong kho" });
      }

      // 4. Tạo bản ghi thành viên mới
      const newMember = await StorageMember.create({
        storage_id,
        user_id: user.id,
        role,
      });

      // 5. **[PHẦN THAY ĐỔI]** Tạo đối tượng trả về theo đúng định dạng client yêu cầu
      const responsePayload = {
        id: user.id,
        email: user.email,
        phone: user.phone,
        full_name: user.fullName, // Giả sử model User của bạn dùng camelCase `fullName`
        avatar_url: user.avatarUrl, // Tương tự
        gender: user.gender,
        created_at: user.createdAt, // Ngày user được tạo trong hệ thống
        updated_at: user.updatedAt, // Ngày user được cập nhật lần cuối
        role: newMember.role,       // Role lấy từ bản ghi `StorageMember` mới tạo
        joined_at: newMember.createdAt, // Ngày tham gia kho chính là ngày bản ghi `StorageMember` được tạo
      };

      // 6. Trả về thành công với payload đã được định dạng
      return res.status(201).json({
        success: true,
        message: "Mời thành viên thành công",
        member: responsePayload, // Trả về đối tượng đã được định dạng
      });

    } catch (error) {
      console.error("inviteMember error:", error);
      return res.status(500).json({
        success: false,
        error: "Lỗi khi mời thành viên"
      });
    }
  }
}

module.exports = new StorageController();
