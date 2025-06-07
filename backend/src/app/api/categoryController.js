const { Category } = require("../models");

class CategoryController {
  constructor() {}

  // Lấy tất cả danh mục
  async getAll(req, res) {
    try {
      const categories = await Category.findAll();
      res.status(200).json({ response: true, categories: categories });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi lấy danh sách danh mục",
        error: error.message,
      });
    }
  }

  // Thêm danh mục mới
  async addCategory(req, res) {
    const { name, icon_code_point, icon_font_family, icon_font_package } =
      req.body;

    try {
      const newCategory = await Category.create({
        name,
        icon_code_point,
        icon_font_family,
        icon_font_package,
      });

      res.status(201).json({
        response: true,
        message: "Thêm danh mục thành công",
        data: newCategory,
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi thêm danh mục",
        error: error.message,
      });
    }
  }

  // Cập nhật danh mục
  async updateCategory(req, res) {
    const { id } = req.params;
    const { name, icon_code_point, icon_font_family, icon_font_package } =
      req.body;

    try {
      const category = await Category.findByPk(id);

      if (!category) {
        return res.status(404).json({
          response: false,
          message: "Danh mục không tồn tại",
        });
      }

      category.name = name;
      category.icon_code_point = icon_code_point;
      category.icon_font_family = icon_font_family;
      category.icon_font_package = icon_font_package;

      await category.save();

      res.status(200).json({
        response: true,
        message: "Cập nhật danh mục thành công",
        data: category,
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi cập nhật danh mục",
        error: error.message,
      });
    }
  }

  // Xoá danh mục
  async deleteCategory(req, res) {
    const { id } = req.params;

    try {
      const category = await Category.findByPk(id);

      if (!category) {
        return res.status(404).json({
          response: false,
          message: "Danh mục không tồn tại",
        });
      }

      await category.destroy();

      res.status(200).json({
        response: true,
        message: "Xóa danh mục thành công",
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi xóa danh mục",
        error: error.message,
      });
    }
  }
}

module.exports = new CategoryController();
