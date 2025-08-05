const { Note, User } = require("../models");

class NoteController {
  // Lấy tất cả ghi chú theo dish_id
  async getAll(req, res) {
    try {
      const { dish_id } = req.params;

      if (!dish_id) {
        return res.status(400).json({ error: "Thiếu dish_id" });
      }

      const notes = await Note.findAll({
        where: { dish_id },
        include: [
          {
            model: User,
            as: "user",
            attributes: ["full_name"],
          },
        ],
        order: [["created_at", "DESC"]], // nếu cần sắp xếp
      });

      const formattedNotes = notes.map(note => ({
        id: note.id,
        dish_id: note.dish_id,
        content: note.content ?? "",
        user_id: note.user_id,
        author: note.user?.full_name ?? "",
        created_at: note.created_at, // hoặc `new Date(note.created_at)`
      }));

      res.json(formattedNotes);
    } catch (error) {
      res.status(500).json({
        error: "Không thể lấy danh sách ghi chú",
        detail: error.message,
      });
    }
  }


  // Lấy ghi chú theo ID
  async getById(req, res) {
    const { id } = req.params;
    try {
      const note = await Note.findByPk(id);
      if (!note) {
        return res.status(404).json({ error: "Không tìm thấy ghi chú" });
      }
      res.json(note);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Lỗi khi lấy ghi chú", detail: error.message });
    }
  }

  // Tạo ghi chú mới
  async create(req, res) {
    const { user_id, dish_id, content, created_at } = req.body;

    if (!user_id || !dish_id === undefined) {
      return res.status(400).json({ error: "Thiếu thông tin bắt buộc" });
    }

    try {
      const newNote = await Note.create({
        user_id,
        dish_id,
        content,
        created_at,
      });

      res.status(201).json(newNote);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Không thể tạo ghi chú", detail: error.message });
    }
  }

  // Cập nhật ghi chú
  async update(req, res) {
    const { id } = req.params;

    try {
      const note = await Note.findByPk(id);
      if (!note) {
        return res.status(404).json({ error: "Không tìm thấy ghi chú" });
      }

      const { content } = req.body;

      note.content = content ?? note.content;

      await note.save();
      res.json(note);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Không thể cập nhật ghi chú", detail: error.message });
    }
  }

  // Xoá ghi chú
  async delete(req, res) {
    const { id } = req.params;

    try {
      const note = await Note.findByPk(id);
      if (!note) {
        return res.status(404).json({ error: "Không tìm thấy ghi chú" });
      }

      await note.destroy();
      res.json({ message: "Xoá ghi chú thành công" });
    } catch (error) {
      res
        .status(500)
        .json({ error: "Không thể xoá ghi chú", detail: error.message });
    }
  }
}

module.exports = new NoteController();
