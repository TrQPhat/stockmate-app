const { Category } = require("../models");

class CategoryController {
  // Lấy danh sách tất cả danh mục


  async getAllCategories(req, res) {
    try {
      const { storage_id } = req.params;
      if (!storage_id) {
        return res.status(400).json({ error: "Thiếu storage_id" });
      }

      const categories = await Category.findAll({
        where: { storage_id },
      });

      res.status(200).json(categories);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy danh sách danh mục" });
    }
  }


  // Lấy thông tin danh mục theo ID
  async getCategoryById(req, res) {
    try {
      const { id } = req.params;
      const category = await Category.findByPk(id);
      if (!category) {
        return res.status(404).json({ error: "Danh mục không tồn tại" });
      }
      res.status(200).json(category);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin danh mục" });
    }
  }

  // Tạo mới danh mục
  async createCategory(req, res) {
    try {
      const { name, description, storage_id } = req.body;

      if (!name || name.trim() === "") {
        return res.status(400).json({ error: "Tên danh mục là bắt buộc" });
      }
      if (!storage_id) {
        return res.status(400).json({ error: "Thiếu storage_id" });
      }

      const newCategory = await Category.create({
        name,
        description,
        storage_id,
        created_at: new Date(),
      });

      res.status(201).json(newCategory);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo danh mục" });
    }
  }

  // Cập nhật danh mục theo ID
  async updateCategory(req, res) {
    try {
      const { id } = req.params;
      const { name, description } = req.body;
      const category = await Category.findByPk(id);
      if (!category) {
        return res.status(404).json({ error: "Danh mục không tồn tại" });
      }

      category.name = name ?? category.name;
      category.description = description ?? category.description;

      await category.save();
      res.status(200).json(category);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật danh mục" });
    }
  }

  // Xóa danh mục theo ID
  async deleteCategory(req, res) {
    try {
      const { id } = req.params;
 
      
      const category = await Category.findOne({ where: { id } });
      if (!category) {
        return res.status(404).json({ error: "Danh mục không tồn tại hoặc không thuộc kho này" });
      }

      await category.destroy();
      res.status(200).json({ message: "Xóa danh mục thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa danh mục" });
    }
  }
}

module.exports = new CategoryController();
