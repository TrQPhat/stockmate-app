const { Dish, Storage, Note, Favorite } = require("../models");

class DishController {
  // Lấy tất cả món ăn
  async getAllDishes(req, res) {
    try {
      const { storage_id } = req.params;

      const whereClause = {};
      if (storage_id) {
        whereClause.storage_id = storage_id;
      }

      const dishes = await Dish.findAll({ where: whereClause });

      res.status(200).json(dishes);
    } catch (error) {
      console.error("Lỗi khi lấy danh sách món ăn:", error);
      res.status(500).json({ error: "Lỗi khi lấy danh sách món ăn" });
    }
  }

  // Lấy món ăn theo ID
  async getDishById(req, res) {
    try {
      const { id } = req.params;
      const dish = await Dish.findByPk(id);

      if (!dish) {
        return res.status(404).json({ error: "Món ăn không tồn tại" });
      }

      res.status(200).json(dish);
    } catch (error) {
      console.error("Lỗi khi lấy món ăn:", error);
      res.status(500).json({ error: "Lỗi khi lấy món ăn" });
    }
  }

  // Thêm món ăn mới
  async createDish(req, res) {
    try {
      const {
        name,
        description,
        instructions,
        image_url,
        cook_time_minutes,
        storage_id,
      } = req.body;

      const newDish = await Dish.create({
        name,
        description,
        instructions,
        image_url,
        cook_time_minutes,
        storage_id,
      });

      res.status(201).json(newDish);
    } catch (error) {
      console.error("Lỗi khi tạo món ăn:", error);
      res.status(500).json({ error: "Lỗi khi tạo món ăn" });
    }
  }

  // Cập nhật món ăn
  async updateDish(req, res) {
    try {
      const { id } = req.params;
      const {
        name,
        description,
        instructions,
        image_url,
        cook_time_minutes,
        storage_id,
      } = req.body;

      const dish = await Dish.findByPk(id);

      if (!dish) {
        return res.status(404).json({ error: "Món ăn không tồn tại" });
      }

      await dish.update({
        name,
        description,
        instructions,
        image_url,
        cook_time_minutes,
        storage_id,
      });

      res.status(200).json(dish);
    } catch (error) {
      console.error("Lỗi khi cập nhật món ăn:", error);
      res.status(500).json({ error: "Lỗi khi cập nhật món ăn" });
    }
  }

  // Xoá món ăn
  async deleteDish(req, res) {
    try {
      const { id } = req.params;
      const dish = await Dish.findByPk(id);

      if (!dish) {
        return res.status(404).json({ error: "Món ăn không tồn tại" });
      }

      await dish.destroy();
      res.status(200).json({ message: "Xóa món ăn thành công" });
    } catch (error) {
      console.error("Lỗi khi xoá món ăn:", error);
      res.status(500).json({ error: "Lỗi khi xóa món ăn" });
    }
  }
}

module.exports = new DishController();
