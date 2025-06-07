const { Ingredient } = require("../models"); // Import model

class IngredientController {
  // 1️⃣ Lấy danh sách nguyên liệu của sản phẩm
  async getIngredientsByProduct(req, res) {
    try {
      const { id } = req.params; // Lấy product_id từ URL
      const ingredients = await Ingredient.findAll({
        where: { product_id: id },
      });

      if (ingredients.length === 0) {
        return res
          .status(404)
          .json({ response: false, message: "Không tìm thấy nguyên liệu" });
      }

      res.status(200).json({ response: true, data: ingredients });
    } catch (error) {
      res
        .status(500)
        .json({ response: false, message: "Lỗi server", error: error.message });
    }
  }

  // 2️⃣ Thêm nguyên liệu vào sản phẩm (Admin)
  async createIngredient(req, res) {
    try {
      const { name, product_id, quantity } = req.body;

      if (!name || !product_id) {
        return res
          .status(400)
          .json({ response: false, message: "Thiếu thông tin" });
      }

      const newIngredient = await Ingredient.create({
        name,
        product_id,
        quantity,
      });
      res
        .status(201)
        .json({
          response: true,
          message: "Thêm nguyên liệu thành công",
          data: newIngredient,
        });
    } catch (error) {
      res
        .status(500)
        .json({ response: false, message: "Lỗi server", error: error.message });
    }
  }

  // 3️⃣ Cập nhật nguyên liệu (Admin)
  async updateIngredient(req, res) {
    try {
      const { id, name, quantity } = req.body;

      const ingredient = await Ingredient.findByPk(id);
      if (!ingredient) {
        return res
          .status(404)
          .json({ response: false, message: "Nguyên liệu không tồn tại" });
      }

      // Cập nhật chỉ những trường có trong request
      await ingredient.update({
        name: name || ingredient.name,
        quantity: quantity || ingredient.quantity,
      });

      res
        .status(200)
        .json({
          response: true,
          message: "Cập nhật thành công",
          data: ingredient,
        });
    } catch (error) {
      res
        .status(500)
        .json({ response: false, message: "Lỗi server", error: error.message });
    }
  }

  // 4️⃣ Xóa nguyên liệu (Admin)
  async deleteIngredient(req, res) {
    try {
      const { id } = req.body;

      const ingredient = await Ingredient.findByPk(id);
      if (!ingredient) {
        return res
          .status(404)
          .json({ response: false, message: "Nguyên liệu không tồn tại" });
      }

      await ingredient.destroy();
      res
        .status(200)
        .json({ response: true, message: "Xóa nguyên liệu thành công" });
    } catch (error) {
      res
        .status(500)
        .json({ response: false, message: "Lỗi server", error: error.message });
    }
  }
}

module.exports = new IngredientController();
