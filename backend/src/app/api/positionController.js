const { Position } = require("../models");

class PositionController {
  // Lấy tất cả vị trí
  async getAll(req, res) {
    try {
      const positions = await Position.findAll();
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
    const { name, description } = req.body;
    if (!name) {
      return res.status(400).json({ error: "Tên vị trí là bắt buộc" });
    }
    try {
      const newPosition = await Position.create({ name, description });
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
      const position = await Position.findByPk(id);
      if (!position) {
        return res.status(404).json({ error: "Danh mục không tồn tại" });
      }

      const { name, description } = req.body;
      position.name = name ?? position.name;
      position.description = description ?? position.description;

      await position.save();
      res.status(200).json(position);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Không thể cập nhật vị trí", detail: error.message });
    }
  }

  // Xoá vị trí theo ID
  async delete(req, res) {
    const { id } = req.params;
    try {
      const position = await Position.findByPk(id);
      if (!position) {
        return res.status(404).json({ error: "Không tìm thấy vị trí" });
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
