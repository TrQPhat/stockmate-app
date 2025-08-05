const { Position } = require("../models");

class PositionController {
  // Lấy tất cả vị trí
  async getAll(req, res) {
    try {
      const { storage_id } = req.params;

      if (!storage_id) {
        return res.status(400).json({ error: "Thiếu storage_id" });
      }

      const positions = await Position.findAll({
        where: { storage_id },
      });

      res.json(positions);
    } catch (error) {
      res.status(500).json({
        error: "Không thể lấy danh sách vị trí",
        detail: error.message,
      });
    }
  }


  // Lấy vị trí theo ID
  async getById(req, res) {
    const { id } = req.params;
    try {
      const position = await Position.findByPk(id);
      if (!position) {
        return res.status(404).json({ error: "Không tìm thấy vị trí" });
      }
      res.json(position);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Lỗi khi lấy vị trí", detail: error.message });
    }
  }

  // Tạo vị trí mới
  async create(req, res) {
    const { name, description, storage_id } = req.body;
    if (!name) {
      return res.status(400).json({ error: "Tên vị trí là bắt buộc" });
    }
    if (!storage_id) {
      return res.status(400).json({ error: "Thiếu storage_id" });
    }
    try {
      const newPosition = await Position.create({ name, description, storage_id });
      res.status(201).json(newPosition);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Không thể tạo vị trí", detail: error.message });
    }
  }

  // Cập nhật vị trí theo ID
  async update(req, res) {
    try {
      const { id } = req.params;

      // Validate cơ bản: id phải tồn tại
      if (!id) {
        return res.status(400).json({ error: "Thiếu id vị trí" });
      }

      const { name, description } = req.body;

      // Optional: kiểm tra body rỗng (không có gì để cập nhật)
      if (name === undefined && description === undefined) {
        return res.status(400).json({ error: "Không có trường nào để cập nhật" });
      }

      const position = await Position.findByPk(id);
      if (!position) {
        return res.status(404).json({ error: "Vị trí không tồn tại" });
      }

      // Chỉ cập nhật những trường cho phép (ngăn mass-assignment)
      const updates = {};
      if (name !== undefined) updates.name = name;
      if (description !== undefined) updates.description = description;

      // Nếu không có thay đổi (cùng giá trị), có thể trả về 200 mà không save
      const hasChanges = Object.keys(updates).some(
        (k) => position[k] !== updates[k]
      );

      if (!hasChanges) {
        return res.status(200).json(position); // hoặc 304 Not Modified tùy yêu cầu
      }

      // Dùng update để apply và validate (hoặc dùng set + save như bạn có)
      await position.update(updates);

      // Nếu cần, reload để lấy associations hoặc fields tự động cập nhật
      // await position.reload();

      return res.status(200).json(position);
    } catch (error) {
      // Xử lý lỗi validation từ Sequelize rõ ràng hơn
      if (error.name === "SequelizeValidationError") {
        const messages = error.errors.map((e) => e.message);
        return res.status(400).json({ error: "Validation failed", detail: messages });
      }

      return res
        .status(500)
        .json({ error: "Không thể cập nhật vị trí", detail: error.message });
    }
  }


  // Xoá vị trí theo ID
  async delete(req, res) {
    const { id } = req.params;

    try {
      const position = await Position.findOne({ where: { id } });
      if (!position) {
        return res.status(404).json({ error: "Không tìm thấy vị trí hoặc không thuộc kho này" });
      }
      await position.destroy();
      res.json({ message: "Xoá vị trí thành công" });
    } catch (error) {
      res
        .status(500)
        .json({ error: "Không thể xoá vị trí", detail: error.message });
    }
  }
}

module.exports = new PositionController();
