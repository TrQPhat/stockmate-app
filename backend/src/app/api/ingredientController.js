const { Ingredient } = require("../models");

class ProductController {
  // Lấy danh sách tất cả sản phẩm
  async getAllProducts(req, res) {
    try {
      const ingredients = await Ingredient.findAll();
      res.status(200).json(ingredients);
    } catch (error) {
      res.status(500).json({
        error: "Lỗi khi lấy danh sách sản phẩm",
        detail: error.message,
      });
    }
  }

  // Lấy thông tin sản phẩm theo id
  async getProductById(req, res) {
    try {
      const { id } = req.params;
      const ingredient = await Ingredient.findByPk(id);
      if (!ingredient) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }
      res.status(200).json(ingredient);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin sản phẩm" });
    }
  }

  // Tạo mới sản phẩm
  async createProduct(req, res) {
    try {
      const {
        id,
        storage_id,
        name,
        category_id,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        image_path,
      } = req.body;

      console.log("Creating product with data:", req.body);
      const newProduct = await Ingredient.create({
        id,
        storage_id,
        name,
        category_id,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        image_path,
      });

      res.status(201).json(newProduct);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Lỗi khi tạo sản phẩm", detail: error.message });
    }
  }

  // Cập nhật sản phẩm theo id
  async updateProduct(req, res) {
    try {
      const { id } = req.params;
      const ingredient = await Ingredient.findByPk(id);
      if (!ingredient) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }

      const {
        storage_id,
        name,
        category_id,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        image_path,
      } = req.body;

      ingredient.storage_id = storage_id ?? ingredient.storage_id;
      ingredient.name = name ?? ingredient.name;
      ingredient.category_id = category_id ?? ingredient.category_id;
      ingredient.quantity = quantity ?? ingredient.quantity;
      ingredient.unit = unit ?? ingredient.unit;
      ingredient.import_date = import_date ?? ingredient.import_date;
      ingredient.expire_date = expire_date ?? ingredient.expire_date;
      ingredient.note = note ?? ingredient.note;
      ingredient.status = status ?? ingredient.status;
      ingredient.image_path = image_path ?? ingredient.image_path;
      ingredient.updated_at = new Date();

      await ingredient.save();

      res.status(200).json(ingredient);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật sản phẩm" });
    }
  }

  // Xóa sản phẩm theo id
  async deleteProduct(req, res) {
    try {
      const { id } = req.params;
      const ingredient = await Ingredient.findByPk(id);
      if (!ingredient) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }

      await ingredient.destroy();

      res.status(200).json({ message: "Xóa sản phẩm thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa sản phẩm" });
    }
  }
}

module.exports = new ProductController();