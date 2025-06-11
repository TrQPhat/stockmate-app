const { Category } = require("../models");
const { v4: uuidv4 } = require('uuid');

class CategoryController {
    // Lấy danh sách tất cả danh mục
    async getAllCategories(req, res) {
        try {
            const categories = await Category.findAll();
            res.status(200).json(categories);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy danh sách danh mục" });
        }
    }

    // Lấy thông tin danh mục theo id
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
            const { name, description } = req.body;
            const newCategory = await Category.create({
                id: uuidv4(), // Tự động tạo UUID
                name,
                description,
            });
            res.status(201).json(newCategory);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi tạo danh mục" });
        }
    }

    // Cập nhật danh mục theo id
    async updateCategory(req, res) {
        try {
            const { id } = req.params;
            const category = await Category.findByPk(id);
            if (!category) {
                return res.status(404).json({ error: "Danh mục không tồn tại" });
            }

            const { name, description } = req.body;
            category.name = name ?? category.name;
            category.description = description ?? category.description;

            await category.save();
            res.status(200).json(category);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi cập nhật danh mục" });
        }
    }

    // Xóa danh mục theo id
    async deleteCategory(req, res) {
        try {
            const { id } = req.params;
            const category = await Category.findByPk(id);
            if (!category) {
                return res.status(404).json({ error: "Danh mục không tồn tại" });
            }

            await category.destroy();
            res.status(200).json({ message: "Xóa danh mục thành công" });
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi xóa danh mục" });
        }
    }
}

module.exports = new CategoryController();