const { Dish, Storage, Note, Favorite } = require("../models");

class DishController {
  // Lấy tất cả món ăn
  async getAllDishes(req, res) {
    try {
      const { storage_id, user_id  } = req.params;

      const whereClause = {};
    if (storage_id) {
      whereClause.storage_id = storage_id;
    }

    // Lấy danh sách món ăn
    const dishes = await Dish.findAll({ where: whereClause });

    // Nếu có user_id, kiểm tra favorite
    let favoriteDishIds = [];
    if (user_id) {
      const favorites = await Favorite.findAll({
        where: { user_id },
        attributes: ['dish_id']
      });
      favoriteDishIds = favorites.map(fav => fav.dish_id);
    }

    // Gắn thêm trường is_favorited cho mỗi dish
    const result = dishes.map(dish => ({
      ...dish.toJSON(),
      is_favorited: favoriteDishIds.includes(dish.id)
    }));

    res.status(200).json(result);
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
        cook_time_minutes,
        storage_id,
      } = req.body;

      const image_path = req.file ? `${req.file.filename}` : null;

      const newDish = await Dish.create({
        name,
        description,
        instructions,
        image_url: image_path,
        cook_time_minutes,
        storage_id,
      });

      res.status(201).json(newDish);
    } catch (error) {
      console.log("Lỗi khi tạo món ăn:", error);
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

      // Nếu có file ảnh mới thì cập nhật, còn không thì giữ nguyên
      let newImageUrl = dish.image_url;
      if (req.file) {
        newImageUrl = `${req.file.filename}`;
      } else if (image_url !== undefined) {
        newImageUrl = image_url;
      }

      await dish.update({
        name,
        description,
        instructions,
        image_url: newImageUrl,
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

  async  toggleFavoriteDish(req, res) {
  try {
    const { user_id, dish_id } = req.body;

    if (!user_id || !dish_id) {
      return res.status(400).json({ error: "user_id và dish_id là bắt buộc" });
    }

    // Kiểm tra xem đã tồn tại Favorite chưa
    const existing = await Favorite.findOne({
      where: { user_id, dish_id },
    });

    if (existing) {
      // Nếu đã tồn tại, xoá (tức là toggle thành false)
      await existing.destroy();
      return res.status(200).json({ is_favorited: false });
    } else {
      // Nếu chưa tồn tại, tạo mới (tức là toggle thành true)
      await Favorite.create({ user_id, dish_id });
      return res.status(200).json({ is_favorited: true });
    }
  } catch (error) {
    console.error("Lỗi khi toggle yêu thích món ăn:", error);
    res.status(500).json({ error: "Đã xảy ra lỗi" });
  }
}
}

module.exports = new DishController();
