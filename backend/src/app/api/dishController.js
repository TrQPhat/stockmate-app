const { Dish, Storage, Note, Favorite } = require("../models");

class DishController {
  // Lấy danh sách tất cả món ăn (kèm dữ liệu liên quan)
  async getAllDishes(req, res) {
    try {
      const dishes = await Dish.findAll({
        include: [
          { model: Storage, attributes: ["id", "name"] },
          { model: Note, attributes: ["id", "content", "quantity"] },
          { model: Favorite, attributes: ["id", "user_id"] },
        ],
      });
      res.status(200).json(dishes);
    } catch (error) {
      console.error("Lỗi khi lấy danh sách món ăn:", error);
      res.status(500).json({ error: "Lỗi khi lấy danh sách món ăn" });
    }
  }

  // Lấy chi tiết 1 món ăn theo ID
  async getDishById(req, res) {
    try {
      const { id } = req.params;
      const dish = await Dish.findByPk(id, {
        include: [
          { model: Storage, attributes: ["id", "name"] },
          { model: Note, attributes: ["id", "content", "quantity"] },
          { model: Favorite, attributes: ["id", "user_id"] },
        ],
      });

      if (!dish) {
        return res.status(404).json({ error: "Món ăn không tồn tại" });
      }

      res.status(200).json(dish);
    } catch (error) {
      console.error("Lỗi khi lấy món ăn:", error);
      res.status(500).json({ error: "Lỗi khi lấy thông tin món ăn" });
    }
  }

  // Tạo món ăn mới
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

      if (!name || !instructions || !storage_id) {
        return res.status(400).json({ error: "Thiếu thông tin bắt buộc" });
      }

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
      const dish = await Dish.findByPk(id);

      if (!dish) {
        return res.status(404).json({ error: "Món ăn không tồn tại" });
      }

      const {
        name,
        description,
        instructions,
        image_url,
        cook_time_minutes,
        storage_id,
      } = req.body;

      dish.name = name ?? dish.name;
      dish.description = description ?? dish.description;
      dish.instructions = instructions ?? dish.instructions;
      dish.image_url = image_url ?? dish.image_url;
      dish.cook_time_minutes = cook_time_minutes ?? dish.cook_time_minutes;
      dish.storage_id = storage_id ?? dish.storage_id;

      await dish.save();
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
